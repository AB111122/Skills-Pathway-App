import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/stat_badge.dart';
import '../../../../models/application_model.dart';
import '../../../../services/application_repository.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class StudentApplicationsScreen extends ConsumerWidget {
  const StudentApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentId = ref.watch(authControllerProvider).currentUser?.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (studentId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Applications')),
        body: const Center(
          child: Text('Please sign in to view your applications.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'My Applications',
          style: AppTextStyles.titleLarge(context),
        ),
      ),
      body: FutureBuilder<List<ApplicationModel>>(
        future: ref.watch(applicationRepositoryProvider).forStudent(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: Text(
                  'Unable to load applications. Please try again.',
                  style: AppTextStyles.bodyMedium(context),
                ),
              ),
            );
          }

          final applications = snapshot.data ?? [];
          if (applications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.p32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 56,
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No applications yet',
                      style: AppTextStyles.titleMedium(context),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Apply to verified scholarships and internships to track your status here.',
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
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.p20),
            itemCount: applications.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final application = applications[index];
              final dateStr = application.applicationDate
                  .toLocal()
                  .toString()
                  .split(' ')
                  .first;

              StatBadgeStyle badgeStyle;
              switch (application.status) {
                case ApplicationStatus.shortlisted:
                  badgeStyle = StatBadgeStyle.success;
                  break;
                case ApplicationStatus.reviewed:
                  badgeStyle = StatBadgeStyle.info;
                  break;
                case ApplicationStatus.rejected:
                  badgeStyle = StatBadgeStyle.error;
                  break;
                case ApplicationStatus.pending:
                  badgeStyle = StatBadgeStyle.warning;
                  break;
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.roundedMedium,
                  side: BorderSide(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorderLight,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    context.push('/opportunities/${application.opportunityId}');
                  },
                  borderRadius: AppDimensions.roundedMedium,
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
                                    application.opportunityTitle,
                                    style: AppTextStyles.titleSmall(context),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    application.universityName,
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
                            StatBadge(
                              text: application.status.name.toUpperCase(),
                              style: badgeStyle,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Applied on: $dateStr',
                              style: AppTextStyles.labelSmall(
                                context,
                                color: isDark
                                    ? AppColors.textMutedDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: AppColors.textMutedLight,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
