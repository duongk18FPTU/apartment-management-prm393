import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

/// Manages the authentication lifecycle for the entire app.
///
/// Provides auth state ([status], [currentUser], [userModel]) to the
/// widget tree via [ChangeNotifier]. GoRouter uses [refreshListenable] to
/// re-evaluate redirects whenever [notifyListeners] is called.
///
/// Sprint 0 → Sprint 1 upgrades:
/// - [UserProfile] replaced by real [UserModel] (Member 2 model).
/// - [login], [logout], [changePassword] implemented via [AuthService].
/// - Separate [isLoading] flag for button loading state (distinct from
///   [AuthStatus.loading] which is for initial auth check).
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService, FirebaseFirestore? firestore})
    : _authService = authService ?? AuthService(),
      _firestore = firestore ?? FirebaseFirestore.instance;

  final AuthService _authService;
  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  UserModel? _userModel;
  String? _errorMessage;
  bool _isLoading = false;
  StreamSubscription<User?>? _authSubscription;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Current authentication lifecycle status.
  AuthStatus get status => _status;

  /// The raw Firebase Auth [User] object, or null when unauthenticated.
  User? get currentUser => _currentUser;

  /// Firestore-sourced user model including role, phone, status etc.
  UserModel? get userModel => _userModel;

  /// True when the user is fully authenticated and profile is loaded.
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// The role of the current user, or null when unauthenticated.
  UserRole? get role => _userModel?.role;

  /// True during an explicit action (login / logout / changePassword).
  /// Distinct from [AuthStatus.loading] which reflects initial auth check.
  bool get isLoading => _isLoading;

  /// The most recent user-facing error message.
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Auth state listener
  // ---------------------------------------------------------------------------

  /// Starts listening to Firebase Auth state changes.
  ///
  /// Call once from [ApartmentApp] immediately after [Firebase.initializeApp].
  void listenToAuthState() {
    _setStatus(AuthStatus.loading);

    _authSubscription?.cancel();
    _authSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
      onError: (Object error) {
        _errorMessage = error.toString();
        _setStatus(AuthStatus.error);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Public auth actions
  // ---------------------------------------------------------------------------

  /// Signs in with [email] and [password].
  ///
  /// Sets [isLoading] during the request. On failure, sets [errorMessage]
  /// and returns false. On success, [listenToAuthState] auto-updates state.
  Future<bool> login({required String email, required String password}) async {
    _clearError();
    _setLoading(true);

    try {
      await _authService.login(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Signs out the current user and clears all local state.
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _userModel = null;
    } on AuthException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Changes the password for the currently signed-in user.
  ///
  /// Returns null on success, or a user-facing error message on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _clearError();
    _setLoading(true);

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message; // caller shows error
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _onAuthStateChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
      _userModel = null;
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    _currentUser = user;
    _setStatus(AuthStatus.loading);

    try {
      final doc = await _firestore
          .collection(AppCollections.users)
          .doc(user.uid)
          .withConverter<UserModel>(
            fromFirestore: (snap, _) => UserModel.fromFirestore(snap),
            toFirestore: (model, _) => model.toMap(),
          )
          .get();

      if (doc.exists && doc.data() != null) {
        _userModel = doc.data();
        if (_userModel!.isActive) {
          _setStatus(AuthStatus.authenticated);
        } else {
          _errorMessage = 'Tài khoản đã bị vô hiệu hóa';
          _currentUser = null;
          _userModel = null;
          _setStatus(AuthStatus.unauthenticated);
          await _authService.logout();
        }
      } else {
        debugPrint(
          '[AuthProvider] Firestore profile missing for uid=${user.uid}',
        );
        _userModel = null;
        _setStatus(AuthStatus.unauthenticated);
      }
    } on FirebaseException catch (e) {
      debugPrint('[AuthProvider] Firestore error: ${e.code} — ${e.message}');
      if (e.code == 'permission-denied') {
        _errorMessage =
            'Tài khoản đã bị vô hiệu hóa hoặc không có quyền truy cập';
        _currentUser = null;
        _userModel = null;
        _setStatus(AuthStatus.unauthenticated);
        await _authService.logout();
      } else {
        _errorMessage = e.message;
        _setStatus(AuthStatus.error);
      }
    }
  }

  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
