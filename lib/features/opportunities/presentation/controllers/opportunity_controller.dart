import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/opportunity_filter_model.dart';
import '../../../../models/opportunity_model.dart';
import '../../../../services/firebase_opportunity_service.dart';
import '../../../../services/mock_opportunity_service.dart';
import '../../../../services/opportunity_service.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../domain/opportunity_state.dart';

final opportunityServiceProvider = Provider<OpportunityService>((ref) {
  return Firebase.apps.isEmpty
      ? MockOpportunityService()
      : FirebaseOpportunityService();
});

final opportunityControllerProvider =
    StateNotifierProvider<OpportunityController, OpportunityState>((ref) {
      final service = ref.watch(opportunityServiceProvider);
      final controller = OpportunityController(service);
      ref.listen(authControllerProvider, (previous, next) {
        if (next.isAuthenticated &&
            previous?.currentUser?.id != next.currentUser?.id) {
          controller.loadOpportunities();
        }
      });
      return controller;
    });

class OpportunityController extends StateNotifier<OpportunityState> {
  final OpportunityService _service;
  StreamSubscription? _authSubscription;

  OpportunityController(this._service) : super(const OpportunityState()) {
    if (Firebase.apps.isNotEmpty) {
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        loadOpportunities();
      } else {
        debugPrint(
          '[OpportunityController] No user session yet. Deferring query until authStateChanges emits non-null user.',
        );
        _authSubscription = auth.authStateChanges().listen((user) {
          if (user != null) {
            debugPrint(
              '[OpportunityController] Auth session restored (UID: ${user.uid}). Loading opportunities.',
            );
            loadOpportunities();
            _authSubscription?.cancel();
            _authSubscription = null;
          }
        });
      }
    } else {
      loadOpportunities();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
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
    } catch (e, stackTrace) {
      debugPrint('[OpportunityController] load opportunities failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load opportunities: $e',
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
      state = state.copyWith(isLoading: false, selectedOpportunity: item);
      return item;
    } catch (e, stackTrace) {
      debugPrint('[OpportunityController] load opportunity failed: $e');
      debugPrintStack(stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to load opportunity details: $e',
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
    try {
      final applied = await _service.markAsApplied(id);
      if (!applied) return;

      final updatedList = state.opportunities.map((opp) {
        if (opp.id == id) {
          return opp.copyWith(isApplied: true, appliedAt: DateTime.now());
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
    } catch (error) {
      debugPrint('[OpportunityController] apply failed: $error');
      state = state.copyWith(
        errorMessage: 'Unable to submit application. Please try again.',
      );
    }
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
