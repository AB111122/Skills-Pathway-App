import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/text_styles.dart';
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
  bool _isLoading = true;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _service.evaluateDeadlineAlerts();
      final items = await _service.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('[NotificationsScreen] Error loading notifications: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to load notifications.';
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    await _service.markAllRead();
    if (!mounted) return;
    final items = await _service.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = items;
    });
  }

  Future<void> _handleNotificationTap(NotificationModel item) async {
    if (!item.isRead) {
      await _service.markRead(item.id);
    }
    if (!mounted) return;

    final router = GoRouter.of(context);
    if (item.opportunityId != null) {
      router.push('/opportunities/${item.opportunityId}');
    } else if (item.applicationId != null) {
      router.push('/applications');
    } else {
      router.go('/network');
    }

    final items = await _service.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text('Notifications', style: AppTextStyles.titleLarge(context)),
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: _buildBody(context, isDark),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: AppTextStyles.titleMedium(context),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadNotifications,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 56,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
              const SizedBox(height: 12),
              Text(
                'No notifications yet',
                style: AppTextStyles.titleMedium(context),
              ),
              const SizedBox(height: 4),
              Text(
                'You\'ll receive alerts for scholarships, application updates, and upcoming deadlines here.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall(
                  context,
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.p16),
        itemCount: _notifications.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.p8),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          final isDeadline = item.type == NotificationType.deadline;

          return Container(
            decoration: BoxDecoration(
              color: item.isRead
                  ? (isDark ? AppColors.surfaceDark : Colors.white)
                  : (isDark
                      ? AppColors.primaryDark.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.05)),
              borderRadius: AppDimensions.roundedMedium,
              border: Border.all(
                color: item.isRead
                    ? (isDark ? AppColors.cardBorderDark : AppColors.cardBorderLight)
                    : (isDark ? AppColors.primaryMint.withValues(alpha: 0.4) : AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
            ),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: AppTextStyles.titleSmall(context).copyWith(
                        fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!item.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: AppTextStyles.bodySmall(
                      context,
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.formatDate(item.createdAt),
                    style: AppTextStyles.labelSmall(
                      context,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDeadline
                      ? AppColors.accentRose.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDeadline
                      ? Icons.notifications_active_rounded
                      : Icons.info_outline_rounded,
                  color: isDeadline ? AppColors.accentRose : AppColors.primary,
                  size: 20,
                ),
              ),
              onTap: () => _handleNotificationTap(item),
            ),
          );
        },
      ),
    );
  }
}
