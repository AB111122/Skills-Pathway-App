import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../models/user_model.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final UserRole initialRole;

  const LoginScreen({
    super.key,
    this.initialRole = UserRole.student,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _rememberMe = true;
  late UserRole _currentRole;

  @override
  void initState() {
    super.initState();
    _currentRole = widget.initialRole;
    _emailController = TextEditingController(
      text: _currentRole == UserRole.student
          ? 'fatima.zahra@nust.edu.pk'
          : 'admissions@nust.edu.pk',
    );
    _passwordController = TextEditingController(text: 'Password123');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _currentRole = role;
      if (role == UserRole.student) {
        _emailController.text = 'fatima.zahra@nust.edu.pk';
      } else {
        _emailController.text = 'admissions@nust.edu.pk';
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      final role = ref.read(authControllerProvider).currentUser?.role;
      context.go(role == UserRole.organization
          ? RouteNames.universityDashboard
          : RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(RouteNames.roleSelection),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Brand Pill Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified Portal Sign In',
                        style: AppTextStyles.labelSmall(
                          context,
                          color: AppColors.primary,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  AppStrings.loginTitle,
                  style: AppTextStyles.displayMedium(context),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.loginSubtitle,
                  style: AppTextStyles.bodyMedium(
                    context,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 24),

                // Role Segmented Switch
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.cardBorderLight.withOpacity(0.5),
                    borderRadius: AppDimensions.roundedMedium,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildRoleTab(
                          label: 'Student',
                          icon: Icons.school_rounded,
                          isSelected: _currentRole == UserRole.student,
                          onTap: () => _onRoleChanged(UserRole.student),
                        ),
                      ),
                      Expanded(
                        child: _buildRoleTab(
                          label: 'University / Firm',
                          icon: Icons.business_rounded,
                          isSelected: _currentRole == UserRole.organization,
                          onTap: () => _onRoleChanged(UserRole.organization),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Error Banner if present
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.p12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: AppDimensions.roundedMedium,
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: AppTextStyles.bodySmall(
                              context,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email Field
                CustomTextField(
                  label: AppStrings.emailLabel,
                  hint: _currentRole == UserRole.student
                      ? 'e.g. fatima.zahra@nust.edu.pk'
                      : 'e.g. admissions@nust.edu.pk',
                  controller: _emailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return AppStrings.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Password Field
                CustomTextField(
                  label: AppStrings.passwordLabel,
                  hint: AppStrings.passwordHint,
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  isPassword: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (val.length < 6) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? true;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.rememberMe,
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.forgotPassword),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        AppStrings.forgotPassword,
                        style: AppTextStyles.labelSmall(
                          context,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sign In Button
                CustomButton(
                  text: AppStrings.signInButton,
                  variant: ButtonVariant.gradient,
                  isLoading: authState.isLoading,
                  icon: Icons.login_rounded,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),

                // Quick Demo Auto-fill Helper
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMint.withOpacity(0.08),
                    borderRadius: AppDimensions.roundedMedium,
                    border: Border.all(
                      color: AppColors.primaryMint.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _currentRole == UserRole.student
                              ? 'Demo Student account pre-loaded (Fatima Zahra, NUST)'
                              : 'Demo Org account pre-loaded (NUST Admissions)',
                          style: AppTextStyles.labelSmall(
                            context,
                            color: isDark
                                ? AppColors.primaryMint
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Don't have an account? Sign up
                Center(
                  child: TextButton(
                    onPressed: () {
                      if (_currentRole == UserRole.student) {
                        context.go(RouteNames.registerStudent);
                      } else {
                        context.go(RouteNames.registerOrganization);
                      }
                    },
                    child: Text.rich(
                      TextSpan(
                        text: "${AppStrings.dontHaveAccount} ",
                        style: AppTextStyles.bodyMedium(
                          context,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        children: [
                          TextSpan(
                            text: AppStrings.signUpButton,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium(
                context,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
