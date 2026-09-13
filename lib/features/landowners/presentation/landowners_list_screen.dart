import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import 'landowners_providers.dart';
import '../domain/landowner_model.dart';
import 'widgets/landowner_form_dialog.dart';
import 'widgets/landowner_profile_dialog.dart';
import 'widgets/purchase_agreement_dialog.dart';

final landownersSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final landownersDateRangeFilterProvider = StateProvider.autoDispose<DashboardDateRange>((ref) => DashboardDateRange.allTime);

class LandownersListScreen extends ConsumerWidget {
  const LandownersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(landownersSearchQueryProvider);
    final dateRangeFilter = ref.watch(landownersDateRangeFilterProvider);

    final currentRole = ref.watch(currentRoleProvider);
    final landownersAsync = ref.watch(landownersListStreamProvider);
    final agreementsAsync = ref.watch(allPurchaseAgreementsStreamProvider);
    final agreementsList = agreementsAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Landowners & Purchase Agreements',
          subtitle:
              'Register seller profiles, survey/Khata land records, and purchase payment schedules.',
          icon: Icons.landscape_outlined,
          actions: [
            if (currentRole.isAdmin) ...[
              OutlinedButton.icon(
                onPressed: () => PurchaseAgreementDialog.show(context),
                icon: const Icon(Icons.note_add_outlined, size: 18),
                label: const Text('New Agreement'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => LandownerFormDialog.show(context),
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Add Landowner'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Filter Bar
        Row(
          children: [
            SizedBox(
              width: 340,
              height: 38,
              child: TextField(
                onChanged: (val) => ref.read(landownersSearchQueryProvider.notifier).state = val,
                decoration: const InputDecoration(
                  hintText: 'Search landowner name, phone, PAN...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: AppTypography.input.copyWith(fontSize: 13),
              ),
            ),
            const SizedBox(width: 16),
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DashboardDateRange>(
                  value: dateRangeFilter,
                  items: DashboardDateRange.values.map((range) {
                    return DropdownMenuItem<DashboardDateRange>(
                      value: range,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text(range.label, style: AppTypography.input.copyWith(fontSize: 13)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(landownersDateRangeFilterProvider.notifier).state = val;
                    }
                  },
                  style: AppTypography.body.copyWith(fontSize: 13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Landowners Data Table
        Expanded(
          child: landownersAsync.when(
            loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Center(
              child: Text(
                'Error loading landowners: $err',
                style: AppTypography.body.copyWith(color: AppColors.dangerText),
              ),
            ),
            data: (landownersList) {
              final filtered = landownersList.where((l) {
                if (!isDateInFilterRange(l.createdAt, dateRangeFilter)) {
                  return false;
                }
                if (searchQuery.isEmpty) return true;
                final q = searchQuery.toLowerCase();
                return l.name.toLowerCase().contains(q) ||
                    l.phone.toLowerCase().contains(q) ||
                    (l.pan != null && l.pan!.toLowerCase().contains(q));
              }).toList();

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Landowner Name'),
                  DataTableColumn(label: 'Phone Number', width: 160),
                  DataTableColumn(label: 'Email', width: 200),
                  DataTableColumn(label: 'PAN Card', width: 140),
                  DataTableColumn(label: 'Registered Date', width: 150),
                  DataTableColumn(label: 'Actions', width: 140, alignment: Alignment.center),
                ],
                rows: filtered.map((landowner) {
                  final formattedDate =
                      DateFormat('dd MMM yyyy').format(landowner.createdAt);
                  final hasAgreement = agreementsList.any((a) => a.landownerId == landowner.id);

                  return [
                    Text(
                      landowner.name,
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      landowner.phone,
                      style: AppTypography.tableCell,
                    ),
                    Text(
                      landowner.email ?? '—',
                      style: AppTypography.tableCell.copyWith(
                        color: landowner.email != null
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                    Text(
                      landowner.pan ?? '—',
                      style: AppTypography.tableCell.copyWith(
                        color: landowner.pan != null
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: AppTypography.secondary,
                    ),
                    if (!hasAgreement)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
                            tooltip: 'Edit Landowner Profile',
                            onPressed: () => LandownerFormDialog.show(context, landowner: landowner),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppColors.accent, size: 20),
                            tooltip: 'Create Purchase Agreement',
                            onPressed: () => PurchaseAgreementDialog.show(
                              context,
                              initialLandownerId: landowner.id,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.dangerText, size: 18),
                            tooltip: 'Delete Landowner Profile',
                            onPressed: () => _handleDeleteLandowner(context, ref, landowner),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
                            tooltip: 'Edit Landowner Profile',
                            onPressed: () => LandownerFormDialog.show(context, landowner: landowner),
                          ),
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 18),
                            tooltip: 'View Landowner Profile & Agreements',
                            onPressed: () => LandownerProfileDialog.show(context, landowner),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.dangerText, size: 18),
                            tooltip: 'Delete Landowner Profile',
                            onPressed: () => _handleDeleteLandowner(context, ref, landowner),
                          ),
                        ],
                      ),
                  ];
                }).toList(),
                emptyMessage: 'No landowners registered yet.',
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleDeleteLandowner(
    BuildContext context,
    WidgetRef ref,
    LandownerModel landowner,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever_outlined, color: AppColors.dangerText, size: 24),
            SizedBox(width: 8),
            Text(
              'Confirm Delete Landowner',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete landowner "${landowner.name}"?\n\n'
          'This action cannot be undone.',
          style: AppTypography.body,
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerText,
              side: const BorderSide(color: AppColors.dangerBorder),
            ),
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerText),
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: const Text('Delete Landowner'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final repo = ref.read(landownersRepositoryProvider);
        await repo.deleteLandowner(landowner.id, userId: 'admin_user', cascade: true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Landowner "${landowner.name}" deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final errorMsg = e.toString().replaceAll('StateError: ', '').replaceAll('ArgumentError: ', '');
          showDialog(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.block, color: AppColors.dangerText, size: 24),
                  SizedBox(width: 8),
                  Text('Cannot Delete Landowner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(errorMsg, style: AppTypography.body),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }
}
