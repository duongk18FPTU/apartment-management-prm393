import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';

class UserStatusControl extends StatelessWidget {
  const UserStatusControl({
    super.key,
    required this.status,
    required this.isCurrentUser,
    required this.onChanged,
  });

  final UserStatus status;
  final bool isCurrentUser;
  final ValueChanged<UserStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.borderMd,
      ),
      child: SwitchListTile.adaptive(
        value: status == UserStatus.active,
        title: Text('Tài khoản hoạt động', style: textTheme.titleMedium),
        subtitle: Text(
          isCurrentUser
              ? 'Không thể tự vô hiệu hóa tài khoản đang đăng nhập.'
              : 'Tắt để ngăn người dùng truy cập ứng dụng.',
          style: textTheme.bodySmall,
        ),
        onChanged: isCurrentUser
            ? null
            : (isActive) =>
                  onChanged(isActive ? UserStatus.active : UserStatus.inactive),
      ),
    );
  }
}
