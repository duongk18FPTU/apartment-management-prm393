import 'package:flutter/material.dart';

import '../../../../utils/validators.dart';
import '../../../../widgets/custom_text_field.dart';

/// The identity fields shared by the create and edit user forms.
class UserIdentityFields extends StatelessWidget {
  const UserIdentityFields({
    super.key,
    required this.fullNameController,
    required this.emailController,
    required this.phoneController,
    required this.nationalIdController,
    required this.isEmailReadOnly,
  });

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nationalIdController;
  final bool isEmailReadOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: 'Họ và tên',
          hint: 'Ví dụ: Nguyễn Minh Anh',
          controller: fullNameController,
          validator: (value) =>
              AppValidators.validateRequired(value, fieldName: 'Họ và tên'),
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Email',
          hint: 'name@apartment.com',
          controller: emailController,
          validator: AppValidators.validateEmail,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
          readOnly: isEmailReadOnly,
          textInputAction: TextInputAction.next,
          helperText: isEmailReadOnly
              ? 'Email được quản lý bởi Firebase Auth'
              : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Số điện thoại',
          hint: '0901234567',
          controller: phoneController,
          validator: AppValidators.validatePhone,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Số CCCD',
          hint: 'Nhập số giấy tờ tùy thân',
          controller: nationalIdController,
          validator: (value) =>
              AppValidators.validateRequired(value, fieldName: 'Số CCCD'),
          keyboardType: TextInputType.number,
          prefixIcon: Icons.badge_outlined,
          textInputAction: TextInputAction.next,
        ),
      ],
    );
  }
}
