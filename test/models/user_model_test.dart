import 'package:flutter_test/flutter_test.dart';

import 'package:prm393_project/models/user_model.dart';

void main() {
  test('parses resident role, nullable apartment and inactive status', () {
    final user = UserModel.fromJson({
      'email': 'resident@example.com',
      'fullName': 'Resident Example',
      'phone': '0900000000',
      'role': 'resident',
      'apartmentId': null,
      'nationalId': '001',
      'status': 'inactive',
    }, id: 'resident-001');

    expect(user.id, 'resident-001');
    expect(user.role, UserRole.resident);
    expect(user.apartmentId, isNull);
    expect(user.status, UserStatus.inactive);
  });
}
