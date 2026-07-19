import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../services/user_service.dart';
import '../../../../utils/constants.dart';
import 'user_access_fields.dart';
import 'user_form_controller.dart';
import 'user_form_feedback.dart';
import 'user_identity_fields.dart';

class UserFormContent extends StatelessWidget {
  const UserFormContent({
    super.key,
    required this.controller,
    required this.apartments,
    required this.isEditing,
    required this.isCurrentUser,
    required this.isSaving,
    required this.submitLabel,
    required this.errorMessage,
    required this.onRoleChanged,
    required this.onApartmentChanged,
    required this.onStatusChanged,
    required this.onSubmit,
  });

  final UserFormController controller;
  final List<ApartmentOption> apartments;
  final bool isEditing;
  final bool isCurrentUser;
  final bool isSaving;
  final String submitLabel;
  final String? errorMessage;
  final ValueChanged<UserRole?> onRoleChanged;
  final ValueChanged<String?> onApartmentChanged;
  final ValueChanged<UserStatus> onStatusChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (!isEditing) ...[
          const SizedBox(height: 16),
          Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFD8E3FB),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x0D1E293B),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  color: Color(0xFF091426),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Điền thông tin bên dưới để cấp quyền truy cập hệ thống cho người dùng mới.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF45474C), fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
        UserIdentityFields(
          fullNameController: controller.fullName,
          emailController: controller.email,
          phoneController: controller.phone,
          nationalIdController: controller.nationalId,
          isEmailReadOnly: isEditing,
        ),
        const SizedBox(height: AppSpacing.lg),
        UserAccessFields(
          role: controller.role,
          apartmentId: controller.apartmentId,
          status: controller.status,
          apartments: apartments,
          onRoleChanged: onRoleChanged,
          onApartmentChanged: onApartmentChanged,
          onStatusChanged: onStatusChanged,
          showStatus: isEditing,
          isCurrentUser: isCurrentUser,
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          UserFormError(message: errorMessage!),
        ],
        const SizedBox(height: AppSpacing.xl),
        UserFormSubmitButton(
          label: submitLabel,
          isSaving: isSaving,
          onPressed: onSubmit,
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
