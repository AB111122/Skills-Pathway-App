import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/services/community_repository.dart';

void main() {
  group('Community, Topics & Admissions Suite', () {
    late MockCommunityRepository communityRepo;

    setUp(() {
      communityRepo = MockCommunityRepository.instance;
    });

    test('University can publish official post with Admissions topic', () async {
      final post = await communityRepo.createUniversityPost(
        universityId: 'org_nust_comm',
        universityName: 'NUST Admissions Office',
        title: 'Fall 2026 Admissions Schedule & Test Dates',
        content: 'Registration for NET Series 1 opens next week.',
        topic: 'Admissions',
      );

      expect(post.authorRole, 'Official University');
      expect(post.authorType, 'university');
      expect(post.topic, 'Admissions');

      final admissionsPosts = await communityRepo.getPosts(topic: 'Admissions');
      expect(admissionsPosts.any((p) => p.id == post.id), isTrue);
    });

    test('Topic filters accurately isolate Admissions, Jobs, Events, and General', () async {
      final admissionsPost = await communityRepo.createPost(
        title: 'Admissions query for FAST',
        content: 'Does FAST accept SAT scores?',
        topic: 'Admissions',
      );

      final jobsPost = await communityRepo.createPost(
        title: 'Junior Flutter Developer role open',
        content: 'Looking for fresh graduates with Flutter expertise.',
        topic: 'Jobs',
      );

      final eventsPost = await communityRepo.createPost(
        title: 'Google I/O Extended Islamabad',
        content: 'Join us this Saturday for tech talks and networking.',
        topic: 'Events',
      );

      final generalPost = await communityRepo.createPost(
        title: 'Advice on choosing final year project',
        content: 'What are the most in-demand AI projects right now?',
        topic: 'General',
      );

      final admissionsResults = await communityRepo.getPosts(topic: 'Admissions');
      expect(admissionsResults.any((p) => p.id == admissionsPost.id), isTrue);
      expect(admissionsResults.any((p) => p.id == jobsPost.id), isFalse);

      final jobsResults = await communityRepo.getPosts(topic: 'Jobs');
      expect(jobsResults.any((p) => p.id == jobsPost.id), isTrue);
      expect(jobsResults.any((p) => p.id == eventsPost.id), isFalse);

      final eventsResults = await communityRepo.getPosts(topic: 'Events');
      expect(eventsResults.any((p) => p.id == eventsPost.id), isTrue);
      expect(eventsResults.any((p) => p.id == generalPost.id), isFalse);

      final generalResults = await communityRepo.getPosts(topic: 'General');
      expect(generalResults.any((p) => p.id == generalPost.id), isTrue);
    });

    test('Post owner can update and delete; non-owner is rejected', () async {
      final post = await communityRepo.createUniversityPost(
        universityId: 'org_giki_comm',
        universityName: 'GIKI',
        title: 'GIKI Admission Notice',
        content: 'Original Content',
        topic: 'Admissions',
      );

      // Owner update
      final updated = await communityRepo.updateUniversityPost(
        'org_giki_comm',
        post.copyWith(title: 'GIKI Admission Notice [Updated Dates]'),
      );
      expect(updated.title, 'GIKI Admission Notice [Updated Dates]');

      // Non-owner update fails
      expect(
        () => communityRepo.updateUniversityPost(
          'org_other_comm',
          post.copyWith(title: 'Malicious Update'),
        ),
        throwsStateError,
      );

      // Non-owner delete fails
      expect(
        () => communityRepo.deleteUniversityPost('org_other_comm', post.id),
        throwsStateError,
      );

      // Owner delete succeeds
      await communityRepo.deleteUniversityPost('org_giki_comm', post.id);
      final authorPosts = communityRepo.postsForAuthor('org_giki_comm');
      expect(authorPosts.any((p) => p.id == post.id), isFalse);
    });
  });
}
