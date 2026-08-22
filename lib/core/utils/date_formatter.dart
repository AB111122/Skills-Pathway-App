import 'package:intl/intl.dart';

/// Formatter utilities for deadlines, dates, and relative timestamps.
class DateFormatter {
  static final DateFormat _standardDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _shortDate = DateFormat('dd MMM');

  static String formatDate(DateTime date) {
    return _standardDate.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDate.format(date);
  }

  /// Returns user-friendly deadline remaining text (e.g. "5 days left", "Closing today", "Expired")
  static String formatDeadlineRemaining(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative && difference.inDays.abs() > 0) {
      return 'Expired';
    }

    final days = difference.inDays;
    final hours = difference.inHours;

    if (days == 0) {
      if (hours <= 0) {
        return 'Closing soon';
      }
      return '$hours hrs left';
    } else if (days == 1) {
      return 'Closing tomorrow';
    } else if (days <= 30) {
      return '$days days left';
    } else {
      final months = (days / 30).round();
      return '$months mos left';
    }
  }

  /// Checks if deadline is within 7 days (urgent)
  static bool isUrgent(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return !difference.isNegative && difference.inDays <= 7;
  }
}
