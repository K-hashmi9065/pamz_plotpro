class BuyerReceivableModel {
  final String installmentId;
  final String saleId;
  final String buyerName;
  final String projectId;
  final int installmentNumber;
  final DateTime dueDate;
  final double dueAmount;
  final double paidAmount;
  final double balanceOutstanding;
  final int overdueDays;

  const BuyerReceivableModel({
    required this.installmentId,
    required this.saleId,
    required this.buyerName,
    required this.projectId,
    required this.installmentNumber,
    required this.dueDate,
    required this.dueAmount,
    required this.paidAmount,
    required this.balanceOutstanding,
    required this.overdueDays,
  });

  String get agingBucket {
    if (overdueDays <= 0) return 'On Time';
    if (overdueDays <= 30) return '1-30 Days Due';
    if (overdueDays <= 60) return '31-60 Days Overdue';
    if (overdueDays <= 90) return '61-90 Days Overdue';
    return '90+ Days Overdue';
  }
}

class LandownerPayableModel {
  final String agreementId;
  final String landownerId;
  final String landownerName;
  final String projectId;
  final double agreedPurchasePrice;
  final double paidAmount;
  final double balanceOutstanding;
  final String status;

  const LandownerPayableModel({
    required this.agreementId,
    required this.landownerId,
    required this.landownerName,
    required this.projectId,
    required this.agreedPurchasePrice,
    required this.paidAmount,
    required this.balanceOutstanding,
    required this.status,
  });

  bool get isFullyPaid => balanceOutstanding <= 0;
}

class ProjectCashFlowModel {
  final String projectId;
  final String projectName;
  final double totalInflows;
  final double totalLandOutflows;
  final double totalExpenseOutflows;

  const ProjectCashFlowModel({
    required this.projectId,
    required this.projectName,
    required this.totalInflows,
    required this.totalLandOutflows,
    required this.totalExpenseOutflows,
  });

  double get totalOutflows => totalLandOutflows + totalExpenseOutflows;
  double get netCashFlow => totalInflows - totalOutflows;
}
