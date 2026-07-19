import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

/// Change Password screen — accessible to all authenticated roles.
///
/// Requires the current password for re-authentication (Firebase security
/// requirement). On success shows a SnackBar and pops back to the caller.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _inlineError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _inlineError = null);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final error = await auth.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() => _inlineError = error);
      return;
    }

    // Success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đổi mật khẩu thành công'),
        backgroundColor: DesignTokens.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.borderSm),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      appBar: AppBar(title: const Text('Đổi mật khẩu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.sm),

                // Instructions card
                _InstructionCard(),
                const SizedBox(height: AppSpacing.lg),

                // Inline error
                if (_inlineError != null) ...[
                  _ErrorBanner(message: _inlineError!),
                  const SizedBox(height: AppSpacing.md),
                ],

                // Current password
                CustomTextField(
                  label: 'Mật khẩu hiện tại',
                  hint: '••••••••',
                  controller: _currentPasswordController,
                  validator: AppValidators.validateLoginPassword,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock_outline_rounded,
                ),
                const SizedBox(height: AppSpacing.md),

                // New password
                CustomTextField(
                  label: 'Mật khẩu mới',
                  hint: '••••••••',
                  controller: _newPasswordController,
                  validator: AppValidators.validatePassword,
                  isPassword: true,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.lock_reset_rounded,
                  helperText: 'Ít nhất 8 ký tự, có chữ hoa, thường và số',
                ),
                const SizedBox(height: AppSpacing.md),

                // Confirm password
                CustomTextField(
                  label: 'Xác nhận mật khẩu mới',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  validator: (value) => AppValidators.validateConfirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.check_circle_outline_rounded,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const LoadingIndicator.circular(size: 22)
                        : const Text('Đổi mật khẩu'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Cancel
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Huỷ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: DesignTokens.secondary.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(
          color: DesignTokens.secondary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: DesignTokens.secondary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Nhập mật khẩu hiện tại để xác minh danh tính trước khi đặt mật khẩu mới.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: DesignTokens.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: DesignTokens.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: DesignTokens.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: DesignTokens.error,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: DesignTokens.error),
            ),
          ),
        ],
      ),
    );
  }
}
