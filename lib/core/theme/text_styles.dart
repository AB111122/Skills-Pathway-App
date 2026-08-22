import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Standard typography combining Outfit (headings) and Plus Jakarta Sans (body).
class AppTextStyles {
  // Display & Headings (Outfit)
  static TextStyle displayLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle displayMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.outfit(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle titleLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle titleMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.outfit(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle titleSmall(BuildContext context, {Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  // Body Text (Plus Jakarta Sans)
  static TextStyle bodyLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle bodyMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.45,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  // Labels & Badges
  static TextStyle labelLarge(BuildContext context, {Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle labelMedium(BuildContext context, {Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle labelSmall(BuildContext context, {Color? color}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
      color: color ?? AppColors.textSecondaryLight,
    );
  }
}
