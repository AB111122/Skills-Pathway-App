import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skills_pathway_app/core/notifications/fcm_notification_service.dart';
import 'package:skills_pathway_app/models/notification_model.dart';
import 'package:skills_pathway_app/services/notification_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('extracts display content from an FCM notification payload', () {
    final message = RemoteMessage(
      data: const {'title': 'Application update', 'body': 'Your status changed.'},
    );

    final content = FcmNotificationService.contentFor(message);

    expect(content?.title, 'Application update');
    expect(content?.body, 'Your status changed.');
  });

  test('extracts display content when message field is used instead of body', () {
    final message = RemoteMessage(
      data: const {'title': 'Announcement', 'message': 'Campus is closed.'},
    );

    final content = FcmNotificationService.contentFor(message);

    expect(content?.title, 'Announcement');
    expect(content?.body, 'Campus is closed.');
  });

  test('ignores data-only messages without display content', () {
    final message = RemoteMessage(data: const {'opportunityId': 'opp-1'});

    expect(FcmNotificationService.contentFor(message), isNull);
  });

  test('syncRemoteMessage records FCM notification into NotificationService history', () async {
    final notificationService = NotificationService();
    final fcmService = FcmNotificationService(
      notificationService: notificationService,
    );

    final message = RemoteMessage(
      messageId: 'msg-123',
      data: const {
        'recipientId': 'user-1',
        'title': 'New Scholarship',
        'body': 'Check out this new scholarship.',
        'type': 'opportunity',
        'opportunityId': 'opp-99',
      },
    );

    await fcmService.syncRemoteMessage(message);

    final notifications = await notificationService.getNotifications();
    expect(notifications.length, 1);
    expect(notifications.first.id, 'msg-123');
    expect(notifications.first.title, 'New Scholarship');
    expect(notifications.first.message, 'Check out this new scholarship.');
    expect(notifications.first.type, NotificationType.opportunity);
    expect(notifications.first.opportunityId, 'opp-99');
  });

  test('syncRemoteMessage prevents duplicate notification records for the same message ID', () async {
    final notificationService = NotificationService();
    final fcmService = FcmNotificationService(
      notificationService: notificationService,
    );

    final message = RemoteMessage(
      messageId: 'msg-unique-456',
      data: const {
        'recipientId': 'user-1',
        'title': 'Application accepted',
        'body': 'Your application was accepted.',
        'type': 'application',
        'applicationId': 'app-10',
      },
    );

    await fcmService.syncRemoteMessage(message);
    await fcmService.syncRemoteMessage(message);

    final notifications = await notificationService.getNotifications();
    expect(notifications.length, 1);
  });
}
