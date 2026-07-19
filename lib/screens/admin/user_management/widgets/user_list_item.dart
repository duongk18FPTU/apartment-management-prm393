import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../utils/constants.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({super.key, required this.user, required this.onTap});

  final UserModel user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayName = user.fullName.trim();
    final firstLetter = displayName.isEmpty
        ? '?'
        : displayName.substring(0, 1).toUpperCase();
    final isActive = user.status == UserStatus.active;

    // Badge styling based on role
    Color badgeBgColor;
    Color badgeTextColor;
    String roleLabelText;
    IconData detailsIcon;
    String detailsLabel;

    switch (user.role) {
      case UserRole.admin:
        badgeBgColor = const Color(0x1F1E293B);
        badgeTextColor = const Color(0xFF1E293B);
        roleLabelText = 'Admin';
        detailsIcon = Icons.shield_rounded;
        detailsLabel = 'Quản trị viên';
        break;
      case UserRole.staff:
        badgeBgColor = const Color(0x1F24A375);
        badgeTextColor = const Color(0xFF24A375);
        roleLabelText = 'Nhân viên';
        detailsIcon = Icons.engineering_rounded;
        detailsLabel = 'Kỹ thuật viên';
        break;
      case UserRole.resident:
        badgeBgColor = const Color(0x1FFE932C);
        badgeTextColor = const Color(0xFFFE932C);
        roleLabelText = 'Cư dân';
        detailsIcon = Icons.apartment_rounded;
        detailsLabel = user.apartmentId != null
            ? 'Căn hộ ${user.apartmentId}'
            : 'Chưa gán phòng';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0x3375777D)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D1E293B),
              offset: Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar stack with active status dot
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  backgroundColor: const Color(0xFFD8E3FB),
                  foregroundColor: const Color(0xFF111C2D),
                  child: user.avatarUrl == null
                      ? Text(
                          firstLetter,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF24A375)
                          : const Color(0xFF75777D),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      color: Color(0xFF091426),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          roleLabelText,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Details Label
                      Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                detailsIcon,
                                size: 14,
                                color: const Color(0xFF75777D),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  detailsLabel,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF75777D),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Color(0x66091426)),
          ],
        ),
      ),
    );
  }
}
