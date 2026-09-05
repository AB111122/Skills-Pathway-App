import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/alert_model.dart';

class AlertRepository {
  static const _storageKey = 'opportunity_alerts';
  final Uuid _uuid;

  AlertRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<List<AlertModel>> getAlerts() async {
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('deadlineReminders')
          .get();
      return snapshot.docs.map(_fromFirestore).toList();
    }
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
        .map(
          (value) =>
              AlertModel.fromJson(jsonDecode(value) as Map<String, dynamic>),
        )
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
    final reminderDate = deadline.subtract(
      Duration(
        days: reminderType == ReminderType.oneDay
            ? 1
            : reminderType == ReminderType.threeDays
            ? 3
            : 7,
      ),
    );
    if (!deadline.isAfter(DateTime.now()) ||
        !reminderDate.isAfter(DateTime.now())) {
      throw StateError('This reminder date is no longer available.');
    }
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      final alerts = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('deadlineReminders')
          .get();
      for (final item in alerts.docs) {
        if (item.data()['opportunityId'] == opportunityId) {
          await item.reference.delete();
        }
      }
      final alert = AlertModel(
        id: _uuid.v4(),
        opportunityId: opportunityId,
        userId: _auth.currentUser!.uid,
        deadline: deadline,
        reminderDate: reminderDate,
        reminderType: reminderType,
      );
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('deadlineReminders')
          .doc(alert.id)
          .set({
            ...alert.toJson(),
            'deadline': Timestamp.fromDate(deadline),
            'reminderDate': Timestamp.fromDate(reminderDate),
          });
      return alert;
    }
    final alerts = await getAlerts();
    alerts.removeWhere((alert) => alert.opportunityId == opportunityId);
    final alert = AlertModel(
      id: _uuid.v4(),
      opportunityId: opportunityId,
      userId: _auth.currentUser?.uid ?? 'local-user',
      deadline: deadline,
      reminderDate: reminderDate,
      reminderType: reminderType,
    );
    alerts.add(alert);
    await _write(alerts);
    return alert;
  }

  Future<void> cancel(String opportunityId) async {
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      final alerts = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('deadlineReminders')
          .get();
      for (final item in alerts.docs) {
        if (item.data()['opportunityId'] == opportunityId) {
          await item.reference.delete();
        }
      }
      return;
    }
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

  AlertModel _fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    DateTime readDate(Object? value) =>
        value is Timestamp ? value.toDate() : DateTime.parse(value as String);
    return AlertModel(
      id: snapshot.id,
      opportunityId: data['opportunityId'] as String,
      userId: data['userId'] as String,
      deadline: readDate(data['deadline']),
      reminderDate: readDate(data['reminderDate']),
      reminderType: ReminderType.values.firstWhere(
        (value) => value.name == data['reminderType'],
        orElse: () => ReminderType.oneDay,
      ),
      isEnabled: data['isEnabled'] as bool? ?? true,
    );
  }
}
