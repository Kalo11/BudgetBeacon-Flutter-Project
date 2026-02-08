import 'package:budget_beacon/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows budget dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const BudgetBeaconApp());

    expect(find.text('BudgetBeacon'), findsOneWidget);
    expect(find.text('Monthly Snapshot'), findsOneWidget);
    expect(find.text('Upcoming Bills'), findsOneWidget);
    expect(find.text('Add Transaction'), findsOneWidget);
  });
}
