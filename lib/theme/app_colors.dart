import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color primaryNavyDark = Color(0xFF0F2042);

  static const Color brandBlue = Color(0xFF2563EB);

  static const Color incomeGreen = Color(0xFF10B981);
  static const Color incomeGreenDark = Color(0xFF059669);
  static const Color incomeSoftTint = Color(0xFFD1FAE5);
  static const Color incomeSoftBg = Color(0xFFECFDF5);

  static const Color expenseCoral = Color(0xFFEF4444);
  static const Color expenseCoralDark = Color(0xFFDC2626);
  static const Color expenseSoftTint = Color(0xFFFEE2E2);
  static const Color expenseSoftBg = Color(0xFFFEF2F2);

  static const Color surfaceBase = Color(0xFFFAF8FF);
  static const Color surfaceCard = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF0F172A);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryNavy,
      primaryNavyDark,
    ],
  );
}