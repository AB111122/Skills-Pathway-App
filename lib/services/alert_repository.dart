import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/alert_model.dart';

class AlertRepository {
  static const _storageKey = 'opportunity_alerts';
  final Uuid _uuid;

  AlertRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  Future<List<AlertModel>> getAlerts() async {
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
        .map((value) => AlertModel.fromJson(jsonDecode(value) as Map<String, dynamic>))
        .toList();
  }

  Future<AlertModel?> getForOpportunity(String opportunityId) async {
    final alerts = await getAlerts();
    for (final alert in alerts) {
      if (alert.opportunityId == opportunityId && alert.isEnabled) return alert;
    }
    return null;
  }

  Future<AlertModel> save({
    required String opportunityId,
    required DateTime deadline,
    required ReminderType reminderType,
  }) async {
    final reminderDate = deadline.subtract(Duration(days: reminderType == ReminderType.oneDay ? 1 : reminderType == ReminderType.threeDays ? 3 : 7));
    if (!deadline.isAfter(DateTime.now()) || !reminderDate.isAfter(DateTime.now())) {
      throw StateError('This reminder date is no longer available.');
    }
    final alerts = await getAlerts();
    alerts.removeWhere((alert) => alert.opportunityId == opportunityId);
    final alert = AlertModel(
      id: _uuid.v4(),
      opportunityId: opportunityId,
      userId: 'local-user',
      deadline: deadline,
      reminderDate: reminderDate,
      reminderType: reminderType,
    );
    alerts.add(alert);
    await _write(alerts);
    return alert;
  }

  Future<void> cancel(String opportunityId) async {
    final alerts = await getAlerts();
    alerts.removeWhere((alert) => alert.opportunityId == opportunityId);
    await _write(alerts);
  }

  Future<void> _write(List<AlertModel> alerts) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _storageKey,
        alerts.map((alert) => jsonEncode(alert.toJson())).toList(),
      );
    } catch (_) {}
  }
}