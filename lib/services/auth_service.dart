import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Authentication operations.
///
/// All UI components call this service — never call [FirebaseAuth] directly
/// from screens or providers. This keeps auth logic testable and swappable.
///
/// Error handling: [FirebaseAuthException] codes are translated to
/// user-friendly Vietnamese messages via [_mapError].
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// The currently signed-in Firebase user, or null.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes — consumed by [AuthProvider].
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Auth operations
  // ---------------------------------------------------------------------------

  /// Signs in with [email] and [password].
  ///
  /// Throws a [AuthException] with a user-friendly message on failure.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] login error: ${e.code}');
      throw AuthException(_mapError(e.code));
    }
  }

  /// Signs out the current user.
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] logout error: ${e.code}');
      throw AuthException(_mapError(e.code));
    }
  }

  /// Changes the password for the currently signed-in user.
  ///
  /// Requires [currentPassword] to re-authenticate before updating.
  /// This is required by Firebase security for sensitive operations.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthException('Bạn chưa đăng nhập');
    }

    try {
      // Re-authenticate to satisfy Firebase security requirement
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] changePassword error: ${e.code}');
      throw AuthException(_mapError(e.code));
    }
  }

  // ---------------------------------------------------------------------------
  // Error mapping
  // ---------------------------------------------------------------------------

  /// Maps Firebase error codes to user-friendly Vietnamese messages.
  static String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Tài khoản không tồn tại';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hoá';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng đợi vài phút rồi thử lại';
      case 'network-request-failed':
        return 'Không có kết nối mạng. Vui lòng kiểm tra internet';
      case 'weak-password':
        return 'Mật khẩu mới quá yếu';
      case 'requires-recent-login':
        return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại';
    }
  }
}

// ---------------------------------------------------------------------------
// AuthException
// ---------------------------------------------------------------------------

/// Typed exception thrown by [AuthService] with a user-facing message.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => 'AuthException: $message';
}
