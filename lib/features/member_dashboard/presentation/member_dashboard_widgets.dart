import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Shared small widgets used by Buyer/Investor/Landowner dashboard screens.

class MemberSummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const MemberSummaryCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(value,
              style: AppTypography.pageTitle.copyWith(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.secondary.copyWith(fontSize: 12.5)),
        ],
      ),
    );
  }
}

class MemberSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const MemberSectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 8),
        Text(title,
            style: AppTypography.cardTitle
                .copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
      ],
    );
  }
}

class MemberFinancialTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const MemberFinancialTile(
      {super.key,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.secondary.copyWith(fontSize: 12)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w700, fontSize: 15, color: color)),
      ],
    );
  }
}

class MemberEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const MemberEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 32, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: AppTypography.cardTitle
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: AppTypography.secondary.copyWith(fontSize: 13.5)),
          ],
        ),
      ),
    );
  }
}
