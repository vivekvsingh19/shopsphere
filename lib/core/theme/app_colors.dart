import 'package:flutter/material.dart';

/// Brand colour tokens for ShopSphere.
/// Deep violet + electric amber accent palette.
abstract final class AppColors {
  // Primary — Deep Violet
  static const Color primary = Color(0xFF5B2D8E);
  static const Color primaryLight = Color(0xFF9B6FD8);
  static const Color primaryContainer = Color(0xFFEADDFF);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary — Electric Amber
  static const Color secondary = Color(0xFFE8852A);
  static const Color secondaryLight = Color(0xFFFFB97A);
  static const Color secondaryContainer = Color(0xFFFFDCC2);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Surface
  static const Color surfaceLight = Color(0xFFFDF8FF);
  static const Color surfaceDark = Color(0xFF12101A);

  // Semantic
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFF897D);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFF57C00);

  // Neutral
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Rating star
  static const Color starGold = Color(0xFFFFC107);

  // Discount badge
  static const Color discountBg = Color(0xFFE53935);
  static const Color discountFg = Color(0xFFFFFFFF);
}
