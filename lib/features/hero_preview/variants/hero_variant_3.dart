import 'package:flutter/material.dart';
import 'package:self_improvement_app/features/hero_preview/widgets/login_form_widget.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

/// Variant 3: Modern Enterprise Cloud SaaS (Clean Minimalist & Interactive Module Showcase)
class HeroVariant3 extends StatefulWidget {
  final StyleTokens tokens;
  final VoidCallback? onNavigateToApp;

  const HeroVariant3({
    super.key,
    required this.tokens,
    this.onNavigateToApp,
  });

  @override
  State<HeroVariant3> createState() => _HeroVariant3State();
}

class _HeroVariant3State extends State<HeroVariant3> {
  int _selectedModuleIndex = 0;

  final List<Map<String, dynamic>> _modules = [
    {
      'title': 'Fuel Inventory',
      'icon': Icons.local_gas_station,
      'metric': '94.8% Capacity',
      'desc': 'Real-time underground tank levels, delivery logbook, ATG sensor telemetry, and automatic outage alerts.',
      'color': Color(0xFF0284C7),
    },
    {
      'title': 'Shower Stalls',
      'icon': Icons.shower_outlined,
      'metric': '6 Clean • 2 In Use',
      'desc': 'Automated driver ticket dispensing, RFID entry codes, housekeeping queue timing, and turnover telemetry.',
      'color': Color(0xFF0D9488),
    },
    {
      'title': 'Commercial Parking',
      'icon': Icons.local_parking,
      'metric': '48 Reserved Bays',
      'desc': 'Interactive top-down parking lot map, tractor-trailer space allocation, and overnight permit verification.',
      'color': Color(0xFF7C3AED),
    },
    {
      'title': 'House Accounts',
      'icon': Icons.badge_outlined,
      'metric': '34 Active Fleets',
      'desc': 'Commercial fleet credit limits, monthly billing statements, net-30 terms, and instant RFID pump authorization.',
      'color': Color(0xFFEA580C),
    },
    {
      'title': 'Blackjack Lounge',
      'icon': Icons.casino_outlined,
      'metric': '2 Live Tables',
      'desc': 'Driver entertainment management, card game settlement logs, and promotional hospitality credits.',
      'color': Color(0xFFDC2626),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 960;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 48 : 20,
            vertical: isWide ? 44 : 24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Release Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: tokens.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: tokens.accent.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt, color: tokens.accent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'ERP 2.0 Cloud Architecture • Live & Synchronized',
                          style: TextStyle(
                            fontFamily: tokens.sansFont,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: tokens.accent,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. SaaS Punchy Headline
                  Text(
                    'The Modern Operating System for Independent Truck Stops',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: isWide ? 38 : 26,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      color: tokens.textHeader,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 3. Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      'Unify fuel management, overnight parking logistics, shower sanitation, retail inventory, and commercial house accounts in one lightning-fast web terminal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 15,
                        height: 1.55,
                        color: tokens.textMain.withOpacity(0.8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // 4. Split Hero / Login Layout
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Interactive ERP Module Explorer
                        Expanded(
                          flex: 6,
                          child: _buildInteractiveModuleTour(tokens),
                        ),
                        const SizedBox(width: 40),
                        // Right: Sleek Modern Login Card
                        Expanded(
                          flex: 5,
                          child: LoginFormWidget(
                            tokens: tokens,
                            style: LoginFormStyle.modernSaaS,
                            onLoginSuccess: widget.onNavigateToApp,
                            title: 'Enterprise Operator Portal',
                            subtitle: 'Sign in with credentials or demo one-click',
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        LoginFormWidget(
                          tokens: tokens,
                          style: LoginFormStyle.modernSaaS,
                          onLoginSuccess: widget.onNavigateToApp,
                          title: 'Enterprise Operator Portal',
                          subtitle: 'Sign in with credentials or demo one-click',
                        ),
                        const SizedBox(height: 36),
                        _buildInteractiveModuleTour(tokens),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractiveModuleTour(StyleTokens tokens) {
    final activeModule = _modules[_selectedModuleIndex];
    final Color modColor = activeModule['color'] as Color;

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: tokens.shadowColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.widgets_outlined, color: tokens.accent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Explore ERP Subsystems',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: tokens.textHeader,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Module Selection Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_modules.length, (index) {
                final mod = _modules[index];
                final isSelected = _selectedModuleIndex == index;
                final Color chipColor = mod['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedModuleIndex = index),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? chipColor.withOpacity(0.12) : tokens.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? chipColor : tokens.border.withOpacity(0.4),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            mod['icon'] as IconData,
                            size: 16,
                            color: isSelected ? chipColor : tokens.textMain.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            mod['title'] as String,
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? chipColor : tokens.textMain.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Active Module Preview Detail Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: modColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: modColor.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: modColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(activeModule['icon'] as IconData, color: modColor, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          activeModule['title'] as String,
                          style: TextStyle(
                            fontFamily: tokens.sansFont,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: tokens.textHeader,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: modColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activeModule['metric'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  activeModule['desc'] as String,
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 13,
                    height: 1.5,
                    color: tokens.textMain.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
