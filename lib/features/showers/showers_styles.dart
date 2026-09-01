import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class ShowersStyles {
  final StyleTokens tokens;
  ShowersStyles(this.tokens);

  TextStyle get titleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: tokens.textHeader,
      );

  TextStyle get unitNumberStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: tokens.textHeader,
      );

  TextStyle get labelStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 11,
        color: tokens.textMain.withOpacity(0.5),
      );

  TextStyle get valueStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: tokens.textHeader,
      );

  Color getStatusColor(bool occupied, bool cleaning) {
    if (cleaning) {
      return tokens.accentOrange; // Orange for Cleaning
    }
    if (occupied) {
      return tokens.accentSecondary; // Red/Terracotta for Occupied
    }
    return tokens.accent; // Teal for Available
  }
}
