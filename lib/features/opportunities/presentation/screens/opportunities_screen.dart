import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/widgets/opportunity_card.dart';
import '../../../../core/widgets/stat_badge.dart';
import '../../domain/opportunity_state.dart';
import '../controllers/opportunity_controller.dart';
import '../widgets/opportunity_filter_sheet.dart';

class OpportunitiesScreen extends ConsumerStatefulWidget {
  const OpportunitiesScreen({super.key});

  @override
  ConsumerState<OpportunitiesScreen> createState() =>
      _OpportunitiesScreenState();
}

class _OpportunitiesScreenState extends ConsumerState<OpportunitiesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(BuildContext context) {
    final currentFilter = ref.read(opportunityControllerProvider).filter;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OpportunityFilterSheet(
        initialFilter: currentFilter,
        onApply: (newFilter) {
          ref
              .read(opportunityControllerProvider.notifier)
              .applyFilter(newFilter);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(opportunityControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentItems = state.currentTabOpportunities;
    final savedCount = state.opportunities.where((o) => o.isSaved).length;
    final appliedCount = state.opportunities.where((o) => o.isApplied).length;
    final activeFilterCount = state.filter.activeFilterCount;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Verified Opportunities',
          style: AppTextStyles.titleLarge(context),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter listings',
                onPressed: () => _openFilterSheet(context),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryMint,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: AppDimensions.roundedLarge,
                  border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorderLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    ref
                        .read(opportunityControllerProvider.notifier)
                        .updateSearchQuery(val);
                  },
                  style: AppTextStyles.bodyMedium(context),
                  decoration: InputDecoration(
                    hintText: 'Search scholarships, internships, skills...',
                    hintStyle: AppTextStyles.bodyMedium(
                      context,
                      color: AppColors.textMutedLight,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.textSecondaryLight,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.textMutedLight,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(opportunityControllerProvider.notifier)
                                  .updateSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Tab Bar Switcher (All, Scholarships, Internships, Saved, Applied)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabChip(
                    context: context,
                    tab: OpportunityTab.all,
                    label: 'All (${state.opportunities.length})',
                    isSelected: state.activeTab == OpportunityTab.all,
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    context: context,
                    tab: OpportunityTab.scholarships,
                    label: 'Scholarships',
                    icon: Icons.school_outlined,
                    isSelected: state.activeTab == OpportunityTab.scholarships,
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    context: context,
                    tab: OpportunityTab.internships,
                    label: 'Internships',
                    icon: Icons.work_outline_rounded,
                    isSelected: state.activeTab == OpportunityTab.internships,
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    context: context,
                    tab: OpportunityTab.saved,
                    label: 'Saved ($savedCount)',
                    icon: Icons.bookmark_border_rounded,
                    isSelected: state.activeTab == OpportunityTab.saved,
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    context: context,
                    tab: OpportunityTab.applied,
                    label: 'Applied ($appliedCount)',
                    icon: Icons.check_circle_outline_rounded,
                    isSelected: state.activeTab == OpportunityTab.applied,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Active Filters Pill Bar
            if (state.filter.hasActiveFilters) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Filters:',
                      style: AppTextStyles.labelSmall(
                        context,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (state.filter.isVerifiedOnly)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: StatBadge(
                                  text: 'Verified Only',
                                  style: StatBadgeStyle.success,
                                  onTap: () {
                                    ref
                                        .read(
                                          opportunityControllerProvider.notifier,
                                        )
                                        .applyFilter(
                                          state.filter.copyWith(
                                            isVerifiedOnly: false,
                                          ),
                                        );
                                  },
                                ),
                              ),
                            if (state.filter.location != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: StatBadge(
                                  text: state.filter.location!,
                                  style: StatBadgeStyle.primary,
                                  onTap: () {
                                    ref
                                        .read(
                                          opportunityControllerProvider.notifier,
                                        )
                                        .applyFilter(
                                          state.filter.copyWith(
                                            clearLocation: true,
                                          ),
                                        );
                                  },
                                ),
                              ),
                            if (state.filter.field != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: StatBadge(
                                  text: state.filter.field!,
                                  style: StatBadgeStyle.neutral,
                                  onTap: () {
                                    ref
                                        .read(
                                          opportunityControllerProvider.notifier,
                                        )
                                        .applyFilter(
                                          state.filter.copyWith(
                                            clearField: true,
                                          ),
                                        );
                                  },
                                ),
                              ),
                            if (state.filter.isPaidOnly)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: StatBadge(
                                  text: 'Paid Only',
                                  style: StatBadgeStyle.success,
                                  onTap: () {
                                    ref
                                        .read(
                                          opportunityControllerProvider.notifier,
                                        )
                                        .applyFilter(
                                          state.filter.copyWith(
                                            isPaidOnly: false,
                                          ),
                                        );
                                  },
                                ),
                              ),
                            InkWell(
                              onTap: () {
                                ref
                                    .read(opportunityControllerProvider.notifier)
                                    .resetFilters();
                              },
                              child: Text(
                                'Clear all',
                                style: AppTextStyles.labelSmall(
                                  context,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            const Divider(height: 1),

            // Content Body
            Expanded(
              child: state.isLoading
                  ? const LoadingIndicator(
                      message: 'Finding verified opportunities...',
                    )
                  : state.errorMessage != null
                      ? ErrorView(
                          message: state.errorMessage!,
                          onRetry: () => ref
                              .read(opportunityControllerProvider.notifier)
                              .loadOpportunities(),
                        )
                      : currentItems.isEmpty
                          ? EmptyStateView(
                              icon: state.activeTab == OpportunityTab.saved
                                  ? Icons.bookmark_border_rounded
                                  : state.activeTab == OpportunityTab.applied
                                      ? Icons.assignment_turned_in_outlined
                                      : Icons.search_off_rounded,
                              title: state.activeTab == OpportunityTab.saved
                                  ? 'No Saved Opportunities'
                                  : state.activeTab == OpportunityTab.applied
                                      ? 'No Applied Listings'
                                      : 'No Opportunities Match Your Filter',
                              message: state.activeTab == OpportunityTab.saved
                                  ? 'Bookmark scholarships and internships to keep track of closing dates.'
                                  : state.activeTab == OpportunityTab.applied
                                      ? 'Applications you initiate through One-Tap Apply will be tracked here.'
                                      : 'Try adjusting your search query, location, or clearing specific filters.',
                              actionButtonText: state.filter.hasActiveFilters
                                  ? 'Reset Filters'
                                  : null,
                              onActionPressed: state.filter.hasActiveFilters
                                  ? () {
                                      _searchController.clear();
                                      ref
                                          .read(
                                            opportunityControllerProvider
                                                .notifier,
                                          )
                                          .resetFilters();
                                    }
                                  : null,
                            )
                          : RefreshIndicator(
                              onRefresh: () => ref
                                  .read(opportunityControllerProvider.notifier)
                                  .loadOpportunities(),
                              color: AppColors.primary,
                              child: ListView.separated(
                                padding: const EdgeInsets.all(
                                  AppDimensions.p20,
                                ),
                                itemCount: currentItems.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 14),
                                itemBuilder: (context, index) {
                                  final opp = currentItems[index];
                                  return OpportunityCard(
                                    opportunity: opp,
                                    onSaveToggle: () {
                                      ref
                                          .read(
                                            opportunityControllerProvider
                                                .notifier,
                                          )
                                          .toggleSave(opp.id);
                                    },
                                    onTap: () {
                                      context.push(
                                        '/opportunities/${opp.id}',
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip({
    required BuildContext context,
    required OpportunityTab tab,
    required String label,
    IconData? icon,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        ref.read(opportunityControllerProvider.notifier).setTab(tab);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? AppColors.surfaceDark
                  : AppColors.cardBorderLight.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.cardBorderDark
                    : AppColors.cardBorderLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
