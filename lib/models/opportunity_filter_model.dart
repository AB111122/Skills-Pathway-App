import 'opportunity_model.dart';

/// Multi-criteria Filter Model for Scholarships and Internships.
class OpportunityFilterModel {
  final String searchQuery;
  final OpportunityType? opportunityType;
  final String? location; // "All", "Pakistan", "Islamabad", "Lahore", "Karachi", "International"
  final String? field; // "All", "Computer Science & AI", "Business & Finance", "Engineering"
  final String? degreeLevel; // "All", "Undergraduate", "Master's", "PhD"
  final bool isPaidOnly;
  final bool isFullyFundedOnly;
  final bool isVerifiedOnly;

  const OpportunityFilterModel({
    this.searchQuery = '',
    this.opportunityType,
    this.location,
    this.field,
    this.degreeLevel,
    this.isPaidOnly = false,
    this.isFullyFundedOnly = false,
    this.isVerifiedOnly = false,
  });

  bool get hasActiveFilters =>
      searchQuery.trim().isNotEmpty ||
      opportunityType != null ||
      (location != null && location != 'All') ||
      (field != null && field != 'All') ||
      (degreeLevel != null && degreeLevel != 'All') ||
      isPaidOnly ||
      isFullyFundedOnly ||
      isVerifiedOnly;

  int get activeFilterCount {
    int count = 0;
    if (opportunityType != null) count++;
    if (location != null && location != 'All') count++;
    if (field != null && field != 'All') count++;
    if (degreeLevel != null && degreeLevel != 'All') count++;
    if (isPaidOnly) count++;
    if (isFullyFundedOnly) count++;
    if (isVerifiedOnly) count++;
    return count;
  }

  OpportunityFilterModel copyWith({
    String? searchQuery,
    OpportunityType? opportunityType,
    bool clearOpportunityType = false,
    String? location,
    bool clearLocation = false,
    String? field,
    bool clearField = false,
    String? degreeLevel,
    bool clearDegreeLevel = false,
    bool? isPaidOnly,
    bool? isFullyFundedOnly,
    bool? isVerifiedOnly,
  }) {
    return OpportunityFilterModel(
      searchQuery: searchQuery ?? this.searchQuery,
      opportunityType: clearOpportunityType
          ? null
          : (opportunityType ?? this.opportunityType),
      location: clearLocation ? null : (location ?? this.location),
      field: clearField ? null : (field ?? this.field),
      degreeLevel: clearDegreeLevel ? null : (degreeLevel ?? this.degreeLevel),
      isPaidOnly: isPaidOnly ?? this.isPaidOnly,
      isFullyFundedOnly: isFullyFundedOnly ?? this.isFullyFundedOnly,
      isVerifiedOnly: isVerifiedOnly ?? this.isVerifiedOnly,
    );
  }

  factory OpportunityFilterModel.initial() => const OpportunityFilterModel();
}
