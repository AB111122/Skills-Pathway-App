import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

/// Local notification abstraction. An OS plugin can be added behind this API later.
class NotificationService {
  static const _storageKey = 'local_notifications';
  final Uuid _uuid;

  NotificationService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  Future<void> initialize() async => SharedPreferences.getInstance();

  Future<List<NotificationModel>> getNotifications() async {
    List<String> values;
    try {
      final preferences = await SharedPreferences.getInstance().timeout(
        const Duration(milliseconds: 100),
      );
      values = preferences.getStringList(_storageKey) ?? [];
    } catch (_) {
      values = [];
    }
    return values
        .map((value) => NotificationModel.fromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> scheduleNotification({
    required String opportunityId,
    required String title,
    required String message,
    required DateTime scheduledDate,
  }) async {
    if (!scheduledDate.isAfter(DateTime.now())) {
      throw StateError('This reminder date is no longer available.');
    }
    final notifications = await getNotifications();
    notifications.removeWhere((item) => item.opportunityId == opportunityId && item.type == NotificationType.deadline);
    notifications.add(NotificationModel(
      id: _uuid.v4(),
      opportunityId: opportunityId,
      title: title,
      message: message,
      createdAt: scheduledDate,
      type: NotificationType.deadline,
    ));
    await _write(notifications);
  }

  Future<void> cancelNotification(String opportunityId) async {
    final notifications = await getNotifications();
    notifications.removeWhere((item) => item.opportunityId == opportunityId && item.type == NotificationType.deadline);
    await _write(notifications);
  }

  Future<void> markRead(String id) async => _update((item) => item.id == id ? item.copyWith(isRead: true) : item);
  Future<void> markAllRead() async => _update((item) => item.copyWith(isRead: true));

  Future<void> _update(NotificationModel Function(NotificationModel) update) async {
    final notifications = (await getNotifications()).map(update).toList();
    await _write(notifications);
  }

  Future<void> _write(List<NotificationModel> notifications) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(_storageKey, notifications.map((item) => jsonEncode(item.toJson())).toList());
    } catch (_) {}
  }
}