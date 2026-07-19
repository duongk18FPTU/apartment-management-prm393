// Form validation utility functions.
//
// All validators follow the signature expected by Flutter's [FormField.validator]:
// - Return null   → field is valid
// - Return String → error message to display

/// Collection of static validators for form fields.
abstract final class AppValidators {
  // ---------------------------------------------------------------------------
  // Email
  // ---------------------------------------------------------------------------

  /// Validates an email address field.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Password
  // ---------------------------------------------------------------------------

  /// Validates a password field.
  ///
  /// Rules: min 8 chars, at least 1 uppercase, 1 lowercase, 1 digit.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ hoa';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ thường';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Mật khẩu phải có ít nhất 1 chữ số';
    }
    return null;
  }

  /// Validates the login password field — minimal check (just not empty).
  ///
  /// Full validation only applies on registration / change password flows.
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }

  /// Validates a confirm-password field against the original password.
  static String? validateConfirmPassword(String? value, String? original) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu';
    }
    if (value != original) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Generic
  // ---------------------------------------------------------------------------

  /// Validates that a field is not empty.
  static String? validateRequired(
    String? value, {
    String fieldName = 'Trường này',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName không được để trống';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Phone
  // ---------------------------------------------------------------------------

  /// Validates a Vietnamese phone number (10 digits, starts with 0).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^0[0-9]{9}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ (10 số, bắt đầu bằng 0)';
    }
    return null;
  }
}
