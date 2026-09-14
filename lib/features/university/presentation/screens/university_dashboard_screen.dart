import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../university_provider.dart';
import '../../../../services/university_portal_repository.dart';

class UniversityDashboardScreen extends ConsumerStatefulWidget {
  const UniversityDashboardScreen({super.key});

  @override
  ConsumerState<UniversityDashboardScreen> createState() =>
      _UniversityDashboardScreenState();
}

class _UniversityDashboardScreenState
    extends ConsumerState<UniversityDashboardScreen> {
  late Future<UniversityStats> _stats;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final organizationId =
        ref.read(authControllerProvider).currentUser?.id ?? '';
    _stats = ref.read(universityRepositoryProvider).getStats(organizationId);
  }

  Future<void> _openAndReload(String location) async {
    await context.push(location);
    if (mounted) setState(_reload);
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
          'Are you sure you want to sign out of the university portal?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.organizationProfile;
    final name = profile?.orgName.isNotEmpty == true
        ? profile!.orgName
        : (auth.currentUser?.name.isNotEmpty == true
            ? auth.currentUser!.name
            : 'University Partner');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'University Portal',
          style: AppTextStyles.titleLarge(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'University Profile',
            onPressed: () => context.go(RouteNames.universityProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: FutureBuilder<UniversityStats>(
        future: _stats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load dashboard data.',
                      style: AppTextStyles.titleMedium(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      snapshot.error is FirebaseException
                          ? (snapshot.error as FirebaseException).message ??
                              'Firebase error'
                          : 'Please check your connection and try again.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall(context),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Retry',
                      icon: Icons.refresh_rounded,
                      width: 140,
                      onPressed: () => setState(_reload),
                    ),
                  ],
                ),
              ),
            );
          }

          final stats =
              snapshot.data ??
              const UniversityStats(
                totalOpportunities: 0,
                activeOpportunities: 0,
                totalApplications: 0,
                pendingApplications: 0,
                publishedPosts: 0,
                engagement: 0,
              );

          return RefreshIndicator(
            onRefresh: () async {
              setState(_reload);
              await _stats;
            },
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.p20),
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              AppColors.primaryDark.withValues(alpha: 0.7),
                              AppColors.surfaceDark,
                            ]
                          : [
                              AppColors.primary.withValues(alpha: 0.12),
                              AppColors.secondary.withValues(alpha: 0.06),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppDimensions.roundedLarge,
                    border: Border.all(
                      color: isDark
                          ? AppColors.cardBorderDark
                          : AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: AppTextStyles.displayMedium(
                              context,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleLarge(context),
                                  ),
                                ),
                                if (profile?.isVerified == true) ...[
                                  const SizedBox(width: 6),
                                  const VerifiedBadge(isVerified: true),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.orgType ??
                                  'Accredited University / Organization',
                              style: AppTextStyles.bodySmall(
                                context,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Grid Section
                Text(
                  'Overview & Metrics',
                  style: AppTextStyles.titleMedium(context),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final crossAxisCount = isWide ? 4 : 2;
                    final cardWidth =
                        (constraints.maxWidth - ((crossAxisCount - 1) * 12)) /
                        crossAxisCount;
                    final cardHeight =
                        constraints.maxWidth < 360 ? 128.0 : 116.0;
                    final ratio = (cardWidth / cardHeight).clamp(0.95, 1.8);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: ratio,
                      children: [
                        _MetricCard(
                          icon: Icons.work_outline_rounded,
                          iconColor: AppColors.primaryMint,
                          label: 'Active Opportunities',
                          value: '${stats.activeOpportunities}',
                          subtext:
                              'Total: ${stats.totalOpportunities > 0 ? stats.totalOpportunities : stats.activeOpportunities}',
                        ),
                        _MetricCard(
                          icon: Icons.assignment_outlined,
                          iconColor: AppColors.secondary,
                          label: 'Applications',
                          value: '${stats.totalApplications}',
                          subtext: 'Received so far',
                        ),
                        _MetricCard(
                          icon: Icons.pending_actions_rounded,
                          iconColor: AppColors.warning,
                          label: 'Pending Reviews',
                          value: '${stats.pendingApplications}',
                          subtext: 'Require decision',
                        ),
                        _MetricCard(
                          icon: Icons.campaign_outlined,
                          iconColor: AppColors.primary,
                          label: 'Community Posts',
                          value: '${stats.publishedPosts}',
                          subtext: '${stats.engagement} engagements',
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 28),

                // Quick Actions Command Center
                Text(
                  'Quick Actions',
                  style: AppTextStyles.titleMedium(context),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final crossAxisCount = isWide ? 3 : 2;
                    final cardWidth =
                        (constraints.maxWidth - ((crossAxisCount - 1) * 12)) /
                        crossAxisCount;
                    final cardHeight =
                        constraints.maxWidth < 360 ? 128.0 : 116.0;
                    final ratio = (cardWidth / cardHeight).clamp(0.95, 1.8);
                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: ratio,
                      children: [
                        _ActionCard(
                          icon: Icons.add_business_rounded,
                          iconColor: AppColors.primary,
                          title: 'Create Opportunity',
                          subtitle: 'Post scholarships & internships',
                          onTap: () => _openAndReload(
                            '/university/opportunities/create',
                          ),
                        ),
                        _ActionCard(
                          icon: Icons.list_alt_rounded,
                          iconColor: AppColors.secondary,
                          title: 'Manage Listings',
                          subtitle: 'Edit, close, or review status',
                          onTap: () =>
                              context.go(RouteNames.universityOpportunities),
                        ),
                        _ActionCard(
                          icon: Icons.people_outline_rounded,
                          iconColor: AppColors.accentGold,
                          title: 'Review Applicants',
                          subtitle: 'Track candidate submissions',
                          onTap: () =>
                              context.go(RouteNames.universityApplications),
                        ),
                        _ActionCard(
                          icon: Icons.campaign_rounded,
                          iconColor: AppColors.primaryMint,
                          title: 'Create Post / Notice',
                          subtitle: 'Admissions & general updates',
                          onTap: () =>
                              _openAndReload('/university/posts/create'),
                        ),
                        _ActionCard(
                          icon: Icons.article_outlined,
                          iconColor: Colors.deepPurpleAccent,
                          title: 'Official Posts',
                          subtitle: 'View and manage community feed',
                          onTap: () => context.go(RouteNames.universityPosts),
                        ),
                        _ActionCard(
                          icon: Icons.account_circle_outlined,
                          iconColor: Colors.blueGrey,
                          title: 'University Profile',
                          subtitle: 'Details, accreditation & contact',
                          onTap: () => context.go(RouteNames.universityProfile),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String subtext;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.displayMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium(
                    context,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(
                    context,
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textSecondaryLight,
                  ).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.roundedLarge,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: AppDimensions.roundedLarge,
          border: Border.all(
            color: isDark
                ? AppColors.cardBorderDark
                : AppColors.cardBorderLight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMutedLight,
                ),
              ],
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall(
                      context,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondaryLight,
                    ).copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
