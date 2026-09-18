import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skills_pathway_app/models/notification_model.dart';
import 'package:skills_pathway_app/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NotificationService local storage fallback tests', () {
    test('getNotifications returns empty list initially', () async {
      final service = NotificationService();
      final notifications = await service.getNotifications();
      expect(notifications, isEmpty);
    });

    test('createForUser and getNotifications saves and retrieves notification', () async {
      final service = NotificationService();
      await service.createForUser(
        recipientId: 'user_123',
        title: 'Application Accepted',
        message: 'Your application has been accepted.',
        type: NotificationType.application,
        applicationId: 'app_1',
      );

      final notifications = await service.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.title, 'Application Accepted');
      expect(notifications.first.message, 'Your application has been accepted.');
      expect(notifications.first.type, NotificationType.application);
      expect(notifications.first.isRead, isFalse);
    });

    test('markRead updates isRead to true', () async {
      final service = NotificationService();
      await service.createForUser(
        recipientId: 'user_123',
        title: 'Application Accepted',
        message: 'Your application has been accepted.',
        type: NotificationType.application,
      );

      final initial = await service.getNotifications();
      final id = initial.first.id;

      await service.markRead(id);
      final updated = await service.getNotifications();
      expect(updated.first.isRead, isTrue);
    });

    test('markAllRead marks all notifications as read', () async {
      final service = NotificationService();
      await service.createForUser(
        recipientId: 'user_123',
        title: 'Notif 1',
        message: 'Message 1',
        type: NotificationType.opportunity,
      );
      await service.createForUser(
        recipientId: 'user_123',
        title: 'Notif 2',
        message: 'Message 2',
        type: NotificationType.opportunity,
      );

      await service.markAllRead();
      final notifications = await service.getNotifications();
      expect(notifications.length, 2);
      expect(notifications.every((n) => n.isRead), isTrue);
    });
  });
}
