import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';

enum AppThemeSetting {
  darkProfileA,
  lightProfileB,
}

class ThemeNotifier extends ChangeNotifier {
  AppThemeSetting _currentTheme = AppThemeSetting.lightProfileB;
  AppThemeSetting get currentTheme => _currentTheme;

  ThemeMode get themeMode => _currentTheme == AppThemeSetting.darkProfileA
      ? ThemeMode.dark
      : ThemeMode.light;

  AppProfile get activeProfile => _currentTheme == AppThemeSetting.darkProfileA
      ? AppProfile.profileA
      : AppProfile.profileB;

  Brightness get brightness => _currentTheme == AppThemeSetting.darkProfileA
      ? Brightness.dark
      : Brightness.light;

  bool get isDark => _currentTheme == AppThemeSetting.darkProfileA;

  void setThemeSetting(AppThemeSetting setting) {
    if (_currentTheme != setting) {
      _currentTheme = setting;
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    setThemeSetting(mode == ThemeMode.dark ? AppThemeSetting.darkProfileA : AppThemeSetting.lightProfileB);
  }
}
