// App-wide constants, enums, and route name definitions.
//
// All route paths are defined here as a single source of truth.
// No magic strings should appear elsewhere in the codebase.

// ---------------------------------------------------------------------------
// Route paths
// ---------------------------------------------------------------------------

/// Named route path constants for GoRouter.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String adminHome = '/admin/home';
  static const String staffHome = '/staff/home';
  static const String residentHome = '/resident/home';

  // Sprint 1 — Authentication
  static const String changePassword = '/change-password';

  // Sprint 2 — User Management (Admin)
  static const String userList = '/admin/users';
  static const String userCreate = '/admin/users/create';
  static const String userEdit = '/admin/users/:id/edit';
}

// ---------------------------------------------------------------------------
// Enumerations
// ---------------------------------------------------------------------------

/// Roles that a user can hold in the system.
enum UserRole {
  admin,
  staff,
  resident;

  /// Parses a raw Firestore string value into a [UserRole].
  ///
  /// Returns [UserRole.resident] as a safe default for unknown values.
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.resident,
    );
  }
}

/// Lifecycle states for the authentication flow.
enum AuthStatus {
  /// Initial state before any auth check has run.
  initial,

  /// Actively waiting for Firebase to respond.
  loading,

  /// User is logged in and their Firestore profile has been loaded.
  authenticated,

  /// User is not logged in (or has logged out).
  unauthenticated,

  /// An error occurred during authentication.
  error,
}

// ---------------------------------------------------------------------------
// Firestore collection names
// ---------------------------------------------------------------------------

/// Firestore collection name constants.
class AppCollections {
  AppCollections._();

  static const String users = 'users';
  static const String apartments = 'apartments';
  static const String requests = 'requests';
  static const String bills = 'bills';
  static const String notifications = 'notifications';
  static const String visitors = 'visitors';
  static const String complaints = 'complaints';
}
