import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../../models/opportunity_model.dart';
import '../theme/text_styles.dart';
import '../utils/date_formatter.dart';
import 'stat_badge.dart';
import 'verified_badge.dart';

/// Reusable Opportunity Card widget used across Dashboard, Search, and Recommendations.
class OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback? onTap;
  final VoidCallback? onSaveToggle;
  final bool isHorizontal;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.onSaveToggle,
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUrgent = DateFormatter.isUrgent(opportunity.deadline);

    return Container(
      width: isHorizontal ? 280 : double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppDimensions.roundedLarge,
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDimensions.roundedLarge,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Org info, Verified badge & Save Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Org Initial / Logo
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppDimensions.roundedMedium,
                      ),
                      child: Center(
                        child: Text(
                          opportunity.organizationName.isNotEmpty
                              ? opportunity.organizationName
                                    .substring(0, 1)
                                    .toUpperCase()
                              : 'O',
                          style: AppTextStyles.titleMedium(
                            context,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Org Name & Location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  opportunity.organizationName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelMedium(
                                    context,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                              if (opportunity.isVerified) ...[
                                const SizedBox(width: 4),
                                const VerifiedBadge(
                                  isVerified: true,
                                  isCompact: true,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  opportunity.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall(
                                    context,
                                    color: isDark
                                        ? AppColors.textMutedDark
                                        : AppColors.textMutedLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Save action
                    if (onSaveToggle != null)
                      IconButton(
                        icon: Icon(
                          opportunity.isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          size: 22,
                          color: opportunity.isSaved
                              ? AppColors.accentGold
                              : (isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight),
                        ),
                        onPressed: onSaveToggle,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        splashRadius: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Opportunity Title
                Text(
                  opportunity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall(context),
                ),
                const SizedBox(height: 6),

                // Short Description
                if (!isHorizontal)
                  Text(
                    opportunity.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(context),
                  ),
                const SizedBox(height: 12),

                // Tags & Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    StatBadge(
                        text: opportunity.type.label,
                      style: StatBadgeStyle.primary,
                      icon: opportunity.type == OpportunityType.scholarship
                          ? Icons.school_outlined
                          : Icons.work_outline_rounded,
                    ),
                    if (opportunity.isInternship)
                      StatBadge(
                        text: opportunity.isPaid ? 'Paid' : 'Unpaid',
                        style: opportunity.isPaid
                            ? StatBadgeStyle.success
                            : StatBadgeStyle.neutral,
                      ),
                    StatBadge(
                      text: opportunity.stipendOrFunding,
                      style: StatBadgeStyle.info,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Divider(),
                const SizedBox(height: 8),

                // Bottom Row: Deadline & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: isUrgent
                              ? AppColors.accentRose
                              : (isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textMutedLight),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDeadlineRemaining(
                            opportunity.deadline,
                          ),
                          style:
                              AppTextStyles.labelSmall(
                                context,
                                color: isUrgent
                                    ? AppColors.accentRose
                                    : (isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textSecondaryLight),
                              ).copyWith(
                                fontWeight: isUrgent
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                    if (opportunity.isVerified)
                      const VerifiedBadge(isVerified: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
