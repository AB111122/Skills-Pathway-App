import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/stat_badge.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../models/opportunity_model.dart';
import '../controllers/opportunity_controller.dart';
import '../widgets/apply_confirmation_dialog.dart';

class OpportunityDetailScreen extends ConsumerStatefulWidget {
  final String opportunityId;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  ConsumerState<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends ConsumerState<OpportunityDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(opportunityControllerProvider.notifier)
          .loadOpportunityDetails(widget.opportunityId);
    });
  }

  void _showApplyDialog(OpportunityModel opp) {
    showDialog(
      context: context,
      builder: (_) => ApplyConfirmationDialog(
        opportunity: opp,
        onApplied: () {
          ref
              .read(opportunityControllerProvider.notifier)
              .markApplied(opp.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(opportunityControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final opp = state.selectedOpportunity ??
        state.opportunities.cast<OpportunityModel?>().firstWhere(
              (o) => o?.id == widget.opportunityId,
              orElse: () => null,
            );

    if (state.isLoading && opp == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const LoadingIndicator(message: 'Loading opportunity details...'),
      );
    }

    if (opp == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          title: 'Opportunity Not Found',
          message: 'This listing could not be found or has expired.',
          onRetry: () => ref
              .read(opportunityControllerProvider.notifier)
              .loadOpportunityDetails(widget.opportunityId),
        ),
      );
    }

    final isUrgent = DateFormatter.isUrgent(opp.deadline);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          opp.isScholarship ? 'Scholarship Details' : 'Internship Details',
          style: AppTextStyles.titleMedium(context),
        ),
        actions: [
          // Deadline reminder bell
          IconButton(
            icon: Icon(
              opp.hasDeadlineReminder
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
              color: opp.hasDeadlineReminder
                  ? AppColors.accentGold
                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
            ),
            tooltip: 'Set Deadline Reminder',
            onPressed: () {
              ref
                  .read(opportunityControllerProvider.notifier)
                  .toggleDeadlineReminder(opp.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    opp.hasDeadlineReminder
                        ? 'Reminder removed for this deadline.'
                        : 'Deadline reminder activated! You will receive alerts before closing.',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          // Bookmark save action
          IconButton(
            icon: Icon(
              opp.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: opp.isSaved
                  ? AppColors.accentGold
                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
            ),
            onPressed: () {
              ref
                  .read(opportunityControllerProvider.notifier)
                  .toggleSave(opp.id);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Box: Org Name, Title, Verified Badge, Funding Pill
                    _buildHeaderCard(context, opp, isDark),
                    const SizedBox(height: 16),

                    // Deadline & Countdown Banner
                    _buildDeadlineContainer(context, opp, isUrgent, isDark),
                    const SizedBox(height: 20),

                    // Description Section
                    _buildSectionContainer(
                      context,
                      isDark,
                      icon: Icons.description_outlined,
                      title: 'Program Overview',
                      content: Text(
                        opp.fullDescription,
                        style: AppTextStyles.bodyMedium(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Funding & Benefits Section
                    if (opp.benefits.isNotEmpty) ...[
                      _buildSectionContainer(
                        context,
                        isDark,
                        icon: Icons.card_giftcard_rounded,
                        title: 'Funding & Benefits',
                        content: Column(
                          children: opp.benefits
                              .map(
                                (b) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: AppColors.primaryMint,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          b,
                                          style: AppTextStyles.bodyMedium(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Eligibility Criteria Section
                    if (opp.eligibilityCriteria.isNotEmpty) ...[
                      _buildSectionContainer(
                        context,
                        isDark,
                        icon: Icons.fact_check_outlined,
                        title: 'Eligibility Requirements',
                        content: Column(
                          children: opp.eligibilityCriteria
                              .map(
                                (c) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.arrow_right_rounded,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          c,
                                          style: AppTextStyles.bodyMedium(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Required Skills Section
                    if (opp.requiredSkills.isNotEmpty) ...[
                      _buildSectionContainer(
                        context,
                        isDark,
                        icon: Icons.psychology_outlined,
                        title: 'Target Skills & Expertise',
                        content: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: opp.requiredSkills
                              .map(
                                (s) => StatBadge(
                                  text: s,
                                  style: StatBadgeStyle.primary,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Required Documents Checklist
                    if (opp.requiredDocuments.isNotEmpty) ...[
                      _buildSectionContainer(
                        context,
                        isDark,
                        icon: Icons.folder_open_rounded,
                        title: 'Required Application Documents',
                        content: Column(
                          children: opp.requiredDocuments
                              .map(
                                (doc) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.description_outlined,
                                        size: 16,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          doc,
                                          style: AppTextStyles.bodySmall(
                                            context,
                                          ).copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Verification Trust Box
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p16),
                      decoration: BoxDecoration(
                        color: opp.isVerified
                            ? AppColors.primary.withValues(alpha: 0.08)
                            : AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: AppDimensions.roundedLarge,
                        border: Border.all(
                          color: opp.isVerified
                              ? AppColors.primary.withValues(alpha: 0.25)
                              : AppColors.warning.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            opp.isVerified
                                ? Icons.verified_user_rounded
                                : Icons.info_outline_rounded,
                            color: opp.isVerified
                                ? AppColors.primary
                                : AppColors.warning,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  opp.isVerified
                                      ? 'Verified Opportunity'
                                      : 'Community Listing (Verification Pending)',
                                  style: AppTextStyles.titleSmall(context),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  opp.isVerified
                                      ? 'This listing was verified through official institution accreditation and official domain validation.'
                                      : 'This opportunity was submitted by the student community and is undergoing verification review.',
                                  style: AppTextStyles.bodySmall(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Action Bar with One-Tap Apply
            Container(
              padding: const EdgeInsets.all(AppDimensions.p20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorderLight,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Bookmark toggle
                  Container(
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
                    child: IconButton(
                      icon: Icon(
                        opp.isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: opp.isSaved
                            ? AppColors.accentGold
                            : (isDark
                                ? AppColors.textMutedDark
                                : AppColors.textSecondaryLight),
                      ),
                      onPressed: () {
                        ref
                            .read(opportunityControllerProvider.notifier)
                            .toggleSave(opp.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),

                  // One-Tap Apply Button / Applied State
                  Expanded(
                    child: opp.isApplied
                        ? Container(
                            height: AppDimensions.buttonHeight,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: AppDimensions.roundedMedium,
                              border: Border.all(
                                color: AppColors.success.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Applied via Official Portal',
                                    style: AppTextStyles.labelLarge(
                                      context,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : CustomButton(
                            text: 'One-Tap Apply',
                            variant: ButtonVariant.gradient,
                            icon: Icons.open_in_new_rounded,
                            isIconTrailing: true,
                            onPressed: () => _showApplyDialog(opp),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    OpportunityModel opp,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.p20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppDimensions.roundedLarge,
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Org Row
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: AppDimensions.roundedMedium,
                ),
                child: Center(
                  child: Text(
                    opp.organizationName.isNotEmpty
                        ? opp.organizationName.substring(0, 1).toUpperCase()
                        : 'O',
                    style: AppTextStyles.titleLarge(
                      context,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            opp.organizationName,
                            style: AppTextStyles.labelLarge(
                              context,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        if (opp.isVerified) ...[
                          const SizedBox(width: 6),
                          const VerifiedBadge(isVerified: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          opp.location,
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            opp.title,
            style: AppTextStyles.titleLarge(context),
          ),
          const SizedBox(height: 16),

          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatBadge(
                text: opp.isScholarship ? 'Scholarship' : 'Internship',
                style: StatBadgeStyle.primary,
                icon: opp.isScholarship
                    ? Icons.school_outlined
                    : Icons.work_outline_rounded,
              ),
              if (opp.isInternship)
                StatBadge(
                  text: opp.isPaid ? 'Paid' : 'Unpaid',
                  style: opp.isPaid
                      ? StatBadgeStyle.success
                      : StatBadgeStyle.neutral,
                ),
              if (opp.duration != null)
                StatBadge(
                  text: opp.duration!,
                  style: StatBadgeStyle.neutral,
                  icon: Icons.timelapse_rounded,
                ),
              if (opp.degreeLevel != null)
                StatBadge(
                  text: opp.degreeLevel!,
                  style: StatBadgeStyle.neutral,
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Funding Highlight Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryMint.withValues(alpha: 0.1),
              borderRadius: AppDimensions.roundedMedium,
              border: Border.all(
                color: AppColors.primaryMint.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opp.isScholarship
                            ? 'Scholarship Coverage'
                            : 'Compensation / Stipend',
                        style: AppTextStyles.labelSmall(
                          context,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      Text(
                        opp.stipendOrFunding,
                        style: AppTextStyles.titleSmall(
                          context,
                          color: AppColors.primaryDark,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineContainer(
    BuildContext context,
    OpportunityModel opp,
    bool isUrgent,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.p16),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.accentRose.withValues(alpha: 0.1)
            : (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: AppDimensions.roundedLarge,
        border: Border.all(
          color: isUrgent
              ? AppColors.accentRose.withValues(alpha: 0.35)
              : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isUrgent
                  ? AppColors.accentRose.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              size: 20,
              color: isUrgent ? AppColors.accentRose : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Application Deadline',
                  style: AppTextStyles.labelSmall(
                    context,
                    color: isUrgent
                        ? AppColors.accentRose
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  DateFormatter.formatDate(opp.deadline),
                  style: AppTextStyles.titleSmall(context),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isUrgent ? AppColors.accentRose : AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              DateFormatter.formatDeadlineRemaining(opp.deadline),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppDimensions.roundedLarge,
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.titleSmall(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
