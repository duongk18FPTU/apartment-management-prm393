import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/custom_text_field.dart';

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
              _RoleFilter(value: roleFilter, onChanged: onRoleChanged),
              _StatusFilter(value: statusFilter, onChanged: onStatusChanged),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleFilter extends StatelessWidget {
  const _RoleFilter({required this.value, required this.onChanged});

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

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.value, required this.onChanged});

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
