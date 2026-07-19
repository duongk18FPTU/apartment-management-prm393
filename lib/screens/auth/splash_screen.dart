import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

/// Animated splash screen shown while the app determines auth state.
///
/// Design references — DESIGN.md (Modern Haven):
/// - Background: [DesignTokens.primary] (#1E293B) — deep slate
/// - Logo text: Be Vietnam Pro 700, white
/// - Accent shimmer: [DesignTokens.secondary] (#D97706) amber
/// - Animation: fade-in + subtle scale-up (hardware-accelerated via
///   [AnimatedOpacity] / [AnimatedScale])
///
/// Navigation logic:
/// - [AuthStatus.authenticated] → role-based home screen
/// - [AuthStatus.unauthenticated] / [AuthStatus.error] → login
/// - [AuthStatus.loading] → stays on splash
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _taglineController;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineOpacity;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Logo: fade-in + scale 0.85 → 1.0 over 800ms
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOut,
    );
    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Tagline: delayed fade-in
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineOpacity = CurvedAnimation(
      parent: _taglineController,
      curve: Curves.easeIn,
    );

    // Start logo animation, then tagline after 300ms delay
    _logoController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _taglineController.forward();
      });
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkNavigation();
  }

  void _checkNavigation() {
    if (_hasNavigated) return;

    final auth = context.watch<AuthProvider>();

    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        // Still waiting — stay on splash
        break;

      case AuthStatus.authenticated:
        _navigate(auth.role);

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        _navigateTo(AppRoutes.login);
    }
  }

  void _navigate(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        _navigateTo(AppRoutes.adminHome);
      case UserRole.staff:
        _navigateTo(AppRoutes.staffHome);
      case UserRole.resident:
      case null:
        _navigateTo(AppRoutes.residentHome);
    }
  }

  void _navigateTo(String path) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    // Small delay so the animation completes before navigating
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) context.go(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes for navigation
    context.watch<AuthProvider>();
    _checkNavigation();

    return Scaffold(
      backgroundColor: DesignTokens.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ---- Logo mark ----
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(scale: _logoScale, child: _LogoMark()),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ---- App name ----
              FadeTransition(
                opacity: _logoOpacity,
                child: Text(
                  'Modern Haven',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: DesignTokens.onPrimary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // ---- Tagline ----
              FadeTransition(
                opacity: _taglineOpacity,
                child: Text(
                  'Quản lý chung cư',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DesignTokens.onPrimary.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl * 2),

              // ---- Amber accent loading indicator ----
              FadeTransition(opacity: _taglineOpacity, child: _AmberLoader()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Geometric logo mark — stylised building silhouette using pure shapes.
class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: DesignTokens.secondary,
        borderRadius: AppRadius.borderMd,
      ),
      child: Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 44,
          color: DesignTokens.onSecondary,
        ),
      ),
    );
  }
}

/// Minimal animated loading indicator using the amber accent color.
class _AmberLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 3,
      child: LinearProgressIndicator(
        backgroundColor: DesignTokens.onPrimary.withValues(alpha: 0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(DesignTokens.secondary),
        borderRadius: AppRadius.borderSm,
      ),
    );
  }
}
