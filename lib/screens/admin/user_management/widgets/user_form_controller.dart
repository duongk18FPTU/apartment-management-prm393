import 'package:flutter/material.dart';

import '../../../../models/user_model.dart';
import '../../../../utils/constants.dart';
import 'user_form_values.dart';

/// Owns the editable values and text controllers used by [UserForm].
class UserFormController {
  UserFormController.fromUser(UserModel? user)
    : fullName = TextEditingController(text: user?.fullName),
      email = TextEditingController(text: user?.email),
      phone = TextEditingController(text: user?.phone),
      nationalId = TextEditingController(text: user?.nationalId),
      role = user?.role ?? UserRole.resident,
      status = user?.status ?? UserStatus.active,
      apartmentId = user?.apartmentId;

  final TextEditingController fullName;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController nationalId;
  UserRole role;
  UserStatus status;
  String? apartmentId;

  UserFormValues get values => UserFormValues(
    fullName: fullName.text,
    email: email.text,
    phone: phone.text,
    nationalId: nationalId.text,
    role: role,
    apartmentId: role == UserRole.resident ? apartmentId : null,
    status: status,
  );

  void dispose() {
    fullName.dispose();
    email.dispose();
    phone.dispose();
    nationalId.dispose();
  }
}
