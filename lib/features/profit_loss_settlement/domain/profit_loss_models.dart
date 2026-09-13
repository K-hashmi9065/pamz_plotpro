import '../../../core/utils/calculation_engine.dart';

class ProjectProfitLossModel {
  final String projectId;
  final String projectName;
  final double totalAgreedSales;
  final double directSaleExpenses;
  final double actualProjectCost;
  final double agentCommissions;
  final double adminManagementFee;
  final double contingencyReserve;
  final double cashCollected;

  const ProjectProfitLossModel({
    required this.projectId,
    required this.projectName,
    required this.totalAgreedSales,
    required this.directSaleExpenses,
    required this.actualProjectCost,
    this.agentCommissions = 0.0,
    this.adminManagementFee = 0.0,
    this.contingencyReserve = 0.0,
    required this.cashCollected,
  });

  /// PRD §7.3 Net Sale Proceeds = Agreed Sales - Direct Sale Expenses
  double get netSaleProceeds =>
      CalculationEngine.calculateNetSaleProceeds(
        agreedSalePrice: totalAgreedSales,
        directSaleExpenses: directSaleExpenses,
      );

  /// PRD §7.3 Gross Project Profit = Net Sale Proceeds - Actual Project Cost
  double get grossProjectProfit =>
      CalculationEngine.calculateSaleProfitLoss(
        netSaleProceeds: netSaleProceeds,
        allocatedPlotCost: actualProjectCost,
      );

  /// PRD §7.5 Distributable Profit
  double get distributableProfit =>
      CalculationEngine.calculateDistributableProfit(
        totalRealizedProfit: grossProjectProfit,
        agentCommissions: agentCommissions,
        adminManagementFee: adminManagementFee,
        contingencyReserve: contingencyReserve,
      );

  /// Cash-based Realized Profit = Cash Collected - Actual Project Cost
  double get realizedProfit {
    final profit = cashCollected - actualProjectCost;
    return profit < 0 ? 0.0 : profit;
  }
}

class InvestorPayoutModel {
  final String id;
  final String investorId;
  final String investorName;
  final String projectId;
  final double capitalInvested;
  final double ownershipPercent;
  final double distributableProfitPool;
  final double payoutsDisbursed;

  const InvestorPayoutModel({
    required this.id,
    required this.investorId,
    required this.investorName,
    required this.projectId,
    required this.capitalInvested,
    required this.ownershipPercent,
    required this.distributableProfitPool,
    required this.payoutsDisbursed,
  });

  /// PRD §7.5 Investor Profit Share = Distributable Profit * (Ownership % / 100)
  double get allocatedProfitShare =>
      CalculationEngine.calculateInvestorProfitShare(
        distributableProfit: distributableProfitPool,
        ownershipPercent: ownershipPercent,
      );

  /// PRD §7.5 Investor ROR % (Rate of Return) = (Profit Share / Capital Invested) * 100
  double get rorPercent =>
      CalculationEngine.calculateInvestorRor(
        investorProfitShare: allocatedProfitShare,
        investorCapitalContributed: capitalInvested,
      );

  /// Backwards-compatible getter for rorPercent
  double get roiPercent => rorPercent;

  /// PRD §7.5 Final Settlement Amount = Capital Invested + Profit Share - Payouts Disbursed
  double get remainingPayoutBalance =>
      CalculationEngine.calculateInvestorSettlement(
        capitalContributed: capitalInvested,
        profitEarned: allocatedProfitShare,
        distributionsPaid: payoutsDisbursed,
      );
}
