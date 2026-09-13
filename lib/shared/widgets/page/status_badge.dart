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

/// Standard status badge paired with semantic color, background, border, text, and optional icon or indicator dot.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
    this.showDot = false,
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

  Color get _borderColor {
    switch (type) {
      case BadgeType.success:
        return AppColors.successBorder;
      case BadgeType.warning:
        return AppColors.warningBorder;
      case BadgeType.danger:
        return AppColors.dangerBorder;
      case BadgeType.info:
        return AppColors.infoBorder;
      case BadgeType.neutral:
        return AppColors.border;
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 11,
              color: _textColor,
            ),
            const SizedBox(width: 4),
          ] else if (showDot) ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: _textColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4.5),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTypography.badge.copyWith(
                color: _textColor,
                fontSize: 11.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
