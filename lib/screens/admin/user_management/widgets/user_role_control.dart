import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../utils/constants.dart';

class UserRoleControl extends StatelessWidget {
  const UserRoleControl({
    super.key,
    required this.role,
    required this.isCurrentUser,
    required this.onChanged,
  });

  final UserRole role;
  final bool isCurrentUser;
  final ValueChanged<UserRole?> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vai trò', style: textTheme.labelLarge),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<UserRole>(
          initialValue: role,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.shield_outlined),
          ),
          items: UserRole.values
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(_roleLabel(item)),
                ),
              )
              .toList(),
          onChanged: isCurrentUser ? null : onChanged,
        ),
        if (isCurrentUser) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Không thể thay đổi vai trò của tài khoản đang đăng nhập.',
            style: textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  String _roleLabel(UserRole value) => switch (value) {
    UserRole.admin => 'Quản trị viên',
    UserRole.staff => 'Nhân viên',
    UserRole.resident => 'Cư dân',
  };
}
