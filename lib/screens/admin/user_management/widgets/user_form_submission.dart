import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import 'user_deactivation_dialog.dart';
import 'user_form_values.dart';

Future<bool> submitUserForm({
  required BuildContext context,
  required GlobalKey<FormState> formKey,
  required UserModel? initialUser,
  required UserFormValues values,
  required Future<bool> Function(UserFormValues values) onSubmit,
}) async {
  if (!formKey.currentState!.validate()) return false;
  final requiresConfirmation =
      initialUser?.status == UserStatus.active &&
      values.status == UserStatus.inactive;
  if (requiresConfirmation && !await confirmUserDeactivation(context)) {
    return false;
  }
  return onSubmit(values);
}

void showUserFormSuccess({
  required BuildContext context,
  required String? message,
  required bool isEditing,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message ?? (isEditing ? 'Đã cập nhật người dùng' : 'Đã tạo người dùng'),
      ),
    ),
  );
  Navigator.of(context).pop();
}
