import 'package:intl/intl.dart';

/// Formatter utilities for PKR / USD stipends and scholarship funds.
class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##,###');

  static String formatPKR(num amount) {
    return 'PKR ${_formatter.format(amount)}';
  }

  static String formatStipendOrCoverage(String value) {
    if (value.toLowerCase().contains('free') ||
        value.toLowerCase().contains('full') ||
        value.toLowerCase().contains('unpaid')) {
      return value;
    }
    return value;
  }
}
