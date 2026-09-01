import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class BlackjackStyles {
  final StyleTokens tokens;
  BlackjackStyles(this.tokens);

  Color get feltBg => tokens.brightness == Brightness.dark
      ? const Color(0xFF1B4D3E)
      : const Color(0xFF0F5243);

  TextStyle get titleStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      );

  TextStyle get scoreTextStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      );

  TextStyle get bannerMessageStyle => TextStyle(
        fontFamily: tokens.serifFont,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: tokens.accentSecondary,
      );

  TextStyle get buttonStyle => TextStyle(
        fontFamily: tokens.sansFont,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      );
}
