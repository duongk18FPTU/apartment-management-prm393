import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/models/user_model.dart';
import 'package:prm393_project/providers/user_provider.dart';
import 'package:prm393_project/screens/admin/user_management/user_edit_screen.dart';
import 'package:prm393_project/services/user_service.dart';
import 'package:prm393_project/utils/constants.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows a retryable error instead of user-not-found', (
    tester,
  ) async {
    final provider = UserProvider(userService: FailingUserRepository());
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: UserEditScreen(userId: 'user-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Không thể tải hồ sơ'), findsOneWidget);
    expect(find.text('Thử lại'), findsOneWidget);
    expect(find.text('Không tìm thấy người dùng này.'), findsNothing);
  });
}

class FailingUserRepository implements UserRepository {
  @override
  Stream<List<UserModel>> watchUsers() => const Stream.empty();

  @override
  Future<UserModel?> getUser(String userId) async {
    throw const UserServiceException('Không thể tải hồ sơ');
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
  }) => throw UnimplementedError();

  @override
  Future<void> updateUser(UserModel user) => throw UnimplementedError();

  @override
  Future<void> updateStatus({
    required String userId,
    required UserStatus status,
  }) => throw UnimplementedError();
}
