// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:warehouse_admin/app.dart';

void main() {
  testWidgets('Warehouse Admin App loads successfully',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WarehouseAdminApp());
    await tester.pumpAndSettle();

    // Verify that our app title is present.
    expect(find.text('Warehouse Admin'), findsOneWidget);

    // Verify sidebar navigation items exist.
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('Stock Update'), findsOneWidget);

    // Verify the dashboard content loads.
    expect(
        find.text(
            'Welcome back! Here is what is happening with your warehouse today.'),
        findsOneWidget);
  });
}
