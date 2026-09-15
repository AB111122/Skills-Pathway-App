import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/models/opportunity_filter_model.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/services/firestore_serializers.dart';
import 'package:skills_pathway_app/services/mock_opportunity_service.dart';
import 'package:skills_pathway_app/services/university_portal_repository.dart';

void main() {
  group('Opportunities CRUD & Student Discovery Suite', () {
    late MockOpportunityService opportunityService;
    late MockUniversityPortalRepository universityRepo;

    setUp(() {
      opportunityService = MockOpportunityService();
      universityRepo = MockUniversityPortalRepository();
    });

    test(
      'University can create opportunities across all supported types',
      () async {
        final types = [
          OpportunityType.internship,
          OpportunityType.scholarship,
          OpportunityType.job,
          OpportunityType.fellowship,
          OpportunityType.event,
          OpportunityType.workshop,
        ];

        for (final type in types) {
          final opp = await opportunityService.createUniversityOpportunity(
            organizationId: 'org_nust_01',
            organizationName: 'NUST',
            title: 'NUST ${type.label} 2026',
            description: 'Official opportunity of type ${type.label}',
            type: type,
            deadline: DateTime.now().add(const Duration(days: 30)),
            location: 'Islamabad, Pakistan',
            applicationUrl: 'https://nust.edu.pk/apply',
          );

          expect(opp.id.isNotEmpty, isTrue);
          expect(opp.type, type);
          expect(opp.organizationId, 'org_nust_01');
          expect(opp.status, OpportunityStatus.published);
        }
      },
    );

    test('Published university opportunity is discoverable with its identity fields', () async {
      final created = await universityRepo.createOpportunity(
        organizationId: 'org_profile_test',
        organizationName: 'Profile University',
        title: 'Profile-visible Fellowship',
        description: 'A published fellowship for student discovery.',
        type: OpportunityType.fellowship,
        deadline: DateTime.now().add(const Duration(days: 30)),
        location: 'Remote',
        applicationUrl: 'https://example.edu/apply',
        category: 'Research',
      );

      final firestoreData = FirestoreSerializers.opportunityToMap(created);
      expect(firestoreData['id'], created.id);
      expect(firestoreData['organizationId'], 'org_profile_test');
      expect(firestoreData['createdBy'], 'org_profile_test');
      expect(firestoreData['category'], 'Research');
      expect(firestoreData['status'], 'published');
      expect(firestoreData['deadline'], isA<Timestamp>());
      expect(firestoreData['shortDescription'], created.shortDescription);
      expect(firestoreData['fullDescription'], created.fullDescription);
      expect(firestoreData['officialUrl'], created.officialUrl);

      final restored = FirestoreSerializers.opportunityFromMap(
        firestoreData,
        id: created.id,
      );
      expect(restored.organizationId, created.organizationId);
      expect(restored.createdBy, created.createdBy);
      expect(restored.type, created.type);
      expect(restored.status, OpportunityStatus.published);
      expect(restored.deadline.toUtc(), created.deadline.toUtc());

      final studentOpportunities = await opportunityService.getOpportunities();
      final visible = studentOpportunities.firstWhere(
        (item) => item.id == created.id,
      );
      expect(visible.title, 'Profile-visible Fellowship');
      expect(visible.organizationName, 'Profile University');
      expect(visible.organizationId, 'org_profile_test');
    });

    test('University can edit opportunity details successfully', () async {
      final created = await opportunityService.createUniversityOpportunity(
        organizationId: 'org_giki_01',
        organizationName: 'GIKI',
        title: 'Initial Title',
        description: 'Initial Description',
        type: OpportunityType.scholarship,
        deadline: DateTime.now().add(const Duration(days: 15)),
        location: 'Topi, KP',
        applicationUrl: 'https://giki.edu.pk',
      );

      await opportunityService.updateUniversityOpportunity(
        'org_giki_01',
        created.copyWith(
          title: 'Updated GIKI Merit Scholarship 2026',
          shortDescription: 'Full tuition coverage',
        ),
      );

      final fetched = await opportunityService.getOpportunityById(created.id);
      expect(fetched?.title, 'Updated GIKI Merit Scholarship 2026');
      expect(fetched?.shortDescription, 'Full tuition coverage');
    });

    test(
      'Opportunity mutation and deletion enforce strict organization ownership',
      () async {
        final created = await universityRepo.createOpportunity(
          organizationId: 'org_fast_01',
          organizationName: 'FAST NUCES',
          title: 'FAST Hackathon 2026',
          description: 'Annual competitive hackathon',
          type: OpportunityType.event,
          deadline: DateTime.now().add(const Duration(days: 10)),
          location: 'Lahore, Pakistan',
          applicationUrl: 'https://nu.edu.pk/hackathon',
        );

        // Attempt edit from another university must throw StateError
        expect(
          () => universityRepo.updateOpportunity(
            'org_other_university',
            created.copyWith(title: 'Hacked Title'),
          ),
          throwsStateError,
        );

        // Attempt delete from another university must throw StateError
        expect(
          () => universityRepo.deleteOpportunity(
            'org_other_university',
            created.id,
          ),
          throwsStateError,
        );

        // Delete by owner succeeds
        await universityRepo.deleteOpportunity('org_fast_01', created.id);
        final remaining = await universityRepo.getOwnedOpportunities(
          'org_fast_01',
        );
        expect(remaining.any((item) => item.id == created.id), isFalse);
      },
    );

    test(
      'Student discovery filters out draft, closed, and expired listings',
      () async {
        // 1. Create active opportunity
        final active = await opportunityService.createUniversityOpportunity(
          organizationId: 'org_nust_01',
          organizationName: 'NUST',
          title: 'Active Open Listing',
          description: 'Open to all',
          type: OpportunityType.internship,
          deadline: DateTime.now().add(const Duration(days: 20)),
          location: 'Islamabad',
          applicationUrl: 'https://nust.edu.pk',
        );

        // 2. Create expired opportunity
        final expired = await opportunityService.createUniversityOpportunity(
          organizationId: 'org_nust_01',
          organizationName: 'NUST',
          title: 'Expired Listing',
          description: 'Past deadline',
          type: OpportunityType.job,
          deadline: DateTime.now().subtract(const Duration(days: 2)),
          location: 'Islamabad',
          applicationUrl: 'https://nust.edu.pk',
        );

        // 3. Create closed opportunity
        final closed = await opportunityService.createUniversityOpportunity(
          organizationId: 'org_nust_01',
          organizationName: 'NUST',
          title: 'Closed Listing',
          description: 'Closed early',
          type: OpportunityType.workshop,
          deadline: DateTime.now().add(const Duration(days: 20)),
          location: 'Islamabad',
          applicationUrl: 'https://nust.edu.pk',
        );
        await opportunityService.closeUniversityOpportunity(
          'org_nust_01',
          closed.id,
        );

        final studentVisible = await opportunityService.getOpportunities();

        expect(studentVisible.any((item) => item.id == active.id), isTrue);
        expect(studentVisible.any((item) => item.id == expired.id), isFalse);
        expect(studentVisible.any((item) => item.id == closed.id), isFalse);
      },
    );

    test(
      'Filters work correctly by category, verified status, and keyword',
      () async {
        final scholarshipList = await opportunityService.getOpportunities(
          filter: const OpportunityFilterModel(
            opportunityType: OpportunityType.scholarship,
          ),
        );
        for (final item in scholarshipList) {
          expect(item.isScholarship, isTrue);
        }

        final verifiedList = await opportunityService.getOpportunities(
          filter: const OpportunityFilterModel(isVerifiedOnly: true),
        );
        for (final item in verifiedList) {
          expect(item.isVerified, isTrue);
        }
      },
    );
  });
}
