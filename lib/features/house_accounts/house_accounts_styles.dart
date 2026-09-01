import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class HouseAccountsStyles {
  final StyleTokens tokens;
  HouseAccountsStyles(this.tokens);

  TextStyle get titleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: tokens.textHeader,
      );

  TextStyle get companyNameStyle => TextStyle(
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: tokens.accent,
      );

  Color getStandingColor(String standing) {
    switch (standing.toUpperCase()) {
      case 'GOOD':
        return tokens.accent; // Teal color
      case 'WARNING':
        return tokens.accentOrange; // Orange color
      case 'DELINQUENT':
        return tokens.accentSecondary; // Red/terracotta color
      default:
        return Colors.grey;
    }
  }
}
