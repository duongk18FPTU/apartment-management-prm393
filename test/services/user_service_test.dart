import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/user_model.dart';
import 'package:prm393_project/services/user_service.dart';
import 'package:prm393_project/utils/constants.dart';

void main() {
  group('FirebaseUserAccountProvisioner', () {
    test('uses the secondary session and exposes account lifecycle', () async {
      final session = FakeProvisioningSession();
      final provisioner = FirebaseUserAccountProvisioner(
        sessionFactory: () async => session,
      );

      final account = await provisioner.createAccount(
        email: 'resident@example.com',
        password: 'Temporary!Aa1',
        displayName: 'Resident One',
      );
      await account.delete();
      await account.dispose();

      expect(account.uid, 'firebase-user');
      expect(session.createdEmail, 'resident@example.com');
      expect(session.createdPassword, 'Temporary!Aa1');
      expect(session.identity.displayName, 'Resident One');
      expect(session.identity.deleted, isTrue);
      expect(session.disposed, isTrue);
    });

    test('rolls back and disposes when display name update fails', () async {
      final session = FakeProvisioningSession();
      session.identity.updateFails = true;
      final provisioner = FirebaseUserAccountProvisioner(
        sessionFactory: () async => session,
      );

      await expectLater(
        () => provisioner.createAccount(
          email: 'resident@example.com',
          password: 'Temporary!Aa1',
          displayName: 'Resident One',
        ),
        throwsA(isA<StateError>()),
      );

      expect(session.identity.deleted, isTrue);
      expect(session.disposed, isTrue);
    });

    test('reports manual cleanup when provisioning rollback fails', () async {
      final session = FakeProvisioningSession();
      session.identity.updateFails = true;
      session.identity.deleteFails = true;
      final provisioner = FirebaseUserAccountProvisioner(
        sessionFactory: () async => session,
      );

      await expectLater(
        () => provisioner.createAccount(
          email: 'resident@example.com',
          password: 'Temporary!Aa1',
          displayName: 'Resident One',
        ),
        throwsA(
          isA<UserServiceException>().having(
            (error) => error.message,
            'message',
            contains('Firebase Authentication'),
          ),
        ),
      );
      expect(session.disposed, isTrue);
    });
  });

  group('UserService.createUser', () {
    late FakeAccountProvisioner provisioner;

    setUp(() {
      provisioner = FakeAccountProvisioner();
    });

    test('creates profile, sends invitation, and disposes account', () async {
      Map<String, Object?>? profile;
      var invitedEmail = '';
      final service = UserService(
        accountProvisioner: provisioner,
        profileCreator:
            ({
              required uid,
              required email,
              required fullName,
              required phone,
              required nationalId,
              required role,
              required apartmentId,
            }) async {
              profile = {
                'uid': uid,
                'email': email,
                'fullName': fullName,
                'role': role,
              };
            },
        invitationSender: (email) async {
          invitedEmail = email;
          return true;
        },
      );

      final result = await service.createUser(
        fullName: '  Nguyen Minh Anh  ',
        email: '  Resident@Example.com ',
        phone: '0901234567',
        nationalId: '079123456789',
        role: UserRole.resident,
      );

      expect(result.uid, 'new-user');
      expect(result.invitationSent, isTrue);
      expect(profile?['email'], 'resident@example.com');
      expect(profile?['fullName'], 'Nguyen Minh Anh');
      expect(invitedEmail, 'resident@example.com');
      expect(provisioner.disposed, isTrue);
      expect(
        provisioner.password,
        matches(RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*!).{24}$')),
      );
    });

    test('deletes Auth account when profile creation fails', () async {
      final service = UserService(
        accountProvisioner: provisioner,
        profileCreator:
            ({
              required uid,
              required email,
              required fullName,
              required phone,
              required nationalId,
              required role,
              required apartmentId,
            }) async => throw StateError('profile failed'),
        invitationSender: (_) async => true,
      );

      await expectLater(
        () => _createResident(service),
        throwsA(isA<StateError>()),
      );
      expect(provisioner.deleted, isTrue);
      expect(provisioner.disposed, isTrue);
    });

    test('surfaces manual cleanup guidance when rollback fails', () async {
      provisioner.deleteFails = true;
      final service = UserService(
        accountProvisioner: provisioner,
        profileCreator:
            ({
              required uid,
              required email,
              required fullName,
              required phone,
              required nationalId,
              required role,
              required apartmentId,
            }) async => throw StateError('profile failed'),
        invitationSender: (_) async => true,
      );

      await expectLater(
        () => _createResident(service),
        throwsA(
          isA<UserServiceException>().having(
            (error) => error.message,
            'message',
            contains('Firebase Authentication'),
          ),
        ),
      );
      expect(provisioner.disposed, isTrue);
    });

    test('reports invitation failure without deleting created user', () async {
      final service = UserService(
        accountProvisioner: provisioner,
        profileCreator:
            ({
              required uid,
              required email,
              required fullName,
              required phone,
              required nationalId,
              required role,
              required apartmentId,
            }) async {},
        invitationSender: (_) async => false,
      );

      final result = await _createResident(service);

      expect(result.invitationSent, isFalse);
      expect(provisioner.deleted, isFalse);
      expect(provisioner.disposed, isTrue);
    });
  });

  test('unknown user status fails closed as inactive', () {
    expect(UserStatus.fromString('unknown'), UserStatus.inactive);
    expect(UserStatus.fromString(''), UserStatus.inactive);
    expect(
      UserModel.fromMap(const {}, 'missing-status').status,
      UserStatus.inactive,
    );
  });
}

Future<UserCreationResult> _createResident(UserService service) {
  return service.createUser(
    fullName: 'Resident One',
    email: 'resident@example.com',
    phone: '0901234567',
    nationalId: '079123456789',
    role: UserRole.resident,
  );
}

class FakeAccountProvisioner implements UserAccountProvisioner {
  bool deleted = false;
  bool disposed = false;
  bool deleteFails = false;
  String password = '';

  @override
  Future<ProvisionedUserAccount> createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    this.password = password;
    return ProvisionedUserAccount(
      uid: 'new-user',
      delete: () async {
        if (deleteFails) throw StateError('rollback failed');
        deleted = true;
      },
      dispose: () async => disposed = true,
    );
  }
}

class FakeProvisioningSession implements UserProvisioningSession {
  final identity = FakeProvisioningIdentity();
  String createdEmail = '';
  String createdPassword = '';
  bool disposed = false;

  @override
  Future<UserProvisioningIdentity> createUser({
    required String email,
    required String password,
  }) async {
    createdEmail = email;
    createdPassword = password;
    return identity;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

class FakeProvisioningIdentity implements UserProvisioningIdentity {
  bool deleted = false;
  bool deleteFails = false;
  bool updateFails = false;
  String displayName = '';

  @override
  String get uid => 'firebase-user';

  @override
  Future<void> delete() async {
    if (deleteFails) throw StateError('delete failed');
    deleted = true;
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    if (updateFails) throw StateError('update failed');
    this.displayName = displayName;
  }
}
