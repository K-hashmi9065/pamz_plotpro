import '../../../core/constants/app_constants.dart';

class InstallmentModel {
  final String id;
  final String? projectId;
  final String? saleId;
  final String? purchaseAgreementId;
  final int installmentNumber;
  final DateTime dueDate;
  final double dueAmount;
  final double paidAmount;
  final InstallmentStatus status;
  final DateTime createdAt;
  final String? buyerName;
  final String? projectName;
  final String? plotInfo;

  const InstallmentModel({
    required this.id,
    this.projectId,
    this.saleId,
    this.purchaseAgreementId,
    required this.installmentNumber,
    required this.dueDate,
    required this.dueAmount,
    required this.paidAmount,
    required this.status,
    required this.createdAt,
    this.buyerName,
    this.projectName,
    this.plotInfo,
  });

  double get balanceRemaining => (dueAmount - paidAmount) < 0 ? 0.0 : (dueAmount - paidAmount);
  double get remainingAmount => balanceRemaining;
  bool get isFullyPaid => paidAmount >= dueAmount;
}
