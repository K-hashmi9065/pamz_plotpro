import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/land_unit_converter.dart';

typedef LandMeasurementDetailsCallback = void Function({
  required String measurementUnit,
  required double areaSqFt,
  double? displayArea,
  double? kattaValue,
  double? dhurValue,
  double? lengthFt,
  double? lengthIn,
  double? breadthFt,
  double? breadthIn,
});

class LandMeasurementInputWidget extends StatefulWidget {
  static const String dimensionsUnit = 'Dimensions (L × B in Ft & In)';

  final String initialUnit;
  final double? initialDisplayArea;
  final double? initialKattaValue;
  final double? initialDhurValue;
  final double initialAreaSqFt;
  final double? initialLengthFt;
  final double? initialLengthIn;
  final double? initialBreadthFt;
  final double? initialBreadthIn;
  final ValueChanged<double>? onAreaChanged;
  final LandMeasurementDetailsCallback? onMeasurementDetailsChanged;
  final String labelPrefix;
  final bool showBadgeSummary;

  const LandMeasurementInputWidget({
    super.key,
    this.initialUnit = dimensionsUnit,
    this.initialDisplayArea,
    this.initialKattaValue,
    this.initialDhurValue,
    this.initialAreaSqFt = 0.0,
    this.initialLengthFt,
    this.initialLengthIn,
    this.initialBreadthFt,
    this.initialBreadthIn,
    this.onAreaChanged,
    this.onMeasurementDetailsChanged,
    this.labelPrefix = 'Land Area',
    this.showBadgeSummary = true,
  });

  @override
  State<LandMeasurementInputWidget> createState() => _LandMeasurementInputWidgetState();
}

class _LandMeasurementInputWidgetState extends State<LandMeasurementInputWidget> {
  late final ValueNotifier<String> _unitNotifier;
  late final ValueNotifier<double> _sqFtNotifier;
  late final ValueNotifier<bool> _dimensionModeNotifier;

  // Single Amount controller
  final _amountController = TextEditingController();

  // Compound Kattha + Dhur controllers
  final _kattaController = TextEditingController();
  final _dhurController = TextEditingController();

  // Dimension (Length x Breadth in Ft & In) controllers
  final _lengthFtController = TextEditingController();
  final _lengthInController = TextEditingController();
  final _breadthFtController = TextEditingController();
  final _breadthInController = TextEditingController();

  static const String dimensionsUnit = LandMeasurementInputWidget.dimensionsUnit;

  static const List<String> _unitOptions = [
    dimensionsUnit,
    'Kattha',
    'Kattha + Dhur',
    'Square Feet',
    'Square Meter',
    'Acre',
    'Bigha',
    'Dhur',
    'Decimal',
  ];

  static bool isCompoundUnit(String unit) => unit == 'Kattha + Dhur' || unit == 'Katta + Dhur';
  static bool isDimensionUnit(String unit) =>
      unit == dimensionsUnit ||
      unit == 'Dimensions (L × B)' ||
      unit.startsWith('Dimensions') ||
      unit.contains('Ft & In');

  String _safeUnit(String unit) {
    if (_unitOptions.contains(unit)) {
      return unit;
    }
    if (isDimensionUnit(unit)) {
      return dimensionsUnit;
    }
    return dimensionsUnit;
  }

  @override
  void initState() {
    super.initState();
    final bool hasDimensions = widget.initialLengthFt != null && widget.initialLengthFt! > 0;
    String startUnit = 'Kattha';
    bool startDimMode = false;

    if (isDimensionUnit(widget.initialUnit) ||
        (hasDimensions &&
            (widget.initialUnit == dimensionsUnit ||
                (widget.initialDisplayArea == null && widget.initialKattaValue == null)))) {
      startUnit = dimensionsUnit;
      startDimMode = true;
    } else {
      startUnit = _unitOptions.contains(widget.initialUnit)
          ? widget.initialUnit
          : (widget.initialUnit == 'Katta'
              ? 'Kattha'
              : (widget.initialUnit == 'Katta + Dhur'
                  ? 'Kattha + Dhur'
                  : 'Kattha'));
      startDimMode = false;
    }

    _unitNotifier = ValueNotifier<String>(startUnit);
    _sqFtNotifier = ValueNotifier<double>(0.0);
    _dimensionModeNotifier = ValueNotifier<bool>(startDimMode);

    double initialAmount = widget.initialDisplayArea ?? 0.0;
    if (initialAmount <= 0 && widget.initialAreaSqFt > 0 && !isCompoundUnit(startUnit) && !startDimMode) {
      initialAmount = LandUnitConverter.sqFtToUnitValue(widget.initialAreaSqFt, startUnit);
    }

    _amountController.text = initialAmount > 0
        ? (initialAmount == initialAmount.roundToDouble() ? initialAmount.toInt().toString() : initialAmount.toString())
        : '';

    double? initialK = widget.initialKattaValue;
    double? initialD = widget.initialDhurValue;
    if (isCompoundUnit(startUnit) && (initialK == null || initialK <= 0) && widget.initialAreaSqFt > 0) {
      final kd = LandUnitConverter.sqFtToKattaDhur(widget.initialAreaSqFt);
      initialK = kd.katta.toDouble();
      initialD = kd.dhur;
    }

    _kattaController.text = initialK != null && initialK > 0
        ? (initialK == initialK.roundToDouble() ? initialK.toInt().toString() : initialK.toString())
        : '';

    _dhurController.text = initialD != null && initialD > 0
        ? (initialD == initialD.roundToDouble() ? initialD.toInt().toString() : initialD.toString())
        : '';

    if (widget.initialLengthFt != null && widget.initialLengthFt! > 0) {
      _lengthFtController.text = widget.initialLengthFt! == widget.initialLengthFt!.roundToDouble()
          ? widget.initialLengthFt!.toInt().toString()
          : widget.initialLengthFt!.toString();
    }
    if (widget.initialLengthIn != null) {
      _lengthInController.text = widget.initialLengthIn! == widget.initialLengthIn!.roundToDouble()
          ? widget.initialLengthIn!.toInt().toString()
          : widget.initialLengthIn!.toString();
    } else if (widget.initialLengthFt != null && widget.initialLengthFt! > 0) {
      _lengthInController.text = '0';
    }

    if (widget.initialBreadthFt != null && widget.initialBreadthFt! > 0) {
      _breadthFtController.text = widget.initialBreadthFt! == widget.initialBreadthFt!.roundToDouble()
          ? widget.initialBreadthFt!.toInt().toString()
          : widget.initialBreadthFt!.toString();
    }
    if (widget.initialBreadthIn != null) {
      _breadthInController.text = widget.initialBreadthIn! == widget.initialBreadthIn!.roundToDouble()
          ? widget.initialBreadthIn!.toInt().toString()
          : widget.initialBreadthIn!.toString();
    } else if (widget.initialBreadthFt != null && widget.initialBreadthFt! > 0) {
      _breadthInController.text = '0';
    }

    _recalculate(notifyParent: false);
  }

  @override
  void dispose() {
    _unitNotifier.dispose();
    _sqFtNotifier.dispose();
    _dimensionModeNotifier.dispose();
    _amountController.dispose();
    _kattaController.dispose();
    _dhurController.dispose();
    _lengthFtController.dispose();
    _lengthInController.dispose();
    _breadthFtController.dispose();
    _breadthInController.dispose();
    super.dispose();
  }

  void _recalculate({bool notifyParent = true}) {
    double sqFt = 0.0;
    double? displayArea;
    double? kattaVal;
    double? dhurVal;

    final currentUnit = _safeUnit(_unitNotifier.value);
    final isDim = _dimensionModeNotifier.value || isDimensionUnit(currentUnit);

    if (isDim) {
      final lFt = double.tryParse(_lengthFtController.text.trim()) ?? 0.0;
      final lIn = double.tryParse(_lengthInController.text.trim()) ?? 0.0;
      final bFt = double.tryParse(_breadthFtController.text.trim()) ?? 0.0;
      final bIn = double.tryParse(_breadthInController.text.trim()) ?? 0.0;

      sqFt = LandUnitConverter.dimensionsToSqFt(
        lengthFt: lFt,
        lengthIn: lIn,
        breadthFt: bFt,
        breadthIn: bIn,
      );

      if (sqFt > 0) {
        final kd = LandUnitConverter.sqFtToKattaDhur(sqFt);
        kattaVal = kd.katta.toDouble();
        dhurVal = kd.dhur;
        displayArea = LandUnitConverter.sqFtToUnitValue(sqFt, 'Kattha');
      }
    } else if (isCompoundUnit(currentUnit)) {
      kattaVal = double.tryParse(_kattaController.text.trim()) ?? 0.0;
      dhurVal = double.tryParse(_dhurController.text.trim()) ?? 0.0;
      sqFt = LandUnitConverter.kattaDhurToSqFt(kattaVal, dhurVal);
      displayArea = LandUnitConverter.sqFtToUnitValue(sqFt, 'Kattha');
    } else {
      displayArea = double.tryParse(_amountController.text.trim()) ?? 0.0;
      sqFt = LandUnitConverter.unitToSqFt(
        unit: currentUnit,
        displayArea: displayArea,
      );
      if (sqFt > 0) {
        final kd = LandUnitConverter.sqFtToKattaDhur(sqFt);
        kattaVal = kd.katta.toDouble();
        dhurVal = kd.dhur;
      }
    }

    _sqFtNotifier.value = sqFt;

    if (notifyParent) {
      final lFt = double.tryParse(_lengthFtController.text.trim());
      final lIn = double.tryParse(_lengthInController.text.trim());
      final bFt = double.tryParse(_breadthFtController.text.trim());
      final bIn = double.tryParse(_breadthInController.text.trim());

      widget.onAreaChanged?.call(sqFt);
      widget.onMeasurementDetailsChanged?.call(
        measurementUnit: isDim ? dimensionsUnit : currentUnit,
        areaSqFt: sqFt,
        displayArea: displayArea,
        kattaValue: kattaVal,
        dhurValue: dhurVal,
        lengthFt: isDim ? lFt : null,
        lengthIn: isDim ? (lIn ?? 0.0) : null,
        breadthFt: isDim ? bFt : null,
        breadthIn: isDim ? (bIn ?? 0.0) : null,
      );
    }
  }

  void _toggleDimensionMode(bool active) {
    _dimensionModeNotifier.value = active;
    _unitNotifier.value = active ? dimensionsUnit : 'Kattha';
    _recalculate();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _unitNotifier,
      builder: (context, selectedUnit, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _dimensionModeNotifier,
          builder: (context, isDimMode, _) {
            final activeUnit = _safeUnit(selectedUnit);
            final isDimension = isDimMode || isDimensionUnit(activeUnit);
            final isCompound = isCompoundUnit(activeUnit);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Header & Mode Toggle Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '${widget.labelPrefix} *',
                        style: AppTypography.secondary.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => _toggleDimensionMode(!isDimension),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDimension ? Icons.edit_note : Icons.straighten,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isDimension ? 'Direct Input' : 'L × B (Ft & In)',
                              style: AppTypography.secondary.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (isDimension) ...[
                  // Dimensions Mode Input Card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Dimensions (Ft & In)',
                                style: AppTypography.secondary.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 200,
                              height: 38,
                              child: DropdownButtonFormField<String>(
                                initialValue: activeUnit,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  labelText: 'Unit',
                                ),
                                items: _unitOptions.map((unit) {
                                  return DropdownMenuItem<String>(
                                    value: unit,
                                    child: Text(
                                      unit,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    _unitNotifier.value = val;
                                    _dimensionModeNotifier.value = isDimensionUnit(val);
                                    _recalculate();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Length Row (Feet & Inches)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _lengthFtController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Length (Feet) *',
                                  hintText: 'e.g. 50',
                                  suffixText: 'ft',
                                ),
                                onChanged: (_) => _recalculate(),
                                validator: (val) {
                                  if (isDimension) {
                                    final lFt = double.tryParse(_lengthFtController.text.trim()) ?? 0.0;
                                    final lIn = double.tryParse(_lengthInController.text.trim()) ?? 0.0;
                                    if (lFt <= 0 && lIn <= 0) return 'Length required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _lengthInController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Length (Inches)',
                                  hintText: '0 - 11',
                                  suffixText: 'in',
                                ),
                                onChanged: (_) => _recalculate(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Breadth Row (Feet & Inches)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: _breadthFtController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Breadth / Width (Feet) *',
                                  hintText: 'e.g. 30',
                                  suffixText: 'ft',
                                ),
                                onChanged: (_) => _recalculate(),
                                validator: (val) {
                                  if (isDimension) {
                                    final bFt = double.tryParse(_breadthFtController.text.trim()) ?? 0.0;
                                    final bIn = double.tryParse(_breadthInController.text.trim()) ?? 0.0;
                                    if (bFt <= 0 && bIn <= 0) return 'Breadth required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _breadthInController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Breadth (Inches)',
                                  hintText: '0 - 11',
                                  suffixText: 'in',
                                ),
                                onChanged: (_) => _recalculate(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else if (!isCompound) ...[
                  // Single Amount & Measurement Dropdown
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Amount *',
                            hintText: 'e.g. 5',
                            suffixText: activeUnit,
                          ),
                          onChanged: (_) => _recalculate(),
                          validator: (val) {
                            if (!isCompoundUnit(activeUnit) && !isDimension) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Amount is required';
                              }
                              final num = double.tryParse(val.trim());
                              if (num == null || num <= 0) {
                                return 'Amount must be > 0';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: activeUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Measurement *',
                          ),
                          items: _unitOptions.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(
                                unit,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _unitNotifier.value = val;
                              _dimensionModeNotifier.value = isDimensionUnit(val);
                              _recalculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Compound Kattha + Dhur Inputs & Measurement Dropdown
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _kattaController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Kattha *',
                            hintText: 'e.g. 1',
                            suffixText: 'Kattha',
                          ),
                          onChanged: (_) => _recalculate(),
                          validator: (val) {
                            if (isCompoundUnit(activeUnit) && !isDimension) {
                              final k = double.tryParse(_kattaController.text.trim()) ?? 0.0;
                              final d = double.tryParse(_dhurController.text.trim()) ?? 0.0;
                              if (k < 0) return 'Cannot be negative';
                              if (k == 0 && d == 0) return 'Enter Kattha or Dhur';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _dhurController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Dhur',
                            hintText: 'e.g. 2',
                            suffixText: 'Dhur',
                          ),
                          onChanged: (_) => _recalculate(),
                          validator: (val) {
                            if (isCompoundUnit(activeUnit) && !isDimension) {
                              final d = double.tryParse(_dhurController.text.trim()) ?? 0.0;
                              if (d < 0) return 'Cannot be negative';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<String>(
                          initialValue: activeUnit,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Measurement *',
                          ),
                          items: _unitOptions.map((unit) {
                            return DropdownMenuItem<String>(
                              value: unit,
                              child: Text(
                                unit,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _unitNotifier.value = val;
                              _dimensionModeNotifier.value = isDimensionUnit(val);
                              _recalculate();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                if (widget.showBadgeSummary)
                  ValueListenableBuilder<double>(
                    valueListenable: _sqFtNotifier,
                    builder: (context, computedSqFt, _) {
                      if (computedSqFt <= 0) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.square_foot, size: 18, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isDimension
                                      ? 'Auto-Calculated Area: ${LandUnitConverter.formatAllUnits(computedSqFt)}'
                                      : 'Entered: ${LandUnitConverter.formatLandMeasurement(
                                          areaSqFt: computedSqFt,
                                          measurementUnit: activeUnit,
                                          displayArea: double.tryParse(_amountController.text.trim()),
                                          kattaValue: double.tryParse(_kattaController.text.trim()),
                                          dhurValue: double.tryParse(_dhurController.text.trim()),
                                        )}  •  Equivalent: ${LandUnitConverter.formatAllUnits(computedSqFt)}',
                                  style: AppTypography.secondary.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
