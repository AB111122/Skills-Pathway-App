import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/notification_model.dart';

/// Local notification abstraction. An OS plugin can be added behind this API later.
class NotificationService {
  static const _storageKey = 'local_notifications';
  final Uuid _uuid;

  NotificationService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  Future<void> initialize() async => SharedPreferences.getInstance();

  Future<List<NotificationModel>> getNotifications() async {
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      final currentUid = _auth.currentUser!.uid;
      final query = _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUid);

      debugPrint(
        '[NotificationService] Executing query: collection("notifications").where("recipientId", isEqualTo: "$currentUid")',
      );

      try {
        final snapshot = await query.get();
        debugPrint(
          '[NotificationService] getNotifications retrieved ${snapshot.docs.length} notifications for user $currentUid',
        );
        return snapshot.docs.map(_fromFirestore).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } catch (e, stackTrace) {
        debugPrint(
          '[NotificationService] Failed to fetch notifications for user $currentUid: $e',
        );
        debugPrintStack(stackTrace: stackTrace);
        rethrow;
      }
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
          (value) => NotificationModel.fromJson(
            jsonDecode(value) as Map<String, dynamic>,
          ),
        )
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
    final notification = NotificationModel(
      id: _uuid.v4(),
      opportunityId: opportunityId,
      title: title,
      message: message,
      createdAt: scheduledDate,
      type: NotificationType.deadline,
    );
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      final currentUid = _auth.currentUser!.uid;
      debugPrint(
        '[NotificationService] scheduleNotification query: collection("notifications").where("recipientId", isEqualTo: "$currentUid")',
      );
      final existing = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUid)
          .get();
      for (final item in existing.docs) {
        final data = item.data();
        if (data['opportunityId'] == opportunityId &&
            data['type'] == NotificationType.deadline.name) {
          await item.reference.delete();
        }
      }
      await _firestore.collection('notifications').doc(notification.id).set({
        ...notification.toJson(),
        'recipientId': currentUid,
        'createdAt': Timestamp.fromDate(notification.createdAt),
      });
      return;
    }
    final notifications = await getNotifications();
    notifications
      ..removeWhere(
        (item) =>
            item.opportunityId == opportunityId &&
            item.type == NotificationType.deadline,
      )
      ..add(notification);
    await _write(notifications);
  }

  Future<void> evaluateDeadlineAlerts() async {
    if (Firebase.apps.isEmpty || _auth.currentUser == null) return;
    final currentUid = _auth.currentUser!.uid;
    try {
      debugPrint(
        '[NotificationService] Evaluating deadline alerts for user: $currentUid',
      );
      final alerts = await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('deadlineReminders')
          .get();
      final now = DateTime.now();
      for (final alert in alerts.docs) {
        final data = alert.data();
        final reminderDate = data['reminderDate'];
        final deadline = data['deadline'];
        final reminder = reminderDate is Timestamp
            ? reminderDate.toDate()
            : DateTime.tryParse(reminderDate as String? ?? '');
        final due = deadline is Timestamp
            ? deadline.toDate()
            : DateTime.tryParse(deadline as String? ?? '');
        if (reminder == null ||
            due == null ||
            now.isBefore(reminder) ||
            !due.isAfter(now)) {
          continue;
        }
        debugPrint(
          '[NotificationService] evaluateDeadlineAlerts checking existing: collection("notifications").where("recipientId", isEqualTo: "$currentUid")',
        );
        final existing = await _firestore
            .collection('notifications')
            .where('recipientId', isEqualTo: currentUid)
            .get();
        final alreadyCreated = existing.docs.any((item) {
          final itemData = item.data();
          return itemData['opportunityId'] == data['opportunityId'] &&
              itemData['type'] == NotificationType.deadline.name;
        });
        if (alreadyCreated) continue;
        await createForUser(
          recipientId: currentUid,
          title: 'Deadline approaching',
          message: 'An opportunity you saved is approaching its deadline.',
          type: NotificationType.deadline,
          opportunityId: alert.id,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('[NotificationService] Error evaluating deadline alerts: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> cancelNotification(String opportunityId) async {
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      final currentUid = _auth.currentUser!.uid;
      debugPrint(
        '[NotificationService] cancelNotification query: collection("notifications").where("recipientId", isEqualTo: "$currentUid")',
      );
      final existing = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUid)
          .get();
      for (final item in existing.docs) {
        final data = item.data();
        if (data['opportunityId'] == opportunityId &&
            data['type'] == NotificationType.deadline.name) {
          await item.reference.delete();
        }
      }
      return;
    }
    final notifications = await getNotifications();
    notifications.removeWhere(
      (item) =>
          item.opportunityId == opportunityId &&
          item.type == NotificationType.deadline,
    );
    await _write(notifications);
  }

  Future<void> markRead(String id) async {
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      debugPrint('[NotificationService] markRead updating notification $id');
      await _firestore.collection('notifications').doc(id).update({
        'isRead': true,
      });
      return;
    }
    await _update((item) => item.id == id ? item.copyWith(isRead: true) : item);
  }

  Future<void> markAllRead() async {
    if (Firebase.apps.isNotEmpty && _auth.currentUser != null) {
      final currentUid = _auth.currentUser!.uid;
      debugPrint(
        '[NotificationService] markAllRead query: collection("notifications").where("recipientId", isEqualTo: "$currentUid")',
      );
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: currentUid)
          .get();
      final batch = _firestore.batch();
      for (final item in snapshot.docs) {
        if (item.data()['isRead'] != true) {
          batch.update(item.reference, {'isRead': true});
        }
      }
      await batch.commit();
      return;
    }
    await _update((item) => item.copyWith(isRead: true));
  }

  Future<void> createForUser({
    required String recipientId,
    required String title,
    required String message,
    required NotificationType type,
    String? opportunityId,
    String? applicationId,
    String? postId,
    String? id,
  }) async {
    final notification = NotificationModel(
      id: id ?? _uuid.v4(),
      opportunityId: opportunityId,
      applicationId: applicationId,
      postId: postId,
      title: title,
      message: message,
      createdAt: DateTime.now(),
      type: type,
    );
    if (Firebase.apps.isNotEmpty) {
      final docRef =
          _firestore.collection('notifications').doc(notification.id);

      final existingDoc = await docRef.get();
      if (existingDoc.exists) return;

      debugPrint(
        '[NotificationService] createForUser writing notification '
        '${notification.id} for recipient $recipientId',
      );

      await docRef.set({
        ...notification.toJson(),
        'recipientId': recipientId,
        'applicationId': ?applicationId,
        'postId': ?postId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return;
    }
    final notifications = await getNotifications();
    if (notifications.any((item) => item.id == notification.id)) return;
    await _write([...notifications, notification]);
  }

  Future<void> _update(
    NotificationModel Function(NotificationModel) update,
  ) async {
    final notifications = (await getNotifications()).map(update).toList();
    await _write(notifications);
  }

  Future<void> _write(List<NotificationModel> notifications) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        _storageKey,
        notifications.map((item) => jsonEncode(item.toJson())).toList(),
      );
    } catch (_) {}
  }

  NotificationModel _fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    final createdAt = data['createdAt'];
    return NotificationModel(
      id: snapshot.id,
      opportunityId: data['opportunityId'] as String?,
      applicationId: data['applicationId'] as String?,
      postId: data['postId'] as String?,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt as String? ?? '') ?? DateTime.now(),
      type: NotificationType.values.firstWhere(
        (value) => value.name == data['type'],
        orElse: () => NotificationType.opportunity,
      ),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
