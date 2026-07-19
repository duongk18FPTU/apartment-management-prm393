import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/resident/home/resident_home_screen.dart';
import '../screens/staff/staff_home_screen.dart';
import '../utils/constants.dart';

/// Builds and returns the app-wide [GoRouter] instance.
///
/// Navigation strategy:
/// - [AppRoutes.splash] (`/`) is always the initial location.
/// - [SplashScreen] checks [AuthProvider.status] and navigates automatically.
/// - [_redirect] acts as a guard on every route to enforce auth state.
///
/// Adding new routes (Sprint 1+):
/// 1. Add the path constant to [AppRoutes] in constants.dart.
/// 2. Add a [GoRoute] entry in [_routes] below.
/// 3. If the route requires auth, the existing redirect logic handles it.
GoRouter buildAppRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: authProvider,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: _routes,
    errorBuilder: (context, state) => _RouterErrorScreen(error: state.error),
  );
}

// ---------------------------------------------------------------------------
// Redirect guard
// ---------------------------------------------------------------------------

/// Role-based redirect logic evaluated on every navigation event.
///
/// Rules:
/// - While auth is still loading → stay on splash (no redirect).
/// - On splash when authenticated → go to the correct home for the user's role.
/// - On a protected route when unauthenticated → go to login.
/// - On login when already authenticated → go home (prevent back-navigation).
String? _redirect(BuildContext context, GoRouterState state) {
  final auth = context.read<AuthProvider>();
  final location = state.matchedLocation;

  // Still initialising — let SplashScreen handle it
  if (auth.status == AuthStatus.initial || auth.status == AuthStatus.loading) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  final isAuthenticated = auth.isAuthenticated;
  final isOnSplash = location == AppRoutes.splash;
  final isOnLogin = location == AppRoutes.login;

  // --- Unauthenticated users ---
  if (!isAuthenticated) {
    // Allow access only to splash and login
    if (isOnSplash || isOnLogin) return null;
    return AppRoutes.login;
  }

  // --- Authenticated users ---
  // Prevent staying on splash or login after auth is resolved
  if (isOnSplash || isOnLogin) {
    return _homeForRole(auth.role);
  }

  // Prevent residents from accessing admin/staff routes
  if (auth.role == UserRole.resident && location.startsWith('/admin')) {
    return AppRoutes.residentHome;
  }
  if (auth.role == UserRole.resident && location.startsWith('/staff')) {
    return AppRoutes.residentHome;
  }

  // Prevent staff from accessing admin-only routes
  if (auth.role == UserRole.staff && location.startsWith('/admin')) {
    return AppRoutes.staffHome;
  }

  return null; // No redirect — allow navigation
}

/// Returns the home path for a given [UserRole].
String _homeForRole(UserRole? role) {
  switch (role) {
    case UserRole.admin:
      return AppRoutes.adminHome;
    case UserRole.staff:
      return AppRoutes.staffHome;
    case UserRole.resident:
    case null:
      return AppRoutes.residentHome;
  }
}

// ---------------------------------------------------------------------------
// Route definitions
// ---------------------------------------------------------------------------

final List<RouteBase> _routes = [
  // Splash / Entry
  GoRoute(
    path: AppRoutes.splash,
    name: 'splash',
    builder: (context, state) => const SplashScreen(),
  ),

  // Authentication
  GoRoute(
    path: AppRoutes.login,
    name: 'login',
    builder: (context, state) => const LoginScreen(),
  ),

  // Change password — accessible to all authenticated roles
  GoRoute(
    path: AppRoutes.changePassword,
    name: 'changePassword',
    builder: (context, state) => const ChangePasswordScreen(),
  ),

  // Admin routes
  GoRoute(
    path: AppRoutes.adminHome,
    name: 'adminHome',
    builder: (context, state) => const AdminHomeScreen(),
    // TODO(member1): Sprint 2 — add nested sub-routes for User Management.
    // e.g. routes: [ GoRoute(path: 'users', ...), GoRoute(path: 'users/create', ...) ]
  ),

  // Staff routes
  GoRoute(
    path: AppRoutes.staffHome,
    name: 'staffHome',
    builder: (context, state) => const StaffHomeScreen(),
  ),

  // Resident routes
  GoRoute(
    path: AppRoutes.residentHome,
    name: 'residentHome',
    builder: (context, state) => const ResidentHomeScreen(),
  ),
];

// ---------------------------------------------------------------------------
// Error screen
// ---------------------------------------------------------------------------

/// Shown when GoRouter cannot match a route.
class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64),
              const SizedBox(height: 16),
              Text(
                '404 — Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.splash),
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
