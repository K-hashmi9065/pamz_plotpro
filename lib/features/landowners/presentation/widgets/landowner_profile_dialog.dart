import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/calculation_engine.dart';
import '../../../../shared/widgets/page/custom_data_table.dart';
import '../../domain/landowner_model.dart';
import '../landowners_providers.dart';
import 'agreement_pdf_dialog.dart';

class LandownerProfileDialog extends ConsumerWidget {
  final LandownerModel landowner;

  const LandownerProfileDialog({
    super.key,
    required this.landowner,
  });

  static Future<void> show(BuildContext context, LandownerModel landowner) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => LandownerProfileDialog(landowner: landowner),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(landownerProjectsStreamProvider(landowner.id));
    final formattedDate = DateFormat('dd MMM yyyy').format(landowner.createdAt);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.border),
      ),
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Container(
        width: 720,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.real_estate_agent_outlined, color: AppColors.accent, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Landowner Profile: ${landowner.name}',
                      style: AppTypography.cardTitle,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone Number', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(landowner.phone, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text('Email Address', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(landowner.email ?? '—', style: AppTypography.body),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PAN Card', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(landowner.pan ?? '—', style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text('Address', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(landowner.address ?? '—', style: AppTypography.body),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Registered Date', style: AppTypography.secondary),
                        const SizedBox(height: 2),
                        Text(formattedDate, style: AppTypography.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Associated Projects (Multi-Project Landowner)',
              style: AppTypography.sectionTitle.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 10),

            // Projects Table
            SizedBox(
              height: 220,
              child: projectsAsync.when(
                loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading landowner projects: $err',
                    style: AppTypography.body.copyWith(color: AppColors.dangerText),
                  ),
                ),
                data: (projectsList) {
                  return CustomDataTable(
                    columns: const [
                      DataTableColumn(label: 'Code', width: 90),
                      DataTableColumn(label: 'Project Name'),
                      DataTableColumn(label: 'Location', width: 160),
                      DataTableColumn(label: 'Purchase Price', width: 150),
                      DataTableColumn(label: 'Status', width: 110),
                      DataTableColumn(label: 'Agreement PDF', width: 120, alignment: Alignment.center),
                    ],
                    rows: projectsList.map((prj) {
                      return [
                        Text(
                          prj.code,
                          style: AppTypography.tableCell.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                        Text(
                          prj.name,
                          style: AppTypography.tableCell.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          prj.location,
                          style: AppTypography.tableCell,
                        ),
                        Text(
                          CalculationEngine.formatCurrency(prj.purchasePrice),
                          style: AppTypography.amountMedium.copyWith(fontSize: 13),
                        ),
                        Text(
                          prj.status.name.toUpperCase(),
                          style: AppTypography.secondary.copyWith(fontSize: 12),
                        ),
                        IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: AppColors.accent, size: 18),
                          tooltip: 'Export / Share Agreement PDF',
                          onPressed: () {
                            AgreementPdfDialog.show(
                              context,
                              landownerName: landowner.name,
                              landownerPhone: landowner.phone,
                              landownerPan: landowner.pan,
                              landownerEmail: landowner.email,
                              landownerAddress: landowner.address,
                              projectName: prj.name,
                              projectCode: prj.code,
                              projectLocation: prj.location,
                              landAreaSqFt: prj.landAreaSqFt,
                              totalPrice: prj.purchasePrice,
                              installmentCount: 5,
                              agreementDate: prj.createdAt,
                            );
                          },
                        ),
                      ];
                    }).toList(),
                    emptyMessage: 'No projects currently associated with this landowner.',
                  );
                },
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
}
