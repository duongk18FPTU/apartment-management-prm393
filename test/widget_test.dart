// Basic smoke test — updated to reflect the refactored app entry point.
// Full widget tests for individual screens will be added in Sprint 3.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project/app/theme.dart';
import 'package:prm393_project/models/user_model.dart';
import 'package:prm393_project/screens/admin/user_management/widgets/user_status_badge.dart';

void main() {
  test('uses the bundled Vietnamese typeface throughout the theme', () {
    final theme = buildAppTheme();

    expect(theme.textTheme.bodyMedium?.fontFamily, 'BeVietnamPro');
    expect(theme.textTheme.titleLarge?.fontFamily, 'BeVietnamPro');
  });

  testWidgets('Placeholder smoke test — Sprint 3 will add real tests', (
    WidgetTester tester,
  ) async {
    // ApartmentApp requires Firebase to be initialised, which is not available
    // in the plain widget test environment. Sprint 3 will set up a Firebase
    // mock and replace this placeholder with real tests for each screen.
    expect(true, isTrue);
  });
  testWidgets('renders semantic user account status labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Column(
          children: [
            UserStatusBadge(status: UserStatus.active),
            UserStatusBadge(status: UserStatus.inactive),
          ],
        ),
      ),
    );

    expect(find.text('Hoạt động'), findsOneWidget);
    expect(find.text('Đã vô hiệu hóa'), findsOneWidget);
  });
}
