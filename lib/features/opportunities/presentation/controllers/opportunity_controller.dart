import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/opportunity_filter_model.dart';
import '../../../../models/opportunity_model.dart';
import '../../../../services/mock_opportunity_service.dart';
import '../../../../services/opportunity_service.dart';
import '../../domain/opportunity_state.dart';

final opportunityServiceProvider = Provider<OpportunityService>((ref) {
  return MockOpportunityService();
});

final opportunityControllerProvider =
    StateNotifierProvider<OpportunityController, OpportunityState>((ref) {
  final service = ref.watch(opportunityServiceProvider);
  return OpportunityController(service);
});

class OpportunityController extends StateNotifier<OpportunityState> {
  final OpportunityService _service;

  OpportunityController(this._service) : super(const OpportunityState()) {
    loadOpportunities();
  }

  /// Loads opportunities based on current filter state
  Future<void> loadOpportunities() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _service.getOpportunities(filter: state.filter);
      state = state.copyWith(
        isLoading: false,
        opportunities: items,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load opportunities: ${e.toString()}',
      );
    }
  }

  /// Live Search
  void updateSearchQuery(String query) {
    final newFilter = state.filter.copyWith(searchQuery: query);
    state = state.copyWith(filter: newFilter);
    loadOpportunities();
  }

  /// Apply Multi-criteria Filter
  void applyFilter(OpportunityFilterModel filter) {
    state = state.copyWith(filter: filter);
    loadOpportunities();
  }

  /// Reset all filters back to initial
  void resetFilters() {
    state = state.copyWith(filter: const OpportunityFilterModel());
    loadOpportunities();
  }

  /// Change active tab (All, Scholarships, Internships, Saved, Applied)
  void setTab(OpportunityTab tab) {
    state = state.copyWith(activeTab: tab);
  }

  void setSort(OpportunitySort sort) {
    state = state.copyWith(sort: sort);
  }

  /// Load details for a specific opportunity
  Future<OpportunityModel?> loadOpportunityDetails(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      final item = await _service.getOpportunityById(id);
      state = state.copyWith(
        isLoading: false,
        selectedOpportunity: item,
      );
      return item;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load details: ${e.toString()}',
      );
      return null;
    }
  }

  /// Toggle Bookmark / Save
  Future<void> toggleSave(String id) async {
    final updatedSavedStatus = await _service.toggleSaveOpportunity(id);

    // Update in local list immediately
    final updatedList = state.opportunities.map((opp) {
      if (opp.id == id) {
        return opp.copyWith(isSaved: updatedSavedStatus);
      }
      return opp;
    }).toList();

    OpportunityModel? updatedSelected = state.selectedOpportunity;
    if (updatedSelected?.id == id) {
      updatedSelected = updatedSelected?.copyWith(isSaved: updatedSavedStatus);
    }

    state = state.copyWith(
      opportunities: updatedList,
      selectedOpportunity: updatedSelected,
    );
  }

  /// Mark opportunity as applied after opening official website
  Future<void> markApplied(String id) async {
    final applied = await _service.markAsApplied(id);
    if (!applied) return;

    final updatedList = state.opportunities.map((opp) {
      if (opp.id == id) {
        return opp.copyWith(
          isApplied: true,
          appliedAt: DateTime.now(),
        );
      }
      return opp;
    }).toList();

    OpportunityModel? updatedSelected = state.selectedOpportunity;
    if (updatedSelected?.id == id) {
      updatedSelected = updatedSelected?.copyWith(
        isApplied: true,
        appliedAt: DateTime.now(),
      );
    }

    state = state.copyWith(
      opportunities: updatedList,
      selectedOpportunity: updatedSelected,
    );
  }

  /// Toggle deadline reminder alert
  Future<void> toggleDeadlineReminder(String id) async {
    final hasReminder = await _service.toggleDeadlineReminder(id);

    final updatedList = state.opportunities.map((opp) {
      if (opp.id == id) {
        return opp.copyWith(hasDeadlineReminder: hasReminder);
      }
      return opp;
    }).toList();

    OpportunityModel? updatedSelected = state.selectedOpportunity;
    if (updatedSelected?.id == id) {
      updatedSelected = updatedSelected?.copyWith(
        hasDeadlineReminder: hasReminder,
      );
    }

    state = state.copyWith(
      opportunities: updatedList,
      selectedOpportunity: updatedSelected,
    );
  }
}
