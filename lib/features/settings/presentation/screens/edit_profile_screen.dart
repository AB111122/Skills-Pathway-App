import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/skill_catalog.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Student Fields
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _degreeController;
  late final TextEditingController _fieldController;
  late final TextEditingController _universityController;
  late final TextEditingController _gpaController;
  late final TextEditingController _gradYearController;
  late String _educationLevel;
  late Set<String> _skills;
  late Set<String> _interests;

  // Org Fields
  late final TextEditingController _orgNameController;
  late final TextEditingController _websiteController;
  late final TextEditingController _regNumController;
  late final TextEditingController _phoneController;
  late final TextEditingController _contactPersonController;
  late String _orgType;

  final TextEditingController _customSkillController = TextEditingController();
  final TextEditingController _customInterestController =
      TextEditingController();

  final List<String> _educationLevels = [
    'High School / Matric',
    'Intermediate / A-Levels',
    'Undergraduate',
    'Master\'s',
    'PhD',
  ];

  final List<String> _orgTypes = [
    'University / Higher Education',
    'Corporate / Tech Firm',
    'Financial Institution / Bank',
    'Non-Profit / NGO',
    'Government / Public Sector',
  ];

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authControllerProvider);
    final isOrg = auth.isOrganization;
    final student = auth.studentProfile;
    final org = auth.organizationProfile;
    final user = auth.currentUser;

    // Initialize Student controllers
    _nameController = TextEditingController(
      text: student?.fullName ?? user?.name ?? '',
    );
    _cityController = TextEditingController(
      text: student?.city ?? org?.city ?? '',
    );
    _degreeController = TextEditingController(text: student?.degree ?? '');
    _fieldController = TextEditingController(
      text: student?.fieldOfStudy ?? '',
    );
    _universityController = TextEditingController(
      text: student?.universityOrCollege ?? '',
    );
    _gpaController = TextEditingController(
      text: student?.gpa != null ? student!.gpa.toString() : '',
    );
    _gradYearController = TextEditingController(
      text: student?.graduationYear != null
          ? student!.graduationYear.toString()
          : '',
    );
    _educationLevel = _educationLevels.contains(student?.educationLevel)
        ? student!.educationLevel
        : 'Undergraduate';
    _skills = Set<String>.from(student?.skills ?? const ['Flutter', 'Python']);
    _interests = Set<String>.from(
      student?.careerInterests ?? const ['AI & Data Science', 'Software Engineering'],
    );

    // Initialize Organization controllers
    _orgNameController = TextEditingController(
      text: org?.orgName ?? user?.name ?? '',
    );
    _websiteController = TextEditingController(text: org?.website ?? '');
    _regNumController = TextEditingController(
      text: org?.registrationNumber ?? '',
    );
    _phoneController = TextEditingController(text: org?.phone ?? '');
    _contactPersonController = TextEditingController(
      text: org?.contactPerson ?? '',
    );
    _orgType = _orgTypes.contains(org?.orgType)
        ? org!.orgType
        : 'University / Higher Education';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _degreeController.dispose();
    _fieldController.dispose();
    _universityController.dispose();
    _gpaController.dispose();
    _gradYearController.dispose();
    _orgNameController.dispose();
    _websiteController.dispose();
    _regNumController.dispose();
    _phoneController.dispose();
    _contactPersonController.dispose();
    _customSkillController.dispose();
    _customInterestController.dispose();
    super.dispose();
  }

  void _addCustomSkill() {
    final val = _customSkillController.text.trim();
    if (val.isNotEmpty && !_skills.contains(val)) {
      setState(() {
        _skills.add(val);
        _customSkillController.clear();
      });
    }
  }

  void _addCustomInterest() {
    final val = _customInterestController.text.trim();
    if (val.isNotEmpty && !_interests.contains(val)) {
      setState(() {
        _interests.add(val);
        _customInterestController.clear();
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = ref.read(authControllerProvider);
    final isOrg = auth.isOrganization;
    bool success = false;

    if (isOrg) {
      final currentOrg = auth.organizationProfile;
      final updatedOrg = currentOrg != null
          ? currentOrg.copyWith(
              orgName: _orgNameController.text.trim(),
              orgType: _orgType,
              website: _websiteController.text.trim(),
              city: _cityController.text.trim(),
              phone: _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
              contactPerson: _contactPersonController.text.trim().isNotEmpty
                  ? _contactPersonController.text.trim()
                  : null,
              registrationNumber: _regNumController.text.trim().isNotEmpty
                  ? _regNumController.text.trim()
                  : null,
            )
          : null;

      if (updatedOrg != null) {
        success = await ref
            .read(authControllerProvider.notifier)
            .updateOrganizationProfile(updatedOrg);
      }
    } else {
      final currentStudent = auth.studentProfile;
      final gpaVal = double.tryParse(_gpaController.text.trim());
      final gradYearVal = int.tryParse(_gradYearController.text.trim());

      final updatedStudent = currentStudent != null
          ? currentStudent.copyWith(
              fullName: _nameController.text.trim(),
              educationLevel: _educationLevel,
              degree: _degreeController.text.trim(),
              fieldOfStudy: _fieldController.text.trim(),
              universityOrCollege: _universityController.text.trim(),
              city: _cityController.text.trim(),
              gpa: gpaVal,
              graduationYear: gradYearVal,
              skills: SkillCatalog.normalizedUnique(_skills),
              careerInterests: _interests.toList(),
            )
          : null;

      if (updatedStudent != null) {
        success = await ref
            .read(authControllerProvider.notifier)
            .updateStudentProfile(updatedStudent);
      }
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final err = ref.read(authControllerProvider).errorMessage ??
          'Failed to update profile. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOrg = authState.isOrganization;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isOrg ? 'Edit Organization Profile' : 'Edit Profile',
          style: AppTextStyles.titleLarge(context),
        ),
        actions: [
          TextButton(
            onPressed: authState.isLoading ? null : _handleSave,
            child: authState.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: AppTextStyles.labelLarge(
                      context,
                      color: AppColors.primary,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.p20),
          child: Form(
            key: _formKey,
            child: isOrg
                ? _buildOrganizationForm(isDark)
                : _buildStudentForm(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          prefixIcon: Icons.person_outline_rounded,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Enter your name' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _cityController,
          label: 'City',
          prefixIcon: Icons.location_on_outlined,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Enter your city' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _educationLevel,
          decoration: InputDecoration(
            labelText: 'Education Level',
            prefixIcon: const Icon(Icons.school_outlined),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          items: _educationLevels.map((level) {
            return DropdownMenuItem(value: level, child: Text(level));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _educationLevel = val);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _degreeController,
          label: 'Degree',
          prefixIcon: Icons.menu_book_outlined,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Enter your degree' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _fieldController,
          label: 'Field of Study',
          prefixIcon: Icons.category_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _universityController,
          label: 'University / College',
          prefixIcon: Icons.account_balance_outlined,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Enter your institution' : null,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _gpaController,
                label: 'GPA (e.g. 3.75)',
                prefixIcon: Icons.grade_outlined,
                keyboardType: const TextInputOptionDecimal(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _gradYearController,
                label: 'Graduation Year',
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Skills', style: AppTextStyles.titleSmall(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _skills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () => setState(() => _skills.remove(skill)),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _customSkillController,
                label: 'Add Skill',
                hint: 'e.g. Kotlin, Data Analysis',
                prefixIcon: Icons.add_circle_outline_rounded,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: _addCustomSkill,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Career Interests', style: AppTextStyles.titleSmall(context)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: _interests.map((interest) {
            return Chip(
              label: Text(interest),
              onDeleted: () => setState(() => _interests.remove(interest)),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _customInterestController,
                label: 'Add Career Interest',
                hint: 'e.g. Cloud Architecture',
                prefixIcon: Icons.explore_outlined,
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              icon: const Icon(Icons.add),
              onPressed: _addCustomInterest,
            ),
          ],
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Save Changes',
          icon: Icons.check_circle_outline_rounded,
          isLoading: ref.watch(authControllerProvider).isLoading,
          onPressed: _handleSave,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildOrganizationForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _orgNameController,
          label: 'Organization Name',
          prefixIcon: Icons.business_rounded,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Enter organization name' : null,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _orgType,
          decoration: InputDecoration(
            labelText: 'Organization Type',
            prefixIcon: const Icon(Icons.category_outlined),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          items: _orgTypes.map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _orgType = val);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _websiteController,
          label: 'Website',
          prefixIcon: Icons.language_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _cityController,
          label: 'Location / City',
          prefixIcon: Icons.location_on_outlined,
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Enter city' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Official Phone Number',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _contactPersonController,
          label: 'Contact Person / Representative',
          prefixIcon: Icons.badge_outlined,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _regNumController,
          label: 'Registration / Reg Number',
          prefixIcon: Icons.verified_user_outlined,
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Save Changes',
          icon: Icons.check_circle_outline_rounded,
          isLoading: ref.watch(authControllerProvider).isLoading,
          onPressed: _handleSave,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class TextInputOptionDecimal extends TextInputType {
  const TextInputOptionDecimal() : super.numberWithOptions(decimal: true);
}
