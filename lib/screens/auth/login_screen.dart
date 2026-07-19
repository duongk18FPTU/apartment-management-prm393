import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

/// Login screen — entry point for all roles.
///
/// Designed to perfectly match the Google Stitch AI visual layout:
/// - Light neutral background (#F8FAFC)
/// - Left-aligned premium title and subtitle (Be Vietnam Pro font)
/// - Inputs styled with 12px rounded borders and white background
/// - Primary slate button (#1E293B)
/// - Bento-lite footer with preview image and Luxe Residence card
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      const _BrandingHeader(),
                      const SizedBox(height: 48),

                      const _ErrorBanner(),
                      const SizedBox(height: 16),

                      _LoginInputField(
                        label: 'Email',
                        hint: 'your@email.com',
                        controller: _emailController,
                        validator: AppValidators.validateEmail,
                        focusNode: _emailFocus,
                        nextFocusNode: _passwordFocus,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),

                      _LoginInputField(
                        label: 'Password',
                        hint: '••••••••',
                        controller: _passwordController,
                        validator: AppValidators.validateLoginPassword,
                        focusNode: _passwordFocus,
                        isPassword: true,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 32),

                      _SubmitButton(onSubmit: _submit),
                      const SizedBox(height: 24),

                      const _ForgotPasswordButton(),
                      const SizedBox(height: 48),

                      const _FooterSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets (Under 100 lines - per AGENTS.md rule)
// ---------------------------------------------------------------------------

class _BrandingHeader extends StatelessWidget {
  const _BrandingHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modern Haven',
          style: textTheme.headlineLarge?.copyWith(
            color: DesignTokens.primary,
            fontWeight: FontWeight.w700,
            fontSize: 36,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Sign in to manage your apartment',
          style: textTheme.titleMedium?.copyWith(
            color: DesignTokens.neutralVariant,
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _LoginInputField extends StatefulWidget {
  const _LoginInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
    required this.focusNode,
    this.nextFocusNode,
    this.isPassword = false,
    this.onFieldSubmitted,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final bool isPassword;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;

  @override
  State<_LoginInputField> createState() => _LoginInputFieldState();
}

class _LoginInputFieldState extends State<_LoginInputField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DesignTokens.onBackground,
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: widget.validator,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.nextFocusNode != null
              ? TextInputAction.next
              : TextInputAction.done,
          onFieldSubmitted: (val) {
            if (widget.onFieldSubmitted != null) {
              widget.onFieldSubmitted!(val);
            } else if (widget.nextFocusNode != null) {
              widget.nextFocusNode!.requestFocus();
            }
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: DesignTokens.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: DesignTokens.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: DesignTokens.error, width: 2),
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
          style: const TextStyle(
            fontSize: 16,
            color: DesignTokens.onBackground,
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: auth.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Đăng Nhập',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        );
      },
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  const _ForgotPasswordButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quên mật khẩu'),
            content: const Text(
              'Vui lòng liên hệ Ban quản trị qua hotline để được cấp lại mật khẩu.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      },
      child: const Text(
        'Quên mật khẩu?',
        style: TextStyle(
          color: DesignTokens.neutralVariant,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final error = auth.errorMessage;
        if (error == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: DesignTokens.error.withValues(alpha: 0.08),
            borderRadius: AppRadius.borderSm,
            border: Border.all(
              color: DesignTokens.error.withValues(alpha: 0.3),
            ),
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
                  error,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: DesignTokens.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCFsAhAPgw57DUvmn1S8SkpSO8kZxcQ8qu35VbRdTBWbCndUVyebp3HVWreBInm_lBFocX5ST_fcqPnPkE4T0BscyyGzGyCMwqEWJCdt8jMnIqiCZuK_RjrVNtzKf7_7sNVrHGRFvb42v6YY7Km8NyrQkKptIwevp1N-QPfYaeR8so5P7jJAmS4nzIeTIXjrON5vqOqXA3Aed2MHZaJRF_FWpbZMAaUzEhWbpjy4q8hrrqENGjgD-UX',
                  height: 128,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.white,
                    height: 128,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.white,
                    height: 128,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: DesignTokens.neutralVariant,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 128,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      color: DesignTokens.primary,
                      size: 28,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'LUXE RESIDENCE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.neutralVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ver 2.4.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: DesignTokens.neutralVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Text(
          '© 2026 Smart Apartment Manager. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: DesignTokens.neutralVariant.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
