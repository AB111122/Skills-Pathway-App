import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notification_preferences_repository.dart';

final notificationPreferencesRepositoryProvider =
    Provider<NotificationPreferencesRepository>((ref) {
  return NotificationPreferencesRepository();
});

class NotificationPreferencesNotifier
    extends StateNotifier<NotificationPreferences> {
  final NotificationPreferencesRepository _repository;

  NotificationPreferencesNotifier(this._repository)
      : super(const NotificationPreferences()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _repository.loadPreferences();
    state = prefs;
  }

  Future<void> toggleOpportunities(bool value) async {
    final updated = state.copyWith(newOpportunities: value);
    state = updated;
    await _repository.savePreferences(updated);
  }

  Future<void> toggleApplicationUpdates(bool value) async {
    final updated = state.copyWith(applicationUpdates: value);
    state = updated;
    await _repository.savePreferences(updated);
  }

  Future<void> toggleDeadlineReminders(bool value) async {
    final updated = state.copyWith(deadlineReminders: value);
    state = updated;
    await _repository.savePreferences(updated);
  }
}

final notificationPreferencesProvider = StateNotifierProvider<
    NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  final repository = ref.watch(notificationPreferencesRepositoryProvider);
  return NotificationPreferencesNotifier(repository);
});
