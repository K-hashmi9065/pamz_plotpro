import '../../../core/constants/app_constants.dart';

class TransactionModel {
  final String id;
  final String projectId;
  final String? installmentId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod paymentMethod;
  final String? referenceNumber;
  final String? receiptPath;
  final bool isVoided;
  final String? voidReason;
  final String createdBy;
  final DateTime createdAt;
  final String? buyerName;
  final String? projectName;

  const TransactionModel({
    required this.id,
    required this.projectId,
    this.installmentId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.referenceNumber,
    this.receiptPath,
    required this.isVoided,
    this.voidReason,
    required this.createdBy,
    required this.createdAt,
    this.buyerName,
    this.projectName,
  });

  bool get isCashOverLimit =>
      paymentMethod == PaymentMethod.cash &&
      amount >= AppConstants.cashTransactionLimit;
}
