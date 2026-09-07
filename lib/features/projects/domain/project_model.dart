import '../../../core/constants/app_constants.dart';
import '../../../core/utils/land_unit_converter.dart';

class ProjectModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String location;
  final ProjectStatus status;
  final String? landownerId;
  final String? landownerName;
  final double landAreaSqFt;
  final String measurementUnit;
  final double? displayArea;
  final double? kattaValue;
  final double? dhurValue;
  final double? lengthFt;
  final double? lengthIn;
  final double? breadthFt;
  final double? breadthIn;
  final double purchasePrice;
  final double actualCost;
  final DateTime createdAt;

  const ProjectModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.location,
    required this.status,
    this.landownerId,
    this.landownerName,
    required this.landAreaSqFt,
    this.measurementUnit = 'Kattha',
    this.displayArea,
    this.kattaValue,
    this.dhurValue,
    this.lengthFt,
    this.lengthIn,
    this.breadthFt,
    this.breadthIn,
    required this.purchasePrice,
    required this.actualCost,
    required this.createdAt,
  });

  bool get isClosed => status == ProjectStatus.closed;
  bool get isCancelled => status == ProjectStatus.cancelled;

  String get formattedArea {
    return LandUnitConverter.formatLandMeasurement(
      areaSqFt: landAreaSqFt,
      measurementUnit: measurementUnit,
      displayArea: displayArea,
      kattaValue: kattaValue,
      dhurValue: dhurValue,
    );
  }

  ProjectModel copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    String? location,
    ProjectStatus? status,
    String? landownerId,
    String? landownerName,
    double? landAreaSqFt,
    String? measurementUnit,
    double? displayArea,
    double? kattaValue,
    double? dhurValue,
    double? lengthFt,
    double? lengthIn,
    double? breadthFt,
    double? breadthIn,
    double? purchasePrice,
    double? actualCost,
    DateTime? createdAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      status: status ?? this.status,
      landownerId: landownerId ?? this.landownerId,
      landownerName: landownerName ?? this.landownerName,
      landAreaSqFt: landAreaSqFt ?? this.landAreaSqFt,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      displayArea: displayArea ?? this.displayArea,
      kattaValue: kattaValue ?? this.kattaValue,
      dhurValue: dhurValue ?? this.dhurValue,
      lengthFt: lengthFt ?? this.lengthFt,
      lengthIn: lengthIn ?? this.lengthIn,
      breadthFt: breadthFt ?? this.breadthFt,
      breadthIn: breadthIn ?? this.breadthIn,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      actualCost: actualCost ?? this.actualCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
