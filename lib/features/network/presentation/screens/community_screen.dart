import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/empty_state_view.dart';

/// Professional Network & Community Screen (Phase 4)
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            'Professional Network',
            style: AppTextStyles.titleLarge(context),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            tabs: [
              Tab(text: 'Hot'),
              Tab(text: 'New'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EmptyStateView(
              icon: Icons.local_fire_department_rounded,
              title: 'Trending Community Discussions',
              message:
                  'Reddit-style feed with upvotes, topic tags (Scholarships, Internships, Tech, Biotech), comments and moderation logic will be integrated in Phase 4.',
            ),
            EmptyStateView(
              icon: Icons.fiber_new_rounded,
              title: 'Latest Posts',
              message: 'Discover newly submitted questions from students across Pakistan.',
            ),
            EmptyStateView(
              icon: Icons.people_outline_rounded,
              title: 'Your Following',
              message: 'Follow specific mentors, university alumni, and topic tags.',
            ),
          ],
        ),
      ),
    );
  }
}
