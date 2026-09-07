import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/navigation_providers.dart';
import '../../../shared/widgets/page/page_header.dart';
import '../../../shared/widgets/page/status_badge.dart';
import 'widgets/user_guide_pdf_dialog.dart';

class HelpTopic {
  final String id;
  final String title;
  final String category;
  final String description;
  final String steps;
  final String whyItMatters;
  final bool adminOnly;

  const HelpTopic({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.steps,
    required this.whyItMatters,
    this.adminOnly = false,
  });
}

class HelpTopicsData {
  static const List<HelpTopic> topics = [
    HelpTopic(
      id: 'getting_started',
      title: 'System Overview & Role-Based Access',
      category: 'General',
      description:
          'PAMZ Land Investment & Sales Management System provides complete project lifecycle management with strict role-based data partitioning.',
      steps:
          '1. Admin Role: Full visibility over financial ledgers, investor payouts, audit logs, and project setup.\n2. Member Role: Operational access to sales, plot status, landowner agreements, and payment recording. Sensitive financial audit logs and investor returns are hidden.',
      whyItMatters:
          'Ensures governance, data integrity, and compliance across executive management and sales teams.',
    ),
    HelpTopic(
      id: 'project_creation',
      title: 'Creating & Managing Projects',
      category: 'Projects',
      description:
          'Projects represent land acquisitions divided into subdividable plots for resale or investment.',
      steps:
          '1. Go to Projects screen.\n2. Click "+ New Project".\n3. Select Landowner, enter gross area in Bigha-Katha-Dhur, purchase agreement price, and location.\n4. Save project.',
      whyItMatters:
          'Forms the master record for land title tracking, plot subdivision, and project-level profit calculation.',
    ),
    HelpTopic(
      id: 'plot_subdivision',
      title: 'Plot Subdivision & Cataloging',
      category: 'Plots',
      description:
          'Subdivide acquired master land into individual marketable plots with custom pricing.',
      steps:
          '1. Open Project Details.\n2. Go to Plots Directory tab.\n3. Click "Subdivide Plot".\n4. Enter Plot Number, Area, and Selling Price.\n5. Status auto-updates upon sale.',
      whyItMatters:
          'Enables accurate inventory control, preventing double-selling of plots.',
    ),
    HelpTopic(
      id: 'buyer_sales',
      title: 'Recording Buyer Sales & Agreements',
      category: 'Sales',
      description:
          'Book sales agreements with buyers, defining payment plans (outright cash or installment plan).',
      steps:
          '1. Navigate to Buyers & Sales screen.\n2. Click "+ New Sale Agreement".\n3. Select Buyer, Project, and Plot.\n4. Choose payment plan (Installment vs Full Cash).\n5. Generate official PDF agreement.',
      whyItMatters:
          'Locks plot availability and establishes buyer receivable schedules for cash flow tracking.',
    ),
    HelpTopic(
      id: 'investor_funding',
      title: 'Investor Capital & Equity Tracking',
      category: 'Investors (Admin Only)',
      description:
          'Track investor equity capital contributions per project and calculate automated ROI distributions.',
      steps:
          '1. Go to Investors screen.\n2. Click "+ Record Investment".\n3. Link investor to project, enter capital amount, and upload investment agreement.\n4. Equity % auto-calculates.',
      whyItMatters:
          'Guarantees transparent capital accounting and accurate profit-sharing settlements upon project completion.',
      adminOnly: true,
    ),
    HelpTopic(
      id: 'pnl_settlement',
      title: 'Profit & Loss & ROI Settlement',
      category: 'Finance (Admin Only)',
      description:
          'Audit gross project profit margins and execute investor profit disbursements.',
      steps:
          '1. Open Profit & Loss screen.\n2. Review Gross Project Profit (Booked Sales - Land & Capitalized Cost).\n3. Switch to Investor ROI Settlements tab.\n4. Click "Disburse" to process investor payouts.',
      whyItMatters:
          'Ensures mathematically verifiable payout calculations based on equity share.',
      adminOnly: true,
    ),
    HelpTopic(
      id: 'audit_log',
      title: 'Security Audit Log',
      category: 'Security (Admin Only)',
      description:
          'Immutably records every financial transaction, agreement creation, and status modification.',
      steps:
          '1. Open Security Audit Log from sidebar.\n2. Filter by User, Feature, or Date.\n3. Review timestamped audit trail.',
      whyItMatters:
          'Provides complete operational accountability and forensic security trail.',
      adminOnly: true,
    ),
  ];
}

final helpGuideSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');
final helpGuideSelectedTopicIdProvider = StateProvider.autoDispose<String?>((ref) => 'getting_started');

class HelpGuideScreen extends ConsumerWidget {
  const HelpGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(helpGuideSearchQueryProvider);
    final selectedTopicId = ref.watch(helpGuideSelectedTopicIdProvider);
    final currentRole = ref.watch(currentRoleProvider);

    // Role-aware filtering: Member sees NO investor help topics
    final visibleTopics = HelpTopicsData.topics.where((t) {
      if (!currentRole.isAdmin && t.adminOnly) return false;
      if (searchQuery.isEmpty) return true;
      final q = searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
    }).toList();

    final selectedTopic = visibleTopics.firstWhere(
      (t) => t.id == selectedTopicId,
      orElse: () => visibleTopics.isNotEmpty ? visibleTopics.first : HelpTopicsData.topics.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Help & User Guide',
          subtitle:
              'In-app documentation, operational walkthroughs, and embedded User Manual guidance.',
          icon: Icons.help_outline,
          actions: [
            ElevatedButton.icon(
              onPressed: () => UserGuidePdfDialog.show(
                context,
                topics: visibleTopics,
                isAdmin: currentRole.isAdmin,
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('Export User Manual (PDF)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Search bar
        SizedBox(
          width: 400,
          child: TextField(
            onChanged: (val) => ref.read(helpGuideSearchQueryProvider.notifier).state = val,
            decoration: const InputDecoration(
              hintText: 'Search help topics...',
              prefixIcon: Icon(Icons.search, size: 18),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            style: AppTypography.input.copyWith(fontSize: 14),
          ),
        ),
        const SizedBox(height: 16),
        // Two-column layout: Topics list on left, topic detail on right
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Topic List
              SizedBox(
                width: 320,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListView.separated(
                    itemCount: visibleTopics.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final topic = visibleTopics[index];
                      final isSelected = topic.id == selectedTopic.id;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppColors.surfaceSubtle,
                        title: Text(
                          topic.title,
                          style: AppTypography.body.copyWith(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? AppColors.accent : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              topic.category,
                              style: AppTypography.secondary.copyWith(fontSize: 12),
                            ),
                            if (topic.adminOnly) ...[
                              const SizedBox(width: 8),
                              const StatusBadge(label: 'ADMIN', type: BadgeType.warning),
                            ],
                          ],
                        ),
                        onTap: () => ref.read(helpGuideSelectedTopicIdProvider.notifier).state = topic.id,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Right Column - Topic Detail with Smooth Switcher Animation
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.015, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(selectedTopic.id),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                StatusBadge(label: selectedTopic.category.toUpperCase(), type: BadgeType.info),
                                if (selectedTopic.adminOnly) ...[
                                  const SizedBox(width: 8),
                                  const StatusBadge(label: 'ADMIN ONLY', type: BadgeType.warning),
                                ],
                                const Spacer(),
                                OutlinedButton.icon(
                                  onPressed: () => UserGuidePdfDialog.show(
                                    context,
                                    topics: visibleTopics,
                                    isAdmin: currentRole.isAdmin,
                                    initialSingleTopic: selectedTopic,
                                  ),
                                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                                  label: const Text('Export Topic PDF'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(selectedTopic.title, style: AppTypography.pageTitle.copyWith(fontSize: 22)),
                            const SizedBox(height: 12),
                            Text(selectedTopic.description, style: AppTypography.body.copyWith(fontSize: 14, height: 1.5)),
                            const Divider(height: 32),

                            Text('Operational Walkthrough / Steps', style: AppTypography.sectionTitle),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(selectedTopic.steps, style: AppTypography.body.copyWith(fontSize: 13, height: 1.6)),
                            ),
                            const SizedBox(height: 24),

                            Text('Why This Workflow Matters', style: AppTypography.sectionTitle),
                            const SizedBox(height: 8),
                            Text(selectedTopic.whyItMatters, style: AppTypography.secondary.copyWith(fontSize: 13, height: 1.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
