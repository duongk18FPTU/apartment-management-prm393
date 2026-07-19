import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/user_model.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utils/constants.dart';
import 'user_form_content.dart';
import 'user_form_controller.dart';
import 'user_form_submission.dart';
import 'user_form_values.dart';

export 'user_form_values.dart';

/// Reusable validated form for creating and editing a user profile.
class UserForm extends StatefulWidget {
  const UserForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initialUser,
    this.currentUserId,
  });

  final String submitLabel;
  final UserModel? initialUser;
  final String? currentUserId;
  final Future<bool> Function(UserFormValues values) onSubmit;

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late final UserFormController _controller;

  bool get _isEditing => widget.initialUser != null;
  bool get _isCurrentUser => widget.initialUser?.uid == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    _controller = UserFormController.fromUser(widget.initialUser);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UserProvider>().loadApartments(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    return Form(
      key: _formKey,
      child: UserFormContent(
        controller: _controller,
        apartments: provider.apartments,
        isEditing: _isEditing,
        isCurrentUser: _isCurrentUser,
        isSaving: provider.isSaving,
        submitLabel: widget.submitLabel,
        errorMessage: provider.errorMessage,
        onRoleChanged: _changeRole,
        onApartmentChanged: (value) => setState(() {
          _controller.apartmentId = value;
        }),
        onStatusChanged: (value) => setState(() {
          _controller.status = value;
        }),
        onSubmit: _submit,
      ),
    );
  }

  void _changeRole(UserRole? value) {
    setState(() {
      _controller.role = value ?? _controller.role;
      if (_controller.role != UserRole.resident) {
        _controller.apartmentId = null;
      }
    });
  }

  Future<void> _submit() async {
    final succeeded = await submitUserForm(
      context: context,
      formKey: _formKey,
      initialUser: widget.initialUser,
      values: _controller.values,
      onSubmit: widget.onSubmit,
    );
    if (!mounted || !succeeded) return;
    showUserFormSuccess(
      context: context,
      message: context.read<UserProvider>().consumeSuccessMessage(),
      isEditing: _isEditing,
    );
  }
}
