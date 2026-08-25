import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../models/opportunity_model.dart';
import '../university_provider.dart';

class UniversityOpportunitiesScreen extends ConsumerStatefulWidget {
  const UniversityOpportunitiesScreen({super.key});
  @override ConsumerState<UniversityOpportunitiesScreen> createState() => _UniversityOpportunitiesScreenState();
}

class _UniversityOpportunitiesScreenState extends ConsumerState<UniversityOpportunitiesScreen> {
  late Future<List<OpportunityModel>> _items;
  @override void initState() { super.initState(); _reload(); }
  void _reload() { _items = ref.read(universityRepositoryProvider).getOwnedOpportunities('prof_org_01'); }
  Future<void> _refresh() async { setState(_reload); await _items; }
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Manage Opportunities')),
    body: FutureBuilder<List<OpportunityModel>>(
      future: _items,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final items = snapshot.data!;
        return RefreshIndicator(onRefresh: _refresh, child: ListView(padding: const EdgeInsets.all(AppDimensions.p20), children: [
          CustomButton(text: 'Create Opportunity', icon: Icons.add_business, onPressed: () async { await context.push('/university/opportunities/create'); if (mounted) setState(_reload); }),
          const SizedBox(height: 20),
          if (items.isEmpty) const Text('No opportunities yet'),
          ...items.map((item) => _OpportunityTile(item: item, onChanged: () { if (mounted) setState(_reload); })),
        ]));
      },
    ),
  );
}

class _OpportunityTile extends ConsumerWidget {
  final OpportunityModel item;
  final VoidCallback onChanged;
  const _OpportunityTile({required this.item, required this.onChanged});
  @override Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
    future: ref.read(universityRepositoryProvider).getApplicants('prof_org_01', item.id),
    builder: (context, snapshot) => Card(child: ListTile(
      title: Text(item.title),
      subtitle: Text('${item.type.name} | Applications: ${snapshot.data?.length ?? 0} | ${item.status == OpportunityStatus.closed ? 'Closed' : 'Active'}'),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'close') {
            final confirmed = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Close opportunity?'), content: const Text('Are you sure you want to close this opportunity?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Close'))]));
            if (confirmed == true) { await ref.read(universityRepositoryProvider).closeOpportunity('prof_org_01', item.id); onChanged(); }
          }
          if (action == 'delete') { await ref.read(universityRepositoryProvider).deleteOpportunity('prof_org_01', item.id); onChanged(); }
          if (action == 'edit') { await context.push('/university/opportunities/${item.id}/edit', extra: item); onChanged(); }
        },
        itemBuilder: (_) => [const PopupMenuItem(value: 'view', child: Text('View')), if (item.status != OpportunityStatus.closed) const PopupMenuItem(value: 'edit', child: Text('Edit')), if (item.status != OpportunityStatus.closed) const PopupMenuItem(value: 'close', child: Text('Close')), const PopupMenuItem(value: 'delete', child: Text('Delete'))],
      ),
    )),
  );
}
