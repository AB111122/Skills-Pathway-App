import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../models/application_model.dart';
import '../../../../models/opportunity_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../university_provider.dart';

class UniversityApplicationsScreen extends ConsumerStatefulWidget {
  const UniversityApplicationsScreen({super.key});
  @override
  ConsumerState<UniversityApplicationsScreen> createState() =>
      _UniversityApplicationsScreenState();
}

class _UniversityApplicationsScreenState
    extends ConsumerState<UniversityApplicationsScreen> {
  OpportunityModel? _selected;
  late Future<List<OpportunityModel>> _opportunities;

  @override
  void initState() {
    super.initState();
    final organizationId =
        ref.read(authControllerProvider).currentUser?.id ?? '';
    _opportunities = ref
        .read(universityRepositoryProvider)
        .getOwnedOpportunities(organizationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: FutureBuilder<List<OpportunityModel>>(
        future: _opportunities,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final opportunities = snapshot.data!;
          final selected =
              _selected ?? (opportunities.isEmpty ? null : opportunities.first);
          if (selected == null)
            return const Center(
              child: Text('No university opportunities yet.'),
            );
          return FutureBuilder<List<ApplicationModel>>(
            future: ref
                .read(universityRepositoryProvider)
                .getApplicants(
                  ref.read(authControllerProvider).currentUser?.id ?? '',
                  selected.id,
                ),
            builder: (context, applicants) {
              final records = applicants.data ?? [];
              return ListView(
                padding: const EdgeInsets.all(AppDimensions.p20),
                children: [
                  DropdownButtonFormField<OpportunityModel>(
                    initialValue: selected,
                    decoration: const InputDecoration(labelText: 'Opportunity'),
                    items: opportunities
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.title),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selected = value),
                  ),
                  const SizedBox(height: 20),
                  if (records.isEmpty) const Text('No applications yet.'),
                  ...records.map(
                    (application) => Card(
                      child: ListTile(
                        title: Text(application.studentName),
                        subtitle: Text(
                          '${application.opportunityTitle}\n${application.applicationDate.toLocal().toString().split(' ').first}',
                        ),
                        isThreeLine: true,
                        trailing: DropdownButton<ApplicationStatus>(
                          value: application.status,
                          onChanged: (status) async {
                            if (status == null) return;
                            await ref
                                .read(universityRepositoryProvider)
                                .updateApplicationStatus(
                                  ref
                                          .read(authControllerProvider)
                                          .currentUser
                                          ?.id ??
                                      '',
                                  application.id,
                                  status,
                                );
                            setState(() {});
                          },
                          items: ApplicationStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.name),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
