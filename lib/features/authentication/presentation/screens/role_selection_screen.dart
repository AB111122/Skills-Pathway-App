import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../models/user_model.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole _selectedRole = UserRole.student;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              const SizedBox(height: AppDimensions.p32),

              // Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.p12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                AppStrings.chooseRoleTitle,
                style: AppTextStyles.displayMedium(context),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.chooseRoleSubtitle,
                style: AppTextStyles.bodyMedium(
                  context,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 36),

              // Role Card 1: Student
              _buildRoleCard(
                context: context,
                role: UserRole.student,
                title: AppStrings.studentRole,
                description: AppStrings.studentRoleDesc,
                icon: Icons.school_rounded,
                badge: 'For Applicants & Learners',
                isSelected: _selectedRole == UserRole.student,
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.student;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Role Card 2: Organization
              _buildRoleCard(
                context: context,
                role: UserRole.organization,
                title: AppStrings.organizationRole,
                description: AppStrings.organizationRoleDesc,
                icon: Icons.business_rounded,
                badge: 'For Universities & Firms',
                isSelected: _selectedRole == UserRole.organization,
                onTap: () {
                  setState(() {
                    _selectedRole = UserRole.organization;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(
                      '${RouteNames.login}?role=${_selectedRole.name}',
                    );
                  },
                  child: const Text('Continue to Sign In'),
                ),
              ),
              const SizedBox(height: 12),

              // Create Account Link
              Center(
                child: TextButton(
                  onPressed: () {
                    if (_selectedRole == UserRole.student) {
                      context.go(RouteNames.registerStudent);
                    } else {
                      context.go(RouteNames.registerOrganization);
                    }
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "New here? ",
                      style: AppTextStyles.bodyMedium(
                        context,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      children: [
                        TextSpan(
                          text: 'Create an Account',
                          style: AppTextStyles.labelLarge(
                            context,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required String badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.roundedLarge,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.p20),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.06))
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: AppDimensions.roundedLarge,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.p12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.surfaceDark
                        : AppColors.backgroundLight),
                borderRadius: AppDimensions.roundedMedium,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.cardBorderLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: AppTextStyles.labelSmall(
                        context,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: AppTextStyles.titleMedium(
                      context,
                      color: isSelected ? AppColors.primary : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? AppColors.primary : AppColors.cardBorderLight,
            ),
          ],
        ),
      ),
    );
  }
}
