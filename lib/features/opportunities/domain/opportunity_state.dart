import '../../../models/opportunity_filter_model.dart';
import '../../../models/opportunity_model.dart';

enum OpportunityTab { all, scholarships, internships, saved, applied }
enum OpportunitySort { deadlineSoonest, deadlineLatest, newest, alphabetical }

/// Immutable state for Opportunity discovery, search, filters, and bookmarks.
class OpportunityState {
  final bool isLoading;
  final List<OpportunityModel> opportunities;
  final OpportunityFilterModel filter;
  final OpportunityTab activeTab;
  final OpportunityModel? selectedOpportunity;
  final String? errorMessage;
  final OpportunitySort sort;

  const OpportunityState({
    this.isLoading = false,
    this.opportunities = const [],
    this.filter = const OpportunityFilterModel(),
    this.activeTab = OpportunityTab.all,
    this.selectedOpportunity,
    this.errorMessage,
    this.sort = OpportunitySort.deadlineSoonest,
  });

  List<OpportunityModel> get currentTabOpportunities {
    final List<OpportunityModel> items;
    switch (activeTab) {
      case OpportunityTab.all:
        items = opportunities;
        break;
      case OpportunityTab.scholarships:
        items = opportunities.where((o) => o.isScholarship).toList();
        break;
      case OpportunityTab.internships:
        items = opportunities.where((o) => o.isInternship).toList();
        break;
      case OpportunityTab.saved:
        items = opportunities.where((o) => o.isSaved).toList();
        break;
      case OpportunityTab.applied:
        items = opportunities.where((o) => o.isApplied).toList();
        break;
    }
    final sorted = [...items];
    switch (sort) {
      case OpportunitySort.deadlineSoonest:
        sorted.sort((a, b) => a.deadline.compareTo(b.deadline));
      case OpportunitySort.deadlineLatest:
        sorted.sort((a, b) => b.deadline.compareTo(a.deadline));
      case OpportunitySort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case OpportunitySort.alphabetical:
        sorted.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }
    return sorted;
  }

  OpportunityState copyWith({
    bool? isLoading,
    List<OpportunityModel>? opportunities,
    OpportunityFilterModel? filter,
    OpportunityTab? activeTab,
    OpportunityModel? selectedOpportunity,
    String? errorMessage,
    OpportunitySort? sort,
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
      sort: sort ?? this.sort,
    );
  }
}
