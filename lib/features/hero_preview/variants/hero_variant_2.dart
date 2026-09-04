import 'package:flutter/material.dart';
import 'package:self_improvement_app/features/hero_preview/widgets/login_form_widget.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

/// Variant 2: Route 66 Americana (Classic Highway Oasis & Diner Heritage)
class HeroVariant2 extends StatelessWidget {
  final StyleTokens tokens;
  final VoidCallback? onNavigateToApp;

  const HeroVariant2({
    super.key,
    required this.tokens,
    this.onNavigateToApp,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 880;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFBF8F2),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 40 : 16,
              vertical: isWide ? 40 : 24,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1080),
                child: Column(
                  children: [
                    // Billboard / Highway Header Section
                    _buildHighwayBanner(tokens),

                    const SizedBox(height: 32),

                    // Main Content: Roadside Highlights & Vintage Login Card
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: _buildHeritagePerks(tokens)),
                          const SizedBox(width: 36),
                          Expanded(
                            flex: 5,
                            child: LoginFormWidget(
                              tokens: tokens,
                              style: LoginFormStyle.vintageHighway,
                              onLoginSuccess: onNavigateToApp,
                              title: 'Stationmaster Portal',
                              subtitle: 'Authorized Operator Access • Store #1',
                              customCardBg: const Color(0xFFFFFDF9),
                              customBorderColor: const Color(0xFFC7462B),
                              customAccentColor: const Color(0xFFC7462B),
                              customTextColor: const Color(0xFF382E27),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          LoginFormWidget(
                            tokens: tokens,
                            style: LoginFormStyle.vintageHighway,
                            onLoginSuccess: onNavigateToApp,
                            title: 'Stationmaster Portal',
                            subtitle: 'Authorized Operator Access • Store #1',
                            customCardBg: const Color(0xFFFFFDF9),
                            customBorderColor: const Color(0xFFC7462B),
                            customAccentColor: const Color(0xFFC7462B),
                            customTextColor: const Color(0xFF382E27),
                          ),
                          const SizedBox(height: 28),
                          _buildHeritagePerks(tokens),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHighwayBanner(StyleTokens tokens) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF2E241E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD97706), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Highway Shield & Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFC7462B),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFBBF24)),
                ),
                child: const Text(
                  'INTERSTATE ROUTE 66 • STORE 1',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16),
            ],
          ),

          const SizedBox(height: 14),

          // Main Billboard Title
          const Text(
            'The All-American Travel Plaza System',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFFBEB),
              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Fueling long-haul freight and highway travelers since 2014 with hospitality and modern efficiency.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFD1C7BD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeritagePerks(StyleTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Station Amenities & Systems',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF382E27),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Everything your shift managers need to keep pumps flowing and drivers refreshed.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B5F54),
          ),
        ),
        const SizedBox(height: 18),
        _buildAmenityCard(
          icon: Icons.local_gas_station,
          title: 'High-Flow Diesel Island',
          desc: '12 multi-grade pumps with auto-settlement and DEF dispenser tracking.',
        ),
        const SizedBox(height: 12),
        _buildAmenityCard(
          icon: Icons.shower,
          title: 'Clean Shower Turnstiles',
          desc: 'Automated PIN voucher system with real-time sanitation queue alerts.',
        ),
        const SizedBox(height: 12),
        _buildAmenityCard(
          icon: Icons.local_shipping,
          title: 'Secure Overnight Parking',
          desc: '50-stall paved commercial lot with automated plate logging.',
        ),
        const SizedBox(height: 12),
        _buildAmenityCard(
          icon: Icons.casino_outlined,
          title: 'Blackjack Drivers Lounge',
          desc: 'Live gaming entertainment ledger and hospitality club integration.',
        ),
      ],
    );
  }

  Widget _buildAmenityCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6DCce)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFC7462B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFC7462B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E241E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B5F54),
                    height: 1.35,
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
