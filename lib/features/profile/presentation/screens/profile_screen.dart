import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/stat_badge.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

/// User Profile Screen (Student / Organization)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authState.currentUser;
    final studentProfile = authState.studentProfile;
    final orgProfile = authState.organizationProfile;

    final displayName = studentProfile?.fullName ??
        orgProfile?.orgName ??
        user?.name ??
        'Fatima Zahra';

    final email = user?.email ?? 'fatima.zahra@nust.edu.pk';
    final isOrg = user?.isOrganization ?? false;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: AppTextStyles.titleLarge(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings & Preferences')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p20),
          child: Column(
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.p20),
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
                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Center(
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName.substring(0, 1).toUpperCase()
                              : 'U',
                          style: AppTextStyles.displayMedium(
                            context,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Name + Verified Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.titleLarge(context),
                        ),
                        if (isOrg && (orgProfile?.isVerified ?? false)) ...[
                          const SizedBox(width: 6),
                          const VerifiedBadge(isVerified: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Text(
                      email,
                      style: AppTextStyles.bodyMedium(
                        context,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Role Badge
                    StatBadge(
                      text: isOrg ? 'University / Provider' : 'Student Account',
                      style: StatBadgeStyle.primary,
                      icon: isOrg ? Icons.business_rounded : Icons.school_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Academic / Organization Details
              if (!isOrg && studentProfile != null) ...[
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
                        'Academic Details',
                        style: AppTextStyles.titleSmall(context),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        context,
                        'Education Level',
                        studentProfile.educationLevel,
                      ),
                      _buildDetailRow(
                        context,
                        'Degree',
                        studentProfile.degree,
                      ),
                      _buildDetailRow(
                        context,
                        'University',
                        studentProfile.universityOrCollege,
                      ),
                      _buildDetailRow(
                        context,
                        'City',
                        studentProfile.city,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Skills',
                        style: AppTextStyles.labelMedium(context),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: studentProfile.skills.map((skill) {
                          return StatBadge(
                            text: skill,
                            style: StatBadgeStyle.neutral,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Quick Actions
              _buildActionTile(
                context,
                icon: Icons.bookmark_border_rounded,
                title: 'Saved Opportunities',
                subtitle: 'View bookmarked scholarships & internships',
                onTap: () => context.go(RouteNames.opportunities),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                context,
                icon: Icons.assignment_outlined,
                title: 'My Applications',
                subtitle: 'Track the status of submitted applications',
                onTap: () => context.go(RouteNames.applications),
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                context,
                icon: Icons.auto_awesome_outlined,
                title: 'Career Roadmap & Insights',
                subtitle: 'Personalized learning steps and skill gaps',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('AI Career Roadmap is scheduled for Phase 6!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                context,
                icon: Icons.description_outlined,
                title: 'Resume & Market Fit Analysis',
                subtitle: 'Resume upload & benchmark against listings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Market Fit & Resume parser ready in Phase 7!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Logout Button
              CustomButton(
                text: 'Sign Out',
                variant: ButtonVariant.outline,
                icon: Icons.logout_rounded,
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(RouteNames.login);
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodySmall(
              context,
              color: isDark
                  ? AppColors.textMutedDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.roundedMedium,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: AppDimensions.roundedMedium,
          border: Border.all(
            color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleSmall(context),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textMutedLight,
            ),
          ],
        ),
      ),
    );
  }
}
