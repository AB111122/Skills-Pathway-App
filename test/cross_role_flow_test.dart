import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/models/application_model.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/services/application_repository.dart';
import 'package:skills_pathway_app/services/mock_opportunity_service.dart';
import 'package:skills_pathway_app/services/community_repository.dart';

void main() {
  test('university opportunity is visible to students and application reaches university', () async {
    final opportunities = MockOpportunityService();
    final created = await opportunities.createUniversityOpportunity(
      organizationId: 'cross-role-university',
      organizationName: 'Mock University',
      title: 'Software Engineering Internship',
      description: 'Cross-role test listing',
      type: OpportunityType.internship,
      deadline: DateTime.now().add(const Duration(days: 20)),
      location: 'Remote',
      applicationUrl: 'https://example.com/apply',
    );
    expect((await opportunities.getOpportunities()).any((item) => item.id == created.id), isTrue);
    await opportunities.markAsApplied(created.id);
    final applicants = await MockApplicationRepository.instance.forOpportunity(created.id);
    expect(applicants.single.studentName, 'Fatima Zahra');
    expect(applicants.single.status, ApplicationStatus.pending);
    await MockApplicationRepository.instance.updateStatus('cross-role-university', applicants.single.id, ApplicationStatus.shortlisted);
    expect((await MockApplicationRepository.instance.forStudent('usr_student_01')).single.status, ApplicationStatus.shortlisted);
  });

  test('unpublished university opportunity is excluded from student discovery', () async {
    final opportunities = MockOpportunityService();
    final created = await opportunities.createUniversityOpportunity(
      organizationId: 'cross-role-draft-university',
      organizationName: 'Draft University',
      title: 'Private opportunity',
      description: 'Not public yet',
      type: OpportunityType.scholarship,
      deadline: DateTime.now().add(const Duration(days: 20)),
      location: 'Remote',
      applicationUrl: 'https://example.com/apply',
    );
    await opportunities.updateUniversityOpportunity(
      'cross-role-draft-university',
      created.copyWith(status: OpportunityStatus.draft),
    );

    final visible = await opportunities.getOpportunities();
    expect(visible.any((item) => item.id == created.id), isFalse);
  });

  test('university posts are in the student feed and student cannot delete them', () async {
    final community = MockCommunityRepository();
    final post = await community.createUniversityPost(
      universityId: 'cross-role-post-university',
      universityName: 'Cross Role University',
      title: 'Admissions and Jobs',
      content: 'Admissions, jobs, and events are open.',
      topic: 'Admissions',
    );

    expect((await community.getPosts()).any((item) => item.id == post.id), isTrue);
    expect(post.topic, 'Admissions');
    expect(
      () => community.deletePost('student-user', post.id),
      throwsStateError,
    );
  });
}
