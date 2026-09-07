class InvestorModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? pan;
  final DateTime createdAt;

  const InvestorModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.pan,
    required this.createdAt,
  });
}

class InvestorFinancialSummary {
  final String investorId;
  final String investorName;
  final double totalInvestedCapital;
  final double totalProfitEarned;
  final double totalWithdrawnPayouts;
  final double netRemainingBalance;
  final bool canBeDeleted;

  const InvestorFinancialSummary({
    required this.investorId,
    required this.investorName,
    required this.totalInvestedCapital,
    required this.totalProfitEarned,
    required this.totalWithdrawnPayouts,
    required this.netRemainingBalance,
    required this.canBeDeleted,
  });
}
