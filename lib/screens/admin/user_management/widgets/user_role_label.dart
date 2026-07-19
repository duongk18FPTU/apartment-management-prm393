import 'package:flutter/material.dart';

import '../../../../utils/constants.dart';

class UserRoleLabel extends StatelessWidget {
  const UserRoleLabel({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final label = switch (role) {
      UserRole.admin => 'Quản trị viên',
      UserRole.staff => 'Nhân viên',
      UserRole.resident => 'Cư dân',
    };
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
