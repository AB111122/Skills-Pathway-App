import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/text_styles.dart';

/// Main Scaffold supporting persistent bottom navigation with StatefulShellRoute.
class MainScaffoldScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = navigationShell.currentIndex;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isNarrow = screenWidth < 380;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.cardBorderDark
                  : AppColors.cardBorderLight,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 4 : 8,
              vertical: 6,
            ),
            child: Row(
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  currentIndex: currentIndex,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: 'Home',
                  isNarrow: isNarrow,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  currentIndex: currentIndex,
                  icon: Icons.work_outline_rounded,
                  selectedIcon: Icons.work_rounded,
                  label: 'Opportunities',
                  isNarrow: isNarrow,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  currentIndex: currentIndex,
                  icon: Icons.forum_outlined,
                  selectedIcon: Icons.forum_rounded,
                  label: 'Community',
                  isNarrow: isNarrow,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  currentIndex: currentIndex,
                  icon: Icons.auto_awesome_outlined,
                  selectedIcon: Icons.auto_awesome_rounded,
                  label: 'AI Guide',
                  isHighlighted: true,
                  isNarrow: isNarrow,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  currentIndex: currentIndex,
                  icon: Icons.person_outline_rounded,
                  selectedIcon: Icons.person_rounded,
                  label: 'Profile',
                  isNarrow: isNarrow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    bool isHighlighted = false,
    bool isNarrow = false,
  }) {
    final isSelected = index == currentIndex;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final activeColor = isHighlighted ? AppColors.accentGold : AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight;

    return Expanded(
      child: InkWell(
        onTap: () => _onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 4 : 8,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: isSelected && !isHighlighted
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                size: isNarrow ? 20 : 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
              SizedBox(height: isNarrow ? 2 : 3),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall(
                    context,
                    color: isSelected ? activeColor : inactiveColor,
                  ).copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: isNarrow ? 10 : 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
