import '../models/opportunity_filter_model.dart';
import '../models/opportunity_model.dart';

/// Service abstraction for Opportunity Discovery, Bookmarks, and Applications.
abstract class OpportunityService {
  Future<List<OpportunityModel>> getOpportunities({OpportunityFilterModel? filter});
  Future<OpportunityModel?> getOpportunityById(String id);
  Future<bool> toggleSaveOpportunity(String id);
  Future<bool> markAsApplied(String id);
  Future<bool> toggleDeadlineReminder(String id);
  Future<List<OpportunityModel>> getSavedOpportunities();
  Future<List<OpportunityModel>> getAppliedOpportunities();
}
