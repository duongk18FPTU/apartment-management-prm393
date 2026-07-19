import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import 'widgets/user_form.dart';

/// Admin screen for provisioning an Auth account and Firestore user profile.
class UserCreateScreen extends StatelessWidget {
  const UserCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo người dùng')),
      body: UserForm(
        submitLabel: 'Tạo người dùng',
        onSubmit: (values) => context.read<UserProvider>().createUser(
          fullName: values.fullName,
          email: values.email,
          phone: values.phone,
          nationalId: values.nationalId,
          role: values.role,
          apartmentId: values.apartmentId,
        ),
      ),
    );
  }
}
