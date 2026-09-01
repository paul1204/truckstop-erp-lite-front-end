import 'package:flutter/material.dart';

enum AppProfile { profileA, profileB }

class StyleTokens {
  final AppProfile profile;
  final Brightness brightness;

  StyleTokens({required this.profile, required this.brightness});

  // Fonts
  String get sansFont => 'Inter';
  String get serifFont => 'Georgia';
  String get monoFont => 'Courier'; // Fallback monospace

  // Colors
  Color get textMain {
    if (profile == AppProfile.profileB) return const Color(0xFF4A453E);
    return brightness == Brightness.dark ? const Color(0xFFE5E2DD) : const Color(0xFF4A453E);
  }

  Color get textHeader {
    if (profile == AppProfile.profileB) return const Color(0xFF201E1C);
    return brightness == Brightness.dark ? const Color(0xFFF9F8F6) : const Color(0xFF201E1C);
  }

  Color get background {
    if (profile == AppProfile.profileB) return const Color(0xFFF9F8F6);
    return brightness == Brightness.dark ? const Color(0xFF2D2B29) : const Color(0xFFF9F8F6);
  }

  Color get border {
    if (profile == AppProfile.profileB) return const Color(0xFFE29A6A);
    return brightness == Brightness.dark ? const Color(0xFF3D3B39) : const Color(0xFFE29A6A);
  }

  Color get accent {
    if (profile == AppProfile.profileB) return const Color(0xFF004B50);
    return brightness == Brightness.dark ? const Color(0xFF4DB6AC) : const Color(0xFF004B50);
  }

  Color get accentSecondary {
    if (profile == AppProfile.profileB) return const Color(0xFFC7462B);
    return brightness == Brightness.dark ? const Color(0xFFFF8A65) : const Color(0xFFC7462B);
  }

  Color get accentOrange {
    return const Color(0xFFD96B27);
  }

  Color get stippleColor {
    if (profile == AppProfile.profileB) return const Color(0xFFE2E0D9);
    return brightness == Brightness.dark ? const Color(0xFF353331) : const Color(0xFFE2E0D9);
  }

  Color get headerBg {
    if (profile == AppProfile.profileB) return const Color(0xFFF5F4F0);
    return const Color(0xFF201E1C); // Profile A Header is dark in both modes
  }

  Color get headerText {
    if (profile == AppProfile.profileB) return const Color(0xFF201E1C);
    return const Color(0xFFF9F8F6);
  }

  Color get navBg {
    if (profile == AppProfile.profileB) return const Color(0xFFF9F8F6);
    return brightness == Brightness.dark ? const Color(0xFF353331) : const Color(0xFFF0EEE9);
  }

  Color get navText {
    return const Color(0xFF5C5852);
  }

  Color get cardBg {
    if (profile == AppProfile.profileB) return const Color(0xFFF9F8F6);
    return brightness == Brightness.dark ? const Color(0xFF2D2B29) : const Color(0xFFF9F8F6);
  }

  Color get shadowColor {
    return brightness == Brightness.dark
        ? const Color(0x66000000)
        : const Color(0x24201E1C);
  }

  Color get footerBg {
    if (profile == AppProfile.profileB) return const Color(0xFFF0EEE9);
    return const Color(0xFF201E1C);
  }

  Color get footerText {
    if (profile == AppProfile.profileB) return const Color(0xFF4A453E);
    return const Color(0xFFA8A29E);
  }

  // Visual decorations
  BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: cardBg,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(6),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: shadowColor.withOpacity(shadowColor.opacity / 2),
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
      ],
    );
  }
}
