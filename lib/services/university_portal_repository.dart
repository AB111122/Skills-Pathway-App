import '../models/application_model.dart';
import '../models/opportunity_model.dart';
import '../models/post_model.dart';
import 'application_repository.dart';
import 'community_repository.dart';
import 'mock_opportunity_service.dart';

class UniversityStats {
  final int totalOpportunities;
  final int activeOpportunities;
  final int totalApplications;
  final int pendingApplications;
  final int publishedPosts;
  final int engagement;
  const UniversityStats({
    this.totalOpportunities = 0,
    required this.activeOpportunities,
    required this.totalApplications,
    required this.pendingApplications,
    required this.publishedPosts,
    required this.engagement,
  });
}

abstract class UniversityPortalRepository {
  Future<List<OpportunityModel>> getOwnedOpportunities(String organizationId);
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
  });
  Future<void> updateOpportunity(
    String organizationId,
    OpportunityModel opportunity,
  );
  Future<void> deleteOpportunity(String organizationId, String opportunityId);
  Future<void> closeOpportunity(String organizationId, String opportunityId);
  Future<UniversityStats> getStats(String organizationId);
  Future<List<ApplicationModel>> getApplicants(
    String organizationId,
    String opportunityId,
  );
  Future<ApplicationModel> updateApplicationStatus(
    String organizationId,
    String applicationId,
    ApplicationStatus status,
  );
  Future<PostModel> createUniversityPost({
    required String organizationId,
    required String universityName,
    required String title,
    required String content,
    required String category,
  });
}

class MockUniversityPortalRepository implements UniversityPortalRepository {
  final MockOpportunityService _opportunities = MockOpportunityService();
  final ApplicationRepository _applications =
      MockApplicationRepository.instance;
  final CommunityRepository _community = MockCommunityRepository.instance;

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
    category: category,
    eligibility: eligibility,
    contactEmail: contactEmail,
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
  ) => _applications.forOrganizationOpportunity(organizationId, opportunityId);
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
    for (final item in owned) {
      applications.addAll(
        await _applications.forOrganizationOpportunity(organizationId, item.id),
      );
    }
    return UniversityStats(
      totalOpportunities: owned.length,
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
      publishedPosts: _community.postsForAuthor(organizationId).length,
      engagement: _community
          .postsForAuthor(organizationId)
          .fold(0, (sum, post) => sum + post.likesCount + post.commentsCount),
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
}
