import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/models/application_model.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/services/application_repository.dart';
import 'package:skills_pathway_app/services/mock_opportunity_service.dart';

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
}
