import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class DashboardStyles {
  final StyleTokens tokens;
  DashboardStyles(this.tokens);

  TextStyle get pageTitleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: tokens.textHeader,
        letterSpacing: -0.9,
      );

  TextStyle get cardTitleStyle => TextStyle(
        fontFamily: tokens.serifFont,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: tokens.textHeader,
      );

  TextStyle get metricLabelStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: tokens.textMain.withOpacity(0.7),
        letterSpacing: 0.5,
      );

  TextStyle get metricValueStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: tokens.accent,
      );

  TextStyle get itemTitleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: tokens.textHeader,
      );

  TextStyle get itemSubStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 12,
        color: tokens.textMain.withOpacity(0.6),
      );

  Color statusColor(String status) {
    switch (status) {
      case 'online':
        return tokens.accent;
      case 'alert':
        return tokens.accentSecondary;
      default:
        return Colors.grey;
    }
  }
}
