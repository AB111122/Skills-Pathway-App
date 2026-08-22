import 'package:flutter/material.dart';

/// Centralized layout dimensions, paddings, and radii.
class AppDimensions {
  // Padding & Margins
  static const double p2 = 2.0;
  static const double p4 = 4.0;
  static const double p8 = 8.0;
  static const double p12 = 12.0;
  static const double p16 = 16.0;
  static const double p20 = 20.0;
  static const double p24 = 24.0;
  static const double p32 = 32.0;
  static const double p40 = 40.0;

  // Border Radii
  static const double r6 = 6.0;
  static const double r8 = 8.0;
  static const double r12 = 12.0;
  static const double r16 = 16.0;
  static const double r20 = 20.0;
  static const double r24 = 24.0;
  static const double rFull = 999.0;

  static const BorderRadius roundedSmall = BorderRadius.all(Radius.circular(r8));
  static const BorderRadius roundedMedium = BorderRadius.all(Radius.circular(r12));
  static const BorderRadius roundedLarge = BorderRadius.all(Radius.circular(r16));
  static const BorderRadius roundedXLarge = BorderRadius.all(Radius.circular(r24));
  static const BorderRadius roundedPill = BorderRadius.all(Radius.circular(rFull));

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 32.0;

  // Elevations
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Button Heights
  static const double buttonHeight = 52.0;
  static const double buttonHeightSmall = 38.0;
}
