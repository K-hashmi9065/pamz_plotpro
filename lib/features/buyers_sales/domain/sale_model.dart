import '../../../core/constants/app_constants.dart';

class SaleModel {
  final String id;
  final String projectId;
  final String buyerId;
  final String buyerName;
  final SaleType saleType;
  final double agreedPrice;
  final double saleExpenses;
  final double? circleRateValue;
  final DateTime saleDate;
  final String status;
  final DateTime createdAt;

  const SaleModel({
    required this.id,
    required this.projectId,
    required this.buyerId,
    required this.buyerName,
    required this.saleType,
    required this.agreedPrice,
    required this.saleExpenses,
    this.circleRateValue,
    required this.saleDate,
    required this.status,
    required this.createdAt,
  });

  bool get isBelowCircleRate =>
      circleRateValue != null && agreedPrice < circleRateValue!;
}
