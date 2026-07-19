import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/theme.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/user_provider.dart';
import '../../../../utils/constants.dart';
import 'user_access_fields.dart';
import 'user_identity_fields.dart';

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
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nationalIdController;
  late UserRole _role;
  late UserStatus _status;
  String? _apartmentId;

  bool get _isEditing => widget.initialUser != null;
  bool get _isCurrentUser => widget.initialUser?.uid == widget.currentUserId;

  @override
  void initState() {
    super.initState();
    final user = widget.initialUser;
    _fullNameController = TextEditingController(text: user?.fullName);
    _emailController = TextEditingController(text: user?.email);
    _phoneController = TextEditingController(text: user?.phone);
    _nationalIdController = TextEditingController(text: user?.nationalId);
    _role = user?.role ?? UserRole.resident;
    _status = user?.status ?? UserStatus.active;
    _apartmentId = user?.apartmentId;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<UserProvider>().loadApartments(),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          UserIdentityFields(
            fullNameController: _fullNameController,
            emailController: _emailController,
            phoneController: _phoneController,
            nationalIdController: _nationalIdController,
            isEmailReadOnly: _isEditing,
          ),
          const SizedBox(height: AppSpacing.lg),
          UserAccessFields(
            role: _role,
            apartmentId: _apartmentId,
            status: _status,
            apartments: provider.apartments,
            onRoleChanged: (role) => setState(() {
              _role = role ?? _role;
              if (_role != UserRole.resident) _apartmentId = null;
            }),
            onApartmentChanged: (apartmentId) =>
                setState(() => _apartmentId = apartmentId),
            onStatusChanged: (status) => setState(() => _status = status),
            showStatus: _isEditing,
            isCurrentUser: _isCurrentUser,
          ),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            _FormError(message: provider.errorMessage!),
          ],
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: provider.isSaving ? null : _submit,
            child: provider.isSaving
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(widget.submitLabel),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _confirmDeactivation()) return;
    if (!mounted) return;

    final succeeded = await widget.onSubmit(
      UserFormValues(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        nationalId: _nationalIdController.text,
        role: _role,
        apartmentId: _role == UserRole.resident ? _apartmentId : null,
        status: _status,
      ),
    );
    if (!mounted || !succeeded) return;

    final successMessage = context.read<UserProvider>().consumeSuccessMessage();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          successMessage ??
              (_isEditing ? 'Đã cập nhật người dùng' : 'Đã tạo người dùng'),
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<bool> _confirmDeactivation() async {
    final wasActive = widget.initialUser?.status == UserStatus.active;
    if (!_isEditing || !wasActive || _status != UserStatus.inactive) {
      return true;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vô hiệu hóa tài khoản?'),
        content: const Text(
          'Người dùng sẽ không thể truy cập ứng dụng cho đến khi được kích hoạt lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Vô hiệu hóa'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

/// Immutable values emitted only after all input fields are valid.
class UserFormValues {
  const UserFormValues({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.role,
    required this.apartmentId,
    required this.status,
  });

  final String fullName;
  final String email;
  final String phone;
  final String nationalId;
  final UserRole role;
  final String? apartmentId;
  final UserStatus status;
}

class _FormError extends StatelessWidget {
  const _FormError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: AppRadius.borderMd,
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onErrorContainer),
      ),
    );
  }
}
