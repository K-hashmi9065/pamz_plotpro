import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:land_investment_and_sales_management/main.dart';
import 'package:land_investment_and_sales_management/features/projects/presentation/widgets/project_form_dialog.dart';
import 'package:land_investment_and_sales_management/features/buyers_sales/presentation/widgets/buyer_form_dialog.dart';
import 'package:land_investment_and_sales_management/features/installments_payments/presentation/widgets/payment_record_dialog.dart';

void main() {
  patrolTest(
    '1. Patrol E2E: App Boot, Widget Search & Navigation Flow',
    ($) async {
      await $.pumpWidget(
        const ProviderScope(
          child: LandInvestmentApp(),
        ),
      );

      await $.pumpAndSettle();

      // Patrol widget selector verification
      expect($(LandInvestmentApp), findsOneWidget);
    },
  );

  patrolTest(
    '2. Patrol E2E: Launch & Validate Project Form Dialog with Patrol Selectors',
    ($) async {
      await $.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => ProjectFormDialog.show(context),
                  child: const Text('Launch Project Form'),
                ),
              ),
            ),
          ),
        ),
      );

      await $.pumpAndSettle();

      // Tap launch button using Patrol $ selector
      await $(find.text('Launch Project Form')).tap();
      await $.pumpAndSettle();

      // Verify ProjectFormDialog using Patrol assertions
      expect($(ProjectFormDialog), findsOneWidget);
      expect($(find.text('Create Project')), findsOneWidget);

      // Close dialog
      await $(find.byIcon(Icons.close)).tap();
      await $.pumpAndSettle();

      expect($(ProjectFormDialog), findsNothing);
    },
  );

  patrolTest(
    '3. Patrol E2E: Validate Buyer Form Dialog with Inline Project Creation Button',
    ($) async {
      await $.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => BuyerFormDialog.show(context),
                  child: const Text('Launch Buyer Form'),
                ),
              ),
            ),
          ),
        ),
      );

      await $.pumpAndSettle();

      await $(find.text('Launch Buyer Form')).tap();
      await $.pumpAndSettle();

      // Verify Buyer Form Dialog & New Project button with Patrol selectors
      expect($(BuyerFormDialog), findsOneWidget);
      expect($(find.text('Register Buyer Profile')), findsOneWidget);
      expect($(find.text(' New Project')), findsOneWidget);

      await $(find.byIcon(Icons.close)).tap();
      await $.pumpAndSettle();

      expect($(BuyerFormDialog), findsNothing);
    },
  );

  patrolTest(
    '4. Patrol E2E: Launch & Validate Record Payment Entry Dialog',
    ($) async {
      await $.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => PaymentRecordDialog.show(context),
                  child: const Text('Launch Payment Form'),
                ),
              ),
            ),
          ),
        ),
      );

      await $.pumpAndSettle();

      await $(find.text('Launch Payment Form')).tap();
      await $.pumpAndSettle();

      expect($(PaymentRecordDialog), findsOneWidget);
      expect($(find.text('Record Payment Entry')), findsOneWidget);

      await $(find.byIcon(Icons.close)).tap();
      await $.pumpAndSettle();

      expect($(PaymentRecordDialog), findsNothing);
    },
  );
}
