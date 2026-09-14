import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';

enum ButtonVariant { primary, secondary, outline, text, gradient }

/// Highly customizable reusable button supporting multiple visual variants, icons, and loading states.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isIconTrailing;
  final bool isLoading;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.icon,
    this.isIconTrailing = false,
    this.isLoading = false,
    this.width,
    this.height = AppDimensions.buttonHeight,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == ButtonVariant.gradient) {
      return Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppDimensions.roundedMedium,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMint.withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppDimensions.roundedMedium,
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: _buildContent(context, Colors.white),
            ),
          ),
        ),
      );
    }

    if (variant == ButtonVariant.outline) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: backgroundColor ?? AppColors.primary,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.roundedMedium,
            ),
          ),
          child: _buildContent(
            context,
            textColor ?? backgroundColor ?? AppColors.primary,
          ),
        ),
      );
    }

    if (variant == ButtonVariant.text) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildContent(
          context,
          textColor ?? AppColors.primary,
        ),
      );
    }

    // Default: Primary or Secondary
    final bg = backgroundColor ??
        (variant == ButtonVariant.secondary
            ? AppColors.secondary
            : AppColors.primary);
    final fg = textColor ?? Colors.white;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedMedium,
          ),
        ),
        child: _buildContent(context, fg),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color fgColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    }

    final textWidget = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTextStyles.labelLarge(context, color: fgColor),
    );

    if (icon == null) return textWidget;

    final iconWidget = Icon(icon, size: 18, color: fgColor);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: isIconTrailing
          ? [Flexible(child: textWidget), const SizedBox(width: 8), iconWidget]
          : [iconWidget, const SizedBox(width: 8), Flexible(child: textWidget)],
    );
  }
}
