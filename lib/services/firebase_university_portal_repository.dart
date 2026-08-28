import 'package:firebase_auth/firebase_auth.dart';

import '../models/application_model.dart';
import '../models/opportunity_model.dart';
import '../models/post_model.dart';
import 'application_repository.dart';
import 'community_repository.dart';
import 'firebase_application_repository.dart';
import 'firebase_community_repository.dart';
import 'firebase_opportunity_service.dart';
import 'university_portal_repository.dart';

class FirebaseUniversityPortalRepository implements UniversityPortalRepository {
  FirebaseUniversityPortalRepository({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance,
      _opportunities = FirebaseOpportunityService(auth: auth),
      _applications = FirebaseApplicationRepository(auth: auth),
      _community = FirebaseCommunityRepository(auth: auth);

  final FirebaseAuth _auth;
  final FirebaseOpportunityService _opportunities;
  final ApplicationRepository _applications;
  final CommunityRepository _community;

  @override
  Future<List<OpportunityModel>> getOwnedOpportunities(String organizationId) =>
      _opportunities.getManagedOpportunities(organizationId);

  @override
  Future<OpportunityModel> createOpportunity({
    required String organizationId,
    required String organizationName,
    required String title,
    required String description,
    required OpportunityType type,
    required DateTime deadline,
    required String location,
    required String applicationUrl,
    String category = 'General',
    String eligibility = '',
    String contactEmail = '',
  }) => _opportunities.createUniversityOpportunity(
    organizationId: organizationId,
    organizationName: organizationName,
    title: title,
    description: description,
    type: type,
    deadline: deadline,
    location: location,
    applicationUrl: applicationUrl,
  );

  @override
  Future<void> updateOpportunity(
    String organizationId,
    OpportunityModel opportunity,
  ) => _opportunities.updateUniversityOpportunity(organizationId, opportunity);

  @override
  Future<void> deleteOpportunity(String organizationId, String opportunityId) =>
      _opportunities.deleteUniversityOpportunity(organizationId, opportunityId);

  @override
  Future<void> closeOpportunity(String organizationId, String opportunityId) =>
      _opportunities.closeUniversityOpportunity(organizationId, opportunityId);

  @override
  Future<List<ApplicationModel>> getApplicants(
    String organizationId,
    String opportunityId,
  ) async {
    _requireOwner(organizationId);
    final opportunity = await _opportunities.getOpportunityById(opportunityId);
    if (opportunity?.organizationId != organizationId) {
      throw StateError(
        'You can only view applicants for your own opportunities.',
      );
    }
    return _applications.forOpportunity(opportunityId);
  }

  @override
  Future<ApplicationModel> updateApplicationStatus(
    String organizationId,
    String applicationId,
    ApplicationStatus status,
  ) => _applications.updateStatus(organizationId, applicationId, status);

  @override
  Future<UniversityStats> getStats(String organizationId) async {
    final owned = await getOwnedOpportunities(organizationId);
    final applications = <ApplicationModel>[];
    for (final opportunity in owned) {
      applications.addAll(await _applications.forOpportunity(opportunity.id));
    }
    final posts = await _community.getPostsByAuthor(organizationId);
    return UniversityStats(
      activeOpportunities: owned
          .where(
            (item) =>
                item.status != OpportunityStatus.closed &&
                item.deadline.isAfter(DateTime.now()),
          )
          .length,
      totalApplications: applications.length,
      pendingApplications: applications
          .where((item) => item.status == ApplicationStatus.pending)
          .length,
      publishedPosts: posts.length,
      engagement: posts.fold(
        0,
        (sum, post) => sum + post.likesCount + post.commentsCount,
      ),
    );
  }

  @override
  Future<PostModel> createUniversityPost({
    required String organizationId,
    required String universityName,
    required String title,
    required String content,
    required String category,
  }) => _community.createUniversityPost(
    universityId: organizationId,
    universityName: universityName,
    title: title,
    content: content,
    topic: category,
  );

  void _requireOwner(String organizationId) {
    if (_auth.currentUser?.uid != organizationId) {
      throw StateError('You can only access your own university data.');
    }
  }
}
