import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/constants.dart';

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
    // Determine active chip
    final isAll = roleFilter == null && statusFilter == null;
    final isResident = roleFilter == UserRole.resident && statusFilter == null;
    final isStaff = roleFilter == UserRole.staff && statusFilter == null;
    final isInactive =
        statusFilter == UserStatus.inactive && roleFilter == null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 16, AppSpacing.md, 12),
      child: Column(
        children: [
          // Search Input Container
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bằng tên hoặc căn hộ',
                hintStyle: const TextStyle(
                  color: Color(0x9945474C),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF75777D),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.tune_rounded,
                    color: Color(0xFF75777D),
                  ),
                  onPressed: () {
                    // Quick clear as fallback
                    searchController.clear();
                    onSearchChanged('');
                    onRoleChanged(null);
                    onStatusChanged(null);
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Horizontal chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Tất cả',
                  isActive: isAll,
                  onTap: () {
                    onRoleChanged(null);
                    onStatusChanged(null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cư dân',
                  isActive: isResident,
                  onTap: () {
                    onRoleChanged(UserRole.resident);
                    onStatusChanged(null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Nhân viên',
                  isActive: isStaff,
                  onTap: () {
                    onRoleChanged(UserRole.staff);
                    onStatusChanged(null);
                  },
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Vô hiệu hóa',
                  isActive: isInactive,
                  onTap: () {
                    onRoleChanged(null);
                    onStatusChanged(UserStatus.inactive);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF091426) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: isActive ? const Color(0xFF091426) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF45474C),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
