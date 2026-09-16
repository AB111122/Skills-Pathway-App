import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skills_pathway_app/core/notifications/fcm_notification_service.dart';

void main() {
  test('extracts display content from an FCM notification payload', () {
    final message = RemoteMessage(
      data: const {'title': 'Application update', 'body': 'Your status changed.'},
    );

    final content = FcmNotificationService.contentFor(message);

    expect(content?.title, 'Application update');
    expect(content?.body, 'Your status changed.');
  });

  test('ignores data-only messages without display content', () {
    final message = RemoteMessage(data: const {'opportunityId': 'opp-1'});

    expect(FcmNotificationService.contentFor(message), isNull);
  });
}