import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_indicator.dart';

/// Login screen — entry point for all roles.
///
/// Design: DESIGN.md Modern Haven — left-aligned layout (non-centered hero,
/// per high-end-visual-design taste skill). Slate primary branding top,
/// white card form section below.
///
/// Flow:
/// 1. User fills email + password.
/// 2. Taps "Đăng nhập" → [AuthProvider.login].
/// 3. On success: GoRouter [redirect] navigates to role-based home.
/// 4. On failure: inline error banner shown below the form card.
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
      duration: const Duration(milliseconds: 500),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
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
    // Clear previous error
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // On success GoRouter redirect handles navigation automatically.
    // On failure the error message is in auth.errorMessage — UI reacts via
    // context.watch in build().
    if (!success && mounted) {
      // Shake the form card to signal error (scroll to top)
      // Error banner is shown inline below via Consumer.
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: DesignTokens.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.height),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Branding header ─────────────────────────────────────
                  _BrandingHeader(fadeAnimation: _fadeAnimation),

                  // ── Form card ────────────────────────────────────────────
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _FormCard(
                          formKey: _formKey,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          emailFocus: _emailFocus,
                          passwordFocus: _passwordFocus,
                          onSubmit: _submit,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets (each under 100 lines — per AGENTS.md rule)
// ---------------------------------------------------------------------------

class _BrandingHeader extends StatelessWidget {
  const _BrandingHeader({required this.fadeAnimation});
  final Animation<double> fadeAnimation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Row(
          children: [
            // Logo mark
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: DesignTokens.secondary,
                borderRadius: AppRadius.borderSm,
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: DesignTokens.onSecondary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modern Haven',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: DesignTokens.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Hệ thống quản lý tòa nhà',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: DesignTokens.onPrimary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DesignTokens.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Đăng nhập',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Nhập thông tin tài khoản của bạn',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DesignTokens.neutralVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Error banner
            _ErrorBanner(),
            const SizedBox(height: AppSpacing.md),

            // Email field
            CustomTextField(
              label: 'Email',
              hint: 'example@apartment.com',
              controller: emailController,
              validator: AppValidators.validateEmail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              focusNode: emailFocus,
              prefixIcon: Icons.email_outlined,
              onFieldSubmitted: (_) => passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Password field
            CustomTextField(
              label: 'Mật khẩu',
              hint: '••••••••',
              controller: passwordController,
              validator: AppValidators.validateLoginPassword,
              isPassword: true,
              textInputAction: TextInputAction.done,
              focusNode: passwordFocus,
              prefixIcon: Icons.lock_outline_rounded,
              onFieldSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit button
            _SubmitButton(onSubmit: onSubmit),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
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

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return ElevatedButton(
          onPressed: auth.isLoading ? null : onSubmit,
          child: auth.isLoading
              ? const LoadingIndicator.circular(size: 22)
              : const Text('Đăng nhập'),
        );
      },
    );
  }
}
