import '../../../core/constants/app_constants.dart';

class ExpenseModel {
  final String id;
  final String projectId;
  final ExpenseCategory category;
  final double amount;
  final DateTime expenseDate;
  final String? vendor;
  final bool isCapitalized;
  final String? notes;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.projectId,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.vendor,
    required this.isCapitalized,
    this.notes,
    required this.createdAt,
  });

  ExpenseModel copyWith({
    String? id,
    String? projectId,
    ExpenseCategory? category,
    double? amount,
    DateTime? expenseDate,
    String? vendor,
    bool? isCapitalized,
    String? notes,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      vendor: vendor ?? this.vendor,
      isCapitalized: isCapitalized ?? this.isCapitalized,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String? get vendorName => vendor;
}
