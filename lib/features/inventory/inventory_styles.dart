import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class InventoryStyles {
  final StyleTokens tokens;
  InventoryStyles(this.tokens);

  TextStyle get titleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: tokens.textHeader,
      );

  TextStyle get subtitleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 14,
        color: tokens.textMain.withOpacity(0.6),
      );

  TextStyle get productNameStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: tokens.textHeader,
      );

  TextStyle get detailLabelStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: tokens.textMain.withOpacity(0.5),
      );

  TextStyle get detailValueStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: tokens.textMain,
      );

  TextStyle get categoryLabelStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: tokens.textMain,
      );
}
