import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skills_pathway_app/core/theme/theme_controller.dart';
import 'package:skills_pathway_app/features/settings/data/notification_preferences_repository.dart';
import 'package:skills_pathway_app/features/settings/presentation/controllers/settings_controller.dart';
import 'package:skills_pathway_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:skills_pathway_app/features/settings/presentation/screens/edit_profile_screen.dart';
import 'package:skills_pathway_app/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:skills_pathway_app/features/authentication/presentation/controllers/auth_controller.dart';
import 'package:skills_pathway_app/features/authentication/data/mock_auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeModeNotifier Tests', () {
    test('default theme mode is system', () {
      final notifier = ThemeModeNotifier();
      expect(notifier.state, ThemeMode.system);
    });

    test('setThemeMode updates state and persists in SharedPreferences', () async {
      final notifier = ThemeModeNotifier();
      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(kThemeModeStorageKey), 'dark');

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);
      expect(prefs.getString(kThemeModeStorageKey), 'light');
    });
  });

  group('Notification Preferences Tests', () {
    test('default notification preferences are all true', () async {
      final repo = NotificationPreferencesRepository();
      final prefs = await repo.loadPreferences();
      expect(prefs.newOpportunities, isTrue);
      expect(prefs.applicationUpdates, isTrue);
      expect(prefs.deadlineReminders, isTrue);
    });

    test('NotificationPreferencesNotifier toggles and persists', () async {
      final repo = NotificationPreferencesRepository();
      final notifier = NotificationPreferencesNotifier(repo);

      await notifier.toggleOpportunities(false);
      expect(notifier.state.newOpportunities, isFalse);

      await notifier.toggleApplicationUpdates(false);
      expect(notifier.state.applicationUpdates, isFalse);

      await notifier.toggleDeadlineReminders(false);
      expect(notifier.state.deadlineReminders, isFalse);

      final stored = await repo.loadPreferences();
      expect(stored.newOpportunities, isFalse);
      expect(stored.applicationUpdates, isFalse);
      expect(stored.deadlineReminders, isFalse);
    });
  });

  group('SettingsScreen Widget Tests', () {
    Widget buildSettingsWidget({AuthService? mockAuth}) {
      return ProviderScope(
        overrides: [
          if (mockAuth != null) authServiceProvider.overrideWithValue(mockAuth),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('renders all 4 main sections and key list items', (tester) async {
      final auth = MockAuthService();
      await auth.login(email: 'fatima.zahra@nust.edu.pk', password: 'Password123');

      await tester.pumpWidget(buildSettingsWidget(mockAuth: auth));
      await tester.pumpAndSettle();

      // Section Headers
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('About & Support'), findsOneWidget);

      // Appearance items
      expect(find.text('Theme'), findsOneWidget);

      // Notification items
      expect(find.text('New Opportunities'), findsOneWidget);
      expect(find.text('Application Status Updates'), findsOneWidget);
      expect(find.text('Deadline Reminders'), findsOneWidget);

      // Account items
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);

      // About / Support items
      expect(find.text('Help & Support / FAQ'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('opens Theme selection dialog and allows selecting a mode', (tester) async {
      await tester.pumpWidget(buildSettingsWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Mode'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);

      await tester.tap(find.text('Dark Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Theme'), findsNothing);
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('toggling notification switch triggers notifier', (tester) async {
      await tester.pumpWidget(buildSettingsWidget());
      await tester.pumpAndSettle();

      final switchFinders = find.byType(Switch);
      expect(switchFinders, findsNWidgets(3));

      // Tap first switch (New Opportunities)
      await tester.tap(switchFinders.first);
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(NotificationPreferencesRepository.keyOpportunities), isFalse);
    });

    testWidgets('tapping Change Password shows reset password confirmation dialog', (tester) async {
      final auth = MockAuthService();
      await auth.login(email: 'fatima.zahra@nust.edu.pk', password: 'Password123');

      await tester.pumpWidget(buildSettingsWidget(mockAuth: auth));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Link'), findsOneWidget);

      await tester.tap(find.text('Send Link'));
      await tester.pumpAndSettle();

      expect(find.text('Password reset email sent! Check your inbox.'), findsOneWidget);
    });

    testWidgets('tapping Delete Account shows permanent deletion confirmation dialog', (tester) async {
      final auth = MockAuthService();
      await auth.login(email: 'fatima.zahra@nust.edu.pk', password: 'Password123');

      await tester.pumpWidget(buildSettingsWidget(mockAuth: auth));
      await tester.pumpAndSettle();

      // Scroll to bottom
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Permanently'), findsOneWidget);
    });
  });

  group('EditProfileScreen Widget Tests', () {
    testWidgets('renders student edit profile form with initial values', (tester) async {
      final auth = MockAuthService();
      await auth.login(email: 'fatima.zahra@nust.edu.pk', password: 'Password123');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(auth),
          ],
          child: const MaterialApp(
            home: EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
  });

  group('NotificationsScreen Widget Tests', () {
    testWidgets('renders notifications screen and handles state cleanly without setState future errors', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
    });
  });
}
