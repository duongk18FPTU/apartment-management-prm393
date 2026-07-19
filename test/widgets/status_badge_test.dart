import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/widgets/status_badge.dart';

void main() {
  testWidgets('StatusBadge.bill renders paid status correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: StatusBadge.bill(BillStatus.paid))),
    );

    // Xác nhận nhãn trạng thái đã thanh toán xuất hiện ở dạng IN HOA
    expect(find.text('ĐÃ THANH TOÁN'), findsOneWidget);

    // Xác nhận chấm tròn nhỏ chỉ thị trạng thái được vẽ (thông qua Container)
    expect(find.byType(Container), findsAtLeastNWidgets(2));
  });

  testWidgets('StatusBadge.bill renders unpaid status correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: StatusBadge.bill(BillStatus.unpaid))),
    );

    // Xác nhận nhãn trạng thái chưa thanh toán xuất hiện
    expect(find.text('CHƯA THANH TOÁN'), findsOneWidget);
  });

  testWidgets('StatusBadge.bill renders pending status correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: StatusBadge.bill(BillStatus.pending))),
    );

    // Xác nhận nhãn trạng thái chờ xử lý xuất hiện
    expect(find.text('CHỜ XỬ LÝ'), findsOneWidget);
  });
}
