import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/features/authentication/data/mock_auth_service.dart';
import 'package:skills_pathway_app/models/application_model.dart';
import 'package:skills_pathway_app/models/opportunity_model.dart';
import 'package:skills_pathway_app/models/post_model.dart';
import 'package:skills_pathway_app/models/user_model.dart';
import 'package:skills_pathway_app/services/firestore_serializers.dart';
import 'package:skills_pathway_app/services/application_repository.dart';
import 'package:skills_pathway_app/services/mock_opportunity_service.dart';
import 'package:skills_pathway_app/services/university_portal_repository.dart';
import 'package:skills_pathway_app/services/community_repository.dart';

void main() {
  group('Firestore serialization contracts', () {
    test('preserves opportunity fields and Timestamp dates', () {
      final createdAt = DateTime.utc(2026, 8, 28, 12);
      final deadline = DateTime.utc(2026, 9, 10);
      final opportunity = OpportunityModel(
        id: 'opp-1',
        title: 'Flutter Internship',
        organizationName: 'University A',
        organizationId: 'uni-a',
        createdBy: 'uni-a',
        type: OpportunityType.internship,
        location: 'Remote',
        deadline: deadline,
        isVerified: true,
        isPaid: true,
        stipendOrFunding: 'PKR 50,000',
        shortDescription: 'Build mobile products.',
        fullDescription: 'Build mobile products with a university team.',
        officialUrl: 'https://example.com',
        requiredSkills: ['Flutter'],
        eligibleFields: ['Computer Science'],
        createdAt: createdAt,
        status: OpportunityStatus.published,
      );

      final data = FirestoreSerializers.opportunityToMap(opportunity);
      final restored = FirestoreSerializers.opportunityFromMap(data, id: 'opp-1');

      expect(data['deadline'], isA<Timestamp>());
      expect(data['createdAt'], isA<Timestamp>());
      expect(restored.title, opportunity.title);
      expect(restored.type, opportunity.type);
      expect(restored.deadline.toUtc(), deadline.toUtc());
      expect(restored.createdAt.toUtc(), createdAt.toUtc());
      expect(restored.requiredSkills, ['Flutter']);
    });

    test('preserves application status and native timestamps', () {
      final application = ApplicationModel(
        id: 'app-1',
        studentId: 'student-1',
        studentName: 'Student',
        opportunityId: 'opp-1',
        opportunityTitle: 'Internship',
        universityId: 'uni-a',
        universityName: 'University A',
        applicationDate: DateTime.utc(2026, 8, 28),
        status: ApplicationStatus.shortlisted,
      );

      final restored = FirestoreSerializers.applicationFromMap(
        FirestoreSerializers.applicationToMap(application),
        id: application.id,
      );

      expect(restored.id, application.id);
      expect(restored.studentId, application.studentId);
      expect(restored.universityId, application.universityId);
      expect(restored.status, ApplicationStatus.shortlisted);
      expect(restored.applicationDate.toUtc(), application.applicationDate.toUtc());
    });

    test('preserves official post ownership and engagement data', () {
      final post = PostModel(
        id: 'post-1',
        authorId: 'uni-a',
        authorName: 'University A',
        authorRole: 'Official University',
        authorType: 'university',
        universityId: 'uni-a',
        title: 'Announcement',
        content: 'Content',
        topic: 'Announcements',
        createdAt: DateTime.utc(2026, 8, 28),
        updatedAt: DateTime.utc(2026, 8, 28),
        likesCount: 4,
        commentsCount: 2,
      );

      final restored = FirestoreSerializers.postFromMap(
        FirestoreSerializers.postToMap(post),
        id: post.id,
      );

      expect(restored.authorId, 'uni-a');
      expect(restored.authorType, 'university');
      expect(restored.universityId, 'uni-a');
      expect(restored.likesCount, 4);
      expect(restored.commentsCount, 2);
    });
  });

  group('Offline auth contracts', () {
    test('login resolves student and organization roles', () async {
      final service = MockAuthService();
      final student = await service.login(
        email: 'student@example.com',
        password: 'Password123',
      );
      final organization = await service.login(
        email: 'admissions@nust.edu.pk',
        password: 'Password123',
      );

      expect(student.role, UserRole.student);
      expect(organization.role, UserRole.organization);
      expect((await service.getStudentProfile(student.id))?.userId,
          'usr_student_01');
      expect((await service.getOrganizationProfile(organization.id))?.userId,
          'usr_org_01');
    });

    test('registration emits a session with the requested role and profile', () async {
      final service = MockAuthService();
      final events = <UserModel?>[];
      final subscription = service.authStateChanges.listen(events.add);

      final student = await service.registerStudent(
        fullName: 'New Student',
        email: 'new.student@example.com',
        password: 'Password123',
        city: 'Lahore',
        educationLevel: 'Undergraduate',
        degree: 'BS Computer Science',
        fieldOfStudy: 'Computer Science',
        university: 'University A',
        skills: ['Dart'],
        careerInterests: ['Software Engineering'],
      );

      await Future<void>.delayed(Duration.zero);
      expect(student.role, UserRole.student);
      expect(events.last?.id, student.id);
      expect((await service.getStudentProfile(student.id))?.fullName,
          'New Student');
      await subscription.cancel();
    });

    test('organization registration preserves organization role and profile', () async {
      final service = MockAuthService();
      final organization = await service.registerOrganization(
        orgName: 'University A',
        orgType: 'University / Higher Education',
        officialEmail: 'admin@university-a.example',
        password: 'Password123',
        website: 'https://university-a.example',
        city: 'Lahore',
        registrationNumber: 'REG-1',
      );

      expect(organization.role, UserRole.organization);
      final profile = await service.getOrganizationProfile(organization.id);
      expect(profile?.orgName, 'University A');
      expect(profile?.isVerified, isFalse);
    });

    test('logout clears the mock session and emits null', () async {
      final service = MockAuthService();
      final events = <UserModel?>[];
      final subscription = service.authStateChanges.listen(events.add);
      await service.login(email: 'student@example.com', password: 'Password123');
      await service.logout();
      await Future<void>.delayed(Duration.zero);

      expect(events.last, isNull);
      await subscription.cancel();
    });
  });

  group('Offline repository ownership and lifecycle contracts', () {
    test('university cannot mutate another university opportunity', () async {
      final repository = MockUniversityPortalRepository();
      final opportunity = await repository.createOpportunity(
        organizationId: 'uni-a',
        organizationName: 'University A',
        title: 'Owned',
        description: 'Description',
        type: OpportunityType.internship,
        deadline: DateTime.now().add(const Duration(days: 5)),
        location: 'Remote',
        applicationUrl: 'https://example.com',
      );

      expect(
        () => repository.updateOpportunity('uni-b', opportunity),
        throwsStateError,
      );
      expect(
        () => repository.deleteOpportunity('uni-b', opportunity.id),
        throwsStateError,
      );
    });

    test('closed and expired opportunities are not discoverable', () async {
      final service = MockOpportunityService();
      final expired = await service.createUniversityOpportunity(
        organizationId: 'uni-expired',
        organizationName: 'University',
        title: 'Expired',
        description: 'Expired listing',
        type: OpportunityType.job,
        deadline: DateTime.now().subtract(const Duration(days: 1)),
        location: 'Remote',
        applicationUrl: 'https://example.com',
      );
      await service.closeUniversityOpportunity('uni-expired', expired.id);

      final visible = await service.getOpportunities();
      expect(visible.any((item) => item.id == expired.id), isFalse);
    });

    test('duplicate applications are prevented and status remains synchronized', () async {
      final service = MockOpportunityService();
      final opportunity = await service.createUniversityOpportunity(
        organizationId: 'uni-status',
        organizationName: 'University',
        title: 'Status Test',
        description: 'Application test',
        type: OpportunityType.internship,
        deadline: DateTime.now().add(const Duration(days: 5)),
        location: 'Remote',
        applicationUrl: 'https://example.com',
      );

      expect(await service.markAsApplied(opportunity.id), isTrue);
      expect(await service.markAsApplied(opportunity.id), isFalse);
      final applications = await MockApplicationRepository.instance
          .forOpportunity(opportunity.id);
      expect(applications, hasLength(1));
      await MockApplicationRepository.instance.updateStatus(
        'uni-status',
        applications.single.id,
        ApplicationStatus.shortlisted,
      );
      expect(
        (await MockApplicationRepository.instance
                .forStudent(applications.single.studentId))
            .single
            .status,
        ApplicationStatus.shortlisted,
      );
    });

    test('university official post ownership rejects another university', () async {
      final repository = MockCommunityRepository.instance;
      final post = await repository.createUniversityPost(
        universityId: 'uni-owner',
        universityName: 'University A',
        title: 'Official',
        content: 'Content',
        topic: 'Announcements',
      );

      expect(
        () => repository.updateUniversityPost('uni-other', post),
        throwsStateError,
      );
      expect(
        () => repository.deleteUniversityPost('uni-other', post.id),
        throwsStateError,
      );
      await repository.deleteUniversityPost('uni-owner', post.id);
    });

    test('community comments, likes, and follows update persisted post state', () async {
      final repository = MockCommunityRepository.instance;
      final post = await repository.createPost(
        title: 'Community contract',
        content: 'Test content',
        topic: 'Technology',
      );

      final comment = await repository.addComment(post.id, 'Useful post');
      expect(comment.postId, post.id);
      expect((await repository.getComments(post.id)).any((item) => item.id == comment.id), isTrue);

      final liked = await repository.toggleLike(post.id);
      expect(liked.isLiked, isTrue);
      expect(liked.likesCount, post.likesCount + 1);
      final unliked = await repository.toggleLike(post.id);
      expect(unliked.isLiked, isFalse);
      expect(unliked.likesCount, post.likesCount);

      final followed = await repository.toggleFollowAuthor(post.id);
      expect(followed.isFollowingAuthor, isTrue);
      final unfollowed = await repository.toggleFollowAuthor(post.id);
      expect(unfollowed.isFollowingAuthor, isFalse);
    });
  });
}
