import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/models/application_model.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/services/application_repository.dart';
import 'package:skills_pathway_app/services/community_repository.dart';
import 'package:skills_pathway_app/services/mock_opportunity_service.dart';

void main() {
  test('closed opportunity cannot receive duplicate applications', () async {
    final service = MockOpportunityService();
    final item = await service.createUniversityOpportunity(
      organizationId: 'polish-university', organizationName: 'Mock University',
      title: 'Closed Listing', description: 'Test', type: OpportunityType.job,
      deadline: DateTime.now().add(const Duration(days: 3)), location: 'Remote',
      applicationUrl: 'https://example.com',
    );
    expect(await service.markAsApplied(item.id), true);
    expect(await service.markAsApplied(item.id), false);
    final records = await MockApplicationRepository.instance.forOpportunity(item.id);
    expect(records, hasLength(1));
  });

  test('post edit and delete enforce university ownership', () async {
    final repository = MockCommunityRepository.instance;
    final post = await repository.createUniversityPost(
      universityId: 'polish-post-university', universityName: 'Mock University',
      title: 'Original', content: 'Content', topic: 'News',
    );
    final updated = await repository.updateUniversityPost(
      'polish-post-university', post.copyWith(title: 'Updated'),
    );
    expect(updated.title, 'Updated');
    expect(() => repository.updateUniversityPost('other-university', post), throwsStateError);
    await repository.deleteUniversityPost('polish-post-university', post.id);
    expect(repository.postsForAuthor('polish-post-university'), isEmpty);
  });

  test('all university opportunity types are supported', () {
    expect(OpportunityType.values, containsAll([
      OpportunityType.internship, OpportunityType.scholarship, OpportunityType.job,
      OpportunityType.fellowship, OpportunityType.event, OpportunityType.workshop,
    ]));
  });

  test('application status remains synchronized in shared repository', () async {
    final repository = MockApplicationRepository.instance;
    final application = ApplicationModel(
      id: 'polish-application', studentId: 'student', studentName: 'Student',
      opportunityId: 'opportunity', opportunityTitle: 'Opportunity',
      universityId: 'university', universityName: 'University',
      applicationDate: DateTime(2026, 8, 26),
    );
    await repository.create(application);
    await repository.updateStatus('university', application.id, ApplicationStatus.shortlisted);
    expect((await repository.forStudent('student')).single.status, ApplicationStatus.shortlisted);
  });
}
