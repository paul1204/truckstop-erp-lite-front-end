import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/settings/theme_notifier.dart';

class SettingsView extends StatefulWidget {
  final StyleTokens tokens;
  final ThemeNotifier themeNotifier;

  const SettingsView({
    super.key,
    required this.tokens,
    required this.themeNotifier,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'System Settings',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: tokens.textHeader,
                ),
              ),
              const SizedBox(height: 4),
              Container(height: 4, width: 100, color: tokens.accent),
            ],
          ),
          const SizedBox(height: 24),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: _buildAppearanceCard(tokens),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(StyleTokens tokens) {
    final currentTheme = widget.themeNotifier.currentTheme;

    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'APPEARANCE & VISUALS',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Application Theme Mode',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: tokens.textHeader,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose between the high-contrast Dark Theme (Profile A) or the clean Light Theme (Profile B).',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 12,
              color: tokens.textMain.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: tokens.border.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: tokens.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AppThemeSetting>(
                value: currentTheme,
                dropdownColor: tokens.cardBg,
                icon: Icon(Icons.arrow_drop_down, color: tokens.accent),
                isExpanded: true,
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: tokens.textHeader,
                ),
                items: [
                  DropdownMenuItem(
                    value: AppThemeSetting.darkProfileA,
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          currentTheme == AppThemeSetting.darkProfileA
                              ? 'Dark Theme (Profile A) (Current)'
                              : 'Dark Theme (Profile A)',
                          style: TextStyle(color: tokens.textHeader),
                        ),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: AppThemeSetting.lightProfileB,
                    child: Row(
                      children: [
                        Icon(Icons.light_mode, size: 16, color: tokens.accent),
                        const SizedBox(width: 8),
                        Text(
                          currentTheme == AppThemeSetting.lightProfileB
                              ? 'Light Theme (Profile B) (Current)'
                              : 'Light Theme (Profile B)',
                          style: TextStyle(color: tokens.textHeader),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (AppThemeSetting? newTheme) {
                  if (newTheme != null) {
                    widget.themeNotifier.setThemeSetting(newTheme);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

