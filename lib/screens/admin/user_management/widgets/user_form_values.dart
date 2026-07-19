import '../../../../models/user_model.dart';
import '../../../../utils/constants.dart';

/// Immutable values emitted only after all user form fields are valid.
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
