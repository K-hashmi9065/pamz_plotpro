class LandownerModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final String? pan;
  final DateTime createdAt;

  const LandownerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.pan,
    required this.createdAt,
  });
}
