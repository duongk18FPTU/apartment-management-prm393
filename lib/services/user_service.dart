import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../utils/constants.dart';

typedef UserProfileCreator =
    Future<void> Function({
      required String uid,
      required String email,
      required String fullName,
      required String phone,
      required String nationalId,
      required UserRole role,
      required String? apartmentId,
    });

typedef InvitationSender = Future<bool> Function(String email);

abstract interface class UserAccountProvisioner {
  Future<ProvisionedUserAccount> createAccount({
    required String email,
    required String password,
    required String displayName,
  });
}

class ProvisionedUserAccount {
  const ProvisionedUserAccount({
    required this.uid,
    required this.delete,
    required this.dispose,
  });

  final String uid;
  final Future<void> Function() delete;
  final Future<void> Function() dispose;
}

abstract interface class UserProvisioningSession {
  Future<UserProvisioningIdentity> createUser({
    required String email,
    required String password,
  });
  Future<void> dispose();
}

abstract interface class UserProvisioningIdentity {
  String get uid;
  Future<void> updateDisplayName(String displayName);
  Future<void> delete();
}

typedef UserProvisioningSessionFactory =
    Future<UserProvisioningSession> Function();

class FirebaseUserAccountProvisioner implements UserAccountProvisioner {
  FirebaseUserAccountProvisioner({
    UserProvisioningSessionFactory? sessionFactory,
  }) : _sessionFactory = sessionFactory ?? _openFirebaseSession;

  final UserProvisioningSessionFactory _sessionFactory;

  @override
  Future<ProvisionedUserAccount> createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    UserProvisioningSession? session;
    UserProvisioningIdentity? user;

    try {
      session = await _sessionFactory();
      user = await session.createUser(email: email, password: password);
      await user.updateDisplayName(displayName);
      return ProvisionedUserAccount(
        uid: user.uid,
        delete: user.delete,
        dispose: session.dispose,
      );
    } catch (error, stackTrace) {
      var rollbackFailed = false;
      if (user != null) {
        try {
          await user.delete();
        } catch (_) {
          rollbackFailed = true;
        }
      }
      if (session != null) {
        try {
          await session.dispose();
        } catch (cleanupError) {
          debugPrint(
            '[UserService] Failed provisioning session cleanup: $cleanupError',
          );
        }
      }
      if (rollbackFailed) {
        throw const UserServiceException(
          'Không thể hoàn tác tài khoản Auth sau khi khởi tạo thất bại. '
          'Vui lòng xóa tài khoản này trong Firebase Authentication trước khi thử lại.',
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  static Future<UserProvisioningSession> _openFirebaseSession() async {
    final app = await Firebase.initializeApp(
      name: 'userProvisioning${DateTime.now().microsecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      return _FirebaseUserProvisioningSession(
        app: app,
        auth: FirebaseAuth.instanceFor(app: app),
      );
    } catch (error, stackTrace) {
      await app.delete();
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}

class _FirebaseUserProvisioningSession implements UserProvisioningSession {
  const _FirebaseUserProvisioningSession({
    required FirebaseApp app,
    required FirebaseAuth auth,
  }) : _app = app,
       _auth = auth;

  final FirebaseApp _app;
  final FirebaseAuth _auth;

  @override
  Future<UserProvisioningIdentity> createUser({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw const UserServiceException('Không thể tạo tài khoản người dùng');
    }
    return _FirebaseUserProvisioningIdentity(user);
  }

  @override
  Future<void> dispose() async {
    try {
      await _auth.signOut();
    } finally {
      await _app.delete();
    }
  }
}

class _FirebaseUserProvisioningIdentity implements UserProvisioningIdentity {
  const _FirebaseUserProvisioningIdentity(this._user);

  final User _user;

  @override
  String get uid => _user.uid;

  @override
  Future<void> delete() => _user.delete();

  @override
  Future<void> updateDisplayName(String displayName) {
    return _user.updateDisplayName(displayName);
  }
}

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
  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    UserAccountProvisioner? accountProvisioner,
    UserProfileCreator? profileCreator,
    InvitationSender? invitationSender,
  }) : _firestoreOverride = firestore,
       _authOverride = auth,
       _accountProvisioner =
           accountProvisioner ?? FirebaseUserAccountProvisioner(),
       _profileCreator = profileCreator,
       _invitationSender = invitationSender;

  final FirebaseFirestore? _firestoreOverride;
  final FirebaseAuth? _authOverride;
  final UserAccountProvisioner _accountProvisioner;
  final UserProfileCreator? _profileCreator;
  final InvitationSender? _invitationSender;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

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
    ProvisionedUserAccount? account;

    try {
      account = await _accountProvisioner.createAccount(
        email: normalizedEmail,
        password: _temporaryPassword(),
        displayName: fullName.trim(),
      );
      try {
        await (_profileCreator ?? _createProfile)(
          uid: account.uid,
          email: normalizedEmail,
          fullName: fullName.trim(),
          phone: phone.trim(),
          nationalId: nationalId.trim(),
          role: role,
          apartmentId: apartmentId,
        );
      } catch (profileError, stackTrace) {
        try {
          await account.delete();
        } catch (_) {
          throw const UserServiceException(
            'Không thể hoàn tác tài khoản Auth sau khi tạo hồ sơ thất bại. '
            'Vui lòng xóa tài khoản này trong Firebase Authentication trước khi thử lại.',
          );
        }
        Error.throwWithStackTrace(profileError, stackTrace);
      }

      final invitationSent = await (_invitationSender ?? _sendInvitation)(
        normalizedEmail,
      );
      return UserCreationResult(
        uid: account.uid,
        email: normalizedEmail,
        invitationSent: invitationSent,
      );
    } on FirebaseAuthException catch (exception) {
      throw UserServiceException.fromAuth(exception);
    } on FirebaseException catch (exception) {
      throw UserServiceException.fromFirebase(exception);
    } finally {
      if (account != null) {
        try {
          await account.dispose();
        } catch (error) {
          debugPrint(
            '[UserService] Secondary Firebase app cleanup failed: $error',
          );
        }
      }
    }
  }

  Future<void> _createProfile({
    required String uid,
    required String email,
    required String fullName,
    required String phone,
    required String nationalId,
    required UserRole role,
    required String? apartmentId,
  }) {
    return _firestore.collection(AppCollections.users).doc(uid).set({
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role.name,
      'apartmentId': apartmentId,
      'nationalId': nationalId,
      'dateOfBirth': null,
      'avatarUrl': null,
      'status': UserStatus.active.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> _sendInvitation(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException {
      return false;
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
