import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../../utils/constants.dart';
import 'user_apartment_control.dart';
import 'user_role_control.dart';
import 'user_status_control.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserRoleControl(
          role: role,
          isCurrentUser: isCurrentUser,
          onChanged: onRoleChanged,
        ),
        if (role == UserRole.resident) ...[
          const SizedBox(height: AppSpacing.md),
          UserApartmentControl(
            apartmentId: apartmentId,
            apartments: apartments,
            onChanged: onApartmentChanged,
          ),
        ],
        if (showStatus) ...[
          const SizedBox(height: AppSpacing.md),
          UserStatusControl(
            status: status,
            isCurrentUser: isCurrentUser,
            onChanged: onStatusChanged,
          ),
        ],
      ],
    );
  }
}
