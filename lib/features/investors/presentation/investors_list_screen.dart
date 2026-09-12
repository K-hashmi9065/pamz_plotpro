import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../core/utils/date_filter_utils.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../audit_log/presentation/audit_log_screen.dart';
import '../../dashboard/presentation/dashboard_providers.dart';
import '../../profit_loss_settlement/domain/profit_loss_models.dart';
import '../../profit_loss_settlement/presentation/profit_loss_providers.dart';
import '../../profit_loss_settlement/presentation/widgets/payout_disbursement_dialog.dart';
import '../../projects/presentation/projects_providers.dart';
import '../domain/investor_model.dart';
import '../domain/project_investor_model.dart';
import 'investors_providers.dart';
import 'widgets/investor_agreement_pdf_dialog.dart';
import 'widgets/investor_form_dialog.dart';
import 'widgets/investor_profile_dialog.dart';
import 'widgets/investor_withdrawal_selection_dialog.dart';
import 'widgets/project_investment_dialog.dart';

final investorsSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final investorsDateRangeFilterProvider = StateProvider.autoDispose<DashboardDateRange>((ref) => DashboardDateRange.allTime);

class InvestorsListScreen extends ConsumerWidget {
  const InvestorsListScreen({super.key});

  void _openInvestorWithdrawal(
    BuildContext context,
    WidgetRef ref,
    List<ProjectInvestorModel> allInvestments, {
    InvestorModel? preselectedInvestor,
  }) {
    final relevantInvestments = preselectedInvestor != null
        ? allInvestments.where((pi) => pi.investorId == preselectedInvestor.id).toList()
        : allInvestments;

    if (relevantInvestments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            preselectedInvestor != null
                ? 'No capital agreements found for ${preselectedInvestor.name}.'
                : 'No active investor project agreements found. Please create an agreement first.',
          ),
        ),
      );
      return;
    }

    final investors = ref.read(investorsListStreamProvider).value ?? [];
    final projects = ref.read(projectsListStreamProvider).value ?? [];
    final auditLogs = ref.read(auditLogsStreamProvider).value ?? [];
    final plList = ref.read(projectProfitLossStreamProvider).value ?? [];

    InvestorPayoutModel buildPayoutModel(ProjectInvestorModel pi) {
      final inv = investors.where((i) => i.id == pi.investorId).firstOrNull;
      final logs = auditLogs.where(
        (log) => log.action == 'DISBURSE_INVESTOR_PAYOUT' && log.entityId == pi.id,
      );
      double totalDisbursed = 0.0;
      for (final log in logs) {
        final parts = log.details.split('₹');
        if (parts.length > 1) {
          final amtStr = parts[1].split(' ')[0].replaceAll(',', '');
          totalDisbursed += double.tryParse(amtStr) ?? 0.0;
        }
      }
      final pl = plList.where((p) => p.projectId == pi.projectId).firstOrNull;
      final profitPool = pl?.distributableProfit ?? 0.0;

      return InvestorPayoutModel(
        id: pi.id,
        investorId: pi.investorId,
        investorName: inv?.name ?? 'Investor',
        projectId: pi.projectId,
        capitalInvested: pi.investedAmount,
        ownershipPercent: pi.ownershipPercent,
        distributableProfitPool: profitPool,
        payoutsDisbursed: totalDisbursed,
      );
    }

    if (relevantInvestments.length == 1) {
      final payout = buildPayoutModel(relevantInvestments.first);
      PayoutDisbursementDialog.show(context, payout: payout);
      return;
    }

    // Build withdrawal options with full search attributes
    final options = relevantInvestments.map((pi) {
      final inv = investors.where((i) => i.id == pi.investorId).firstOrNull;
      final proj = projects.where((p) => p.id == pi.projectId).firstOrNull;
      final payout = buildPayoutModel(pi);

      return InvestorWithdrawalOption(
        investorName: inv?.name ?? 'Investor',
        projectName: proj?.name ?? 'Project #${pi.projectId}',
        projectLocation: proj?.location,
        phone: inv?.phone,
        capitalInvested: payout.capitalInvested,
        remainingPayoutBalance: payout.remainingPayoutBalance,
        payout: payout,
      );
    }).toList();

    // Show searchable selection dialog
    InvestorWithdrawalSelectionDialog.show(
      context: context,
      options: options,
      preselectedInvestorName: preselectedInvestor?.name,
    );
  }

  Future<void> _handleDeleteInvestor(BuildContext context, WidgetRef ref, InvestorModel investor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.delete_forever_outlined, color: AppColors.dangerText, size: 24),
            const SizedBox(width: 8),
            Text('Confirm Delete Investor', style: AppTypography.cardTitle),
          ],
        ),
        content: Text(
          'Are you sure you want to delete investor "${investor.name}" (${investor.phone})?\n\n'
          'WARNING: This will delete the investor profile and clean up any capital allocations.',
          style: AppTypography.body,
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.dangerText,
              side: const BorderSide(color: AppColors.dangerBorder),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.dangerText),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Investor', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(investorsRepositoryProvider);
        await repo.deleteInvestor(investor.id, userId: 'admin_user', force: true);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Investor "${investor.name}" deleted successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting investor: $e')),
          );
        }
      }
    }
  }

  void _openInvestorAgreement(
    BuildContext context,
    WidgetRef ref,
    InvestorModel investor,
    List<ProjectInvestorModel> allInvestments,
  ) {
    final invInvestments = allInvestments.where((pi) => pi.investorId == investor.id).toList();
    if (invInvestments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No capital investment allocated to this investor yet. Please allocate first.')),
      );
      return;
    }

    final projects = ref.read(projectsListStreamProvider).value ?? [];

    if (invInvestments.length == 1) {
      final pi = invInvestments.first;
      final proj = projects.where((p) => p.id == pi.projectId).firstOrNull;
      if (proj != null) {
        InvestorAgreementPdfDialog.show(
          context,
          investorName: investor.name,
          investorPhone: investor.phone,
          investorPan: investor.pan,
          investorEmail: investor.email,
          projectName: proj.name,
          projectCode: proj.code,
          projectLocation: proj.location,
          projectLandAreaSqFt: proj.landAreaSqFt,
          investedAmount: pi.investedAmount,
          ownershipPercent: pi.ownershipPercent,
          ownershipMethod: pi.ownershipMethod,
          agreementDate: pi.createdAt,
        );
      }
      return;
    }

    // Multiple projects: Show selection dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Select Project Agreement (${investor.name})', style: AppTypography.cardTitle),
        content: SizedBox(
          width: 420,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: invInvestments.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (_, idx) {
              final pi = invInvestments[idx];
              final proj = projects.where((p) => p.id == pi.projectId).firstOrNull;
              final pName = proj?.name ?? 'Project #${pi.projectId}';
              final pCode = proj?.code ?? '';
              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AppColors.accent),
                title: Text('$pName ($pCode)', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                subtitle: Text('Contributed: ${CalculationEngine.formatCurrency(pi.investedAmount)} • ${pi.ownershipPercent.toStringAsFixed(2)}%'),
                trailing: const Icon(Icons.chevron_right, size: 18),
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (proj != null) {
                    InvestorAgreementPdfDialog.show(
                      context,
                      investorName: investor.name,
                      investorPhone: investor.phone,
                      investorPan: investor.pan,
                      investorEmail: investor.email,
                      projectName: proj.name,
                      projectCode: proj.code,
                      projectLocation: proj.location,
                      projectLandAreaSqFt: proj.landAreaSqFt,
                      investedAmount: pi.investedAmount,
                      ownershipPercent: pi.ownershipPercent,
                      ownershipMethod: pi.ownershipMethod,
                      agreementDate: pi.createdAt,
                    );
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(investorsSearchQueryProvider);
    final dateRangeFilter = ref.watch(investorsDateRangeFilterProvider);
    final currentRole = ref.watch(currentRoleProvider);

    // STRICT BUSINESS LOGIC ROLE BOUNDARY CHECK (PRD §5 / AC-09.1 - AC-09.4)
    if (!currentRole.isAdmin) {
      return const Center(
        child: Text(
          'ACCESS RESTRICTED: Investor management is restricted to Admin role only (AC-09.1 - AC-09.4).',
          style: TextStyle(color: AppColors.dangerText, fontWeight: FontWeight.bold),
        ),
      );
    }

    final investorsAsync = ref.watch(investorsListStreamProvider);
    final selectedProjectId = ref.watch(selectedProjectFilterProvider);
    final allInvestments = ref.watch(allProjectInvestorsStreamProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Investors & Project Agreements',
          subtitle:
              'Register investor profiles, capital contributions, and project ownership agreements.',
          icon: Icons.pie_chart_outline,
          actions: [
            OutlinedButton.icon(
              onPressed: () => _openInvestorWithdrawal(context, ref, allInvestments),
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: const Text('Investor Withdrawal'),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: () => ProjectInvestmentDialog.show(context),
              icon: const Icon(Icons.note_add_outlined, size: 18),
              label: const Text('New Agreement'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => InvestorFormDialog.show(context),
              icon: const Icon(Icons.person_add_outlined, size: 18),
              label: const Text('Add Investor'),
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
                  DataTableColumn(label: 'Registered Date', width: 140),
                  DataTableColumn(label: 'Agreement PDF', width: 130, alignment: Alignment.center),
                  DataTableColumn(label: 'Actions', width: 160, alignment: Alignment.center),
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
                    if (hasAgreement)
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: AppColors.accent, size: 18),
                        tooltip: 'Generate / View Investor Agreement PDF',
                        onPressed: () => _openInvestorAgreement(
                          context,
                          ref,
                          investor,
                          allInvestments,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.accent, size: 20),
                        tooltip: 'Create Investor Agreement',
                        onPressed: () => ProjectInvestmentDialog.show(
                          context,
                          preselectedInvestorId: investor.id,
                        ),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.primary, size: 18),
                          tooltip: 'Investor Withdrawal',
                          onPressed: () => _openInvestorWithdrawal(
                            context,
                            ref,
                            allInvestments,
                            preselectedInvestor: investor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit_outlined, color: AppColors.accent, size: 18),
                          tooltip: 'Edit Investor Profile',
                          onPressed: () => InvestorFormDialog.show(
                            context,
                            investor: investor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 18),
                          tooltip: 'View Profile & Agreements',
                          onPressed: () => InvestorProfileDialog.show(
                            context,
                            investor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete_outline, color: AppColors.dangerText, size: 18),
                          tooltip: 'Delete Investor',
                          onPressed: () => _handleDeleteInvestor(
                            context,
                            ref,
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
