import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String appVersion = '1.0.0 (Build 1)';

  Future<void> _showThemeSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeMode currentMode,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog<ThemeMode>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Choose Theme',
          style: AppTextStyles.titleMedium(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              subtitle: const Text('Matches device system appearance'),
              secondary: const Icon(Icons.brightness_auto_rounded),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Light Mode'),
              subtitle: const Text('Bright and clear emerald theme'),
              secondary: const Icon(Icons.light_mode_rounded),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                  Navigator.pop(ctx);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark Mode'),
              subtitle: const Text('Dark night aesthetic with mint accents'),
              secondary: const Icon(Icons.dark_mode_rounded),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(val);
                  Navigator.pop(ctx);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleChangePassword(BuildContext context, WidgetRef ref) async {
    final auth = ref.read(authControllerProvider);
    final userEmail = auth.currentUser?.email ?? '';

    if (userEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No email found for this account.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
          'A password reset link will be sent to:\n\n$userEmail\n\nClick the link in the email to set a new password.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send Link'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .sendPasswordReset(userEmail);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Password reset email sent! Check your inbox.'
                  : 'Unable to send reset email. Please try again.',
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go(RouteNames.login);
      }
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action is permanent and cannot be undone.\n\nAll your profile information, applications, and saved opportunities will be permanently erased.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await ref.read(authControllerProvider.notifier).deleteAccount();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been deleted.'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(RouteNames.login);
        } else {
          final err = ref.read(authControllerProvider).errorMessage ??
              'Failed to delete account. Please try signing in again first.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(err),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showHelpSupportDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMutedLight.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Help & Support / FAQ',
                style: AppTextStyles.titleLarge(context),
              ),
              const SizedBox(height: 8),
              Text(
                'Have questions or need assistance? Reach out to our dedicated support team.',
                style: AppTextStyles.bodyMedium(context),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.email_outlined, color: AppColors.primary),
                ),
                title: const Text('Email Support'),
                subtitle: const Text('support@skillspathway.pk'),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                onTap: () async {
                  final uri = Uri.parse('mailto:support@skillspathway.pk?subject=Skills%20Pathway%20Support');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.headset_mic_outlined, color: AppColors.secondary),
                ),
                title: const Text('Pakistan Support Helpline'),
                subtitle: const Text('+92 51 111-754557 (9 AM - 6 PM PKT)'),
                trailing: const Icon(Icons.phone_in_talk_rounded, size: 18),
                onTap: () async {
                  final uri = Uri.parse('tel:+9251111754557');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.quiz_outlined, color: AppColors.primaryMint),
                ),
                title: const Text('Frequently Asked Questions'),
                subtitle: const Text('Scholarships, admissions, and roadmaps guide'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showFaqDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showFaqDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Frequently Asked Questions'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '1. How are scholarships verified?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'All scholarships are posted and verified by registered universities, HEC, or vetted organizations with official credentials.',
                ),
                SizedBox(height: 14),
                Text(
                  '2. Can I edit my skills and interests later?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Yes, you can update your skills anytime from the Profile tab or through Edit Profile in Settings.',
                ),
                SizedBox(height: 14),
                Text(
                  '3. How does the AI Career Guide work?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'The AI assistant analyzes your current degree, education level, and chosen skills to generate personalized learning paths and interview preparation tips.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);
    final notifPrefs = ref.watch(notificationPreferencesProvider);
    final auth = ref.watch(authControllerProvider);
    final user = auth.currentUser;

    String themeLabel;
    IconData themeIcon;
    switch (themeMode) {
      case ThemeMode.light:
        themeLabel = 'Light Mode';
        themeIcon = Icons.light_mode_rounded;
        break;
      case ThemeMode.dark:
        themeLabel = 'Dark Mode';
        themeIcon = Icons.dark_mode_rounded;
        break;
      case ThemeMode.system:
      default:
        themeLabel = 'System Default';
        themeIcon = Icons.brightness_auto_rounded;
        break;
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Settings & Preferences',
          style: AppTextStyles.titleLarge(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.p20,
            vertical: AppDimensions.p16,
          ),
          children: [
            // Section 1: Appearance
            _buildSectionHeader(context, 'Appearance', Icons.palette_outlined),
            const SizedBox(height: 8),
            _buildCard(
              context,
              isDark: isDark,
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(themeIcon, color: AppColors.primary, size: 20),
                ),
                title: Text('Theme', style: AppTextStyles.titleSmall(context)),
                subtitle: Text(
                  themeLabel,
                  style: AppTextStyles.bodySmall(context),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMutedLight,
                ),
                onTap: () => _showThemeSelectionDialog(context, ref, themeMode),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Notifications
            _buildSectionHeader(
              context,
              'Notifications',
              Icons.notifications_outlined,
            ),
            const SizedBox(height: 8),
            _buildCard(
              context,
              isDark: isDark,
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: AppColors.primaryMint,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'New Opportunities',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      'Matching scholarships, fellowships & internships',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    value: notifPrefs.newOpportunities,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleOpportunities(val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Application Status Updates',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      'Real-time alerts on submission reviews and results',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    value: notifPrefs.applicationUpdates,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleApplicationUpdates(val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.accentRose.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.alarm_rounded,
                        color: AppColors.accentRose,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Deadline Reminders',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      'Reminders 24h & 48h before opportunity deadlines',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    value: notifPrefs.deadlineReminders,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) => ref
                        .read(notificationPreferencesProvider.notifier)
                        .toggleDeadlineReminders(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: Account
            _buildSectionHeader(
              context,
              'Account',
              Icons.account_circle_outlined,
            ),
            const SizedBox(height: 8),
            _buildCard(
              context,
              isDark: isDark,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.edit_note_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Edit Profile',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      auth.isOrganization
                          ? 'Update institution details, type & contact'
                          : 'Update academic info, university & skills',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textMutedLight,
                    ),
                    onTap: () => context.push(RouteNames.editProfile),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Change Password',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      user?.email.isNotEmpty == true
                          ? 'Send reset link to ${user!.email}'
                          : 'Reset via secure email link',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textMutedLight,
                    ),
                    onTap: () => _handleChangePassword(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.warning,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Sign Out',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      'Sign out of this session',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textMutedLight,
                    ),
                    onTap: () => _handleLogout(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 4: About & Support
            _buildSectionHeader(
              context,
              'About & Support',
              Icons.info_outline_rounded,
            ),
            const SizedBox(height: 8),
            _buildCard(
              context,
              isDark: isDark,
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Help & Support / FAQ',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      'Contact assistance & browse guides',
                      style: AppTextStyles.bodySmall(context),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.textMutedLight,
                    ),
                    onTap: () => _showHelpSupportDialog(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.textMutedLight.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: AppColors.textSecondaryLight,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'App Version',
                      style: AppTextStyles.titleSmall(context),
                    ),
                    subtitle: Text(
                      appVersion,
                      style: AppTextStyles.bodySmall(context),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      'Delete Account',
                      style: AppTextStyles.titleSmall(context)?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    subtitle: Text(
                      'Permanently remove account and all data',
                      style: AppTextStyles.bodySmall(
                        context,
                        color: AppColors.error.withValues(alpha: 0.8),
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.error,
                    ),
                    onTap: () => _handleDeleteAccount(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.titleSmall(
            context,
            color: AppColors.primary,
          ).copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: AppDimensions.roundedLarge,
        border: Border.all(
          color: isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
