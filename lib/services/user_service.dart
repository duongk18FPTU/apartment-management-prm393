import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

/// Provides Firestore operations for the admin-only user management module.
///
/// Account creation uses a secondary Firebase app so the Admin session remains
/// signed in while the project stays compatible with Firebase's Spark plan.
abstract interface class UserRepository {
  Stream<List<UserModel>> watchUsers();
  Future<UserModel?> getUser(String userId);
  Future<UserCreationResult> createUser({
    required String fullName,
    required String email,
    required String phone,
    required String nationalId,
    required UserRole role,
    String? apartmentId,
  });
  Future<void> updateUser(UserModel user);
  Future<void> updateStatus({
    required String userId,
    required UserStatus status,
  });
  Future<List<ApartmentOption>> getApartmentOptions();
}

class UserService implements UserRepository {
  UserService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<UserModel> get _users => _firestore
      .collection(AppCollections.users)
      .withConverter<UserModel>(
        fromFirestore: (snapshot, _) => UserModel.fromFirestore(snapshot),
        toFirestore: (user, _) => user.toMap(),
      );

  /// Watches all user profiles ordered by name for the management list.
  @override
  Stream<List<UserModel>> watchUsers() {
    return _users
        .orderBy('fullName')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((document) => document.data()).toList(),
        );
  }

  /// Gets a single user profile by its Firestore document ID.
  @override
  Future<UserModel?> getUser(String userId) async {
    try {
      return (await _users.doc(userId).get()).data();
    } on FirebaseException catch (exception) {
      throw UserServiceException.fromFirebase(exception);
    }
  }

  /// Creates an Auth account without replacing the current Admin session.
  @override
  Future<UserCreationResult> createUser({
    required String fullName,
    required String email,
    required String phone,
    required String nationalId,
    required UserRole role,
    String? apartmentId,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    FirebaseApp? secondaryApp;
    User? createdUser;
    var profileCreated = false;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'userProvisioning${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: _temporaryPassword(),
      );
      createdUser = credential.user;
      if (createdUser == null) {
        throw const UserServiceException('Không thể tạo tài khoản người dùng');
      }

      await createdUser.updateDisplayName(fullName.trim());
      await _firestore
          .collection(AppCollections.users)
          .doc(createdUser.uid)
          .set({
            'email': normalizedEmail,
            'fullName': fullName.trim(),
            'phone': phone.trim(),
            'role': role.name,
            'apartmentId': apartmentId,
            'nationalId': nationalId.trim(),
            'dateOfBirth': null,
            'avatarUrl': null,
            'status': UserStatus.active.name,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      profileCreated = true;

      await secondaryAuth.signOut();
      var invitationSent = true;
      try {
        await _auth.sendPasswordResetEmail(email: normalizedEmail);
      } on FirebaseAuthException {
        invitationSent = false;
      }
      return UserCreationResult(
        uid: createdUser.uid,
        email: normalizedEmail,
        invitationSent: invitationSent,
      );
    } on FirebaseAuthException catch (exception) {
      throw UserServiceException.fromAuth(exception);
    } on FirebaseException catch (exception) {
      throw UserServiceException.fromFirebase(exception);
    } finally {
      if (createdUser != null && !profileCreated) {
        await createdUser.delete().catchError((_) {});
      }
      await secondaryApp?.delete();
    }
  }

  /// Updates the Firestore profile using Admin-only Security Rules.
  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(AppCollections.users).doc(user.uid).update({
        'fullName': user.fullName.trim(),
        'phone': user.phone.trim(),
        'nationalId': user.nationalId.trim(),
        'role': user.role.name,
        'apartmentId': user.apartmentId,
        'status': user.status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (exception) {
      throw UserServiceException.fromFirebase(exception);
    }
  }

  /// Locks app data access by changing the Firestore profile status.
  @override
  Future<void> updateStatus({
    required String userId,
    required UserStatus status,
  }) async {
    try {
      await _firestore.collection(AppCollections.users).doc(userId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (exception) {
      throw UserServiceException.fromFirebase(exception);
    }
  }

  String _temporaryPassword() {
    const characters =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
    final random = Random.secure();
    final randomPart = List.generate(
      20,
      (_) => characters[random.nextInt(characters.length)],
    ).join();
    return '$randomPart!Aa1';
  }

  /// Loads available apartments without depending on Member 2's model layer.
  @override
  Future<List<ApartmentOption>> getApartmentOptions() async {
    try {
      final snapshot = await _firestore
          .collection(AppCollections.apartments)
          .orderBy('number')
          .get();
      return snapshot.docs
          .map(
            (document) => ApartmentOption(
              id: document.id,
              number: document.data()['number'] as String? ?? document.id,
            ),
          )
          .toList();
    } on FirebaseException catch (exception) {
      throw UserServiceException.fromFirebase(exception);
    }
  }
}

/// A compact option used by the user form's apartment selector.
class ApartmentOption {
  const ApartmentOption({required this.id, required this.number});

  final String id;
  final String number;
}

/// Result of provisioning a managed account and sending its invitation email.
class UserCreationResult {
  const UserCreationResult({
    required this.uid,
    required this.email,
    required this.invitationSent,
  });

  final String uid;
  final String email;
  final bool invitationSent;
}

/// A user-facing error for failures in the user management data layer.
class UserServiceException implements Exception {
  const UserServiceException(this.message);

  factory UserServiceException.fromFirebase(FirebaseException exception) {
    return UserServiceException(switch (exception.code) {
      'permission-denied' => 'Bạn không có quyền thực hiện thao tác này',
      'not-found' => 'Không tìm thấy người dùng',
      'unavailable' => 'Không thể kết nối máy chủ. Vui lòng thử lại',
      _ => 'Không thể cập nhật dữ liệu người dùng. Vui lòng thử lại',
    });
  }

  factory UserServiceException.fromAuth(FirebaseAuthException exception) {
    return UserServiceException(switch (exception.code) {
      'email-already-in-use' => 'Email này đã được sử dụng',
      'invalid-email' => 'Email không hợp lệ',
      'operation-not-allowed' => 'Đăng nhập Email/Password chưa được bật',
      'too-many-requests' => 'Quá nhiều yêu cầu. Vui lòng thử lại sau',
      'network-request-failed' =>
        'Không có kết nối mạng. Vui lòng kiểm tra và thử lại',
      _ => 'Không thể tạo tài khoản. Vui lòng thử lại',
    });
  }

  final String message;

  @override
  String toString() => message;
}
