import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/land_unit_converter.dart';
import '../../../../core/widgets/land_measurement_input_widget.dart';

class LandCalculatorDialog extends StatefulWidget {
  const LandCalculatorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LandCalculatorDialog(),
    );
  }

  @override
  State<LandCalculatorDialog> createState() => _LandCalculatorDialogState();
}

class _LandCalculatorDialogState extends State<LandCalculatorDialog> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Converter state
  final ValueNotifier<double> _convertedSqFtNotifier = ValueNotifier<double>(0.0);

  // Road Calculator state
  final _roadLengthFtController = TextEditingController();
  final _roadLengthInController = TextEditingController();
  final _roadBreadthFtController = TextEditingController();
  final _roadBreadthInController = TextEditingController();

  final _roadLengthFtFocusNode = FocusNode();
  final _roadLengthInFocusNode = FocusNode();
  final _roadBreadthFtFocusNode = FocusNode();
  final _roadBreadthInFocusNode = FocusNode();

  final ValueNotifier<double> _roadAreaSqFtNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _roadLengthFtFocusNode.addListener(() {
      if (!_roadLengthFtFocusNode.hasFocus) _normalizeRoadLength();
    });
    _roadLengthInFocusNode.addListener(() {
      if (!_roadLengthInFocusNode.hasFocus) _normalizeRoadLength();
    });
    _roadBreadthFtFocusNode.addListener(() {
      if (!_roadBreadthFtFocusNode.hasFocus) _normalizeRoadBreadth();
    });
    _roadBreadthInFocusNode.addListener(() {
      if (!_roadBreadthInFocusNode.hasFocus) _normalizeRoadBreadth();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _roadLengthFtFocusNode.dispose();
    _roadLengthInFocusNode.dispose();
    _roadBreadthFtFocusNode.dispose();
    _roadBreadthInFocusNode.dispose();
    _roadLengthFtController.dispose();
    _roadLengthInController.dispose();
    _roadBreadthFtController.dispose();
    _roadBreadthInController.dispose();
    _convertedSqFtNotifier.dispose();
    _roadAreaSqFtNotifier.dispose();
    super.dispose();
  }

  void _normalizeRoadLength() {
    final rawFt = _roadLengthFtController.text.trim();
    final rawIn = _roadLengthInController.text.trim();
    if (rawFt.isEmpty && rawIn.isEmpty) return;

    final lFt = double.tryParse(rawFt) ?? 0.0;
    final lIn = double.tryParse(rawIn) ?? 0.0;
    final totalDecimalFeet = lFt + (lIn / 12.0);
    if (totalDecimalFeet > 0) {
      final fi = LandUnitConverter.decimalFeetToFeetInches(totalDecimalFeet);
      _roadLengthFtController.text = fi.feet.toString();
      final inStr = fi.inches == fi.inches.roundToDouble()
          ? fi.inches.toInt().toString()
          : fi.inches.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      _roadLengthInController.text = inStr == '0' ? '' : inStr;
      _calculateRoadArea();
    }
  }

  void _normalizeRoadBreadth() {
    final rawFt = _roadBreadthFtController.text.trim();
    final rawIn = _roadBreadthInController.text.trim();
    if (rawFt.isEmpty && rawIn.isEmpty) return;

    final bFt = double.tryParse(rawFt) ?? 0.0;
    final bIn = double.tryParse(rawIn) ?? 0.0;
    final totalDecimalFeet = bFt + (bIn / 12.0);
    if (totalDecimalFeet > 0) {
      final fi = LandUnitConverter.decimalFeetToFeetInches(totalDecimalFeet);
      _roadBreadthFtController.text = fi.feet.toString();
      final inStr = fi.inches == fi.inches.roundToDouble()
          ? fi.inches.toInt().toString()
          : fi.inches.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '');
      _roadBreadthInController.text = inStr == '0' ? '' : inStr;
      _calculateRoadArea();
    }
  }

  void _calculateRoadArea() {
    final lFt = double.tryParse(_roadLengthFtController.text.trim()) ?? 0.0;
    final lIn = double.tryParse(_roadLengthInController.text.trim()) ?? 0.0;
    final bFt = double.tryParse(_roadBreadthFtController.text.trim()) ?? 0.0;
    final bIn = double.tryParse(_roadBreadthInController.text.trim()) ?? 0.0;

    _roadAreaSqFtNotifier.value = LandUnitConverter.calculateRoadAreaSqFt(
      lengthFt: lFt,
      lengthIn: lIn,
      breadthFt: bFt,
      breadthIn: bIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 580,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.straighten, color: AppColors.accent, size: 22),
                    const SizedBox(width: 8),
                    Text('Land Measuring & Road Calculator', style: AppTypography.cardTitle),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 12),

            Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(3),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accent,
                indicatorWeight: 2.5,
                labelColor: AppColors.accent,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                unselectedLabelStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.calculate_outlined, size: 18), text: 'Unit Converter'),
                  Tab(icon: Icon(Icons.add_road, size: 18), text: 'Road Area (L × B)'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Unit Converter
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LandMeasurementInputWidget(
                          labelPrefix: 'Input Land',
                          onAreaChanged: (sqFt) {
                            _convertedSqFtNotifier.value = sqFt;
                          },
                        ),
                        const SizedBox(height: 20),
                        ValueListenableBuilder<double>(
                          valueListenable: _convertedSqFtNotifier,
                          builder: (context, convertedSqFt, _) {
                            return _buildConversionResultsCard(convertedSqFt);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Tab 2: Road Calculator (Length x Breadth)
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Road Corridor Dimensions (Length × Breadth)',
                          style: AppTypography.secondary.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _roadLengthFtController,
                                focusNode: _roadLengthFtFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Road Length (Feet)',
                                  hintText: 'e.g. 100 or 405.5',
                                  suffixText: 'ft',
                                ),
                                onEditingComplete: () {
                                  _normalizeRoadLength();
                                  _roadLengthInFocusNode.requestFocus();
                                },
                                onChanged: (_) => _calculateRoadArea(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _roadLengthInController,
                                focusNode: _roadLengthInFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Length (Inches)',
                                  hintText: '0 - 11',
                                  suffixText: 'in',
                                ),
                                onEditingComplete: () {
                                  _normalizeRoadLength();
                                  _roadBreadthFtFocusNode.requestFocus();
                                },
                                onChanged: (_) => _calculateRoadArea(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _roadBreadthFtController,
                                focusNode: _roadBreadthFtFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Road Breadth / Width (Feet)',
                                  hintText: 'e.g. 15 or 15.5',
                                  suffixText: 'ft',
                                ),
                                onEditingComplete: () {
                                  _normalizeRoadBreadth();
                                  _roadBreadthInFocusNode.requestFocus();
                                },
                                onChanged: (_) => _calculateRoadArea(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                controller: _roadBreadthInController,
                                focusNode: _roadBreadthInFocusNode,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Breadth (Inches)',
                                  hintText: '0 - 11',
                                  suffixText: 'in',
                                ),
                                onEditingComplete: () {
                                  _normalizeRoadBreadth();
                                  _roadBreadthInFocusNode.unfocus();
                                },
                                onChanged: (_) => _calculateRoadArea(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ValueListenableBuilder<double>(
                          valueListenable: _roadAreaSqFtNotifier,
                          builder: (context, roadAreaSqFt, _) {
                            return _buildConversionResultsCard(roadAreaSqFt, title: 'Calculated Road Access Area');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionResultsCard(double sqFt, {String title = 'Converted Area Breakdown'}) {
    final dec = LandUnitConverter.sqFtToDecimal(sqFt);
    final bigha = LandUnitConverter.sqFtToBigha(sqFt);
    final sqM = (sqFt / LandUnitConverter.sqFtPerSqMeter).toStringAsFixed(1);

    final totalKatta = LandUnitConverter.sqFtToKatta(sqFt);
    final totalKattaStr = totalKatta == totalKatta.roundToDouble()
        ? totalKatta.toInt().toString()
        : double.parse(totalKatta.toStringAsFixed(3)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

    final totalDhur = LandUnitConverter.sqFtToDhur(sqFt);
    final totalDhurStr = totalDhur == totalDhur.roundToDouble()
        ? totalDhur.toInt().toString()
        : double.parse(totalDhur.toStringAsFixed(2)).toString().replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.cardTitle.copyWith(fontSize: 14, color: AppColors.accent),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildResultTile('Square Feet', '${sqFt.toStringAsFixed(1)} sq.ft'),
              ),
              Expanded(
                child: _buildResultTile('Kattha', '$totalKattaStr Kattha'),
              ),
              Expanded(
                child: _buildResultTile('Dhur', '$totalDhurStr Dhur'),
              ),
              Expanded(
                child: _buildResultTile('Decimal', '$dec Dec'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildResultTile('Decimal', '$dec Dec'),
              ),
              Expanded(
                child: _buildResultTile('Bigha', '$bigha Bigha'),
              ),
              Expanded(
                child: _buildResultTile('Sq. Meters', '$sqM m²'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.secondary.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.body.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
