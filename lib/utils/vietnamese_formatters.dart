import 'package:intl/intl.dart';

/// Locale-aware formatters shared by Vietnamese user-facing screens.
abstract final class VietnameseFormatters {
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  static final DateFormat date = DateFormat('dd/MM/yyyy', 'vi_VN');
  static final DateFormat dateTime = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');

  static String billingMonth(String value) {
    final parts = value.split('-');
    if (parts.length != 2) return value;
    return '${parts[1]}/${parts[0]}';
  }
}
