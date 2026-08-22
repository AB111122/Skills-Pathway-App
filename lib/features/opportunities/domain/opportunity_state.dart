import '../../../models/opportunity_filter_model.dart';
import '../../../models/opportunity_model.dart';

enum OpportunityTab { all, scholarships, internships, saved, applied }

/// Immutable state for Opportunity discovery, search, filters, and bookmarks.
class OpportunityState {
  final bool isLoading;
  final List<OpportunityModel> opportunities;
  final OpportunityFilterModel filter;
  final OpportunityTab activeTab;
  final OpportunityModel? selectedOpportunity;
  final String? errorMessage;

  const OpportunityState({
    this.isLoading = false,
    this.opportunities = const [],
    this.filter = const OpportunityFilterModel(),
    this.activeTab = OpportunityTab.all,
    this.selectedOpportunity,
    this.errorMessage,
  });

  List<OpportunityModel> get currentTabOpportunities {
    switch (activeTab) {
      case OpportunityTab.all:
        return opportunities;
      case OpportunityTab.scholarships:
        return opportunities.where((o) => o.isScholarship).toList();
      case OpportunityTab.internships:
        return opportunities.where((o) => o.isInternship).toList();
      case OpportunityTab.saved:
        return opportunities.where((o) => o.isSaved).toList();
      case OpportunityTab.applied:
        return opportunities.where((o) => o.isApplied).toList();
    }
  }

  OpportunityState copyWith({
    bool? isLoading,
    List<OpportunityModel>? opportunities,
    OpportunityFilterModel? filter,
    OpportunityTab? activeTab,
    OpportunityModel? selectedOpportunity,
    String? errorMessage,
    bool clearSelected = false,
  }) {
    return OpportunityState(
      isLoading: isLoading ?? this.isLoading,
      opportunities: opportunities ?? this.opportunities,
      filter: filter ?? this.filter,
      activeTab: activeTab ?? this.activeTab,
      selectedOpportunity: clearSelected
          ? null
          : (selectedOpportunity ?? this.selectedOpportunity),
      errorMessage: errorMessage,
    );
  }
}
