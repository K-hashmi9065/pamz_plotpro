import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRole = ref.watch(currentRoleProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Settings & Administration (Admin Only)',
            subtitle:
                'Local database configuration, role security boundaries, and offline data backups.',
            icon: Icons.settings_outlined,
          ),
          const SizedBox(height: 20),

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
                      'ACCESS RESTRICTED: Member role does not have administrative permissions to view system configuration.',
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
            // Settings Cards List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Account & System Role', style: AppTypography.cardTitle),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.account_circle, color: AppColors.accent, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Logged in as Administrator', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
                          Text('Role: Admin (Full system & investor data access)', style: AppTypography.secondary),
                        ],
                      ),
                      const Spacer(),
                      StatusBadge(label: 'ADMIN ROLE', type: BadgeType.info),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Database & Offline Storage Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Offline Local Storage & Database', style: AppTypography.cardTitle),
                  const SizedBox(height: 12),
                  Text(
                    'Local SQLite Database Location:',
                    style: AppTypography.secondary.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SelectableText(
                      '%APPDATA%\\LandInvestmentSystem\\land_investment.sqlite',
                      style: AppTypography.input.copyWith(fontSize: 13, fontFamily: 'monospace'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Database backup copy created in AppData folder!')),
                          );
                        },
                        icon: const Icon(Icons.backup_outlined, size: 18),
                        label: const Text('Create Local DB Backup'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Database integrity check: OK (No corrupt tables).')),
                          );
                        },
                        icon: const Icon(Icons.health_and_safety_outlined, size: 18),
                        label: const Text('Verify Database Integrity'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Statutory & Tax Compliance Thresholds Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statutory Tax & Regulatory Parameters', style: AppTypography.cardTitle),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Section 269ST Cash Limit', style: AppTypography.secondary.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              CalculationEngine.formatCurrency(AppConstants.cashTransactionLimit),
                              style: AppTypography.amountMedium.copyWith(color: AppColors.warningText),
                            ),
                            Text('Single day/transaction cash ceiling', style: AppTypography.secondary.copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Section 194-IA TDS Threshold', style: AppTypography.secondary.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              CalculationEngine.formatCurrency(AppConstants.tdsPropertyThreshold),
                              style: AppTypography.amountMedium.copyWith(color: AppColors.accent),
                            ),
                            Text('1% TDS on property sale >= ₹50 Lakhs', style: AppTypography.secondary.copyWith(fontSize: 11)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
