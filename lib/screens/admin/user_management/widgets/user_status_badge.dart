import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';

/// Compact, semantic status badge for a user row.
class UserStatusBadge extends StatelessWidget {
  const UserStatusBadge({super.key, required this.status});

  final UserStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isActive = status == UserStatus.active;
    final background = isActive
        ? colorScheme.tertiaryContainer
        : colorScheme.errorContainer;
    final foreground = isActive
        ? colorScheme.onTertiaryContainer
        : colorScheme.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Đã vô hiệu hóa',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: foreground),
      ),
    );
  }
}
