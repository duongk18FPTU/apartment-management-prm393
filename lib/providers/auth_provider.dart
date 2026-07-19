import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../utils/constants.dart';

/// Lightweight user profile fetched from Firestore `users` collection.
///
/// TODO(member1): Replace this entire class with the real `UserModel` from
/// Member 2 (lib/models/user_model.dart) once Sprint 0 models are merged.
/// Steps:
/// 1. `import '../models/user_model.dart';`
/// 2. Replace `UserProfile` → `UserModel` everywhere in this file.
/// 3. Delete this class.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
  });

  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String? avatarUrl;

  factory UserProfile.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserProfile(
      uid: uid,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: UserRole.fromString(data['role'] as String? ?? ''),
      avatarUrl: data['avatarUrl'] as String?,
    );
  }
}

/// Manages the authentication lifecycle for the entire app.
///
/// Sprint 0 scope:
/// - Listens to Firebase Auth state changes via [listenToAuthState].
/// - Fetches the user's role from Firestore on sign-in.
/// - Exposes [status], [currentUser], and [userProfile] for GoRouter redirect.
///
/// Sprint 1 will add: [login], [logout], [changePassword] methods.
class AuthProvider extends ChangeNotifier {
  AuthProvider({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  UserProfile? _userProfile;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Current authentication lifecycle status.
  AuthStatus get status => _status;

  /// The raw Firebase Auth [User] object, or null when unauthenticated.
  User? get currentUser => _currentUser;

  /// Firestore-sourced profile including the user's [UserRole].
  UserProfile? get userProfile => _userProfile;

  /// Convenience shorthand: true when the user is fully authenticated.
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// The role of the currently authenticated user, or null.
  UserRole? get role => _userProfile?.role;

  /// The last error message, populated when [status] is [AuthStatus.error].
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Starts listening to Firebase Auth state changes.
  ///
  /// Call this once from the app's initialisation path (e.g. inside [main]
  /// after [Firebase.initializeApp]).  GoRouter's redirect will re-evaluate
  /// every time [notifyListeners] is called.
  void listenToAuthState() {
    _setStatus(AuthStatus.loading);

    _authSubscription?.cancel();
    _authSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
      onError: (Object error) {
        _errorMessage = error.toString();
        _setStatus(AuthStatus.error);
      },
    );
  }

  /// Releases the Firebase Auth subscription.
  ///
  /// Called automatically by [ChangeNotifier.dispose].
  // TODO(member1): Sprint 1 — add login(), logout(), changePassword() methods.
  // Depends on: AuthService (Member 3, Sprint 0).
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
      _userProfile = null;
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    _currentUser = user;
    _setStatus(AuthStatus.loading);

    try {
      final doc = await _firestore
          .collection(AppCollections.users)
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        _userProfile = UserProfile.fromFirestore(doc.data()!, user.uid);
        _setStatus(AuthStatus.authenticated);
      } else {
        // Auth record exists but no Firestore profile yet (edge case).
        debugPrint(
          '[AuthProvider] Firestore profile missing for uid=${user.uid}',
        );
        _userProfile = null;
        _setStatus(AuthStatus.unauthenticated);
      }
    } on FirebaseException catch (e) {
      debugPrint('[AuthProvider] Firestore error: ${e.code} — ${e.message}');
      _errorMessage = e.message;
      _setStatus(AuthStatus.error);
    }
  }

  void _setStatus(AuthStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }
}
