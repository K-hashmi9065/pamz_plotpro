import 'package:intl/intl.dart';
import 'land_unit_converter.dart';

/// Centralized Financial Math & Calculation Engine for Land Investment System.
/// Every formula in PRD §7 lives here and nowhere else.
/// All monetary values are rounded cleanly to 2 decimal places to eliminate floating-point drift.
abstract class CalculationEngine {
  static final NumberFormat indianCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat indianNumberFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '',
    decimalDigits: 0,
  );

  static double _round2(double val) {
    return double.parse(val.toStringAsFixed(2));
  }

  /// Format money in Indian currency format (e.g. ₹1,00,000.00 or ₹15,00,000)
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    if (showDecimals) {
      return indianCurrencyFormat.format(amount);
    }
    final intAmount = amount.round();
    final formatted = indianNumberFormat.format(intAmount).trim();
    return '₹$formatted';
  }

  /// PRD §7.1: Actual Project Cost = Purchase Price + Sum of Capitalized Expenses
  static double calculateActualProjectCost({
    required double purchasePrice,
    required List<double> capitalizedExpenses,
  }) {
    final expenseSum = capitalizedExpenses.fold(0.0, (a, b) => a + b);
    return _round2(purchasePrice + expenseSum);
  }

  /// PRD §7.2: Plot Cost Allocation - Area-Based Method
  /// Plot Allocated Cost = (Plot Area / Total Project Area) * Actual Project Cost
  static double calculateAreaBasedPlotCost({
    required double plotAreaSqFt,
    required double totalProjectAreaSqFt,
    required double actualProjectCost,
  }) {
    if (totalProjectAreaSqFt <= 0) return 0.0;
    return _round2((plotAreaSqFt / totalProjectAreaSqFt) * actualProjectCost);
  }

  /// Area-wise division of Project Expenses across plots:
  /// Allocated Project Expense = (Plot Area / Total Project Area) * Total Project Expense
  static double calculatePlotAllocatedExpense({
    required double plotAreaSqFt,
    required double totalProjectAreaSqFt,
    required double totalProjectExpense,
  }) {
    if (totalProjectAreaSqFt <= 0) return 0.0;
    return _round2((plotAreaSqFt / totalProjectAreaSqFt) * totalProjectExpense);
  }

  /// Plot Total Expense = Area-wise Allocated Project Expense + Direct Plot Brokerage Charge
  static double calculatePlotTotalExpense({
    required double allocatedExpense,
    required double brokerageCharge,
  }) {
    return _round2(allocatedExpense + brokerageCharge);
  }

  /// Plot Total Cost = Base Land Purchase Cost + Plot Total Expense
  static double calculatePlotTotalCost({
    required double basePurchaseCost,
    required double plotTotalExpense,
  }) {
    return _round2(basePurchaseCost + plotTotalExpense);
  }

  /// PRD §7.2: Plot Cost Allocation - Percentage-Based Method
  static double calculatePercentageBasedPlotCost({
    required double allocationPercentage,
    required double actualProjectCost,
  }) {
    return _round2((allocationPercentage / 100.0) * actualProjectCost);
  }

  /// PRD §7.3: Net Sale Proceeds & Profit/Loss
  /// Net Sale Proceeds = Agreed Sale Price - Direct Sale Expenses
  /// Sale Profit/Loss = Net Sale Proceeds - Allocated Plot Cost
  static double calculateNetSaleProceeds({
    required double agreedSalePrice,
    required double directSaleExpenses,
  }) {
    return _round2(agreedSalePrice - directSaleExpenses);
  }

  static double calculateSaleProfitLoss({
    required double netSaleProceeds,
    required double allocatedPlotCost,
  }) {
    return _round2(netSaleProceeds - allocatedPlotCost);
  }

  /// PRD §7.4: Investor Ownership Percentage (Capital-Based Formula)
  /// Ownership % = (Investor Contribution / Total Share Capital) * 100
  static double calculateInvestorOwnershipPercent({
    required double investorContribution,
    required double totalShareCapital,
  }) {
    if (totalShareCapital <= 0) return 0.0;
    return _round2((investorContribution / totalShareCapital) * 100.0);
  }

  /// PRD §7.5: Distributable Profit = Realized Project Profit - Commissions - Management Fees - Reserve
  static double calculateDistributableProfit({
    required double totalRealizedProfit,
    double agentCommissions = 0.0,
    double adminManagementFee = 0.0,
    double contingencyReserve = 0.0,
  }) {
    final profit = totalRealizedProfit - agentCommissions - adminManagementFee - contingencyReserve;
    return profit < 0 ? 0.0 : _round2(profit);
  }

  /// PRD §7.5: Investor Profit Share & ROR (Rate of Return)
  /// Investor Profit Share = Distributable Profit * (Investor Ownership % / 100)
  /// Investor ROR % = (Investor Profit Share / Investor Capital Contributed) * 100
  static double calculateInvestorProfitShare({
    required double distributableProfit,
    required double ownershipPercent,
  }) {
    return _round2(distributableProfit * (ownershipPercent / 100.0));
  }

  static double calculateInvestorRor({
    required double investorProfitShare,
    required double investorCapitalContributed,
  }) {
    if (investorCapitalContributed <= 0) return 0.0;
    return _round2((investorProfitShare / investorCapitalContributed) * 100.0);
  }

  /// Backwards-compatible alias for calculateInvestorRor
  static double calculateInvestorRoi({
    required double investorProfitShare,
    required double investorCapitalContributed,
  }) {
    return calculateInvestorRor(
      investorProfitShare: investorProfitShare,
      investorCapitalContributed: investorCapitalContributed,
    );
  }

  /// PRD §7.5: Investor Final Settlement
  /// Settlement = Capital Contributed + Profit Earned - Distributions Paid
  static double calculateInvestorSettlement({
    required double capitalContributed,
    required double profitEarned,
    required double distributionsPaid,
  }) {
    return _round2(capitalContributed + profitEarned - distributionsPaid);
  }

  /// PRD §7.6: Receivables, Payables & Cash Flow
  static double calculateBalanceReceivable({
    required double totalAgreedSales,
    required double cashCollected,
  }) {
    final balance = totalAgreedSales - cashCollected;
    return balance < 0 ? 0.0 : _round2(balance);
  }

  static double calculateBalancePayable({
    required double totalObligations,
    required double cashPaid,
  }) {
    final balance = totalObligations - cashPaid;
    return balance < 0 ? 0.0 : _round2(balance);
  }

  static double calculateNetCashFlow({
    required double totalCashInflows,
    required double totalCashOutflows,
  }) {
    return _round2(totalCashInflows - totalCashOutflows);
  }

  /// PRD §7.7: Break-Even Area / Sales Value
  static double calculateBreakEvenSqFt({
    required double actualProjectCost,
    required double targetSellingPricePerSqFt,
  }) {
    if (targetSellingPricePerSqFt <= 0) return 0.0;
    return _round2(actualProjectCost / targetSellingPricePerSqFt);
  }

  /// PRD §7.8: Agent Commission Calculation
  static double calculateCommission({
    required double salePrice,
    required double commissionPercent,
  }) {
    return _round2(salePrice * (commissionPercent / 100.0));
  }

  /// Calculate Remaining Project Land by normalizing project area and plot areas in Sq Ft,
  /// then formatting the remaining area in the Project's measurement unit.
  static String calculateRemainingProjectLand({
    required double projectLandAreaSqFt,
    required String projectMeasurementUnit,
    required List<double> plotAreasSqFt,
    double? projectDisplayArea,
    double? projectKattaValue,
    double? projectDhurValue,
  }) {
    final totalPlotsSqFt = plotAreasSqFt.fold<double>(0.0, (sum, area) => sum + area);
    final remainingSqFt = projectLandAreaSqFt - totalPlotsSqFt;
    final normalizedRemainingSqFt = remainingSqFt < 0 ? 0.0 : remainingSqFt;

    return LandUnitConverter.formatLandMeasurement(
      areaSqFt: normalizedRemainingSqFt,
      measurementUnit: projectMeasurementUnit,
    );
  }
}
