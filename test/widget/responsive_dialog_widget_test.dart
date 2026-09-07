import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:land_investment_and_sales_management/features/projects/presentation/widgets/project_form_dialog.dart';
import 'package:land_investment_and_sales_management/features/landowners/presentation/widgets/landowner_form_dialog.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/presentation/widgets/payment_record_dialog.dart';
import 'package:land_investment_and_sales_management/features/landowners/presentation/landowners_providers.dart';
import 'package:land_investment_and_sales_management/features/projects/presentation/projects_providers.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/presentation/sales_providers.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/presentation/installments_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        landownersListStreamProvider.overrideWith((ref) => Stream.value([])),
        projectsListStreamProvider.overrideWith((ref) => Stream.value([])),
        salesListStreamProvider.overrideWith((ref) => Stream.value([])),
        installmentsListStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('Responsive Dialog Widget Tests at Minimum Window Size (1024 x 700)', () {
    testWidgets('ProjectFormDialog renders cleanly without layout overflow at 1024x700', (tester) async {
      tester.view.physicalSize = const Size(1024, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const ProjectFormDialog()));
      await tester.pump();

      expect(find.text('Create New Project'), findsOneWidget);
      expect(find.text('Project Name *'), findsOneWidget);
      expect(find.text('Location *'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Create Project'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('LandownerFormDialog renders cleanly without layout overflow at 1024x700', (tester) async {
      tester.view.physicalSize = const Size(1024, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const LandownerFormDialog()));
      await tester.pump();

      expect(find.text('Register Landowner'), findsNWidgets(2));
      expect(find.text('Landowner Full Name *'), findsOneWidget);
      expect(find.text('Phone Number *'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('PaymentRecordDialog renders target project & buyer fields cleanly at 1024x700', (tester) async {
      tester.view.physicalSize = const Size(1024, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(const PaymentRecordDialog()));
      await tester.pump();

      expect(find.text('Record Payment Entry'), findsOneWidget);
      expect(find.text('Select Project *'), findsOneWidget);
      expect(find.text('Select Buyer / Sale *'), findsOneWidget);
      expect(find.text('Select Installment'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
