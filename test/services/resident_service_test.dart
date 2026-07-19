import 'package:flutter_test/flutter_test.dart';

import 'package:prm393_project/models/user_model.dart';
import 'package:prm393_project/services/resident_service.dart';

void main() {
  test('builds a resident document with the resident role', () {
    final data = ResidentService.toDocumentData(
      const UserModel(
        id: 'resident-001',
        email: 'resident@example.com',
        fullName: 'Resident Example',
        phone: '0900000000',
        role: UserRole.admin,
        nationalId: '001',
        status: UserStatus.active,
      ),
      now: DateTime(2026, 7, 19),
    );

    expect(data['role'], 'resident');
    expect(data['status'], 'active');
    expect(data['fullName'], 'Resident Example');
    expect(data['createdAt'], isNotNull);
  });
}
