import '../../../core/constants/app_constants.dart';

class ProjectInvestorModel {
  final String id;
  final String projectId;
  final String investorId;
  final String investorName;
  final double investedAmount;
  final double ownershipPercent;
  final OwnershipMethod ownershipMethod;
  final DateTime createdAt;

  const ProjectInvestorModel({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.investorName,
    required this.investedAmount,
    required this.ownershipPercent,
    required this.ownershipMethod,
    required this.createdAt,
  });

  ProjectInvestorModel copyWith({
    String? id,
    String? projectId,
    String? investorId,
    String? investorName,
    double? investedAmount,
    double? ownershipPercent,
    OwnershipMethod? ownershipMethod,
    DateTime? createdAt,
  }) {
    return ProjectInvestorModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      investorId: investorId ?? this.investorId,
      investorName: investorName ?? this.investorName,
      investedAmount: investedAmount ?? this.investedAmount,
      ownershipPercent: ownershipPercent ?? this.ownershipPercent,
      ownershipMethod: ownershipMethod ?? this.ownershipMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
