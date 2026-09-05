import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/models/application_model.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/services/application_repository.dart';
import 'package:skills_pathway_app/services/mock_opportunity_service.dart';

void main() {
  group('Application Lifecycle & State Synchronization Suite', () {
    late MockOpportunityService oppService;
    late MockApplicationRepository appRepo;

    setUp(() {
      oppService = MockOpportunityService();
      appRepo = MockApplicationRepository.instance;
    });

    test('Student application is created, prevents duplicates, and reaches university', () async {
      final opp = await oppService.createUniversityOpportunity(
        organizationId: 'org_nust_flow',
        organizationName: 'NUST SEECS',
        title: 'Cloud Research Internship 2026',
        description: 'Research internship in distributed systems',
        type: OpportunityType.internship,
        deadline: DateTime.now().add(const Duration(days: 14)),
        location: 'Islamabad',
        applicationUrl: 'https://seecs.nust.edu.pk/apply',
      );

      // Student applies first time
      final applyResult = await oppService.markAsApplied(opp.id);
      expect(applyResult, isTrue);

      // Duplicate apply attempt is rejected
      final duplicateResult = await oppService.markAsApplied(opp.id);
      expect(duplicateResult, isFalse);

      // Verify application reaches university repository
      final universityApplicants = await appRepo.forOpportunity(opp.id);
      expect(universityApplicants, hasLength(1));

      final firstApplicant = universityApplicants.first;
      expect(firstApplicant.opportunityId, opp.id);
      expect(firstApplicant.universityId, 'org_nust_flow');
      expect(firstApplicant.status, ApplicationStatus.pending);
    });

    test('University status updates synchronize in real-time for student view', () async {
      const studentId = 'usr_student_01';
      const universityId = 'org_fast_sync';
      final app = ApplicationModel(
        id: 'app_sync_test_01',
        studentId: studentId,
        studentName: 'Fatima Zahra',
        opportunityId: 'opp_fast_01',
        opportunityTitle: 'FAST AI Fellowship',
        universityId: universityId,
        universityName: 'FAST NUCES',
        applicationDate: DateTime.now(),
        status: ApplicationStatus.pending,
      );

      await appRepo.create(app);

      // 1. Initial status is pending
      final studentAppsInit = await appRepo.forStudent(studentId);
      expect(
        studentAppsInit.firstWhere((a) => a.id == 'app_sync_test_01').status,
        ApplicationStatus.pending,
      );

      // 2. University changes status to reviewed
      await appRepo.updateStatus(universityId, app.id, ApplicationStatus.reviewed);
      final studentAppsReviewed = await appRepo.forStudent(studentId);
      expect(
        studentAppsReviewed.firstWhere((a) => a.id == 'app_sync_test_01').status,
        ApplicationStatus.reviewed,
      );

      // 3. University changes status to shortlisted
      await appRepo.updateStatus(universityId, app.id, ApplicationStatus.shortlisted);
      final studentAppsShortlisted = await appRepo.forStudent(studentId);
      expect(
        studentAppsShortlisted.firstWhere((a) => a.id == 'app_sync_test_01').status,
        ApplicationStatus.shortlisted,
      );

      // 4. Unauthorized university cannot change applicant status
      expect(
        () => appRepo.updateStatus('org_fake_university', app.id, ApplicationStatus.rejected),
        throwsStateError,
      );
    });
  });
}
