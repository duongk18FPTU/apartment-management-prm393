import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/custom_text_field.dart';
import 'user_filter_dropdowns.dart';

/// Search and compact role/status filters for the user list.
class UserFilterBar extends StatelessWidget {
  const UserFilterBar({
    super.key,
    required this.searchController,
    required this.roleFilter,
    required this.statusFilter,
    required this.onSearchChanged,
    required this.onRoleChanged,
    required this.onStatusChanged,
  });

  final TextEditingController searchController;
  final UserRole? roleFilter;
  final UserStatus? statusFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UserRole?> onRoleChanged;
  final ValueChanged<UserStatus?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Tìm người dùng',
            hint: 'Tên, email hoặc căn hộ',
            controller: searchController,
            prefixIcon: Icons.search_rounded,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Bộ lọc', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              UserRoleFilter(value: roleFilter, onChanged: onRoleChanged),
              UserStatusFilter(value: statusFilter, onChanged: onStatusChanged),
            ],
          ),
        ],
      ),
    );
  }
}
