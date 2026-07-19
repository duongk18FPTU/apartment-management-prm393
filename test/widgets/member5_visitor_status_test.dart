import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/app/theme.dart';
import 'package:prm393_project/services/visitor_service.dart';

void main() {
  Future<void> pumpLabels(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: Column(
            children: [
              Text(VisitorStatus.label(VisitorStatus.registered)),
              Text(VisitorStatus.label(VisitorStatus.checkedIn)),
              Text(VisitorStatus.label(VisitorStatus.checkedOut)),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('VisitorStatus labels render in Vietnamese', (tester) async {
    await pumpLabels(tester);

    expect(find.text('Chờ check-in'), findsOneWidget);
    expect(find.text('Trong tòa'), findsOneWidget);
    expect(find.text('Đã ra'), findsOneWidget);
  });
}
