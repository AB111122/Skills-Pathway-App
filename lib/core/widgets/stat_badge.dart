import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../theme/text_styles.dart';

enum StatBadgeStyle { neutral, success, warning, error, primary, info }

/// Reusable pill badge for tags, categories, funding types, and status indicators.
class StatBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final StatBadgeStyle style;
  final Color? customColor;
  final VoidCallback? onTap;

  const StatBadge({
    super.key,
    required this.text,
    this.icon,
    this.style = StatBadgeStyle.neutral,
    this.customColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor) = _getColors(context);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fgColor.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fgColor),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall(context, color: fgColor).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: content,
      );
    }

    return content;
  }

  (Color, Color) _getColors(BuildContext context) {
    if (customColor != null) {
      return (customColor!.withValues(alpha: 0.12), customColor!);
    }

    switch (style) {
      case StatBadgeStyle.primary:
        return (AppColors.primary.withValues(alpha: 0.1), AppColors.primary);
      case StatBadgeStyle.success:
        return (AppColors.success.withValues(alpha: 0.12), AppColors.success);
      case StatBadgeStyle.warning:
        return (AppColors.warning.withValues(alpha: 0.15), AppColors.warning);
      case StatBadgeStyle.error:
        return (AppColors.error.withValues(alpha: 0.12), AppColors.error);
      case StatBadgeStyle.info:
        return (AppColors.info.withValues(alpha: 0.12), AppColors.info);
      case StatBadgeStyle.neutral:
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return (
          isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.textPrimaryLight.withValues(alpha: 0.06),
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        );
    }
  }
}
