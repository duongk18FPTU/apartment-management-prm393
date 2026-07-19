import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../../utils/constants.dart';

/// Role, apartment and status controls shared by user create and edit forms.
class UserAccessFields extends StatelessWidget {
  const UserAccessFields({
    super.key,
    required this.role,
    required this.apartmentId,
    required this.status,
    required this.apartments,
    required this.onRoleChanged,
    required this.onApartmentChanged,
    required this.onStatusChanged,
    required this.showStatus,
    required this.isCurrentUser,
  });

  final UserRole role;
  final String? apartmentId;
  final UserStatus status;
  final List<ApartmentOption> apartments;
  final ValueChanged<UserRole?> onRoleChanged;
  final ValueChanged<String?> onApartmentChanged;
  final ValueChanged<UserStatus> onStatusChanged;
  final bool showStatus;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final options = List<ApartmentOption>.of(apartments);
    if (apartmentId != null &&
        !options.any((option) => option.id == apartmentId)) {
      options.add(ApartmentOption(id: apartmentId!, number: apartmentId!));
    }

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
          onChanged: isCurrentUser ? null : onRoleChanged,
        ),
        if (isCurrentUser) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Không thể thay đổi vai trò của tài khoản đang đăng nhập.',
            style: textTheme.bodySmall,
          ),
        ],
        if (role == UserRole.resident) ...[
          const SizedBox(height: AppSpacing.md),
          Text('Căn hộ', style: textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          DropdownButtonFormField<String>(
            initialValue: apartmentId,
            isExpanded: true,
            decoration: const InputDecoration(
              hintText: 'Chọn căn hộ (không bắt buộc)',
              prefixIcon: Icon(Icons.apartment_outlined),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('Chưa gán căn hộ'),
              ),
              ...options.map(
                (option) => DropdownMenuItem(
                  value: option.id,
                  child: Text('Căn hộ ${option.number}'),
                ),
              ),
            ],
            onChanged: onApartmentChanged,
          ),
        ],
        if (showStatus) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
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
                  : (isActive) => onStatusChanged(
                      isActive ? UserStatus.active : UserStatus.inactive,
                    ),
            ),
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
