import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../theme/text_styles.dart';
import 'custom_button.dart';

/// Reusable Empty State view with icon, title, description, and optional action button.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionButtonText;
  final VoidCallback? onActionPressed;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionButtonText,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.p32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.p24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.p20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium(context),
            ),
            const SizedBox(height: AppDimensions.p8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context),
            ),
            if (actionButtonText != null && onActionPressed != null) ...[
              const SizedBox(height: AppDimensions.p24),
              CustomButton(
                text: actionButtonText!,
                onPressed: onActionPressed,
                width: 200,
                variant: ButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
