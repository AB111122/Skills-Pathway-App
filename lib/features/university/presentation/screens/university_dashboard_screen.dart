import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../university_provider.dart';
import '../../../../services/university_portal_repository.dart';

class UniversityDashboardScreen extends ConsumerWidget {
  const UniversityDashboardScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) { final auth = ref.watch(authControllerProvider); final profile = auth.organizationProfile; final name = profile?.orgName ?? auth.currentUser?.name ?? 'University Portal'; final organizationId = auth.currentUser?.id ?? ''; return Scaffold(appBar: AppBar(title: const Text('University Dashboard')), body: FutureBuilder<UniversityStats>(future: ref.read(universityRepositoryProvider).getStats(organizationId), builder: (context, snapshot) { final stats = snapshot.data ?? const UniversityStats(activeOpportunities: 0, totalApplications: 0, pendingApplications: 0, publishedPosts: 0, engagement: 0); return ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [Text('Welcome, $name', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 20), CustomButton(text: 'Create Opportunity', icon: Icons.add_business, onPressed: () => context.push('/university/opportunities/create')), const SizedBox(height: 10), CustomButton(text: 'Create Post', icon: Icons.campaign_outlined, variant: ButtonVariant.outline, onPressed: () => context.push('/university/posts/create')), const SizedBox(height: 24), Wrap(spacing: 10, runSpacing: 10, children: [_StatCard(label: 'Active Opportunities', value: '${stats.activeOpportunities}'), _StatCard(label: 'Applications', value: '${stats.totalApplications}'), _StatCard(label: 'Published Posts', value: '${stats.publishedPosts}'), _StatCard(label: 'Engagement', value: '${stats.engagement}')]), const SizedBox(height: 24), Text('Manage your university opportunities and official communications.', style: Theme.of(context).textTheme.bodyLarge) ]); })); }
}
class _StatCard extends StatelessWidget { final String label; final String value; const _StatCard({required this.label, required this.value}); @override Widget build(BuildContext context) => SizedBox(width: 160, child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: Theme.of(context).textTheme.headlineMedium), Text(label)])))); }
