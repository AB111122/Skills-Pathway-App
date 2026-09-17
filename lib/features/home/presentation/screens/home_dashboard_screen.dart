import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/opportunity_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/stat_badge.dart';
import '../../../../models/opportunity_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../opportunities/presentation/controllers/opportunity_controller.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final oppState = ref.watch(opportunityControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userName = authState.studentProfile?.fullName ??
        authState.currentUser?.name ??
        'Student';

    final opportunities = oppState.opportunities;

    final upcomingDeadlines = opportunities
        .where((opp) => opp.deadline.difference(DateTime.now()).inDays <= 7)
        .toList();

    final scholarships = opportunities
        .where((opp) => opp.type == OpportunityType.scholarship)
        .take(3)
        .toList();

    final internships = opportunities
        .where((opp) => opp.type == OpportunityType.internship)
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Top Bar: Greeting & Notifications
              _buildTopBar(context, userName, isDark),
              const SizedBox(height: 20),

              // Profile Completion Card
              _buildProfileCompletionCard(context, isDark),
              const SizedBox(height: 20),

              // Quick AI Assistant Shortcut Banner
              _buildAiPromptBanner(context),
              const SizedBox(height: 24),

              // Upcoming Deadlines Carousel
              if (upcomingDeadlines.isNotEmpty) ...[
                SectionHeader(
                  title: AppStrings.upcomingDeadlines,
                  subtitle: 'Opportunities closing in the next 7 days',
                  icon: Icons.timer_outlined,
                  actionText: AppStrings.viewAll,
                  onActionTap: () => context.go(RouteNames.opportunities),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 275,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcomingDeadlines.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final opp = upcomingDeadlines[index];
                      return OpportunityCard(
                        opportunity: opp,
                        isHorizontal: true,
                        onSaveToggle: () {
                          ref
                              .read(opportunityControllerProvider.notifier)
                              .toggleSave(opp.id);
                        },
                        onTap: () => context.push('/opportunities/${opp.id}'),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Pakistan Market Pulse Snapshot
              _buildMarketPulseCard(context, isDark),
              const SizedBox(height: 24),

              // Recommended Scholarships Section
              SectionHeader(
                title: AppStrings.recommendedScholarships,
                subtitle: 'Matched with your academic profile',
                icon: Icons.school_outlined,
                actionText: AppStrings.viewAll,
                onActionTap: () => context.go(RouteNames.opportunities),
              ),
              const SizedBox(height: 8),
              ...scholarships.map(
                (opp) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: OpportunityCard(
                    opportunity: opp,
                    onSaveToggle: () {
                      ref
                          .read(opportunityControllerProvider.notifier)
                          .toggleSave(opp.id);
                    },
                    onTap: () => context.push('/opportunities/${opp.id}'),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Recommended Internships Section
              SectionHeader(
                title: AppStrings.recommendedInternships,
                subtitle: 'Verified corporate & tech trainee programs',
                icon: Icons.work_outline_rounded,
                actionText: AppStrings.viewAll,
                onActionTap: () => context.go(RouteNames.opportunities),
              ),
              const SizedBox(height: 8),
              ...internships.map(
                (opp) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: OpportunityCard(
                    opportunity: opp,
                    onSaveToggle: () {
                      ref
                          .read(opportunityControllerProvider.notifier)
                          .toggleSave(opp.id);
                    },
                    onTap: () => context.push('/opportunities/${opp.id}'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Community Discussion Snippet
              _buildCommunityTeaser(context, isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String userName, bool isDark) {
    return Row(
      children: [
        // Avatar
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'S',
              style: AppTextStyles.titleMedium(context, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalam-o-Alaikum,',
                style: AppTextStyles.bodySmall(
                  context,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge(context),
              ),
            ],
          ),
        ),

        // Notification Bell
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? AppColors.cardBorderDark
                  : AppColors.cardBorderLight,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 22,
            ),
            onPressed: () {
              context.push(RouteNames.notifications);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCompletionCard(BuildContext context, bool isDark) {
    const double progress = 0.85;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.p16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppDimensions.roundedLarge,
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppStrings.profileCompletionTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall(context),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(progress * 100).toInt()}%',
                style: AppTextStyles.labelLarge(
                  context,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8.0,
            percent: progress,
            backgroundColor: isDark
                ? AppColors.cardBorderDark
                : AppColors.cardBorderLight,
            progressColor: AppColors.primaryMint,
            barRadius: const Radius.circular(4),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppStrings.profileCompletionSubtitle,
                  style: AppTextStyles.bodySmall(
                    context,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => context.go(RouteNames.profile),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Update',
                  style: AppTextStyles.labelMedium(
                    context,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiPromptBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.p20),
      decoration: BoxDecoration(
        gradient: AppColors.aiBannerGradient,
        borderRadius: AppDimensions.roundedLarge,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.aiAssistantBannerTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleMedium(
                    context,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.aiAssistantBannerSubtitle,
            style: AppTextStyles.bodySmall(
              context,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: AppDimensions.roundedMedium,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '"How do I prepare for a tech internship in Pakistan?"',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall(
                            context,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => context.go(RouteNames.chatbot),
                borderRadius: AppDimensions.roundedMedium,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF4338CA),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketPulseCard(BuildContext context, bool isDark) {
    return Container(
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.primaryMint,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.marketPulse,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.titleSmall(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const StatBadge(
                text: 'Live Demand',
                style: StatBadgeStyle.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Top skills requested in verified 2026 internships & jobs:',
            style: AppTextStyles.bodySmall(
              context,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          _buildMarketSkillRow(
            context,
            'Python / AI Frameworks',
            0.48,
            '48% of listings',
          ),
          const SizedBox(height: 8),
          _buildMarketSkillRow(
            context,
            'Flutter / Mobile Dev',
            0.39,
            '39% of listings',
          ),
          const SizedBox(height: 8),
          _buildMarketSkillRow(
            context,
            'SQL & Cloud Architecture',
            0.34,
            '34% of listings',
          ),
        ],
      ),
    );
  }

  Widget _buildMarketSkillRow(
    BuildContext context,
    String skill,
    double ratio,
    String label,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                skill,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelSmall(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall(
                context,
                color: AppColors.primaryMint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearPercentIndicator(
          lineHeight: 6.0,
          percent: ratio,
          backgroundColor: AppColors.cardBorderLight.withValues(alpha: 0.5),
          progressColor: AppColors.primary,
          barRadius: const Radius.circular(3),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildCommunityTeaser(BuildContext context, bool isDark) {
    return Container(
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
              const Icon(
                Icons.forum_outlined,
                color: AppColors.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Student Community Buzz',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"How to write a strong Statement of Purpose for HEC / Global Scholarships?"',
            style: AppTextStyles.bodyMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              const StatBadge(
                text: 'r/Scholarships',
                style: StatBadgeStyle.primary,
              ),
              Text(
                '24 comments • 3h ago',
                style: AppTextStyles.labelSmall(
                  context,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              TextButton(
                onPressed: () => context.go(RouteNames.network),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Join Discussion'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
