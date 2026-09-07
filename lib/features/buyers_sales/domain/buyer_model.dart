class BuyerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? pan;
  final String? aadhar;
  final DateTime createdAt;

  const BuyerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.pan,
    this.aadhar,
    required this.createdAt,
  });
}
