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
import '../controllers/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      setState(() {
        _isSubmitted = true;
      });
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
          onPressed: () => context.go(RouteNames.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.p24),
          child: _isSubmitted ? _buildSuccessView(context) : _buildForm(context, authState),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, dynamic authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(AppDimensions.p16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reset Password',
            style: AppTextStyles.displayMedium(context),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the email associated with your account and we\'ll send you instructions to reset your password.',
            style: AppTextStyles.bodyMedium(
              context,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: AppStrings.emailLabel,
            hint: 'e.g. yourname@university.edu.pk',
            controller: _emailController,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return AppStrings.fieldRequired;
              if (!val.contains('@') || !val.contains('.')) return AppStrings.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Send Reset Link',
            variant: ButtonVariant.gradient,
            isLoading: authState.isLoading,
            onPressed: _handleSubmit,
          ),
          const Spacer(),
          Center(
            child: TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: Text(
                'Back to Sign In',
                style: AppTextStyles.labelLarge(
                  context,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimensions.p24),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.success,
            size: 54,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Instructions Sent!',
          style: AppTextStyles.displayMedium(context),
        ),
        const SizedBox(height: 12),
        Text(
          'We have sent password recovery instructions to ${_emailController.text}. Please check your inbox and spam folder.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(context),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Return to Sign In',
          variant: ButtonVariant.primary,
          onPressed: () => context.go(RouteNames.login),
        ),
      ],
    );
  }
}
