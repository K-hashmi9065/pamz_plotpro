import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/pdf/investor_statement_pdf_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../investors/domain/investor_model.dart';
import '../../investors/domain/project_investor_model.dart';
import '../../investors/presentation/widgets/investor_statement_pdf_dialog.dart';
import '../../projects/domain/project_model.dart';
import 'member_dashboard_providers.dart';
import 'member_dashboard_widgets.dart';

final _currencyFmt =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _dateFmt = DateFormat('dd MMM yyyy, hh:mm a');

class InvestorDashboardScreen extends ConsumerWidget {
  const InvestorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(investorProjectsProvider);
    final distributionsAsync = ref.watch(investorDistributionsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'My Investment Portfolio',
            subtitle:
                'Total invested amount, withdrawals, and project-wise returns.',
            icon: Icons.pie_chart_outline,
            actions: const [],
          ),
          const SizedBox(height: 8),
          projectsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style:
                      AppTypography.secondary.copyWith(color: AppColors.danger)),
            ),
            data: (investments) {
              if (investments.isEmpty) {
                return const MemberEmptyState(
                  icon: Icons.pie_chart_outline,
                  title: 'No investments found',
                  subtitle: 'Your investment records will appear here.',
                );
              }

              final totalInvested =
                  investments.fold(0.0, (s, i) => s + i.investedAmount);
              final distributions =
                  distributionsAsync.valueOrNull ?? [];
              final totalWithdrawn =
                  distributions.fold(0.0, (s, d) => s + d.amount);
              final remaining = totalInvested - totalWithdrawn;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards row
                  Row(
                    children: [
                      Expanded(
                        child: MemberSummaryCard(
                          icon: Icons.trending_up_outlined,
                          label: 'Total Invested',
                          value: _currencyFmt.format(totalInvested),
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MemberSummaryCard(
                          icon: Icons.south_rounded,
                          label: 'Total Withdrawn',
                          value: _currencyFmt.format(totalWithdrawn),
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MemberSummaryCard(
                          icon: Icons.account_balance_outlined,
                          label: 'Remaining',
                          value: _currencyFmt.format(remaining),
                          color: remaining > 0
                              ? AppColors.success
                              : AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MemberSummaryCard(
                          icon: Icons.business_outlined,
                          label: 'Projects',
                          value: investments.length.toString(),
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Project-wise investments
                  Text('Project-wise Investments',
                      style: AppTypography.cardTitle.copyWith(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 14),
                  ...investments.map(
                    (inv) => _InvestmentCard(
                      investment: inv,
                      distributions: distributions
                          .where(
                              (d) => d.projectId == inv.projectId)
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Withdrawal history
                  if (distributions.isNotEmpty) ...[
                    Text('Withdrawal History',
                        style: AppTypography.cardTitle.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 14),
                    _WithdrawalHistoryTable(distributions: distributions),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Investment Card ───────────────────────────────────────────────────────────

class _InvestmentCard extends ConsumerWidget {
  final ProjectInvestor investment;
  final List<Distribution> distributions;

  const _InvestmentCard(
      {required this.investment, required this.distributions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(investment.projectId));
    final totalWithdrawn =
        distributions.fold(0.0, (s, d) => s + d.amount);
    final remaining = investment.investedAmount - totalWithdrawn;

    return projectAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (project) {
        final projectName = project?.name ?? 'Unknown Project';
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.business_outlined,
                          size: 20, color: AppColors.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(projectName,
                              style: AppTypography.cardTitle.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                          Text(
                            'Ownership: ${investment.ownershipPercent.toStringAsFixed(2)}%',
                            style: AppTypography.secondary
                                .copyWith(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: const Size(0, 28),
                      ),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 13, color: AppColors.accent),
                      label: const Text('Statement PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () async {
                        final db = ref.read(appDatabaseProvider);
                        final currentUser = ref.read(currentUserProvider);
                        final invName = currentUser?.name ?? 'Investor';

                        final prj = await (db.select(db.projects)..where((p) => p.id.equals(investment.projectId))).getSingleOrNull();
                        final inv = await (db.select(db.investors)..where((i) => i.id.equals(investment.investorId))).getSingleOrNull();

                        final allPiRows = await (db.select(db.projectInvestors)..where((pi) => pi.investorId.equals(investment.investorId))).get();
                        final allPi = allPiRows.where((pi) => pi.projectId == investment.projectId).toList();
                        final investments = allPi.map((pi) {
                          final method = OwnershipMethod.values.firstWhere(
                            (m) => m.name == pi.ownershipMethod,
                            orElse: () => OwnershipMethod.capitalBased,
                          );
                          return ProjectInvestorModel(
                            id: pi.id,
                            projectId: pi.projectId,
                            investorId: pi.investorId,
                            investorName: invName,
                            investedAmount: pi.investedAmount,
                            ownershipPercent: pi.ownershipPercent,
                            ownershipMethod: method,
                            createdAt: pi.createdAt,
                          );
                        }).toList();

                        final withdrawalRecords = distributions.map((d) {
                          return InvestorWithdrawalRecord(
                            date: d.distributionDate,
                            amount: d.amount,
                            reference: d.notes ?? 'BANK_TRANSFER',
                            disbursedBy: 'PAMZ Admin',
                          );
                        }).toList();

                        final projectModel = prj != null
                            ? ProjectModel(
                                id: prj.id,
                                name: prj.name,
                                code: prj.code,
                                location: prj.location,
                                landAreaSqFt: prj.landAreaSqFt,
                                measurementUnit: prj.measurementUnit,
                                displayArea: prj.displayArea,
                                kattaValue: prj.kattaValue,
                                dhurValue: prj.dhurValue,
                                lengthFt: prj.lengthFt,
                                lengthIn: prj.lengthIn,
                                breadthFt: prj.breadthFt,
                                breadthIn: prj.breadthIn,
                                purchasePrice: prj.purchasePrice,
                                actualCost: prj.actualCost,
                                status: ProjectStatus.values.firstWhere((s) => s.name == prj.status, orElse: () => ProjectStatus.active),
                                createdAt: prj.createdAt,
                              )
                            : ProjectModel(
                                id: investment.projectId,
                                name: projectName,
                                code: 'PRJ',
                                location: '',
                                landAreaSqFt: 0,
                                purchasePrice: 0,
                                actualCost: 0,
                                status: ProjectStatus.active,
                                createdAt: DateTime.now(),
                              );

                        final investorModel = inv != null
                            ? InvestorModel(
                                id: inv.id,
                                name: inv.name,
                                phone: inv.phone,
                                email: inv.email,
                                pan: inv.pan,
                                createdAt: inv.createdAt,
                              )
                            : null;

                        if (context.mounted) {
                          InvestorStatementPdfDialog.show(
                            context,
                            project: projectModel,
                            investor: investorModel,
                            investorName: invName,
                            ownershipPercent: investment.ownershipPercent,
                            investments: investments,
                            withdrawals: withdrawalRecords,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              // Financial row
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        label: 'Invested Amount',
                        value: _currencyFmt.format(investment.investedAmount),
                        color: AppColors.accent,
                      ),
                    ),
                    Expanded(
                      child: _InfoTile(
                        label: 'Withdrawn',
                        value: _currencyFmt.format(totalWithdrawn),
                        color: AppColors.orange,
                      ),
                    ),
                    Expanded(
                      child: _InfoTile(
                        label: 'Remaining',
                        value: _currencyFmt.format(remaining),
                        color: remaining > 0
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Withdrawal history table ──────────────────────────────────────────────────

class _WithdrawalHistoryTable extends ConsumerWidget {
  final List<Distribution> distributions;
  const _WithdrawalHistoryTable({required this.distributions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text('Project',
                        style: AppTypography.secondary.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('Date',
                        style: AppTypography.secondary.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
                Expanded(
                    flex: 2,
                    child: Text('Amount',
                        textAlign: TextAlign.end,
                        style: AppTypography.secondary.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          // Rows
          ...distributions.asMap().entries.map((entry) {
            final index = entry.key;
            final dist = entry.value;
            final projectAsync =
                ref.watch(projectByIdProvider(dist.projectId));
            final projectName =
                projectAsync.valueOrNull?.name ?? 'Loading...';

            return Container(
              decoration: BoxDecoration(
                color: index.isEven
                    ? AppColors.surface
                    : AppColors.surfaceSubtle,
                borderRadius: index == distributions.length - 1
                    ? const BorderRadius.vertical(
                        bottom: Radius.circular(12))
                    : BorderRadius.zero,
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: const BoxDecoration(
                            color: AppColors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(projectName,
                              style: AppTypography.body
                                  .copyWith(fontSize: 13.5),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _dateFmt.format(dist.distributionDate),
                      style: AppTypography.secondary
                          .copyWith(fontSize: 12.5),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      _currencyFmt.format(dist.amount),
                      textAlign: TextAlign.end,
                      style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.orange),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoTile(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.secondary.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: color)),
      ],
    );
  }
}
