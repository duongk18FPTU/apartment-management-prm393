import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import 'widgets/user_edit_states.dart';
import 'widgets/user_form.dart';

/// Admin screen for updating a user profile, role, apartment and status.
class UserEditScreen extends StatefulWidget {
  const UserEditScreen({super.key, required this.userId});

  final String userId;

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = context.read<UserProvider>().loadUser(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa người dùng')),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const UserEditSkeleton();
          }
          if (!snapshot.hasData && provider.errorMessage != null) {
            return UserEditErrorState(
              message: provider.errorMessage!,
              onRetry: _retry,
            );
          }
          if (!snapshot.hasData) return const UserNotFoundState();
          return UserForm(
            initialUser: snapshot.data,
            currentUserId: context.read<AuthProvider>().currentUser?.uid,
            submitLabel: 'Lưu thay đổi',
            onSubmit: (values) => _updateUser(snapshot.data!, values),
          );
        },
      ),
    );
  }

  Future<bool> _updateUser(UserModel user, UserFormValues values) {
    return context.read<UserProvider>().updateUser(
      user.copyWith(
        fullName: values.fullName.trim(),
        phone: values.phone.trim(),
        nationalId: values.nationalId.trim(),
        role: values.role,
        apartmentId: values.apartmentId,
        clearApartmentId: values.apartmentId == null,
        status: values.status,
      ),
    );
  }

  void _retry() {
    setState(() {
      _userFuture = context.read<UserProvider>().loadUser(widget.userId);
    });
  }
}
