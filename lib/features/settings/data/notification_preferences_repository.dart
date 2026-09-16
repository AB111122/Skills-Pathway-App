import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model representing user's local notification preferences.
class NotificationPreferences {
  final bool newOpportunities;
  final bool applicationUpdates;
  final bool deadlineReminders;

  const NotificationPreferences({
    this.newOpportunities = true,
    this.applicationUpdates = true,
    this.deadlineReminders = true,
  });

  NotificationPreferences copyWith({
    bool? newOpportunities,
    bool? applicationUpdates,
    bool? deadlineReminders,
  }) {
    return NotificationPreferences(
      newOpportunities: newOpportunities ?? this.newOpportunities,
      applicationUpdates: applicationUpdates ?? this.applicationUpdates,
      deadlineReminders: deadlineReminders ?? this.deadlineReminders,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPreferences &&
          runtimeType == other.runtimeType &&
          newOpportunities == other.newOpportunities &&
          applicationUpdates == other.applicationUpdates &&
          deadlineReminders == other.deadlineReminders;

  @override
  int get hashCode =>
      newOpportunities.hashCode ^
      applicationUpdates.hashCode ^
      deadlineReminders.hashCode;
}

/// Repository responsible for reading and writing notification preferences from/to SharedPreferences.
class NotificationPreferencesRepository {
  static const String keyOpportunities = 'pref_notif_opportunities';
  static const String keyApplications = 'pref_notif_applications';
  static const String keyDeadlines = 'pref_notif_deadlines';

  Future<NotificationPreferences> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newOpportunities = prefs.getBool(keyOpportunities) ?? true;
      final applicationUpdates = prefs.getBool(keyApplications) ?? true;
      final deadlineReminders = prefs.getBool(keyDeadlines) ?? true;

      return NotificationPreferences(
        newOpportunities: newOpportunities,
        applicationUpdates: applicationUpdates,
        deadlineReminders: deadlineReminders,
      );
    } catch (e) {
      debugPrint('[NotificationPreferencesRepository] Error loading preferences: $e');
      return const NotificationPreferences();
    }
  }

  Future<void> savePreferences(NotificationPreferences preferences) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyOpportunities, preferences.newOpportunities);
      await prefs.setBool(keyApplications, preferences.applicationUpdates);
      await prefs.setBool(keyDeadlines, preferences.deadlineReminders);
    } catch (e) {
      debugPrint('[NotificationPreferencesRepository] Error saving preferences: $e');
    }
  }
}
