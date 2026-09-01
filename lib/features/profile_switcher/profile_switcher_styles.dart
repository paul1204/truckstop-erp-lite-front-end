import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class ProfileSwitcherStyles {
  final StyleTokens tokens;
  ProfileSwitcherStyles(this.tokens);

  Color get triggerBg => tokens.profile == AppProfile.profileB
      ? tokens.accent.withOpacity(0.05)
      : tokens.brightness == Brightness.dark
          ? const Color(0xFF353331)
          : const Color(0xFFE8E6E1).withOpacity(0.4);

  Color get triggerBorder => tokens.border;

  TextStyle get emailStyle => TextStyle(
        fontFamily: tokens.sansFont,
        color: tokens.textMain,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      );

  TextStyle get dropdownItemStyle => TextStyle(
        fontFamily: tokens.sansFont,
        color: tokens.textMain,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      );

  TextStyle get dropdownActiveItemStyle => TextStyle(
        fontFamily: tokens.sansFont,
        color: tokens.accent,
        fontWeight: FontWeight.w700,
        fontSize: 14,
      );
}
