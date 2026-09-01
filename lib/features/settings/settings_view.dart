import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/settings/theme_notifier.dart';

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
  // Mock settings switches
  bool _realtimeSales = true;
  bool _soundNotifications = false;
  bool _detailedLogging = true;

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

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildAppearanceCard(tokens),
                          const SizedBox(height: 20),
                          _buildFeatureTogglesCard(tokens),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 6,
                      child: _buildSystemInfoCard(tokens),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildAppearanceCard(tokens),
                    const SizedBox(height: 20),
                    _buildFeatureTogglesCard(tokens),
                    const SizedBox(height: 20),
                    _buildSystemInfoCard(tokens),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard(StyleTokens tokens) {
    final currentMode = widget.themeNotifier.themeMode;

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
            'Choose between the high-contrast dark theme or the clean light layout.',
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
              child: DropdownButton<ThemeMode>(
                value: currentMode,
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
                    value: ThemeMode.dark,
                    child: Row(
                      children: [
                        const Icon(Icons.dark_mode, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text('Dark Theme (Current)', style: TextStyle(color: tokens.textHeader)),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Row(
                      children: [
                        Icon(Icons.light_mode, size: 16, color: tokens.accent),
                        const SizedBox(width: 8),
                        Text('Light Theme', style: TextStyle(color: tokens.textHeader)),
                      ],
                    ),
                  ),
                ],
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    widget.themeNotifier.setThemeMode(newMode);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTogglesCard(StyleTokens tokens) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ERP LITE MODULE PREFERENCES',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchRow(
            'Real-time Sales Pulling',
            'Enables regular dashboard statistics updates from /api/sales/by-shift.',
            _realtimeSales,
            (val) => setState(() => _realtimeSales = val),
            tokens,
          ),
          Divider(color: tokens.border, height: 24),
          _buildSwitchRow(
            'Sound Alerts on Incidents',
            'Triggers an audible alert when a critical fuel pump or facility incident is logged.',
            _soundNotifications,
            (val) => setState(() => _soundNotifications = val),
            tokens,
          ),
          Divider(color: tokens.border, height: 24),
          _buildSwitchRow(
            'Detailed HTTP Logging',
            'Logs HTTP request details and payload schemas directly in the developer console.',
            _detailedLogging,
            (val) => setState(() => _detailedLogging = val),
            tokens,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String title, String description, bool value, ValueChanged<bool> onChanged, StyleTokens tokens) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: tokens.textHeader,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 11,
                  color: tokens.textMain.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: tokens.accent,
          activeTrackColor: tokens.accent.withOpacity(0.2),
          inactiveThumbColor: tokens.textMain.withOpacity(0.4),
          inactiveTrackColor: tokens.border,
        ),
      ],
    );
  }

  Widget _buildSystemInfoCard(StyleTokens tokens) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM & BACKEND METADATA',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('ERP Version', '1.0.0-LITE (Build 2026.08.04)', tokens),
          _buildInfoRow('Primary ERP Host', 'http://localhost:9000', tokens),
          _buildInfoRow('Microservice Sensors Port', 'http://127.0.0.1:5000', tokens),
          _buildInfoRow('Active API Integration', 'GET /api/sales/by-shift/{date}', tokens),
          _buildInfoRow('Platform OS Version', 'macOS (Darwin-x64)', tokens),
          _buildInfoRow('Dart SDK Target', '^3.12.2', tokens),
          _buildInfoRow('Theme Engine', 'Material 3', tokens),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: tokens.accent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: tokens.accent.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: tokens.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ERP LITE is currently running in local development mode. Hot Reload and hot restarting are active.',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: tokens.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, StyleTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 12,
              color: tokens.textMain.withOpacity(0.5),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: tokens.textHeader,
            ),
          ),
        ],
      ),
    );
  }
}
