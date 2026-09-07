import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:land_investment_and_sales_management/main.dart';
import 'package:land_investment_and_sales_management/features/projects/presentation/widgets/project_form_dialog.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/presentation/widgets/buyer_form_dialog.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/presentation/widgets/payment_record_dialog.dart';
import 'package:land_investment_and_sales_management/features/landowners/presentation/widgets/landowner_form_dialog.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full Application End-to-End Integration Tests', () {
    testWidgets('1. App Launch & Navigation Dashboard Verification', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: LandInvestmentApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify App Title / Executive Dashboard is rendered
      expect(find.byType(LandInvestmentApp), findsOneWidget);
    });

    testWidgets('2. Dialog Integration: Project Form Dialog Launch & Interaction', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => ProjectFormDialog.show(context),
                  child: const Text('Open Project Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to open ProjectFormDialog
      await tester.tap(find.text('Open Project Dialog'));
      await tester.pumpAndSettle();

      // Verify Project Form Dialog elements are rendered
      expect(find.byType(ProjectFormDialog), findsOneWidget);
      expect(find.text('Create Project'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectFormDialog), findsNothing);
    });

    testWidgets('3. Dialog Integration: Buyer Form Dialog with Inline Project Creation Button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BuyerFormDialog.show(context),
                  child: const Text('Open Buyer Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to open BuyerFormDialog
      await tester.tap(find.text('Open Buyer Dialog'));
      await tester.pumpAndSettle();

      // Verify Buyer Form Dialog elements and + New Project button are rendered
      expect(find.byType(BuyerFormDialog), findsOneWidget);
      expect(find.text('Register Buyer Profile'), findsOneWidget);
      expect(find.text(' Associated Project (Optional)'), findsOneWidget);
      expect(find.text(' New Project'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(BuyerFormDialog), findsNothing);
    });

    testWidgets('4. Dialog Integration: Landowner Form Dialog with Inline Project Selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => LandownerFormDialog.show(context),
                  child: const Text('Open Landowner Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to open LandownerFormDialog
      await tester.tap(find.text('Open Landowner Dialog'));
      await tester.pumpAndSettle();

      // Verify Landowner Form Dialog and + New Project inline button
      expect(find.byType(LandownerFormDialog), findsOneWidget);
      expect(find.text('Register Landowner'), findsOneWidget);
      expect(find.text('+ New Project'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(LandownerFormDialog), findsNothing);
    });

    testWidgets('5. Dialog Integration: Record Payment Entry Dialog Launch', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PaymentRecordDialog.show(context),
                  child: const Text('Open Payment Dialog'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap button to open PaymentRecordDialog
      await tester.tap(find.text('Open Payment Dialog'));
      await tester.pumpAndSettle();

      // Verify Record Payment Entry dialog opens cleanly
      expect(find.byType(PaymentRecordDialog), findsOneWidget);
      expect(find.text('Record Payment Entry'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentRecordDialog), findsNothing);
    });
  });
}
