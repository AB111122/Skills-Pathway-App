import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/stat_badge.dart';
import '../../../../models/application_model.dart';
import '../../../../models/opportunity_model.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../university_provider.dart';

class UniversityOpportunitiesScreen extends ConsumerStatefulWidget {
  const UniversityOpportunitiesScreen({super.key});

  @override
  ConsumerState<UniversityOpportunitiesScreen> createState() =>
      _UniversityOpportunitiesScreenState();
}

class _UniversityOpportunitiesScreenState
    extends ConsumerState<UniversityOpportunitiesScreen> {
  late Future<List<OpportunityModel>> _items;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final organizationId =
        ref.read(authControllerProvider).currentUser?.id ?? '';
    _items = ref
        .read(universityRepositoryProvider)
        .getOwnedOpportunities(organizationId);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _items;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Manage Opportunities',
          style: AppTextStyles.titleLarge(context),
        ),
      ),
      body: FutureBuilder<List<OpportunityModel>>(
        future: _items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 44,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Unable to load listings.',
                      style: AppTextStyles.titleMedium(context),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Retry',
                      width: 130,
                      onPressed: _refresh,
                    ),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.p20),
              children: [
                CustomButton(
                  text: 'Create Opportunity',
                  icon: Icons.add_business_rounded,
                  onPressed: () async {
                    await context.push('/university/opportunities/create');
                    if (mounted) setState(_reload);
                  },
                ),
                const SizedBox(height: 20),
                if (items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p32),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          size: 56,
                          color: isDark
                              ? AppColors.textMutedDark
                              : AppColors.textMutedLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No opportunities created yet',
                          style: AppTextStyles.titleMedium(context),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Create scholarships and internships to attract students.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall(
                            context,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...items.map(
                    (item) => _OpportunityTile(
                      item: item,
                      onChanged: () {
                        if (mounted) setState(_reload);
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OpportunityTile extends ConsumerWidget {
  final OpportunityModel item;
  final VoidCallback onChanged;

  const _OpportunityTile({required this.item, required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationId =
        ref.read(authControllerProvider).currentUser?.id ?? '';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isClosed =
        item.status == OpportunityStatus.closed ||
        item.deadline.isBefore(DateTime.now());

    return FutureBuilder<List<ApplicationModel>>(
      future: ref
          .read(universityRepositoryProvider)
          .getApplicants(organizationId, item.id),
      builder: (context, snapshot) {
        final applicantCount = snapshot.data?.length ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppDimensions.roundedMedium,
            side: BorderSide(
              color: isDark
                  ? AppColors.cardBorderDark
                  : AppColors.cardBorderLight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.titleSmall(context),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.location,
                            style: AppTextStyles.bodySmall(
                              context,
                              color: isDark
                                  ? AppColors.textMutedDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) async {
                        if (action == 'view') {
                          await context.push('/opportunities/${item.id}');
                          return;
                        }
                        if (action == 'edit') {
                          if (!context.mounted) return;
                          await context.push(
                            '/university/opportunities/${item.id}/edit',
                            extra: item,
                          );
                          if (context.mounted) onChanged();
                          return;
                        }
                        if (action == 'close') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Close opportunity?'),
                              content: const Text(
                                'Are you sure you want to close this opportunity? Students will no longer be able to apply.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Close Opportunity'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref
                                .read(universityRepositoryProvider)
                                .closeOpportunity(organizationId, item.id);
                            onChanged();
                          }
                          return;
                        }
                        if (action == 'delete') {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete opportunity?'),
                              content: const Text(
                                'Are you sure you want to delete this opportunity?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await ref
                                .read(universityRepositoryProvider)
                                .deleteOpportunity(organizationId, item.id);
                            onChanged();
                          }
                          return;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Text('View Details'),
                        ),
                        if (!isClosed)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                        if (!isClosed)
                          const PopupMenuItem(
                            value: 'close',
                            child: Text('Close'),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    StatBadge(
                      text: item.type.label,
                      style: StatBadgeStyle.primary,
                    ),
                    StatBadge(
                      text: '$applicantCount Applicants',
                      style: StatBadgeStyle.neutral,
                    ),
                    StatBadge(
                      text: isClosed ? 'Closed' : 'Active',
                      style: isClosed
                          ? StatBadgeStyle.error
                          : StatBadgeStyle.success,
                    ),
                    StatBadge(
                      text:
                          'Deadline: ${item.deadline.toLocal().toString().split(' ').first}',
                      style: StatBadgeStyle.neutral,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
