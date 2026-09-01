import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class ParkingStyles {
  final StyleTokens tokens;
  ParkingStyles(this.tokens);

  TextStyle get titleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: tokens.textHeader,
      );

  TextStyle get spotNumberStyle => TextStyle(
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
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: tokens.textHeader,
      );

  Color getOccupiedColor(bool occupied) {
    if (occupied) {
      return tokens.accentSecondary; // Red/Terracotta for Occupied
    }
    return tokens.accent; // Teal for Available
  }
}
