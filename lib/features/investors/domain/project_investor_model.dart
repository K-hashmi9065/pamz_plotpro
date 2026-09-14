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

class AggregatedProjectInvestorModel {
  final String investorId;
  final String investorName;
  final String projectId;
  final double totalInvestedAmount;
  final double totalOwnershipPercent;
  final List<ProjectInvestorModel> contributions;
  final DateTime firstInvestmentDate;
  final DateTime latestInvestmentDate;

  const AggregatedProjectInvestorModel({
    required this.investorId,
    required this.investorName,
    required this.projectId,
    required this.totalInvestedAmount,
    required this.totalOwnershipPercent,
    required this.contributions,
    required this.firstInvestmentDate,
    required this.latestInvestmentDate,
  });

  String get primaryId => contributions.isNotEmpty ? contributions.first.id : '';

  ProjectInvestorModel toPrimaryProjectInvestor() {
    return ProjectInvestorModel(
      id: primaryId,
      projectId: projectId,
      investorId: investorId,
      investorName: investorName,
      investedAmount: totalInvestedAmount,
      ownershipPercent: totalOwnershipPercent,
      ownershipMethod: contributions.isNotEmpty
          ? contributions.first.ownershipMethod
          : OwnershipMethod.capitalBased,
      createdAt: firstInvestmentDate,
    );
  }

  static List<AggregatedProjectInvestorModel> aggregateList(List<ProjectInvestorModel> list) {
    final Map<String, List<ProjectInvestorModel>> grouped = {};
    for (final item in list) {
      grouped.putIfAbsent(item.investorId, () => []).add(item);
    }

    return grouped.entries.map((entry) {
      final items = entry.value;
      items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final totalInvested = items.fold(0.0, (s, i) => s + i.investedAmount);
      final totalOwnership = items.fold(0.0, (s, i) => s + i.ownershipPercent);

      return AggregatedProjectInvestorModel(
        investorId: entry.key,
        investorName: items.first.investorName,
        projectId: items.first.projectId,
        totalInvestedAmount: totalInvested,
        totalOwnershipPercent: totalOwnership,
        contributions: items,
        firstInvestmentDate: items.first.createdAt,
        latestInvestmentDate: items.last.createdAt,
      );
    }).toList();
  }
}
