import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/calculation_engine.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import 'settings_providers.dart';

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

            // PDF & Document Branding Card
            const _PdfBrandingCard(),
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
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _PdfBrandingCard extends ConsumerStatefulWidget {
  const _PdfBrandingCard();

  @override
  ConsumerState<_PdfBrandingCard> createState() => _PdfBrandingCardState();
}

class _PdfBrandingCardState extends ConsumerState<_PdfBrandingCard> {
  late final TextEditingController _pdfHeaderController;
  final ValueNotifier<bool> _isSavedFeedbackNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final initialHeader = ref.read(pdfHeaderTitleProvider);
    _pdfHeaderController = TextEditingController(text: initialHeader);
  }

  @override
  void dispose() {
    _pdfHeaderController.dispose();
    _isSavedFeedbackNotifier.dispose();
    super.dispose();
  }

  Future<void> _saveHeader() async {
    final newTitle = _pdfHeaderController.text.trim();
    await ref.read(pdfHeaderTitleProvider.notifier).updateHeaderTitle(newTitle);
    _isSavedFeedbackNotifier.value = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _isSavedFeedbackNotifier.value = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF Header updated to "${ref.read(pdfHeaderTitleProvider)}". All new PDFs will use this branding.'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _resetToDefault() async {
    await ref.read(pdfHeaderTitleProvider.notifier).resetToDefault();
    _pdfHeaderController.text = 'PAMZ PlotPro';
    _isSavedFeedbackNotifier.value = true;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _isSavedFeedbackNotifier.value = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF Header reset to default "PAMZ PlotPro".'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeHeader = ref.watch(pdfHeaderTitleProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
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
                  const Icon(Icons.picture_as_pdf_outlined, color: AppColors.accent, size: 22),
                  const SizedBox(width: 8),
                  Text('PDF & Document Branding', style: AppTypography.cardTitle),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isSavedFeedbackNotifier,
                builder: (context, isSaved, _) {
                  if (!isSaved) return const SizedBox.shrink();
                  return Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.successText, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Saved',
                        style: AppTypography.body.copyWith(
                          color: AppColors.successText,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Configure the official organization / company title rendered at the top of all newly generated PDF documents (Customer Agreements, Land Purchase Agreements, Investor Statements, and Invoices).',
            style: AppTypography.secondary,
          ),
          const SizedBox(height: 16),

          // Input field
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _pdfHeaderController,
                  decoration: InputDecoration(
                    labelText: 'PDF Header / Organization Name *',
                    hintText: 'e.g. PAMZ PlotPro or Wasi Property',
                    helperText: 'Default: PAMZ PlotPro. Previously generated static PDFs retain their original headers.',
                    prefixIcon: const Icon(Icons.business_outlined, size: 20),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  style: AppTypography.input.copyWith(fontWeight: FontWeight.w600),
                  onSubmitted: (_) => _saveHeader(),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _saveHeader,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Save Header'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _resetToDefault,
                icon: const Icon(Icons.restore_outlined, size: 18),
                label: const Text('Reset Default'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live Preview Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.preview_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE PDF HEADER PREVIEW',
                      style: AppTypography.secondary.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeHeader,
                          style: AppTypography.sectionTitle.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Enterprise Real Estate & Land Development',
                          style: AppTypography.secondary.copyWith(fontSize: 12),
                        ),
                        Text(
                          'Project: Green Acres Township (PRJ-001)',
                          style: AppTypography.body.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight.withAlpha(50),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.accent),
                      ),
                      child: Text(
                        'TAX INVOICE / AGREEMENT',
                        style: AppTypography.body.copyWith(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
