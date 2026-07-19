import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/constants.dart';

class UserRoleFilter extends StatelessWidget {
  const UserRoleFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserRole? value;
  final ValueChanged<UserRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<UserRole?>(
      value: value,
      underline: const SizedBox.shrink(),
      borderRadius: AppRadius.borderMd,
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(value: null, child: Text('Tất cả vai trò')),
        DropdownMenuItem(value: UserRole.admin, child: Text('Quản trị viên')),
        DropdownMenuItem(value: UserRole.staff, child: Text('Nhân viên')),
        DropdownMenuItem(value: UserRole.resident, child: Text('Cư dân')),
      ],
    );
  }
}

class UserStatusFilter extends StatelessWidget {
  const UserStatusFilter({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final UserStatus? value;
  final ValueChanged<UserStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<UserStatus?>(
      value: value,
      underline: const SizedBox.shrink(),
      borderRadius: AppRadius.borderMd,
      onChanged: onChanged,
      items: const [
        DropdownMenuItem(value: null, child: Text('Tất cả trạng thái')),
        DropdownMenuItem(value: UserStatus.active, child: Text('Hoạt động')),
        DropdownMenuItem(
          value: UserStatus.inactive,
          child: Text('Đã vô hiệu hóa'),
        ),
      ],
    );
  }
}
