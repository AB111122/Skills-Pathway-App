import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String badgeText;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.badgeText,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      title: 'Verified Scholarships & Internships',
      description:
          'Access 100% verified undergraduate, master\'s, and corporate opportunities from top universities and global organizations in Pakistan and abroad.',
      icon: Icons.verified_user_rounded,
      iconColor: AppColors.primaryMint,
      badgeText: 'Verified Listings Only',
    ),
    OnboardingItem(
      title: 'AI Career Roadmap & Skill Gap Analyzer',
      description:
          'Get intelligent, step-by-step career roadmaps, discover in-demand Pakistan tech & market skills, and analyze resume fit in seconds.',
      icon: Icons.auto_awesome_rounded,
      iconColor: AppColors.accentGold,
      badgeText: 'Smart Guidance',
    ),
    OnboardingItem(
      title: 'Professional Network & One-Tap Apply',
      description:
          'Connect with alumni, join topic communities (Technology, Biotech, Business), track closing deadlines, and apply directly via official portals.',
      icon: Icons.hub_rounded,
      iconColor: AppColors.secondary,
      badgeText: 'Connect & Succeed',
    ),
  ];

  void _onNext() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.go(RouteNames.roleSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go(RouteNames.roleSelection),
            child: Text(
              'Skip',
              style: AppTextStyles.labelMedium(
                context,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                        // Icon Hero Container
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item.iconColor.withValues(alpha: 0.12),
                            border: Border.all(
                              color: item.iconColor.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 70,
                              color: item.iconColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.badgeText,
                            style: AppTextStyles.labelSmall(
                              context,
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.displayMedium(context).copyWith(
                            fontSize: 24,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Description
                        Text(
                          item.description,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(
                            context,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.p24,
                vertical: AppDimensions.p20,
              ),
              child: Column(
                children: [
                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.cardBorderLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Action Button
                  CustomButton(
                    text: _currentPage == _items.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    variant: ButtonVariant.gradient,
                    icon: Icons.arrow_forward_rounded,
                    isIconTrailing: true,
                    onPressed: _onNext,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
