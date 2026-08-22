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
import '../../domain/auth_state.dart';
import '../controllers/auth_controller.dart';

class RegisterStudentScreen extends ConsumerStatefulWidget {
  const RegisterStudentScreen({super.key});

  @override
  ConsumerState<RegisterStudentScreen> createState() =>
      _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends ConsumerState<RegisterStudentScreen> {
  int _currentStep = 1;
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 1: Personal Info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController(text: 'Islamabad');

  // Step 2: Academic Background
  String _educationLevel = 'Undergraduate';
  final _degreeController = TextEditingController(text: 'BS Computer Science');
  final _fieldController = TextEditingController(text: 'Computer Science');
  final _universityController =
      TextEditingController(text: 'National University of Sciences & Technology (NUST)');

  // Step 3: Skills & Interests
  final List<String> _availableSkills = [
    'Flutter',
    'Python',
    'Machine Learning',
    'Data Analysis',
    'SQL',
    'Graphic Design',
    'Financial Modeling',
    'Digital Marketing',
    'Public Speaking',
  ];
  final Set<String> _selectedSkills = {'Flutter', 'Python', 'Machine Learning'};

  final List<String> _availableInterests = [
    'AI & Data Science',
    'Software Engineering',
    'Fintech & Banking',
    'Management Consulting',
    'Biotechnology',
    'Civil / Electrical Engineering',
  ];
  final Set<String> _selectedInterests = {
    'AI & Data Science',
    'Software Engineering',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _degreeController.dispose();
    _fieldController.dispose();
    _universityController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (!_step1FormKey.currentState!.validate()) return;
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      if (!_step2FormKey.currentState!.validate()) return;
      setState(() => _currentStep = 3);
    } else {
      _handleCompleteRegistration();
    }
  }

  Future<void> _handleCompleteRegistration() async {
    final success =
        await ref.read(authControllerProvider.notifier).registerStudent(
              fullName: _nameController.text.trim().isNotEmpty
                  ? _nameController.text.trim()
                  : 'Fatima Zahra',
              email: _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : 'fatima.zahra@nust.edu.pk',
              password: _passwordController.text.isNotEmpty
                  ? _passwordController.text
                  : 'Password123',
              city: _cityController.text.trim(),
              educationLevel: _educationLevel,
              degree: _degreeController.text.trim(),
              fieldOfStudy: _fieldController.text.trim(),
              university: _universityController.text.trim(),
              skills: _selectedSkills.toList(),
              careerInterests: _selectedInterests.toList(),
            );

    if (success && mounted) {
      context.go(RouteNames.home);
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
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep -= 1);
            } else {
              context.go(RouteNames.roleSelection);
            }
          },
        ),
        title: Text(
          'Student Registration',
          style: AppTextStyles.titleMedium(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Tracker
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.p24,
                vertical: AppDimensions.p12,
              ),
              child: Row(
                children: [
                  _buildStepIndicator(
                    step: 1,
                    title: 'Account',
                    isActive: _currentStep >= 1,
                  ),
                  _buildStepDivider(isActive: _currentStep >= 2),
                  _buildStepIndicator(
                    step: 2,
                    title: 'Academic',
                    isActive: _currentStep >= 2,
                  ),
                  _buildStepDivider(isActive: _currentStep >= 3),
                  _buildStepIndicator(
                    step: 3,
                    title: 'Skills',
                    isActive: _currentStep >= 3,
                  ),
                ],
              ),
            ),
            const Divider(),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.p24),
                child: _buildCurrentStepContent(context, authState),
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(AppDimensions.p24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.cardBorderDark
                        : AppColors.cardBorderLight,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (_currentStep > 1) ...[
                    Expanded(
                      flex: 1,
                      child: CustomButton(
                        text: 'Back',
                        variant: ButtonVariant.outline,
                        onPressed: () => setState(() => _currentStep -= 1),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      text: _currentStep == 3 ? 'Complete & Start' : 'Next Step',
                      variant: ButtonVariant.gradient,
                      isLoading: authState.isLoading,
                      icon: _currentStep == 3
                          ? Icons.check_circle_outline_rounded
                          : Icons.arrow_forward_rounded,
                      isIconTrailing: true,
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(BuildContext context, AuthState authState) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Personal();
      case 2:
        return _buildStep2Academic();
      case 3:
      default:
        return _buildStep3SkillsAndInterests();
    }
  }

  Widget _buildStep1Personal() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Details',
            style: AppTextStyles.titleLarge(context),
          ),
          const SizedBox(height: 4),
          Text(
            'Create your student credentials to receive personalized opportunities.',
            style: AppTextStyles.bodySmall(context),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: AppStrings.fullNameLabel,
            hint: 'e.g. Fatima Zahra',
            controller: _nameController,
            prefixIcon: Icons.person_outline_rounded,
            validator: (val) =>
                val == null || val.trim().isEmpty ? AppStrings.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: AppStrings.emailLabel,
            hint: 'e.g. fatima.zahra@nust.edu.pk',
            controller: _emailController,
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.trim().isEmpty) return AppStrings.fieldRequired;
              if (!val.contains('@') || !val.contains('.')) return AppStrings.invalidEmail;
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: AppStrings.passwordLabel,
            hint: AppStrings.passwordHint,
            controller: _passwordController,
            prefixIcon: Icons.lock_outline_rounded,
            isPassword: true,
            validator: (val) {
              if (val == null || val.isEmpty) return AppStrings.fieldRequired;
              if (val.length < 6) return AppStrings.passwordTooShort;
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'City / Location',
            hint: 'e.g. Islamabad, Lahore, Karachi, Peshawar',
            controller: _cityController,
            prefixIcon: Icons.location_city_rounded,
            validator: (val) =>
                val == null || val.trim().isEmpty ? AppStrings.fieldRequired : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2Academic() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Background',
            style: AppTextStyles.titleLarge(context),
          ),
          const SizedBox(height: 4),
          Text(
            'We use your academic details to match verified scholarships and eligibility criteria.',
            style: AppTextStyles.bodySmall(context),
          ),
          const SizedBox(height: 24),
          Text(
            'Current Education Level',
            style: AppTextStyles.labelMedium(context),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              'High School / FSC',
              'Undergraduate',
              'Master\'s',
              'PhD',
              'Fresh Graduate',
            ].map((level) {
              final isSelected = _educationLevel == level;
              return ChoiceChip(
                label: Text(level),
                selected: isSelected,
                selectedColor: AppColors.primary.withOpacity(0.15),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _educationLevel = level);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Degree Program',
            hint: 'e.g. BS Computer Science, BBA, MBBS',
            controller: _degreeController,
            prefixIcon: Icons.school_outlined,
            validator: (val) =>
                val == null || val.trim().isEmpty ? AppStrings.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Field of Study',
            hint: 'e.g. Computer Science, AI, Business, Pre-Med',
            controller: _fieldController,
            prefixIcon: Icons.menu_book_rounded,
            validator: (val) =>
                val == null || val.trim().isEmpty ? AppStrings.fieldRequired : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'University / College Name',
            hint: 'e.g. NUST, FAST-NUCES, LUMS, GIKI, UET',
            controller: _universityController,
            prefixIcon: Icons.account_balance_rounded,
            validator: (val) =>
                val == null || val.trim().isEmpty ? AppStrings.fieldRequired : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3SkillsAndInterests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills & Career Goals',
          style: AppTextStyles.titleLarge(context),
        ),
        const SizedBox(height: 4),
        Text(
          'Select your top skills and preferred career trajectories.',
          style: AppTextStyles.bodySmall(context),
        ),
        const SizedBox(height: 24),
        Text(
          'Your Current Skills',
          style: AppTextStyles.labelMedium(context),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSkills.map((skill) {
            final isSelected = _selectedSkills.contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              selectedColor: AppColors.primaryMint.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primaryDark : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSkills.add(skill);
                  } else {
                    _selectedSkills.remove(skill);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Target Career Fields',
          style: AppTextStyles.labelMedium(context),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((interest) {
            final isSelected = _selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              selectedColor: AppColors.secondary.withOpacity(0.2),
              checkmarkColor: AppColors.secondary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.secondary : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required String title,
    required bool isActive,
  }) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primary : AppColors.cardBorderLight,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondaryLight,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondaryLight,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? AppColors.primary : AppColors.cardBorderLight,
      ),
    );
  }
}
