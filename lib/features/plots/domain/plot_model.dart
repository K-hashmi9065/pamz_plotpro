import '../../../core/constants/app_constants.dart';
import '../../../core/utils/land_unit_converter.dart';

class PlotModel {
  final String id;
  final String projectId;
  final String plotNumber;
  final double areaSqFt;
  final String measurementUnit;
  final double? displayArea;
  final double? kattaValue;
  final double? dhurValue;
  final double? lengthFt;
  final double? lengthIn;
  final double? breadthFt;
  final double? breadthIn;
  final double allocatedCost;
  final double expectedPrice;
  final PlotStatus status;
  final String? brokerName;
  final String? brokerPhone;
  final double brokerageCharge;
  final DateTime createdAt;

  const PlotModel({
    required this.id,
    required this.projectId,
    required this.plotNumber,
    required this.areaSqFt,
    this.measurementUnit = 'Kattha',
    this.displayArea,
    this.kattaValue,
    this.dhurValue,
    this.lengthFt,
    this.lengthIn,
    this.breadthFt,
    this.breadthIn,
    required this.allocatedCost,
    required this.expectedPrice,
    required this.status,
    this.brokerName,
    this.brokerPhone,
    this.brokerageCharge = 0.0,
    required this.createdAt,
  });

  bool get isRoad =>
      plotNumber.toLowerCase().contains('road') ||
      plotNumber.toLowerCase().contains('access road') ||
      plotNumber.toLowerCase().startsWith('road');

  bool get isAvailable => !isRoad && status == PlotStatus.available;
  bool get isSold => !isRoad && status == PlotStatus.sold;
  bool get hasBrokerage =>
      (brokerName != null && brokerName!.trim().isNotEmpty) ||
      (brokerPhone != null && brokerPhone!.trim().isNotEmpty) ||
      brokerageCharge > 0;

  String get formattedLength {
    final ft = lengthFt ?? 0.0;
    final inch = lengthIn ?? 0.0;
    if (ft == 0 && inch == 0) return '—';
    final ftStr = ft == ft.roundToDouble()
        ? ft.toInt().toString()
        : ft.toString();
    final inStr = inch == inch.roundToDouble()
        ? inch.toInt().toString()
        : inch.toString();
    if (inch == 0) return '$ftStr ft';
    return '$ftStr ft $inStr in';
  }

  String get formattedBreadth {
    final ft = breadthFt ?? 0.0;
    final inch = breadthIn ?? 0.0;
    if (ft == 0 && inch == 0) return '—';
    final ftStr = ft == ft.roundToDouble()
        ? ft.toInt().toString()
        : ft.toString();
    final inStr = inch == inch.roundToDouble()
        ? inch.toInt().toString()
        : inch.toString();
    if (inch == 0) return '$ftStr ft';
    return '$ftStr ft $inStr in';
  }

  String get formattedArea {
    return LandUnitConverter.formatLandMeasurement(
      areaSqFt: areaSqFt,
      measurementUnit: measurementUnit,
      displayArea: displayArea,
      kattaValue: kattaValue,
      dhurValue: dhurValue,
    );
  }

  PlotModel copyWith({
    String? id,
    String? projectId,
    String? plotNumber,
    double? areaSqFt,
    String? measurementUnit,
    double? displayArea,
    double? kattaValue,
    double? dhurValue,
    double? lengthFt,
    double? lengthIn,
    double? breadthFt,
    double? breadthIn,
    double? allocatedCost,
    double? expectedPrice,
    PlotStatus? status,
    String? brokerName,
    String? brokerPhone,
    double? brokerageCharge,
    DateTime? createdAt,
  }) {
    return PlotModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      plotNumber: plotNumber ?? this.plotNumber,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      displayArea: displayArea ?? this.displayArea,
      kattaValue: kattaValue ?? this.kattaValue,
      dhurValue: dhurValue ?? this.dhurValue,
      lengthFt: lengthFt ?? this.lengthFt,
      lengthIn: lengthIn ?? this.lengthIn,
      breadthFt: breadthFt ?? this.breadthFt,
      breadthIn: breadthIn ?? this.breadthIn,
      allocatedCost: allocatedCost ?? this.allocatedCost,
      expectedPrice: expectedPrice ?? this.expectedPrice,
      status: status ?? this.status,
      brokerName: brokerName ?? this.brokerName,
      brokerPhone: brokerPhone ?? this.brokerPhone,
      brokerageCharge: brokerageCharge ?? this.brokerageCharge,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
