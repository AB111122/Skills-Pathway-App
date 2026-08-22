import 'package:flutter/material.dart';

/// Centralized color palette tailored for Skills Pathway (Pakistan Career & Education platform).
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF0D5C3A); // Deep Pakistani Emerald
  static const Color primaryDark = Color(0xFF073B24);
  static const Color primaryLight = Color(0xFF15803D);
  static const Color primaryMint = Color(0xFF00C896); // Vibrant Mint Accent

  // Secondary & Accents
  static const Color secondary = Color(0xFF0284C7); // Trust Sky Blue
  static const Color accentGold = Color(0xFFF59E0B); // Achievement Amber/Gold
  static const Color accentRose = Color(0xFFF43F5E); // Urgent/Deadline Rose

  // Neutral Background & Surface Colors (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardBorderLight = Color(0xFFE2E8F0);

  // Neutral Background & Surface Colors (Dark)
  static const Color backgroundDark = Color(0xFF0B1120);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color cardBorderDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color verifiedBadge = Color(0xFF0284C7); // Verified blue badge

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0D5C3A), Color(0xFF00C896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF073B24), Color(0xFF0D5C3A), Color(0xFF00875A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient aiBannerGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF4338CA), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
