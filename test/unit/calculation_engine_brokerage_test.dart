import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/utils/calculation_engine.dart';
import 'package:land_investment_and_sales_management/core/utils/land_unit_converter.dart';

void main() {
  group('CalculationEngine - Brokerage & Area-Wise Expense Calculations', () {
    test('Area-wise expense division across plots with Kattha conversion', () {
      // User prompt scenario:
      // Project general expense = 1,000
      // Plot 1 has 3 Kattha (4,089 sq.ft)
      // Plot 2 has 2 Kattha (2,726 sq.ft)
      // Total Area = 5 Kattha (6,815 sq.ft)
      // Plot 1 share = (3/5) * 1000 = 600
      // Plot 2 share = (2/5) * 1000 = 400
      final plot1AreaSqFt = LandUnitConverter.kattaDhurToSqFt(3, 0);
      final plot2AreaSqFt = LandUnitConverter.kattaDhurToSqFt(2, 0);
      final totalProjectAreaSqFt = plot1AreaSqFt + plot2AreaSqFt; // 6815.0
      const totalProjectExpense = 1000.0;

      final plot1AllocatedExpense = CalculationEngine.calculatePlotAllocatedExpense(
        plotAreaSqFt: plot1AreaSqFt,
        totalProjectAreaSqFt: totalProjectAreaSqFt,
        totalProjectExpense: totalProjectExpense,
      );

      final plot2AllocatedExpense = CalculationEngine.calculatePlotAllocatedExpense(
        plotAreaSqFt: plot2AreaSqFt,
        totalProjectAreaSqFt: totalProjectAreaSqFt,
        totalProjectExpense: totalProjectExpense,
      );

      expect(plot1AllocatedExpense, equals(600.0));
      expect(plot2AllocatedExpense, equals(400.0));
      expect(plot1AllocatedExpense + plot2AllocatedExpense, equals(1000.0));
    });

    test('User Scenario: 5 plots of 1 Kattha, 5000 project expense, 2000 brokerage on Plot 1', () {
      // 5 plots each 1 Kattha = 1363 sq ft
      // Total project area = 5 Kattha = 6815 sq ft
      // Project general expense = 5000
      // Per plot general expense = (1/5) * 5000 = 1000
      // Plot 1 brokerage = 2000
      // Plot 1 total expense = 1000 + 2000 = 3000
      // Plots 2-5 total expense = 1000 + 0 = 1000
      final oneKatthaSqFt = LandUnitConverter.kattaDhurToSqFt(1, 0);
      final totalProjectAreaSqFt = oneKatthaSqFt * 5;
      const generalProjectExpense = 5000.0;

      final allocatedGenExp = CalculationEngine.calculatePlotAllocatedExpense(
        plotAreaSqFt: oneKatthaSqFt,
        totalProjectAreaSqFt: totalProjectAreaSqFt,
        totalProjectExpense: generalProjectExpense,
      );

      expect(allocatedGenExp, equals(1000.0));

      final plot1TotalExpense = CalculationEngine.calculatePlotTotalExpense(
        allocatedExpense: allocatedGenExp,
        brokerageCharge: 2000.0,
      );
      final otherPlotsTotalExpense = CalculationEngine.calculatePlotTotalExpense(
        allocatedExpense: allocatedGenExp,
        brokerageCharge: 0.0,
      );

      expect(plot1TotalExpense, equals(3000.0));
      expect(otherPlotsTotalExpense, equals(1000.0));

      // Sum of all 5 plot expenses = 3000 + (4 * 1000) = 7000 (5000 general + 2000 brokerage)
      expect(plot1TotalExpense + (4 * otherPlotsTotalExpense), equals(7000.0));
    });

    test('Plot Total Expense = Area-wise Allocated Expense + Direct Brokerage Charge', () {
      const allocatedExpense = 600.0;
      const brokerageCharge = 500.0;

      final plotTotalExpense = CalculationEngine.calculatePlotTotalExpense(
        allocatedExpense: allocatedExpense,
        brokerageCharge: brokerageCharge,
      );

      expect(plotTotalExpense, equals(1100.0));
    });

    test('Plot Total Cost = Base Land Purchase Cost + Plot Total Expense', () {
      const baseLandPurchaseCost = 50000.0;
      const plotTotalExpense = 1100.0;

      final plotTotalCost = CalculationEngine.calculatePlotTotalCost(
        basePurchaseCost: baseLandPurchaseCost,
        plotTotalExpense: plotTotalExpense,
      );

      expect(plotTotalCost, equals(51100.0));
    });

    test('Zero totalProjectArea returns 0.0 without crashing', () {
      final allocated = CalculationEngine.calculatePlotAllocatedExpense(
        plotAreaSqFt: 1000.0,
        totalProjectAreaSqFt: 0.0,
        totalProjectExpense: 5000.0,
      );
      expect(allocated, equals(0.0));
    });
  });
}
