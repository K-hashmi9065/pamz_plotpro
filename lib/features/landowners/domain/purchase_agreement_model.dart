class PurchaseAgreementModel {
  final String id;
  final String projectId;
  final String landownerId;
  final double totalPrice;
  final DateTime agreementDate;
  final String status;
  final DateTime createdAt;

  const PurchaseAgreementModel({
    required this.id,
    required this.projectId,
    required this.landownerId,
    required this.totalPrice,
    required this.agreementDate,
    required this.status,
    required this.createdAt,
  });
}
