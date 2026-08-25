import '../models/opportunity_filter_model.dart';
import '../models/opportunity_model.dart';
import '../models/student_profile_model.dart';
import 'opportunity_service.dart';

abstract class AiService {
  Future<String> sendMessage(String message, StudentProfileModel? profile);
  Future<List<OpportunityModel>> recommendOpportunities({required OpportunityType type, StudentProfileModel? profile});
}

class MockAiService implements AiService {
  final OpportunityService opportunityService;
  MockAiService(this.opportunityService);

  @override
  Future<String> sendMessage(String message, StudentProfileModel? profile) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final lower = message.toLowerCase();
    final skills = profile?.skills.join(', ');
    if (lower.contains('intern')) return 'Based on your profile${skills == null ? '' : ' and skills in $skills'}, start with verified internships matching your field. I can narrow these by location or deadline.';
    if (lower.contains('scholar')) return 'Look for scholarships aligned with your education level and field. I can show platform listings that are explicitly verified, but acceptance is decided by each organization.';
    if (lower.contains('resume')) return 'Keep your resume focused: lead with measurable projects, match relevant skills to the role, and keep evidence links easy to scan. Full resume parsing is planned for a later phase.';
    if (lower.contains('market')) return 'For market insight, compare your target role with recurring skills in current listings. This is general guidance from the mock assistant, not a guarantee of employment.';
    return 'I can help you explore career directions, internships, scholarships, resume improvements, and market skills. Tell me what you want to work on next.';
  }

  @override
  Future<List<OpportunityModel>> recommendOpportunities({required OpportunityType type, StudentProfileModel? profile}) async {
    final items = await opportunityService.getOpportunities(filter: OpportunityFilterModel(opportunityType: type, isVerifiedOnly: true));
    return items;
  }
}
