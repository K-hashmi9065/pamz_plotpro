import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:land_investment_and_sales_management/core/constants/app_constants.dart';
import 'package:land_investment_and_sales_management/core/database/app_database.dart';
import 'package:land_investment_and_sales_management/core/database/database_provider.dart';
import 'package:land_investment_and_sales_management/features/plots/domain/plot_model.dart';
import 'package:land_investment_and_sales_management/features/plots/presentation/widgets/add_brokerage_dialog.dart';
import 'package:land_investment_and_sales_management/features/plots/presentation/widgets/brokerage_info_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestableWidget(Widget child) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('Brokerage Dialogs Widget Tests', () {
    final testPlot = PlotModel(
      id: 'plot-1',
      projectId: 'project-1',
      plotNumber: 'Plot #01',
      areaSqFt: 4089, // 3 Kattha
      measurementUnit: 'Kattha',
      allocatedCost: 600000,
      expectedPrice: 1000000,
      status: PlotStatus.available,
      brokerName: 'Anil Kumar',
      brokerPhone: '9876543210',
      brokerageCharge: 50000,
      createdAt: DateTime.now(),
    );

    testWidgets('AddBrokerageDialog renders all inputs and validates correctly', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(AddBrokerageDialog(plot: testPlot)));
      await tester.pump();

      expect(find.text('Add Brokerage Charge'), findsOneWidget);
      expect(find.textContaining('Plot #01'), findsNWidgets(2));
      expect(find.text('Broker Name *'), findsOneWidget);
      expect(find.text('Broker Mobile Number'), findsOneWidget);
      expect(find.text('Brokerage Charge (₹) *'), findsOneWidget);
      expect(find.text('Save Brokerage Charge'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('BrokerageInfoDialog renders broker details when assigned', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestableWidget(BrokerageInfoDialog(plot: testPlot)));
      await tester.pump();

      expect(find.text('Brokerage Information'), findsOneWidget);
      expect(find.text('Anil Kumar'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text('₹50,000'), findsOneWidget);
      expect(find.text('Edit Brokerage'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });

    testWidgets('BrokerageInfoDialog renders empty state when no broker assigned', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final unassignedPlot = PlotModel(
        id: 'plot-2',
        projectId: 'project-1',
        plotNumber: 'Plot #02',
        areaSqFt: 2726,
        allocatedCost: 400000,
        expectedPrice: 800000,
        status: PlotStatus.available,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(buildTestableWidget(BrokerageInfoDialog(plot: unassignedPlot)));
      await tester.pump();

      expect(find.text('No Brokerage Recorded'), findsOneWidget);
      expect(find.text('Add Brokerage Charge'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
