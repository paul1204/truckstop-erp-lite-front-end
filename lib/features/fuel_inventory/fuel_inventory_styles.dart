import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class FuelInventoryStyles {
  final StyleTokens tokens;
  FuelInventoryStyles(this.tokens);

  TextStyle get titleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: tokens.textHeader,
      );

  TextStyle get labelStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: tokens.textHeader,
      );

  TextStyle get valueStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: tokens.textMain.withOpacity(0.8),
      );

  TextStyle get infoTextStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 11,
        color: tokens.textMain.withOpacity(0.5),
      );

  TextStyle get formTitleStyle => TextStyle(
        fontFamily: tokens.serifFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: tokens.textHeader,
      );

  Color tankColor(double percent) {
    if (tokens.profile == AppProfile.profileB) {
      if (percent < 20) return tokens.accentSecondary; // Redwood Terracotta
      if (percent < 50) return tokens.accentOrange; // Redwood Orange
      return tokens.accent; // Redwood Teal
    } else {
      if (percent < 20) return Colors.red;
      if (percent < 50) return Colors.orange;
      return Colors.green;
    }
  }
}
