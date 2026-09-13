import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/legal_disclaimers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/land_unit_converter.dart';
import '../../../../shared/widgets/searchable_buyer_dropdown.dart';
import '../../../../shared/widgets/searchable_project_dropdown.dart';
import '../../../plots/presentation/plots_providers.dart';
import '../../../plots/presentation/widgets/plot_subdivision_dialog.dart';
import '../../../projects/presentation/projects_providers.dart';
import '../../../projects/presentation/widgets/project_form_dialog.dart';
import '../sales_providers.dart';
import 'buyer_form_dialog.dart';
import 'buyer_sale_pdf_dialog.dart';

class SaleAgreementDialog extends ConsumerStatefulWidget {
  final String? preselectedProjectId;
  final String? preselectedBuyerId;

  const SaleAgreementDialog({
    super.key,
    this.preselectedProjectId,
    this.preselectedBuyerId,
  });

  static Future<void> show(
    BuildContext context, {
    String? preselectedProjectId,
    String? preselectedBuyerId,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SaleAgreementDialog(
        preselectedProjectId: preselectedProjectId,
        preselectedBuyerId: preselectedBuyerId,
      ),
    );
  }

  @override
  ConsumerState<SaleAgreementDialog> createState() =>
      _SaleAgreementDialogState();
}

class _SaleAgreementDialogState extends ConsumerState<SaleAgreementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _agreedPriceController = TextEditingController();
  final _expensesController = TextEditingController();
  final _circleRateController = TextEditingController();
  final _initialInstallmentController = TextEditingController();
  final _installmentsCountController = TextEditingController();

  late final ValueNotifier<String?> _selectedProjectIdNotifier;
  late final ValueNotifier<String?> _selectedBuyerIdNotifier;
  final ValueNotifier<SaleType> _selectedSaleTypeNotifier =
      ValueNotifier<SaleType>(SaleType.plotWise);
  final ValueNotifier<List<String>> _selectedPlotIdsNotifier =
      ValueNotifier<List<String>>([]);
  final DateTime _saleDate = DateTime.now();
  final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showCircleRateWarningNotifier =
      ValueNotifier<bool>(false);
  final ValueNotifier<String?> _errorMessageNotifier =
      ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _selectedProjectIdNotifier =
        ValueNotifier<String?>(widget.preselectedProjectId);
    _selectedBuyerIdNotifier =
        ValueNotifier<String?>(widget.preselectedBuyerId);
  }

  Future<void> _createNewProject() async {
    final newProject = await ProjectFormDialog.show(context);
    if (newProject != null && mounted) {
      _selectedProjectIdNotifier.value = newProject.id;
      _selectedPlotIdsNotifier.value = [];
    }
  }

  Future<void> _createNewBuyer() async {
    await BuyerFormDialog.show(context);
  }

  @override
  void dispose() {
    _agreedPriceController.dispose();
    _expensesController.dispose();
    _circleRateController.dispose();
    _initialInstallmentController.dispose();
    _installmentsCountController.dispose();
    _selectedProjectIdNotifier.dispose();
    _selectedBuyerIdNotifier.dispose();
    _selectedSaleTypeNotifier.dispose();
    _selectedPlotIdsNotifier.dispose();
    _isSavingNotifier.dispose();
    _showCircleRateWarningNotifier.dispose();
    _errorMessageNotifier.dispose();
    super.dispose();
  }

  void _checkCircleRate() {
    final agreed = double.tryParse(_agreedPriceController.text.trim()) ?? 0.0;
    final circle = double.tryParse(_circleRateController.text.trim()) ?? 0.0;
    _showCircleRateWarningNotifier.value =
        circle > 0 && agreed > 0 && agreed < circle;
  }

  String _formatSqFt(double sqFt, String unit) {
    if (sqFt <= 0) return '0 Sq Ft';
    if (unit.toLowerCase().contains('dimension')) {
      final sqFtStr = sqFt == sqFt.roundToDouble()
          ? sqFt.toInt().toString()
          : double.parse(sqFt.toStringAsFixed(2))
              .toString()
              .replaceAll(RegExp(r'\.0+$'), '');
      return '$sqFtStr Sq Ft';
    }
    if (unit.toLowerCase().contains('katta') ||
        unit.toLowerCase().contains('kattha')) {
      final totalKatta = LandUnitConverter.sqFtToKatta(sqFt);
      final kattaStr = totalKatta == totalKatta.roundToDouble()
          ? totalKatta.toInt().toString()
          : double.parse(totalKatta.toStringAsFixed(2))
              .toString()
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');
      return '$kattaStr Kattha';
    }
    return LandUnitConverter.formatLandMeasurement(
        areaSqFt: sqFt, measurementUnit: unit);
  }

  String _formatKatthaSub(double sqFt) {
    if (sqFt <= 0) return '0 Kattha';
    final totalKattha = LandUnitConverter.sqFtToKatta(sqFt);
    final katthaStr = totalKattha == totalKattha.roundToDouble()
        ? totalKattha.toInt().toString()
        : double.parse(totalKattha.toStringAsFixed(2))
            .toString()
            .replaceAll(RegExp(r'0+$'), '')
            .replaceAll(RegExp(r'\.$'), '');
    return '$katthaStr Kattha';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProjectIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a Project *';
      return;
    }
    if (_selectedBuyerIdNotifier.value == null) {
      _errorMessageNotifier.value = 'Please select a Buyer *';
      return;
    }

    _isSavingNotifier.value = true;
    _errorMessageNotifier.value = null;

    try {
      final repo = ref.read(salesRepositoryProvider);
      final price = double.parse(_agreedPriceController.text.trim());
      final expenses = double.tryParse(_expensesController.text.trim()) ?? 0.0;
      final circleRate = double.tryParse(_circleRateController.text.trim());
      final initialInstallment =
          double.tryParse(_initialInstallmentController.text.trim());
      final installmentsCount =
          int.tryParse(_installmentsCountController.text.trim());

      final projects = ref.read(projectsListStreamProvider).value ?? [];
      final buyers = ref.read(buyersListStreamProvider).value ?? [];

      final project = projects
          .firstWhere((p) => p.id == _selectedProjectIdNotifier.value);
      final buyer =
          buyers.firstWhere((b) => b.id == _selectedBuyerIdNotifier.value);

      final newSale = await repo.createSaleAgreement(
        projectId: _selectedProjectIdNotifier.value!,
        buyerId: _selectedBuyerIdNotifier.value!,
        saleType: _selectedSaleTypeNotifier.value,
        agreedPrice: price,
        saleExpenses: expenses,
        circleRateValue: circleRate,
        saleDate: _saleDate,
        plotIds: _selectedPlotIdsNotifier.value,
        initialInstallmentAmount: initialInstallment,
        installmentCount: installmentsCount,
        userId: 'active_user',
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sale agreement created! Opening PDF...'),
          ),
        );

        BuyerSalePdfDialog.show(
          context,
          sale: newSale,
          buyer: buyer,
          projectName: project.name,
          projectCode: project.code,
          projectLocation: project.location,
        );
      }
    } catch (e) {
      _errorMessageNotifier.value =
          e.toString().replaceAll('ArgumentError: ', '');
      _isSavingNotifier.value = false;
    }
  }

  Widget _buildLandAndPlotSection(
    String? selectedProjectId,
    SaleType selectedSaleType,
    List<String> selectedPlotIds,
  ) {
    if (selectedProjectId == null) return const SizedBox.shrink();

    final projects = ref.watch(projectsListStreamProvider).value ?? [];
    final project = projects.cast<dynamic>().firstWhere(
          (p) => p.id == selectedProjectId,
          orElse: () => null,
        );
    if (project == null) return const SizedBox.shrink();

    final plotsAsync =
        ref.watch(projectPlotsStreamProvider(selectedProjectId));

    return plotsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      ),
      error: (e, s) => Text('Error loading plots: $e'),
      data: (plots) {
        final double totalLandSqFt = project.landAreaSqFt;
        final double plottedSqFt =
            plots.fold(0.0, (sum, p) => sum + p.areaSqFt);
        final double remainingSqFt =
            (totalLandSqFt - plottedSqFt).clamp(0.0, double.infinity);
        final availablePlots = plots.where((p) => p.isAvailable).toList();

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceSubtle,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.landscape_outlined,
                          color: AppColors.accent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Project Land Breakdown & Plots',
                        style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                    ),
                    onPressed: () => PlotSubdivisionDialog.show(
                      context,
                      preselectedProjectId: selectedProjectId,
                    ),
                    icon: const Icon(Icons.add_location_alt, size: 14),
                    label: const Text('+ Create Plot',
                        style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Land Metrics Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _landMetric(
                        'Total Land',
                        _formatSqFt(totalLandSqFt, project.measurementUnit),
                        subtitle: _formatKatthaSub(totalLandSqFt),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    Expanded(
                      child: _landMetric(
                        'Plotted Land',
                        _formatSqFt(plottedSqFt, project.measurementUnit),
                        subtitle: _formatKatthaSub(plottedSqFt),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    Expanded(
                      child: _landMetric(
                        'Remaining Land',
                        _formatSqFt(remainingSqFt, project.measurementUnit),
                        subtitle: _formatKatthaSub(remainingSqFt),
                        color: remainingSqFt > 0
                            ? AppColors.successText
                            : AppColors.warningText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Available Plots Selection UI
              if (selectedSaleType == SaleType.plotWise) ...[
                if (availablePlots.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedPlotIds.isNotEmpty &&
                            availablePlots
                                .any((p) => p.id == selectedPlotIds.first)
                        ? selectedPlotIds.first
                        : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Available Plot *',
                    ),
                    items: availablePlots.map((plot) {
                      return DropdownMenuItem(
                        value: plot.id,
                        child: Text(
                          'Plot ${plot.plotNumber} - ${plot.formattedArea} (₹${plot.expectedPrice.round()})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      _selectedPlotIdsNotifier.value = val != null ? [val] : [];
                    },
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Please select a plot for sale'
                        : null,
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.warningText, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No available plots found in this project. (${_formatSqFt(remainingSqFt, project.measurementUnit)} remaining land available)',
                            style: AppTypography.secondary.copyWith(
                              color: AppColors.warningText,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          onPressed: () => PlotSubdivisionDialog.show(
                            context,
                            preselectedProjectId: selectedProjectId,
                          ),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Create New Plot',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else if (selectedSaleType == SaleType.multiplePlots ||
                  selectedSaleType == SaleType.mixed) ...[
                if (availablePlots.isNotEmpty) ...[
                  Text('Select Available Plots for Bulk Sale:',
                      style: AppTypography.secondary
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availablePlots.map((plot) {
                      final isSelected = selectedPlotIds.contains(plot.id);
                      return FilterChip(
                        selected: isSelected,
                        label: Text
                            ('Plot ${plot.plotNumber} (${plot.formattedArea})'),
                        onSelected: (selected) {
                          final currentList =
                              List<String>.from(_selectedPlotIdsNotifier.value);
                          if (selected) {
                            currentList.add(plot.id);
                          } else {
                            currentList.remove(plot.id);
                          }
                          _selectedPlotIdsNotifier.value = currentList;
                        },
                        selectedColor: AppColors.accent.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.accent,
                      );
                    }).toList(),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: AppColors.warningText, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No available plots found. (${_formatSqFt(remainingSqFt, project.measurementUnit)} remaining land available for subdivision)',
                            style: AppTypography.secondary.copyWith(
                              color: AppColors.warningText,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                          ),
                          onPressed: () => PlotSubdivisionDialog.show(
                            context,
                            preselectedProjectId: selectedProjectId,
                          ),
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Create Plot',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _landMetric(String label, String value, {String? subtitle, Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTypography.secondary.copyWith(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.body.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color ?? AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.secondary.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color != null
                  ? color.withValues(alpha: 0.85)
                  : AppColors.accent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListStreamProvider);
    final buyersAsync = ref.watch(buyersListStreamProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isSavingNotifier,
            builder: (context, isSaving, _) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('New Sale Agreement',
                            style: AppTypography.cardTitle),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 14),

                    ValueListenableBuilder<String?>(
                      valueListenable: _errorMessageNotifier,
                      builder: (context, errorMessage, _) {
                        if (errorMessage == null) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.dangerBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            errorMessage,
                            style: AppTypography.secondary.copyWith(
                              color: AppColors.dangerText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),

                    // Section 43CA / 50C Compliance Warning Banner
                    ValueListenableBuilder<bool>(
                      valueListenable: _showCircleRateWarningNotifier,
                      builder: (context, showWarning, _) {
                        if (!showWarning) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warningBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.warningText,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Section 43CA / 50C Tax Warning',
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.warningText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LegalDisclaimers.circleRateWarning43CA,
                                style: AppTypography.secondary.copyWith(
                                  color: AppColors.warningText,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Select Project *
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectedProjectIdNotifier,
                      builder: (context, selectedProjectId, _) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: projectsAsync.when(
                                  data: (projects) => SearchableProjectDropdown(
                                    projects: projects,
                                    selectedProjectId: selectedProjectId,
                                    labelText: 'Target Project *',
                                    onChanged: (val) {
                                      _selectedProjectIdNotifier.value = val;
                                      _selectedPlotIdsNotifier.value = [];
                                    },
                                    validator: (val) => val == null
                                        ? 'Project * is required'
                                        : null,
                                  ),
                                  loading: () => const LinearProgressIndicator(),
                                  error: (e, s) =>
                                      Text('Error loading projects: $e'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _createNewProject,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text(
                                  'New Project',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Dynamic Project Land Breakdown & Plots Section
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectedProjectIdNotifier,
                      builder: (context, selectedProjectId, _) {
                        return ValueListenableBuilder<SaleType>(
                          valueListenable: _selectedSaleTypeNotifier,
                          builder: (context, selectedSaleType, _) {
                            return ValueListenableBuilder<List<String>>(
                              valueListenable: _selectedPlotIdsNotifier,
                              builder: (context, selectedPlotIds, _) {
                                return _buildLandAndPlotSection(
                                  selectedProjectId,
                                  selectedSaleType,
                                  selectedPlotIds,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),

                    // Select Buyer *
                    ValueListenableBuilder<String?>(
                      valueListenable: _selectedBuyerIdNotifier,
                      builder: (context, selectedBuyerId, _) {
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: buyersAsync.when(
                                  data: (buyers) => SearchableBuyerDropdown(
                                    buyers: buyers,
                                    selectedBuyerId: selectedBuyerId,
                                    labelText: 'Select Customer *',
                                    onChanged: (val) =>
                                        _selectedBuyerIdNotifier.value = val,
                                    validator: (val) => val == null
                                        ? 'Customer * is required'
                                        : null,
                                  ),
                                  loading: () => const LinearProgressIndicator(),
                                  error: (e, s) =>
                                      Text('Error loading customers: $e'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: _createNewBuyer,
                                icon: const Icon(Icons.person_add, size: 18),
                                label: const Text(
                                  'New Customer',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Sale Type Dropdown *
                    ValueListenableBuilder<SaleType>(
                      valueListenable: _selectedSaleTypeNotifier,
                      builder: (context, selectedSaleType, _) {
                        return DropdownButtonFormField<SaleType>(
                          initialValue: selectedSaleType,
                          isExpanded: true,
                          decoration:
                              const InputDecoration(labelText: 'Sale Type *'),
                          items: const [
                            DropdownMenuItem(
                              value: SaleType.plotWise,
                              child: Text(
                                'PLOT_WISE (Single plot sale)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: SaleType.wholeLand,
                              child: Text(
                                'WHOLE_LAND (Entire parent land)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: SaleType.multiplePlots,
                              child: Text(
                                'MULTIPLE_PLOTS (Bulk plot bundle)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            DropdownMenuItem(
                              value: SaleType.mixed,
                              child: Text(
                                'MIXED (Individual + bulk parcel)',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              _selectedSaleTypeNotifier.value = val;
                              _selectedPlotIdsNotifier.value = [];
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    // Agreed Sale Price & DLC Circle Rate Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _agreedPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Agreed Sale Price (₹) *',
                              hintText: 'e.g. 3500000',
                            ),
                            onChanged: (_) => _checkCircleRate(),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Sale Price * is required';
                              }
                              if (double.tryParse(val.trim()) == null) {
                                return 'Enter valid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _circleRateController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'DLC / Circle Rate Value (Optional)',
                              hintText: 'e.g. 4000000',
                            ),
                            onChanged: (_) => _checkCircleRate(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Direct Sale Expenses (Optional)
                    TextFormField(
                      controller: _expensesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText:
                            'Direct Sale Expenses / Brokerage (Optional)',
                        hintText: 'e.g. 50000',
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Optional Installment Details Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _initialInstallmentController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Initial Down Payment (Optional)',
                              hintText: 'e.g. 500000',
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextFormField(
                            controller: _installmentsCountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Installments Count (Optional)',
                              hintText: 'e.g. 4',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.dangerText,
                            side: const BorderSide(color: AppColors.dangerBorder),
                          ),
                          onPressed: isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: isSaving ? null : _submit,
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Execute Agreement'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

