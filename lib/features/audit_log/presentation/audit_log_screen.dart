import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/custom_data_table.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import '../../projects/presentation/projects_providers.dart';

final auditLogsStreamProvider = StreamProvider<List<AuditLog>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.auditLogs)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.timestamp)]))
      .watch();
});

final auditLogSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

class AuditLogScreen extends ConsumerWidget {
  const AuditLogScreen({super.key});

  BadgeType _getActionBadgeType(String action) {
    switch (action) {
      case 'VOID_TRANSACTION':
        return BadgeType.danger;
      case 'RECORD_PAYMENT':
        return BadgeType.success;
      case 'DISBURSE_INVESTOR_PAYOUT':
        return BadgeType.info;
      default:
        return BadgeType.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(auditLogSearchQueryProvider);
    final currentRole = ref.watch(currentRoleProvider);
    final auditLogsAsync = ref.watch(auditLogsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Audit Log & Traceability (Admin Only)',
          subtitle:
              'Immutable chronological record of system actions, financial reversals, and compliance alerts.',
          icon: Icons.history_edu_outlined,
        ),
        const SizedBox(height: 16),

        if (!currentRole.isAdmin) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.dangerBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dangerBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.dangerText, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ACCESS RESTRICTED: Member role does not have permission to inspect system audit logs.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.dangerText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Search Filter Bar
          SizedBox(
            width: 320,
            height: 38,
            child: TextField(
              onChanged: (val) => ref.read(auditLogSearchQueryProvider.notifier).state = val,
              decoration: const InputDecoration(
                hintText: 'Search audit action or details...',
                prefixIcon: Icon(Icons.search, size: 18),
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              style: AppTypography.input.copyWith(fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),

          // Audit Logs Table
          Expanded(
            child: auditLogsAsync.when(
              loading: () => const CustomDataTable(
                columns: [],
                rows: [],
                isLoading: true,
              ),
              error: (err, stack) => Center(
                child: Text('Error loading audit log: $err'),
              ),
              data: (logs) {
                final filteredLogs = logs.where((log) {
                  if (searchQuery.isEmpty) return true;
                  final q = searchQuery.toLowerCase();
                  final actionMatch = log.action.toLowerCase().contains(q);
                  final detailsMatch = log.details.toLowerCase().contains(q);
                  final userMatch = log.userId.toLowerCase().contains(q);
                  return actionMatch || detailsMatch || userMatch;
                }).toList();

                return CustomDataTable(
                  columns: const [
                    DataTableColumn(label: 'Timestamp', width: 170),
                    DataTableColumn(label: 'User ID', width: 130),
                    DataTableColumn(label: 'Action', width: 220),
                    DataTableColumn(label: 'Target Entity', width: 150),
                    DataTableColumn(label: 'Audit Details & Parameters'),
                  ],
                  rows: filteredLogs.map((log) {
                    return [
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(log.timestamp),
                        style: AppTypography.secondary,
                      ),
                      Text(
                        log.userId,
                        style: AppTypography.tableCell.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      StatusBadge(
                        label: log.action,
                        type: _getActionBadgeType(log.action),
                      ),
                      Text(
                        '${log.entityType} (${log.entityId})',
                        style: AppTypography.tableCell,
                      ),
                      Text(
                        log.details,
                        style: AppTypography.tableCell.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ];
                  }).toList(),
                  emptyMessage: 'No audit log entries recorded.',
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
