import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../models/opportunity_model.dart';

/// Confirmation Dialog for One-Tap Apply ensuring safe redirection to the official external portal.
class ApplyConfirmationDialog extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onApplied;

  const ApplyConfirmationDialog({
    super.key,
    required this.opportunity,
    required this.onApplied,
  });

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.parse(opportunity.officialUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      onApplied();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryDark,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.primaryMint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Marked as "Applied" in your local profile tracker!',
                    style: AppTextStyles.labelMedium(context, color: Colors.white),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Could not open portal link: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.roundedLarge,
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.p24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.open_in_new_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'One-Tap Official Apply',
                        style: AppTextStyles.titleMedium(context),
                      ),
                      Text(
                        opportunity.isScholarship
                            ? 'Scholarship Portal Redirection'
                            : 'Internship Portal Redirection',
                        style: AppTextStyles.bodySmall(
                          context,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Opportunity Summary Box
            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.cardDark
                    : AppColors.backgroundLight,
                borderRadius: AppDimensions.roundedMedium,
                border: Border.all(
                  color: isDark
                      ? AppColors.cardBorderDark
                      : AppColors.cardBorderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          opportunity.title,
                          style: AppTextStyles.titleSmall(context),
                        ),
                      ),
                      if (opportunity.isVerified)
                        const VerifiedBadge(isVerified: true, isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    opportunity.organizationName,
                    style: AppTextStyles.labelSmall(
                      context,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Official URL box
            Text(
              'Official Application URL:',
              style: AppTextStyles.labelSmall(
                context,
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.secondary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.link_rounded,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      opportunity.officialUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSmall(
                        context,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Important Transparency Notice
            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: AppDimensions.roundedMedium,
                border: Border.all(
                  color: AppColors.warning.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will be redirected to the provider\'s official external website to submit your details. Skills Pathway does not submit applications on your behalf.',
                      style: AppTextStyles.bodySmall(
                        context,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textPrimaryLight,
                      ).copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    variant: ButtonVariant.outline,
                    height: 44,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Proceed to Official Site',
                    variant: ButtonVariant.gradient,
                    icon: Icons.open_in_new_rounded,
                    isIconTrailing: true,
                    height: 44,
                    onPressed: () => _launchUrl(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
