import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/user_model.dart';
import 'package:prm393_project/providers/user_provider.dart';
import 'package:prm393_project/services/user_service.dart';
import 'package:prm393_project/utils/constants.dart';

void main() {
  late FakeUserRepository repository;
  late UserProvider provider;

  setUp(() {
    repository = FakeUserRepository();
    provider = UserProvider(userService: repository);
  });

  tearDown(() async {
    provider.dispose();
    await repository.dispose();
  });

  test('filters users by search, role, and status', () async {
    provider.listenToUsers();
    repository.usersController.add([
      _user(uid: '1', name: 'Nguyễn Minh Anh', role: UserRole.resident),
      _user(
        uid: '2',
        name: 'Trần Bảo Long',
        role: UserRole.staff,
        status: UserStatus.inactive,
      ),
    ]);
    await Future<void>.delayed(Duration.zero);

    provider.setSearchQuery('bao');
    provider.setRoleFilter(UserRole.staff);
    provider.setStatusFilter(UserStatus.inactive);

    expect(provider.filteredUsers, hasLength(1));
    expect(provider.filteredUsers.single.uid, '2');
  });

  test('reports when account is created but invitation email fails', () async {
    repository.creationResult = const UserCreationResult(
      uid: 'new-user',
      email: 'resident@example.com',
      invitationSent: false,
    );

    final succeeded = await provider.createUser(
      fullName: 'Resident One',
      email: 'resident@example.com',
      phone: '0901234567',
      nationalId: '079123456789',
      role: UserRole.resident,
    );

    expect(succeeded, isTrue);
    expect(provider.consumeSuccessMessage(), contains('chưa gửi được email'));
  });

  test('prevents self-disable before calling the repository', () async {
    final succeeded = await provider.updateStatus(
      userId: 'admin-1',
      status: UserStatus.inactive,
      currentUserId: 'admin-1',
    );

    expect(succeeded, isFalse);
    expect(repository.statusUpdateCalls, 0);
  });

  test('refresh waits until the replacement stream emits', () async {
    provider.listenToUsers();
    repository.usersController.add([
      _user(uid: '1', name: 'Initial User', role: UserRole.resident),
    ]);
    await Future<void>.delayed(Duration.zero);

    var completed = false;
    final refresh = provider.refreshUsers()..then((_) => completed = true);
    final duplicateRefresh = provider.refreshUsers();
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);

    repository.usersController.add([
      _user(uid: '2', name: 'Refreshed User', role: UserRole.staff),
    ]);
    await Future.wait([refresh, duplicateRefresh]);

    expect(completed, isTrue);
    expect(provider.users.single.uid, '2');
  });

  test('loadUser exposes repository errors for the edit error state', () async {
    repository.getUserError = const UserServiceException('Load failed');

    final user = await provider.loadUser('missing-user');

    expect(user, isNull);
    expect(provider.errorMessage, 'Load failed');
  });
}

UserModel _user({
  required String uid,
  required String name,
  required UserRole role,
  UserStatus status = UserStatus.active,
}) {
  final now = DateTime(2026);
  return UserModel(
    uid: uid,
    email: '$uid@example.com',
    fullName: name,
    phone: '0901234567',
    role: role,
    nationalId: '079123456789',
    status: status,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeUserRepository implements UserRepository {
  final usersController = StreamController<List<UserModel>>.broadcast();
  UserCreationResult creationResult = const UserCreationResult(
    uid: 'new-user',
    email: 'new@example.com',
    invitationSent: true,
  );
  int statusUpdateCalls = 0;
  UserServiceException? getUserError;

  @override
  Stream<List<UserModel>> watchUsers() => usersController.stream;

  @override
  Future<UserModel?> getUser(String userId) async {
    if (getUserError case final error?) throw error;
    return null;
  }

  @override
  Future<List<ApartmentOption>> getApartmentOptions() async => const [];

  @override
  Future<UserCreationResult> createUser({
    required String fullName,
    required String email,
    required String phone,
    required String nationalId,
    required UserRole role,
    String? apartmentId,
  }) async => creationResult;

  @override
  Future<void> updateUser(UserModel user) async {}

  @override
  Future<void> updateStatus({
    required String userId,
    required UserStatus status,
  }) async {
    statusUpdateCalls++;
  }

  Future<void> dispose() => usersController.close();
}
