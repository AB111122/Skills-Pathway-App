import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';

/// AI Chatbot Home & Assistant Screen (Phase 5)
class ChatbotHomeScreen extends StatefulWidget {
  const ChatbotHomeScreen({super.key});

  @override
  State<ChatbotHomeScreen> createState() => _ChatbotHomeScreenState();
}

class _ChatbotHomeScreenState extends State<ChatbotHomeScreen> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _openConversation() {
    final prompt = _input.text.trim();
    if (prompt.isEmpty) return;
    context.push('/chatbot/conversation', extra: prompt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quickActions = [
      {
        'title': 'Career Guidance',
        'icon': Icons.explore_rounded,
        'desc': 'Find suitable career paths for your degree',
      },
      {
        'title': 'Find Internships',
        'icon': Icons.work_rounded,
        'desc': 'Match verified opportunities in Pakistan',
      },
      {
        'title': 'Resume Help',
        'icon': Icons.description_rounded,
        'desc': 'Check for missing keywords & skills',
      },
      {
        'title': 'Scholarships',
        'icon': Icons.school_rounded,
        'desc': 'Discover funded programs & deadlines',
      },
      {
        'title': 'Market Insights',
        'icon': Icons.insights_rounded,
        'desc': 'Explore trending technology & job stats',
      },
      {
        'title': 'Ask Me Anything',
        'icon': Icons.auto_awesome_rounded,
        'desc': 'Custom questions & advice',
      },
    ];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                gradient: AppColors.aiBannerGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI Career Assistant',
              style: AppTextStyles.titleMedium(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can I help you today?',
                style: AppTextStyles.displayMedium(context)
                    .copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Personalized recommendations powered by your profile and verified listings.',
                style: AppTextStyles.bodyMedium(
                  context,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),

              // Quick Action Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                  ),
                  itemCount: quickActions.length,
                  itemBuilder: (context, index) {
                    final item = quickActions[index];
                    return InkWell(
                      onTap: () {
                        context.push(
                          '/chatbot/conversation',
                          extra: item['title'] as String,
                        );
                      },
                      borderRadius: AppDimensions.roundedLarge,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.p16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: AppDimensions.roundedLarge,
                          border: Border.all(
                            color: isDark
                                ? AppColors.cardBorderDark
                                : AppColors.cardBorderLight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: AppDimensions.roundedMedium,
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item['title'] as String,
                              style: AppTextStyles.titleSmall(context),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['desc'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
                  },
                ),
              ),

              // Chat Input Bar Simulation
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: AppDimensions.roundedMedium,
                  border: Border.all(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        onSubmitted: (_) => _openConversation(),
                        textInputAction: TextInputAction.send,
                        decoration: const InputDecoration(
                          hintText: 'Ask about scholarships, career roadmaps, or jobs...',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: AppColors.primary,
                      ),
                      onPressed: _openConversation,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
