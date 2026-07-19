import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Login screen stub — will be fully implemented by Member 1 in Sprint 1.
///
/// Displays a minimal placeholder so GoRouter can navigate here without
/// crashing. Sprint 1 implementation will include:
/// - Email/Password form with validation
/// - Firebase Auth integration via AuthService
/// - Forgot password flow
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary,
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 36,
                    color: DesignTokens.onPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Modern Haven',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Login screen — Sprint 1',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.neutralVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
