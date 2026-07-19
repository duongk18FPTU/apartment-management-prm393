import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/app/theme.dart';
import 'package:prm393_project/models/complaint_model.dart';
import 'package:prm393_project/models/request_model.dart';
import 'package:prm393_project/widgets/complaint_status_chip.dart';
import 'package:prm393_project/widgets/request_status_chip.dart';

void main() {
  Future<void> pumpChip(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('RequestStatusChip', () {
    testWidgets('shows pending label', (tester) async {
      await pumpChip(
        tester,
        const RequestStatusChip(status: RequestStatus.pending),
      );
      expect(find.text('Chờ xử lý'), findsOneWidget);
    });

    testWidgets('shows in progress and completed labels', (tester) async {
      await pumpChip(
        tester,
        const Column(
          children: [
            RequestStatusChip(status: RequestStatus.inProgress),
            RequestStatusChip(status: RequestStatus.completed),
          ],
        ),
      );
      expect(find.text('Đang xử lý'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsOneWidget);
    });
  });

  group('ComplaintStatusChip', () {
    testWidgets('shows all complaint status labels', (tester) async {
      await pumpChip(
        tester,
        const Column(
          children: [
            ComplaintStatusChip(status: ComplaintStatus.submitted),
            ComplaintStatusChip(status: ComplaintStatus.inReview),
            ComplaintStatusChip(status: ComplaintStatus.resolved),
          ],
        ),
      );
      expect(find.text('Đã gửi'), findsOneWidget);
      expect(find.text('Đang xem xét'), findsOneWidget);
      expect(find.text('Đã phản hồi'), findsOneWidget);
    });
  });
}
