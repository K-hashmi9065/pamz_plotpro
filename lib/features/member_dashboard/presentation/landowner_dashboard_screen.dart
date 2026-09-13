import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/land_unit_converter.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../landowners/domain/purchase_agreement_model.dart';
import '../../landowners/presentation/landowners_providers.dart';
import '../../landowners/presentation/widgets/landowner_invoice_pdf_dialog.dart';
import '../../projects/domain/project_model.dart';
import '../../projects/presentation/projects_providers.dart' hide projectByIdProvider;
import 'member_dashboard_providers.dart';
import 'member_dashboard_widgets.dart';

final _currencyFmt =
    NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final _dateFmt = DateFormat('dd MMM yyyy');

class LandownerDashboardScreen extends ConsumerWidget {
  const LandownerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreementsAsync = ref.watch(landownerAgreementsProvider);
    final projectsAsync = ref.watch(landownerProjectsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'My Land Sales',
            subtitle: 'Your land projects, payment agreements and history.',
            icon: Icons.landscape_outlined,
            actions: const [],
          ),
          const SizedBox(height: 8),
          agreementsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text('Error: $e',
                  style:
                      AppTypography.secondary.copyWith(color: AppColors.danger)),
            ),
            data: (agreements) {
              final projects = projectsAsync.valueOrNull ?? [];

              if (agreements.isEmpty && projects.isEmpty) {
                return const MemberEmptyState(
                  icon: Icons.landscape_outlined,
                  title: 'No land sale agreements',
                  subtitle: 'Your purchase agreements and associated land projects will appear here.',
                );
              }

              double totalAgreed = 0;
              for (final a in agreements) {
                totalAgreed += a.totalPrice;
              }
              // If no separate agreements yet, use project purchase prices
              if (totalAgreed == 0) {
                for (final p in projects) {
                  totalAgreed += p.purchasePrice;
                }
              }

              // Group agreements by project
              final Map<String, List<PurchaseAgreement>> projectAgreements = {};
              for (final a in agreements) {
                projectAgreements.putIfAbsent(a.projectId, () => []).add(a);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary cards
                  Row(
                    children: [
                      Expanded(
                        child: MemberSummaryCard(
                          icon: Icons.business_outlined,
                          label: 'Projects',
                          value: projects.isNotEmpty
                              ? projects.length.toString()
                              : (projectAgreements.keys.length.toString()),
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: MemberSummaryCard(
                          icon: Icons.receipt_long_outlined,
                          label: 'Total Land Value',
                          value: _currencyFmt.format(totalAgreed),
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _LandownerTotalPaidCard(
                            agreements: agreements,
                            projects: projects),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _LandownerDuesCard(
                            agreements: agreements,
                            projects: projects,
                            totalAgreed: totalAgreed),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Associated Land Projects
                  if (projects.isNotEmpty) ...[
                    const MemberSectionHeader(
                      title: 'Associated Land Projects',
                      icon: Icons.business_outlined,
                    ),
                    const SizedBox(height: 12),
                    ...projects.map((project) {
                      final projectAgrees = projectAgreements[project.id] ?? [];
                      return _LandProjectCard(
                        project: project,
                        agreements: projectAgrees,
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // Project-wise agreement sections for any other agreements
                  ...projectAgreements.entries
                      .where((entry) => !projects.any((p) => p.id == entry.key))
                      .map((entry) {
                    return _LandownerProjectSection(
                      projectId: entry.key,
                      agreements: entry.value,
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Land Project Card ─────────────────────────────────────────────────────────

class _LandProjectCard extends ConsumerWidget {
  final Project project;
  final List<PurchaseAgreement> agreements;

  const _LandProjectCard({
    required this.project,
    required this.agreements,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.business_rounded,
                      color: AppColors.accent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            project.name,
                            style: AppTypography.cardTitle.copyWith(
                                fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              project.code,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            project.location.isNotEmpty
                                ? project.location
                                : 'Location not specified',
                            style: AppTypography.secondary
                                .copyWith(fontSize: 12.5),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            _dateFmt.format(project.createdAt),
                            style: AppTypography.secondary
                                .copyWith(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: project.status.toUpperCase()),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: MemberFinancialTile(
                    label: 'Land Purchase Price',
                    value: _currencyFmt.format(project.purchasePrice),
                    color: AppColors.accent,
                  ),
                ),
                Expanded(
                  child: MemberFinancialTile(
                    label: 'Project Area',
                    value: project.landAreaSqFt > 0
                        ? '${NumberFormat('#,##,###').format(project.landAreaSqFt)} sq ft (${LandUnitConverter.sqFtToKatta(project.landAreaSqFt)} Kattha)'
                        : '—',
                    color: AppColors.textPrimary,
                  ),
                ),
                Expanded(
                  child: MemberFinancialTile(
                    label: 'Agreements',
                    value: (agreements.isNotEmpty || project.purchasePrice > 0)
                        ? '${agreements.isNotEmpty ? agreements.length : 1} Active'
                        : 'Pending Agreement',
                    color: (agreements.isNotEmpty || project.purchasePrice > 0)
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          () {
            final effectiveAgreements = agreements.isNotEmpty
                ? agreements
                : [
                    PurchaseAgreement(
                      id: 'AUTO_${project.id}',
                      projectId: project.id,
                      landownerId: project.landownerId ?? '',
                      totalPrice: project.purchasePrice,
                      agreementDate: project.createdAt,
                      status: 'ACTIVE',
                      createdAt: project.createdAt,
                    ),
                  ];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...effectiveAgreements
                          .map((a) => _AgreementCard(agreement: a)),
                    ],
                  ),
                ),
              ],
            );
          }(),
        ],
      ),
    );
  }
}

// ── Project section ───────────────────────────────────────────────────────────

class _LandownerProjectSection extends ConsumerWidget {
  final String projectId;
  final List<PurchaseAgreement> agreements;

  const _LandownerProjectSection(
      {required this.projectId, required this.agreements});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    return projectAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (project) {
        final name = project?.name ?? 'Unknown Project';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MemberSectionHeader(title: name, icon: Icons.business_outlined),
            const SizedBox(height: 12),
            ...agreements.map((a) => _AgreementCard(agreement: a)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _AgreementCard extends ConsumerWidget {
  final PurchaseAgreement agreement;
  const _AgreementCard({required this.agreement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installmentsAsync =
        ref.watch(agreementInstallmentsProvider(agreement.id));
    final transactionsAsync =
        ref.watch(agreementTransactionsProvider(agreement.id));
    final transactions = transactionsAsync.value ?? [];

    return installmentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (installments) {
        final totalPaid = transactions.isNotEmpty
            ? transactions.fold(0.0, (s, t) => s + t.amount)
            : installments.fold(0.0, (s, i) => s + i.paidAmount);
        final remaining = (agreement.totalPrice - totalPaid).clamp(0.0, double.infinity);
        final paidInstallments =
            installments.where((i) => i.paidAmount > 0).toList();

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
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Purchase Agreement',
                              style: AppTypography.cardTitle.copyWith(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            'Agreement Date: ${_dateFmt.format(agreement.agreementDate)}',
                            style: AppTypography.secondary
                                .copyWith(fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatusChip(status: agreement.status),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(0, 28),
                          ),
                          icon: const Icon(Icons.picture_as_pdf_outlined, size: 13, color: AppColors.accent),
                          label: const Text('Statement PDF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          onPressed: () {
                            final projects = ref.read(projectsListStreamProvider).value ?? [];
                            final proj = projects.where((p) => p.id == agreement.projectId).firstOrNull;
                            final landowners = ref.read(landownersListStreamProvider).value ?? [];
                            final landowner = landowners.where((l) => l.id == agreement.landownerId).firstOrNull;

                            final agreementModel = PurchaseAgreementModel(
                              id: agreement.id,
                              projectId: agreement.projectId,
                              landownerId: agreement.landownerId,
                              totalPrice: agreement.totalPrice,
                              agreementDate: agreement.agreementDate,
                              status: agreement.status,
                              createdAt: agreement.createdAt,
                            );

                            final projModel = proj ??
                                ProjectModel(
                                  id: agreement.projectId,
                                  name: 'Project',
                                  code: 'PRJ',
                                  location: '',
                                  landAreaSqFt: 0,
                                  purchasePrice: agreement.totalPrice,
                                  actualCost: agreement.totalPrice,
                                  status: ProjectStatus.active,
                                  createdAt: agreement.createdAt,
                                );

                            LandownerInvoicePdfDialog.show(
                              context,
                              project: projModel,
                              agreement: agreementModel,
                              landowner: landowner,
                              transactions: transactions,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: MemberFinancialTile(
                        label: 'Agreed Price',
                        value: _currencyFmt.format(agreement.totalPrice),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: MemberFinancialTile(
                        label: 'Total Paid',
                        value: _currencyFmt.format(totalPaid),
                        color: AppColors.success,
                      ),
                    ),
                    Expanded(
                      child: MemberFinancialTile(
                        label: 'Remaining',
                        value: _currencyFmt.format(remaining),
                        color: remaining > 0
                            ? AppColors.danger
                            : AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              if (transactions.isNotEmpty || paidInstallments.isNotEmpty) ...[
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Payment History (${transactions.isNotEmpty ? transactions.length : paidInstallments.length} Records)',
                            style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600, fontSize: 13.5),
                          ),
                          if (remaining <= 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 13, color: AppColors.success),
                                  const SizedBox(width: 4),
                                  Text(
                                    'All Payments Cleared',
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      if (transactions.isNotEmpty)
                        ...transactions
                            .map((tx) => _LandownerTransactionRow(tx: tx))
                      else
                        ...paidInstallments.map((inst) =>
                            _LandownerInstallmentRow(inst: inst)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _LandownerTransactionRow extends StatelessWidget {
  final Transaction tx;
  const _LandownerTransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paid on: ${_dateFmt.format(tx.paymentDate)}',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mode: ${tx.paymentMethod.toUpperCase()}${tx.referenceNumber != null && tx.referenceNumber!.trim().isNotEmpty ? " • Ref: ${tx.referenceNumber!.trim()}" : ""}',
                  style: AppTypography.secondary.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currencyFmt.format(tx.amount),
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'CLEARED / PAID',
                  style: AppTypography.caption.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LandownerInstallmentRow extends StatelessWidget {
  final Installment inst;
  const _LandownerInstallmentRow({required this.inst});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${inst.installmentNumber}',
              style: AppTypography.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Due: ${_dateFmt.format(inst.dueDate)}',
              style: AppTypography.secondary.copyWith(fontSize: 12.5),
            ),
          ),
          Text(
            _currencyFmt.format(inst.paidAmount),
            style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

// ── Paid / Dues helpers ───────────────────────────────────────────────────────

class _LandownerTotalPaidCard extends ConsumerWidget {
  final List<PurchaseAgreement> agreements;
  final List<Project> projects;
  const _LandownerTotalPaidCard({required this.agreements, this.projects = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double total = 0;
    final Set<String> checkedAgreementIds = {};
    for (final a in agreements) {
      checkedAgreementIds.add(a.id);
      final txs =
          ref.watch(agreementTransactionsProvider(a.id)).valueOrNull ?? [];
      if (txs.isNotEmpty) {
        total += txs.fold(0.0, (s, t) => s + t.amount);
      } else {
        final inst =
            ref.watch(agreementInstallmentsProvider(a.id)).valueOrNull ?? [];
        total += inst.fold(0.0, (s, i) => s + i.paidAmount);
      }
    }
    for (final p in projects) {
      final autoId = 'AUTO_${p.id}';
      if (!checkedAgreementIds.contains(autoId)) {
        final txs =
            ref.watch(agreementTransactionsProvider(autoId)).valueOrNull ?? [];
        if (txs.isNotEmpty) {
          total += txs.fold(0.0, (s, t) => s + t.amount);
        } else {
          final inst =
              ref.watch(agreementInstallmentsProvider(autoId)).valueOrNull ?? [];
          total += inst.fold(0.0, (s, i) => s + i.paidAmount);
        }
      }
    }
    return MemberSummaryCard(
      icon: Icons.check_circle_outline,
      label: 'Total Paid',
      value: _currencyFmt.format(total),
      color: AppColors.success,
    );
  }
}

class _LandownerDuesCard extends ConsumerWidget {
  final List<PurchaseAgreement> agreements;
  final List<Project> projects;
  final double totalAgreed;
  const _LandownerDuesCard(
      {required this.agreements, this.projects = const [], required this.totalAgreed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double paid = 0;
    final Set<String> checkedAgreementIds = {};
    for (final a in agreements) {
      checkedAgreementIds.add(a.id);
      final txs =
          ref.watch(agreementTransactionsProvider(a.id)).valueOrNull ?? [];
      if (txs.isNotEmpty) {
        paid += txs.fold(0.0, (s, t) => s + t.amount);
      } else {
        final inst =
            ref.watch(agreementInstallmentsProvider(a.id)).valueOrNull ?? [];
        paid += inst.fold(0.0, (s, i) => s + i.paidAmount);
      }
    }
    for (final p in projects) {
      final autoId = 'AUTO_${p.id}';
      if (!checkedAgreementIds.contains(autoId)) {
        final txs =
            ref.watch(agreementTransactionsProvider(autoId)).valueOrNull ?? [];
        if (txs.isNotEmpty) {
          paid += txs.fold(0.0, (s, t) => s + t.amount);
        } else {
          final inst =
              ref.watch(agreementInstallmentsProvider(autoId)).valueOrNull ?? [];
          paid += inst.fold(0.0, (s, i) => s + i.paidAmount);
        }
      }
    }
    final dues = (totalAgreed - paid).clamp(0.0, double.infinity);
    return MemberSummaryCard(
      icon: Icons.warning_amber_outlined,
      label: 'Remaining / Dues',
      value: _currencyFmt.format(dues),
      color: dues > 0 ? AppColors.danger : AppColors.success,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
      ),
      child: Text(status,
          style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accent)),
    );
  }
}
