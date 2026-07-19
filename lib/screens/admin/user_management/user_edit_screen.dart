import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../widgets/loading_indicator.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa người dùng')),
      body: FutureBuilder<UserModel?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _EditSkeleton();
          }
          if (!snapshot.hasData) return const _UserNotFound();
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
}

class _EditSkeleton extends StatelessWidget {
  const _EditSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: List.generate(
        5,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.md),
          child: LoadingIndicator.skeleton(width: double.infinity, height: 72),
        ),
      ),
    );
  }
}

class _UserNotFound extends StatelessWidget {
  const _UserNotFound();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Không tìm thấy người dùng này.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
