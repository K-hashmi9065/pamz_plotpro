import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum BadgeType {
  success,
  warning,
  danger,
  info,
  neutral,
}

/// Standard status badge paired with semantic color, background, text, and optional icon.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
  });

  Color get _bgColor {
    switch (type) {
      case BadgeType.success:
        return AppColors.successBg;
      case BadgeType.warning:
        return AppColors.warningBg;
      case BadgeType.danger:
        return AppColors.dangerBg;
      case BadgeType.info:
        return AppColors.infoBg;
      case BadgeType.neutral:
        return AppColors.surfaceSubtle;
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.success:
        return AppColors.successText;
      case BadgeType.warning:
        return AppColors.warningText;
      case BadgeType.danger:
        return AppColors.dangerText;
      case BadgeType.info:
        return AppColors.infoText;
      case BadgeType.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: _textColor,
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTypography.secondary.copyWith(
                color: _textColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
