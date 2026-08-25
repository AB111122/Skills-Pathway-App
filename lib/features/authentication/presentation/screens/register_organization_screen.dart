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

class RegisterOrganizationScreen extends ConsumerStatefulWidget {
  const RegisterOrganizationScreen({super.key});

  @override
  ConsumerState<RegisterOrganizationScreen> createState() =>
      _RegisterOrganizationScreenState();
}

class _RegisterOrganizationScreenState
    extends ConsumerState<RegisterOrganizationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _cityController = TextEditingController(text: 'Islamabad');
  final _registrationNumberController = TextEditingController();

  String _orgType = 'University / Higher Education';
  final List<String> _orgTypes = [
    'University / Higher Education',
    'Corporate / Tech Firm',
    'Financial Institution / Bank',
    'Non-Profit / NGO',
    'Government / Public Sector',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _websiteController.dispose();
    _cityController.dispose();
    _registrationNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success =
        await ref.read(authControllerProvider.notifier).registerOrganization(
              orgName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : 'NUST Admissions',
              orgType: _orgType,
              officialEmail: _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : 'admissions@nust.edu.pk',
              password: _passwordController.text.isNotEmpty
                  ? _passwordController.text
                  : 'Password123',
              website: _websiteController.text.trim().isNotEmpty
                  ? _websiteController.text.trim()
                  : 'https://nust.edu.pk',
              city: _cityController.text.trim(),
              registrationNumber: _registrationNumberController.text.trim(),
            );

    if (success && mounted) {
      context.go(RouteNames.universityDashboard);
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
        title: Text(
          'Register Organization',
          style: AppTextStyles.titleMedium(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(AppDimensions.p16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.08),
                    borderRadius: AppDimensions.roundedLarge,
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.secondary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verified Opportunity Provider',
                              style: AppTextStyles.titleSmall(context),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'All organization accounts are reviewed for legitimacy to protect student applicants.',
                              style: AppTextStyles.bodySmall(context),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextField(
                  label: 'Organization / University Name',
                  hint: 'e.g. National University of Sciences & Technology',
                  controller: _nameController,
                  prefixIcon: Icons.business_rounded,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),

                Text(
                  'Organization Type',
                  style: AppTextStyles.labelMedium(context),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: _orgType,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.category_outlined,
                      size: 20,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  items: _orgTypes
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: AppTextStyles.bodyMedium(context),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _orgType = val);
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Official Domain Email',
                  hint: 'e.g. admissions@nust.edu.pk or hr@systems.ltd',
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
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Official Website',
                  hint: 'e.g. https://nust.edu.pk',
                  controller: _websiteController,
                  prefixIcon: Icons.language_rounded,
                  keyboardType: TextInputType.url,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'City / HQ Location',
                  hint: 'e.g. Islamabad, Pakistan',
                  controller: _cityController,
                  prefixIcon: Icons.location_city_rounded,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  label: 'Registration / HEC Recognition Number',
                  hint: 'e.g. HEC-REC-2024-998',
                  controller: _registrationNumberController,
                  prefixIcon: Icons.badge_outlined,
                  validator: (val) => val == null || val.trim().isEmpty
                      ? AppStrings.fieldRequired
                      : null,
                ),
                const SizedBox(height: 16),

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
                    if (val.length < 6) return AppStrings.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                CustomButton(
                  text: 'Submit for Verification & Register',
                  variant: ButtonVariant.gradient,
                  isLoading: authState.isLoading,
                  icon: Icons.shield_outlined,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
