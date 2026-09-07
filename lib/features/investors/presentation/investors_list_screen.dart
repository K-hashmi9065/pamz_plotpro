import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import 'investors_providers.dart';
import 'widgets/investor_form_dialog.dart';
import 'widgets/investor_profile_dialog.dart';
import 'widgets/project_investment_dialog.dart';

final investorsSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final investorsDateRangeFilterProvider = StateProvider.autoDispose<DashboardDateRange>((ref) => DashboardDateRange.allTime);

class InvestorsListScreen extends ConsumerWidget {
  const InvestorsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(investorsSearchQueryProvider);
    final dateRangeFilter = ref.watch(investorsDateRangeFilterProvider);
    final currentRole = ref.watch(currentRoleProvider);

    // STRICT BUSINESS LOGIC ROLE BOUNDARY CHECK (PRD §5 / AC-09.1 - AC-09.4)
    if (!currentRole.isAdmin) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.dangerBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.dangerText),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 48, color: AppColors.dangerText),
              const SizedBox(height: 12),
              Text(
                'Access Denied',
                style: AppTypography.sectionTitle.copyWith(color: AppColors.dangerText),
              ),
              const SizedBox(height: 8),
              Text(
                'Investor data is strictly restricted to Admin users only.',
                style: AppTypography.body.copyWith(color: AppColors.dangerText),
              ),
            ],
          ),
        ),
      );
    }

    final investorsAsync = ref.watch(investorsListStreamProvider);
    final allInvestmentsAsync = ref.watch(allProjectInvestorsStreamProvider);
    final allInvestments = allInvestmentsAsync.value ?? [];
    final selectedProjectId = ref.watch(selectedProjectFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Investors & Project Ownership',
          subtitle:
              'Manage investor capital pool, project share capital, and ownership percentage allocation.',
          icon: Icons.pie_chart_outline,
          actions: [
            OutlinedButton.icon(
              onPressed: () => ProjectInvestmentDialog.show(context),
              icon: const Icon(Icons.add_card_outlined, size: 18),
              label: const Text('Allocate Capital'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => InvestorFormDialog.show(context),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Register Investor'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Filter Bar
        Row(
          children: [
            SizedBox(
              width: 320,
              height: 38,
              child: TextField(
                onChanged: (val) => ref.read(investorsSearchQueryProvider.notifier).state = val,
                decoration: const InputDecoration(
                  hintText: 'Search investor name, phone, PAN...',
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
                      ref.read(investorsDateRangeFilterProvider.notifier).state = val;
                    }
                  },
                  style: AppTypography.body.copyWith(fontSize: 13),
                ),
              ),
            ),
            if (selectedProjectId != null) ...[
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Filtered by Project ID: $selectedProjectId',
                  style: AppTypography.secondary.copyWith(
                    color: AppColors.infoText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),

        // Investors Data Table
        Expanded(
          child: investorsAsync.when(
            loading: () => const CustomDataTable(columns: [], rows: [], isLoading: true),
            error: (err, stack) => Center(
              child: Text(
                'Error loading investor profiles: $err',
                style: AppTypography.body.copyWith(color: AppColors.dangerText),
              ),
            ),
            data: (investorsList) {
              final filtered = investorsList.where((inv) {
                if (!isDateInFilterRange(inv.createdAt, dateRangeFilter)) {
                  return false;
                }
                if (searchQuery.isEmpty) return true;
                final q = searchQuery.toLowerCase();
                return inv.name.toLowerCase().contains(q) ||
                    inv.phone.toLowerCase().contains(q) ||
                    (inv.pan != null && inv.pan!.toLowerCase().contains(q));
              }).toList();

              return CustomDataTable(
                columns: const [
                  DataTableColumn(label: 'Investor Name'),
                  DataTableColumn(label: 'Phone Number', width: 150),
                  DataTableColumn(label: 'PAN Card', width: 140),
                  DataTableColumn(label: 'Registered Date', width: 150),
                  DataTableColumn(label: 'Actions', width: 120, alignment: Alignment.center),
                ],
                rows: filtered.map((investor) {
                  final formattedDate =
                      DateFormat('dd MMM yyyy').format(investor.createdAt);
                  final hasAgreement = allInvestments.any((pi) => pi.investorId == investor.id);

                  return [
                    Text(
                      investor.name,
                      style: AppTypography.tableCell.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      investor.phone,
                      style: AppTypography.tableCell,
                    ),
                    Text(
                      investor.pan ?? '—',
                      style: AppTypography.tableCell.copyWith(
                        color: investor.pan != null
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
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.accent, size: 20),
                        tooltip: 'Allocate Capital Investment',
                        onPressed: () => ProjectInvestmentDialog.show(
                          context,
                          preselectedInvestorId: investor.id,
                        ),
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
                            tooltip: 'Edit Investor Profile',
                            onPressed: () => InvestorFormDialog.show(
                              context,
                              investor: investor,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.folder_shared_outlined, color: AppColors.primary, size: 18),
                            tooltip: 'View Profile & Agreements',
                            onPressed: () => InvestorProfileDialog.show(
                              context,
                              investor,
                            ),
                          ),
                        ],
                      ),
                  ];
                }).toList(),
                emptyMessage: 'No investors match the filter.',
              );
            },
          ),
        ),
      ],
    );
  }
}
