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
  late final ValueNotifier<String> _actualUnitNotifier;
  late final ValueNotifier<double> _sqFtNotifier;
  late final ValueNotifier<double> _calculatedSqFtNotifier;
  late final ValueNotifier<bool> _dimensionModeNotifier;

  // Single Amount controller
  final _amountController = TextEditingController();

  // Actual Registered Area (Optional manual paper area) controller
  final _actualAreaController = TextEditingController();

  // Dimension (Length x Breadth in Ft & In) controllers & focus nodes
  final _lengthFtController = TextEditingController();
  final _lengthInController = TextEditingController();
  final _breadthFtController = TextEditingController();
  final _breadthInController = TextEditingController();

  final _lengthFtFocusNode = FocusNode();
  final _lengthInFocusNode = FocusNode();
  final _breadthFtFocusNode = FocusNode();
  final _breadthInFocusNode = FocusNode();

  static const String dimensionsUnit = LandMeasurementInputWidget.dimensionsUnit;

  static const List<String> _unitOptions = [
    dimensionsUnit,
    'Square Feet',
    'Kattha',
    'Dhur',
    'Decimal',
  ];

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
    _lengthFtFocusNode.addListener(_handleLengthFtFocusChange);
    _lengthInFocusNode.addListener(_handleLengthInFocusChange);
    _breadthFtFocusNode.addListener(_handleBreadthFtFocusChange);
    _breadthInFocusNode.addListener(_handleBreadthInFocusChange);

    final bool hasDimensions = widget.initialLengthFt != null && widget.initialLengthFt! > 0;
    String startUnit = 'Square Feet';
    bool startDimMode = false;

    if (isDimensionUnit(widget.initialUnit) ||
        (hasDimensions &&
            (widget.initialUnit == dimensionsUnit || widget.initialDisplayArea == null))) {
      startUnit = dimensionsUnit;
      startDimMode = true;
    } else {
      startUnit = _unitOptions.contains(widget.initialUnit)
          ? widget.initialUnit
          : (widget.initialUnit == 'Katta' ? 'Kattha' : 'Square Feet');
      startDimMode = false;
    }

    _unitNotifier = ValueNotifier<String>(startUnit);
    _actualUnitNotifier = ValueNotifier<String>(
        _unitOptions.contains(widget.initialUnit) && widget.initialUnit != dimensionsUnit
            ? widget.initialUnit
            : 'Kattha');
    _sqFtNotifier = ValueNotifier<double>(0.0);
    _calculatedSqFtNotifier = ValueNotifier<double>(0.0);
    _dimensionModeNotifier = ValueNotifier<bool>(startDimMode);

    double initialAmount = widget.initialDisplayArea ?? 0.0;
    if (initialAmount <= 0 && widget.initialAreaSqFt > 0 && !startDimMode) {
      initialAmount = LandUnitConverter.sqFtToUnitValue(widget.initialAreaSqFt, startUnit);
    }

    _amountController.text = initialAmount > 0
        ? (initialAmount == initialAmount.roundToDouble() ? initialAmount.toInt().toString() : initialAmount.toString())
        : '';

    if (widget.initialDisplayArea != null && widget.initialDisplayArea! > 0 && startDimMode) {
      _actualAreaController.text = widget.initialDisplayArea == widget.initialDisplayArea!.roundToDouble()
          ? widget.initialDisplayArea!.toInt().toString()
          : widget.initialDisplayArea!.toString();
    }

    if (widget.initialLengthFt != null && widget.initialLengthFt! > 0) {
      final totalL = widget.initialLengthFt! + ((widget.initialLengthIn ?? 0.0) / 12.0);
      final fi = LandUnitConverter.decimalFeetToFeetInches(totalL);
      _lengthFtController.text = fi.feet.toString();
      _lengthInController.text = fi.inches > 0
          ? (fi.inches == fi.inches.roundToDouble() ? fi.inches.toInt().toString() : fi.inches.toString())
          : '';
    }

    if (widget.initialBreadthFt != null && widget.initialBreadthFt! > 0) {
      final totalB = widget.initialBreadthFt! + ((widget.initialBreadthIn ?? 0.0) / 12.0);
      final fi = LandUnitConverter.decimalFeetToFeetInches(totalB);
      _breadthFtController.text = fi.feet.toString();
      _breadthInController.text = fi.inches > 0
          ? (fi.inches == fi.inches.roundToDouble() ? fi.inches.toInt().toString() : fi.inches.toString())
          : '';
    }

    _recalculate(notifyParent: false);
  }

  @override
  void dispose() {
    _lengthFtFocusNode.removeListener(_handleLengthFtFocusChange);
    _lengthInFocusNode.removeListener(_handleLengthInFocusChange);
    _breadthFtFocusNode.removeListener(_handleBreadthFtFocusChange);
    _breadthInFocusNode.removeListener(_handleBreadthInFocusChange);

    _lengthFtFocusNode.dispose();
    _lengthInFocusNode.dispose();
    _breadthFtFocusNode.dispose();
    _breadthInFocusNode.dispose();

    _unitNotifier.dispose();
    _actualUnitNotifier.dispose();
    _sqFtNotifier.dispose();
    _calculatedSqFtNotifier.dispose();
    _dimensionModeNotifier.dispose();
    _amountController.dispose();
    _actualAreaController.dispose();
    _lengthFtController.dispose();
    _lengthInController.dispose();
    _breadthFtController.dispose();
    _breadthInController.dispose();
    super.dispose();
  }

  void _handleLengthFtFocusChange() {
    if (!_lengthFtFocusNode.hasFocus) {
      _normalizeLength();
    }
  }

  void _handleLengthInFocusChange() {
    if (!_lengthInFocusNode.hasFocus) {
      _normalizeLength();
    }
  }

  void _handleBreadthFtFocusChange() {
    if (!_breadthFtFocusNode.hasFocus) {
      _normalizeBreadth();
    }
  }

  void _handleBreadthInFocusChange() {
    if (!_breadthInFocusNode.hasFocus) {
      _normalizeBreadth();
    }
  }

  /// Normalizes length (e.g. 405.5 ft -> 405 ft 6 in; 18 in -> 1 ft 6 in)
  void _normalizeLength() {
    final rawFt = _lengthFtController.text.trim();
    final rawIn = _lengthInController.text.trim();
    if (rawFt.isEmpty && rawIn.isEmpty) return;

    final lFt = double.tryParse(rawFt) ?? 0.0;
    final lIn = double.tryParse(rawIn) ?? 0.0;

    final totalDecimalFeet = lFt + (lIn / 12.0);
    if (totalDecimalFeet > 0) {
      final fi = LandUnitConverter.decimalFeetToFeetInches(totalDecimalFeet);
      _lengthFtController.text = fi.feet.toString();
      final inStr = fi.inches == fi.inches.roundToDouble()
          ? fi.inches.toInt().toString()
          : fi.inches.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      _lengthInController.text = inStr == '0' ? '' : inStr;
      _recalculate();
    }
  }

  /// Normalizes breadth (e.g. 30.5 ft -> 30 ft 6 in; 18 in -> 1 ft 6 in)
  void _normalizeBreadth() {
    final rawFt = _breadthFtController.text.trim();
    final rawIn = _breadthInController.text.trim();
    if (rawFt.isEmpty && rawIn.isEmpty) return;

    final bFt = double.tryParse(rawFt) ?? 0.0;
    final bIn = double.tryParse(rawIn) ?? 0.0;

    final totalDecimalFeet = bFt + (bIn / 12.0);
    if (totalDecimalFeet > 0) {
      final fi = LandUnitConverter.decimalFeetToFeetInches(totalDecimalFeet);
      _breadthFtController.text = fi.feet.toString();
      final inStr = fi.inches == fi.inches.roundToDouble()
          ? fi.inches.toInt().toString()
          : fi.inches.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      _breadthInController.text = inStr == '0' ? '' : inStr;
      _recalculate();
    }
  }

  void _recalculate({bool notifyParent = true}) {
    double sqFt = 0.0;
    double calculatedSqFt = 0.0;
    double? displayArea;

    final currentUnit = _safeUnit(_unitNotifier.value);
    final isDim = _dimensionModeNotifier.value || isDimensionUnit(currentUnit);

    if (isDim) {
      final lFt = double.tryParse(_lengthFtController.text.trim()) ?? 0.0;
      final lIn = double.tryParse(_lengthInController.text.trim()) ?? 0.0;
      final bFt = double.tryParse(_breadthFtController.text.trim()) ?? 0.0;
      final bIn = double.tryParse(_breadthInController.text.trim()) ?? 0.0;

      calculatedSqFt = LandUnitConverter.dimensionsToSqFt(
        lengthFt: lFt,
        lengthIn: lIn,
        breadthFt: bFt,
        breadthIn: bIn,
      );
      _calculatedSqFtNotifier.value = calculatedSqFt;

      final actualText = _actualAreaController.text.trim();
      final actualUnit = _actualUnitNotifier.value;
      final enteredActualVal = double.tryParse(actualText);

      if (enteredActualVal != null && enteredActualVal > 0) {
        displayArea = enteredActualVal;
        sqFt = LandUnitConverter.unitToSqFt(
          unit: actualUnit,
          displayArea: enteredActualVal,
        );
      } else {
        sqFt = calculatedSqFt;
        displayArea = null;
      }
    } else {
      final text = _amountController.text.trim();
      final parsed = double.tryParse(text);
      displayArea = (parsed != null && parsed > 0) ? parsed : null;
      sqFt = displayArea != null
          ? LandUnitConverter.unitToSqFt(
              unit: currentUnit,
              displayArea: displayArea,
            )
          : 0.0;
      _calculatedSqFtNotifier.value = 0.0;
    }

    _sqFtNotifier.value = sqFt;

    if (notifyParent) {
      final lFt = double.tryParse(_lengthFtController.text.trim());
      final lIn = double.tryParse(_lengthInController.text.trim());
      final bFt = double.tryParse(_breadthFtController.text.trim());
      final bIn = double.tryParse(_breadthInController.text.trim());

      final effectiveUnit = isDim
          ? (_actualAreaController.text.trim().isNotEmpty ? _actualUnitNotifier.value : dimensionsUnit)
          : currentUnit;

      widget.onAreaChanged?.call(sqFt);
      widget.onMeasurementDetailsChanged?.call(
        measurementUnit: effectiveUnit,
        areaSqFt: sqFt,
        displayArea: displayArea,
        kattaValue: null,
        dhurValue: null,
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
                                focusNode: _lengthFtFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Length (Feet) *',
                                  hintText: 'e.g. 50 or 405.5',
                                  suffixText: 'ft',
                                ),
                                onEditingComplete: () {
                                  _normalizeLength();
                                  _lengthInFocusNode.requestFocus();
                                },
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
                                focusNode: _lengthInFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Length (Inches)',
                                  hintText: '0 - 11',
                                  suffixText: 'in',
                                ),
                                onEditingComplete: () {
                                  _normalizeLength();
                                  _breadthFtFocusNode.requestFocus();
                                },
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
                                focusNode: _breadthFtFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Breadth / Width (Feet) *',
                                  hintText: 'e.g. 30 or 30.5',
                                  suffixText: 'ft',
                                ),
                                onEditingComplete: () {
                                  _normalizeBreadth();
                                  _breadthInFocusNode.requestFocus();
                                },
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
                                focusNode: _breadthInFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Breadth (Inches)',
                                  hintText: '0 - 11',
                                  suffixText: 'in',
                                ),
                                onEditingComplete: () {
                                  _normalizeBreadth();
                                  _breadthInFocusNode.unfocus();
                                },
                                onChanged: (_) => _recalculate(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Actual Registered Area (Optional) & Unit Dropdown
                        ValueListenableBuilder<String>(
                          valueListenable: _actualUnitNotifier,
                          builder: (context, actualUnit, _) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    controller: _actualAreaController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Actual Registered Area (Optional)',
                                      hintText: 'e.g. 10.5 or 12500',
                                      suffixText: actualUnit,
                                    ),
                                    onChanged: (_) => _recalculate(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonFormField<String>(
                                    initialValue: _unitOptions.contains(actualUnit) && actualUnit != dimensionsUnit
                                        ? actualUnit
                                        : 'Kattha',
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Area Unit',
                                    ),
                                    items: _unitOptions.where((u) => u != dimensionsUnit).map((unit) {
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
                                        _actualUnitNotifier.value = val;
                                        _recalculate();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ] else ...[
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
                            if (!isDimension) {
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
                ],

                if (widget.showBadgeSummary)
                  ValueListenableBuilder<double>(
                    valueListenable: _sqFtNotifier,
                    builder: (context, computedSqFt, _) {
                      return ValueListenableBuilder<double>(
                        valueListenable: _calculatedSqFtNotifier,
                        builder: (context, computedCalcSqFt, _) {
                          if (computedSqFt <= 0 && computedCalcSqFt <= 0) return const SizedBox.shrink();
                          final bool isActualEntered = _actualAreaController.text.trim().isNotEmpty;

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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (isDimension && computedCalcSqFt > 0) ...[
                                          Text(
                                            'Calculated Area (L × B): ${LandUnitConverter.formatAllUnits(computedCalcSqFt)}',
                                            style: AppTypography.secondary.copyWith(
                                              color: AppColors.accent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                        ],
                                        Text(
                                          isDimension
                                              ? (isActualEntered
                                                  ? 'Actual Registered Area: ${LandUnitConverter.formatLandMeasurement(
                                                      areaSqFt: computedSqFt,
                                                      measurementUnit: _actualUnitNotifier.value,
                                                      displayArea: double.tryParse(_actualAreaController.text.trim()),
                                                    )}  •  Equivalent: ${LandUnitConverter.formatAllUnits(computedSqFt)}'
                                                  : 'Actual Registered Area: NA')
                                              : 'Entered: ${LandUnitConverter.formatLandMeasurement(
                                                  areaSqFt: computedSqFt,
                                                  measurementUnit: activeUnit,
                                                  displayArea: double.tryParse(_amountController.text.trim()),
                                                )}  •  Equivalent: ${LandUnitConverter.formatAllUnits(computedSqFt)}',
                                          style: AppTypography.secondary.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
