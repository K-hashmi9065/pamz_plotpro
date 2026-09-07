import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../page/page_header.dart';

/// Temporary placeholder widget for routes until feature module screens are built.
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const PlaceholderPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: title,
          subtitle: description,
          icon: icon,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppTypography.sectionTitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppTypography.secondary,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
