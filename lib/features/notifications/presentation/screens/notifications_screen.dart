import 'package:flutter/material.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../models/notification_model.dart';
import '../../../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  late Future<List<NotificationModel>> _items;

  @override
  void initState() {
    super.initState();
    _items = _service.getNotifications();
  }

  void _reload() => setState(() => _items = _service.getNotifications());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
          actions: [
            TextButton(
              onPressed: () async {
                await _service.markAllRead();
                _reload();
              },
              child: const Text('Mark all read'),
            ),
          ],
        ),
        body: FutureBuilder<List<NotificationModel>>(
          future: _items,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            if (snapshot.data!.isEmpty) return const Center(child: Text('No notifications yet'));
            return ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.p16),
              itemCount: snapshot.data!.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.p8),
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  tileColor: item.isRead ? null : Theme.of(context).colorScheme.primaryContainer,
                  title: Text(item.title),
                  subtitle: Text('${item.message}\n${DateFormatter.formatDate(item.createdAt)}'),
                  isThreeLine: true,
                  leading: Icon(item.type == NotificationType.deadline ? Icons.notifications_active_outlined : Icons.info_outline),
                  onTap: item.isRead ? null : () async {
                    await _service.markRead(item.id);
                    _reload();
                  },
                );
              },
            );
          },
        ),
      );
}