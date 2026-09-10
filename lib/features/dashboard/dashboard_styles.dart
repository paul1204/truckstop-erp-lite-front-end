import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';

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
}
