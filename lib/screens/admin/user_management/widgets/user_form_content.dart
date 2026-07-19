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
