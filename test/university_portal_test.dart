import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/services/university_portal_repository.dart';

void main() {
  test('university repository creates records owned by the current university', () async {
    final repository = MockUniversityPortalRepository();
    final created = await repository.createOpportunity(
      organizationId: 'university-a',
      organizationName: 'Mock University A',
      title: 'Campus Fellowship',
      description: 'Development listing',
      type: OpportunityType.scholarship,
      deadline: DateTime.now().add(const Duration(days: 10)),
      location: 'Islamabad',
      applicationUrl: 'https://example.com/apply',
    );
    expect(created.organizationId, 'university-a');
    expect((await repository.getOwnedOpportunities('university-a')).length, 1);
  });

  test('university cannot delete another university record', () async {
    final repository = MockUniversityPortalRepository();
    final created = await repository.createOpportunity(
      organizationId: 'university-a',
      organizationName: 'Mock University A',
      title: 'Owned Listing',
      description: 'Development listing',
      type: OpportunityType.internship,
      deadline: DateTime.now().add(const Duration(days: 10)),
      location: 'Remote',
      applicationUrl: 'https://example.com/apply',
    );
    expect(
      () => repository.deleteOpportunity('university-b', created.id),
      throwsStateError,
    );
  });
}
