import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final profile = auth.organizationProfile;
    final name =
        profile?.orgName ?? auth.currentUser?.name ?? 'University Portal';

    return Scaffold(
      appBar: AppBar(title: const Text('University Dashboard')),
      body: FutureBuilder<UniversityStats>(
        future: _stats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load dashboard. ${snapshot.error is FirebaseException ? (snapshot.error as FirebaseException).code : 'Please try again.'}',
              ),
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

          return RefreshIndicator(
            onRefresh: () async {
              setState(_reload);
              await _stats;
            },
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.p20),
              children: [
                Text(
                  'Welcome, $name',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Create Opportunity',
                  icon: Icons.add_business,
                  onPressed: () =>
                      _openAndReload('/university/opportunities/create'),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'Create Post',
                  icon: Icons.campaign_outlined,
                  variant: ButtonVariant.outline,
                  onPressed: () => _openAndReload('/university/posts/create'),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatCard(
                      label: 'Active Opportunities',
                      value: '${stats.activeOpportunities}',
                    ),
                    _StatCard(
                      label: 'Applications',
                      value: '${stats.totalApplications}',
                    ),
                    _StatCard(
                      label: 'Pending Applications',
                      value: '${stats.pendingApplications}',
                    ),
                    _StatCard(
                      label: 'Published Posts',
                      value: '${stats.publishedPosts}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Manage your university opportunities and official communications.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 160,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineMedium),
            Text(label),
          ],
        ),
      ),
    ),
  );
}
