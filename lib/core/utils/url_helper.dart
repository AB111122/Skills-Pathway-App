import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shared helper utility for safe external URL normalization and launching.
class UrlHelper {
  const UrlHelper._();

  /// Normalizes a given URL string by trimming whitespace and prepending 'https://'
  /// if the string does not start with http:// or https://.
  static String normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';
    final lower = trimmed.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  /// Safely attempts to open an external URL.
  ///
  /// Normalizes the URL first, handles platform exceptions, and displays a user-facing
  /// SnackBar message if the URL cannot be launched or is invalid.
  static Future<bool> launchExternalUrl(
    BuildContext context,
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
    String failureMessage = "Couldn't open this link — it may be invalid",
  }) async {
    final normalized = normalizeUrl(url);
    if (normalized.isEmpty) {
      if (context.mounted) {
        _showErrorSnackBar(context, failureMessage);
      }
      return false;
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || (uri.host.isEmpty && !uri.isScheme('mailto') && !uri.isScheme('tel'))) {
      if (context.mounted) {
        _showErrorSnackBar(context, failureMessage);
      }
      return false;
    }

    try {
      bool launched = false;
      if (await canLaunchUrl(uri)) {
        launched = await launchUrl(uri, mode: mode);
      }
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched && context.mounted) {
        _showErrorSnackBar(context, failureMessage);
      }
      return launched;
    } catch (e) {
      debugPrint('[UrlHelper] Error launching URL "$normalized": $e');
      if (context.mounted) {
        _showErrorSnackBar(context, failureMessage);
      }
      return false;
    }
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
