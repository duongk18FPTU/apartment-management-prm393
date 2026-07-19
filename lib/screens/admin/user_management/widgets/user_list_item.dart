import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import 'user_role_label.dart';
import 'user_status_badge.dart';

/// A tappable user summary with role, apartment and account state.
class UserListItem extends StatelessWidget {
  const UserListItem({super.key, required this.user, required this.onTap});

  final UserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = user.displayName.trim();
    return Card(
      child: InkWell(
        borderRadius: AppRadius.borderMd,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Text(
                  displayName.isEmpty
                      ? '?'
                      : displayName.substring(0, 1).toUpperCase(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        UserRoleLabel(role: user.role),
                        if (user.apartmentId != null)
                          Text(
                            'Căn hộ ${user.apartmentId}',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        UserStatusBadge(status: user.status),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
