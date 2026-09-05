import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../university_provider.dart';
import '../../../../services/university_portal_repository.dart';

class UniversityProfileScreen extends ConsumerWidget {
  const UniversityProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.organizationProfile;
    final name = profile?.orgName ?? auth.currentUser?.name ?? 'University';
    final organizationId = auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('University Profile'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Log out?'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
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
            },
          ),
        ],
      ),
      body: organizationId == null
          ? const Center(child: Text('Please sign in to view your profile.'))
          : FutureBuilder<UniversityStats>(
              future: ref
                  .read(universityRepositoryProvider)
                  .getStats(organizationId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load profile data.'),
                  );
                }
                final stats =
                    snapshot.data ??
                    const UniversityStats(
                      activeOpportunities: 0,
                      totalApplications: 0,
                      pendingApplications: 0,
                      publishedPosts: 0,
                      engagement: 0,
                    );
                final initial = name.isEmpty
                    ? 'U'
                    : name.substring(0, 1).toUpperCase();
                return ListView(
                  padding: const EdgeInsets.all(AppDimensions.p20),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.p20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile?.orgType ??
                                      'University / Higher Education',
                                ),
                                if (profile?.isVerified == true)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: VerifiedBadge(isVerified: true),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'Organization Details',
                      children: [
                        _InfoRow(
                          icon: Icons.email_outlined,
                          label:
                              profile?.officialEmail ??
                              auth.currentUser?.email ??
                              'Email not provided',
                        ),
                        _InfoRow(
                          icon: Icons.location_on_outlined,
                          label: profile?.city ?? 'Location not provided',
                        ),
                        _InfoRow(
                          icon: Icons.language_outlined,
                          label: profile?.website ?? 'Website not provided',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _Metric(
                          label: 'Active opportunities',
                          value: '${stats.activeOpportunities}',
                        ),
                        _Metric(
                          label: 'Applications',
                          value: '${stats.totalApplications}',
                        ),
                        _Metric(
                          label: 'Published posts',
                          value: '${stats.publishedPosts}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Manage Opportunities',
                      icon: Icons.work_outline,
                      onPressed: () =>
                          context.go(RouteNames.universityOpportunities),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Community & Admissions',
                      icon: Icons.campaign_outlined,
                      variant: ButtonVariant.outline,
                      onPressed: () => context.go(RouteNames.universityPosts),
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Sign Out',
                      icon: Icons.logout_rounded,
                      variant: ButtonVariant.outline,
                      onPressed: () => _logout(context, ref),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) context.go(RouteNames.login);
    }
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection({required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppDimensions.p16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    ),
  );
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  const _Metric({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    ),
  );
}
