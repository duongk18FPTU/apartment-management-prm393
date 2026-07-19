import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prm393_project/utils/vietnamese_formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('vi_VN');
  });

  test('formats Vietnamese currency without decimal digits', () {
    final formatted = VietnameseFormatters.currency.format(450000);
    expect(formatted, contains('450.000'));
    expect(formatted, contains('₫'));
    expect(formatted, isNot(contains(',00')));
  });

  test('formats date and time using Vietnamese order', () {
    final value = DateTime(2026, 7, 19, 16, 50);
    expect(VietnameseFormatters.date.format(value), '19/07/2026');
    expect(VietnameseFormatters.dateTime.format(value), '19/07/2026 16:50');
  });

  test('formats billing month for Vietnamese readers', () {
    expect(VietnameseFormatters.billingMonth('2026-07'), '07/2026');
    expect(VietnameseFormatters.billingMonth('invalid'), 'invalid');
  });
}
