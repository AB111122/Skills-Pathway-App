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

class UniversityProfileScreen extends ConsumerWidget {
  const UniversityProfileScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.organizationProfile;
    final name = profile?.orgName.isNotEmpty == true
        ? profile!.orgName
        : (auth.currentUser?.name.isNotEmpty == true
            ? auth.currentUser!.name
            : 'University Profile');
    final organizationId = auth.currentUser?.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'University Profile',
          style: AppTextStyles.titleLarge(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Settings & Preferences',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RouteNames.settings),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: organizationId == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: Text(
                  'Please sign in to view your profile.',
                  style: AppTextStyles.bodyMedium(context),
                ),
              ),
            )
          : FutureBuilder<UniversityStats>(
              future: ref
                  .read(universityRepositoryProvider)
                  .getStats(organizationId),
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
                            size: 44,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Unable to load profile data.',
                            style: AppTextStyles.titleMedium(context),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            snapshot.error is FirebaseException
                                ? (snapshot.error as FirebaseException).message ??
                                    'Firebase error'
                                : 'Please try again later.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall(context),
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

                final oppCount = stats.totalOpportunities > 0
                    ? stats.totalOpportunities
                    : stats.activeOpportunities;

                return ListView(
                  padding: const EdgeInsets.all(AppDimensions.p20),
                  children: [
                    // Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.surfaceDark,
                                  AppColors.primaryDark.withValues(alpha: 0.5),
                                ]
                              : [
                                  Colors.white,
                                  AppColors.primary.withValues(alpha: 0.06),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppDimensions.roundedLarge,
                        border: Border.all(
                          color: isDark
                              ? AppColors.cardBorderDark
                              : AppColors.cardBorderLight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.2 : 0.04,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
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
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  textAlign: TextAlign.center,
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
                            profile?.orgType ?? 'University / Higher Education',
                            style: AppTextStyles.bodyMedium(
                              context,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Organization Details Card
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: AppDimensions.roundedLarge,
                        border: Border.all(
                          color: isDark
                              ? AppColors.cardBorderDark
                              : AppColors.cardBorderLight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About & Contact',
                            style: AppTextStyles.titleSmall(context),
                          ),
                          const SizedBox(height: 12),
                          _DetailRow(
                            icon: Icons.email_outlined,
                            label: 'Official Email',
                            value: profile?.officialEmail.isNotEmpty == true
                                ? profile!.officialEmail
                                : (auth.currentUser?.email.isNotEmpty == true
                                    ? auth.currentUser!.email
                                    : 'Not provided'),
                          ),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location / City',
                            value: profile?.city?.isNotEmpty == true
                                ? profile!.city!
                                : 'Not specified',
                          ),
                          _DetailRow(
                            icon: Icons.language_outlined,
                            label: 'Website',
                            value: profile?.website.isNotEmpty == true
                                ? profile!.website
                                : 'Not specified',
                          ),
                          if (profile?.registrationNumber?.isNotEmpty == true)
                            _DetailRow(
                              icon: Icons.badge_outlined,
                              label: 'Registration / Reg No.',
                              value: profile!.registrationNumber!,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Statistics Grid
                    Text(
                      'Activity & Statistics',
                      style: AppTextStyles.titleMedium(context),
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        final crossAxisCount = isWide ? 3 : 3;
                        final cardWidth =
                            (constraints.maxWidth -
                                ((crossAxisCount - 1) * 10)) /
                            crossAxisCount;
                        final cardHeight =
                            constraints.maxWidth < 360 ? 96.0 : 88.0;
                        final ratio = (cardWidth / cardHeight).clamp(0.85, 1.5);
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: ratio,
                          children: [
                            _StatBox(
                              label: 'Opportunities',
                              value: '$oppCount',
                              icon: Icons.work_outline_rounded,
                              color: AppColors.primaryMint,
                            ),
                            _StatBox(
                              label: 'Applications',
                              value: '${stats.totalApplications}',
                              icon: Icons.assignment_outlined,
                              color: AppColors.secondary,
                            ),
                            _StatBox(
                              label: 'Posts',
                              value: '${stats.publishedPosts}',
                              icon: Icons.campaign_outlined,
                              color: AppColors.primary,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Quick Actions
                    Text(
                      'Actions',
                      style: AppTextStyles.titleMedium(context),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Create Opportunity',
                      icon: Icons.add_business_rounded,
                      onPressed: () =>
                          context.push('/university/opportunities/create'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Manage Opportunities',
                      icon: Icons.list_alt_rounded,
                      variant: ButtonVariant.outline,
                      onPressed: () =>
                          context.go(RouteNames.universityOpportunities),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Create Community / Admissions Post',
                      icon: Icons.campaign_rounded,
                      variant: ButtonVariant.outline,
                      onPressed: () =>
                          context.push('/university/posts/create'),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'View Applications',
                      icon: Icons.people_outline_rounded,
                      variant: ButtonVariant.outline,
                      onPressed: () =>
                          context.go(RouteNames.universityApplications),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Sign Out',
                      icon: Icons.logout_rounded,
                      variant: ButtonVariant.outline,
                      onPressed: () => _logout(context, ref),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: AppTextStyles.bodySmall(
                      context,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  TextSpan(
                    text: value,
                    style: AppTextStyles.labelMedium(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.p12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppDimensions.roundedMedium,
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleMedium(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
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
    );
  }
}
