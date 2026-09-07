import 'package:flutter_test/flutter_test.dart';
import 'package:land_investment_and_sales_management/core/utils/calculation_engine.dart';

void main() {
  group('CalculationEngine Unit Tests - PRD §7 & Acceptance Criteria', () {
    test('Actual Project Cost = Purchase Price + Capitalized Expenses (PRD §7.1 / AC-04.1)', () {
      final purchasePrice = 20000000.0; // ₹2,00,00,000
      final capitalizedExpenses = [800000.0]; // ₹8,00,000 DEVELOPMENT expense

      final actualCost = CalculationEngine.calculateActualProjectCost(
        purchasePrice: purchasePrice,
        capitalizedExpenses: capitalizedExpenses,
      );

      expect(actualCost, equals(20800000.0)); // ₹2,08,00,000
    });

    test('Period Expenses do not alter Actual Project Cost (AC-04.2)', () {
      final purchasePrice = 20000000.0;
      final capitalizedExpenses = [800000.0];
      // Marketing expense is period expense (not capitalized)

      final actualCost = CalculationEngine.calculateActualProjectCost(
        purchasePrice: purchasePrice,
        capitalizedExpenses: capitalizedExpenses,
      );

      expect(actualCost, equals(20800000.0));
    });

    test('Area-Based Plot Cost Allocation (PRD §7.2 / AC-05.1)', () {
      final actualProjectCost = 22700000.0; // ₹2,27,00,000
      final totalArea = 227000.0; // 2,27,000 sq.ft
      final plot12Area = 1000.0; // 1,000 sq.ft

      final allocatedCost = CalculationEngine.calculateAreaBasedPlotCost(
        plotAreaSqFt: plot12Area,
        totalProjectAreaSqFt: totalArea,
        actualProjectCost: actualProjectCost,
      );

      expect(allocatedCost, equals(100000.0)); // ₹1,00,000
    });

    test('Investor Ownership % - Single Investor 100% (PRD §7.4 / AC-03.1)', () {
      final contribution = 5000000.0; // ₹50,00,000
      final totalShareCapital = 5000000.0;

      final ownership = CalculationEngine.calculateInvestorOwnershipPercent(
        investorContribution: contribution,
        totalShareCapital: totalShareCapital,
      );

      expect(ownership, equals(100.0));
    });

    test('Investor Ownership % - Dilution to 50% each (PRD §7.4 / AC-03.2)', () {
      final totalShareCapital = 10000000.0; // ₹1,00,00,000
      final investorAContribution = 5000000.0;
      final investorBContribution = 5000000.0;

      final ownershipA = CalculationEngine.calculateInvestorOwnershipPercent(
        investorContribution: investorAContribution,
        totalShareCapital: totalShareCapital,
      );

      final ownershipB = CalculationEngine.calculateInvestorOwnershipPercent(
        investorContribution: investorBContribution,
        totalShareCapital: totalShareCapital,
      );

      expect(ownershipA, equals(50.0));
      expect(ownershipB, equals(50.0));
    });

    test('Net Sale Proceeds & Profit Calculation (PRD §7.3)', () {
      final agreedPrice = 10000000.0; // ₹1,00,00,000
      final saleExpenses = 200000.0; // ₹2,00,00
      final allocatedCost = 6500000.0; // ₹65,00,000

      final netProceeds = CalculationEngine.calculateNetSaleProceeds(
        agreedSalePrice: agreedPrice,
        directSaleExpenses: saleExpenses,
      );

      final profit = CalculationEngine.calculateSaleProfitLoss(
        netSaleProceeds: netProceeds,
        allocatedPlotCost: allocatedCost,
      );

      expect(netProceeds, equals(9800000.0));
      expect(profit, equals(3300000.0)); // ₹33,00,000
    });

    test('Investor Final Settlement Calculation (PRD §7.5)', () {
      final capitalContributed = 5000000.0;
      final profitEarned = 1500000.0;
      final distributionsPaid = 1000000.0;

      final settlement = CalculationEngine.calculateInvestorSettlement(
        capitalContributed: capitalContributed,
        profitEarned: profitEarned,
        distributionsPaid: distributionsPaid,
      );

      expect(settlement, equals(5500000.0)); // ₹55,00,000
    });

    test('Indian Currency Formatting (₹1,00,000)', () {
      final formatted1Lakh = CalculationEngine.formatCurrency(100000);
      final formatted1Crore = CalculationEngine.formatCurrency(10000000);

      expect(formatted1Lakh, contains('1,00,000'));
      expect(formatted1Crore, contains('1,00,00,000'));
    });
  });
}
