import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:land_investment_and_sales_management/main.dart';

void main() {
  testWidgets('Land Investment App desktop shell test', (WidgetTester tester) async {
    // Set desktop screen size for widget test environment
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: LandInvestmentApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    // Verify app shell loads successfully
    expect(find.byType(LandInvestmentApp), findsOneWidget);
  });
}
