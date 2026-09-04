import 'package:flutter/material.dart';
import 'package:self_improvement_app/features/hero_preview/widgets/login_form_widget.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

/// Variant 1: Industrial Fleet Command (Dark Tech & Telematics)
class HeroVariant1 extends StatelessWidget {
  final StyleTokens tokens;
  final VoidCallback? onNavigateToApp;

  const HeroVariant1({
    super.key,
    required this.tokens,
    this.onNavigateToApp,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 920;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF090E17),
                Color(0xFF0F172A),
                Color(0xFF0D212F),
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 48 : 20,
              vertical: isWide ? 48 : 28,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: _buildHeroPitch(tokens)),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 5,
                            child: LoginFormWidget(
                              tokens: tokens,
                              style: LoginFormStyle.glassmorphism,
                              onLoginSuccess: onNavigateToApp,
                              title: 'Fleet Command Login',
                              subtitle: 'Enterprise Dispatch & Terminal Access',
                            ),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildHeroPitch(tokens),
                          const SizedBox(height: 36),
                          Center(
                            child: LoginFormWidget(
                              tokens: tokens,
                              style: LoginFormStyle.glassmorphism,
                              onLoginSuccess: onNavigateToApp,
                              title: 'Fleet Command Login',
                              subtitle: 'Enterprise Dispatch & Terminal Access',
                            ),
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

  Widget _buildHeroPitch(StyleTokens tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live System Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00F2FE).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF00F2FE),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ERP SYSTEM // STORE #1 ONLINE',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: Color(0xFF00F2FE),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Bold Headline
        const Text(
          'Mission-Critical Operations for Highway Travel Plazas',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            height: 1.15,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 14),

        // Value description
        Text(
          'Centralized real-time telemetry across underground fuel tanks, commercial parking bays, 24/7 shower turnstiles, retail POS, and house accounts in one lightning-fast terminal.',
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.white.withOpacity(0.8),
          ),
        ),

        const SizedBox(height: 24),

        // Live Telemetry Grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTelemetryBadge(
              icon: Icons.local_gas_station,
              label: 'Fuel Depot',
              val: 'Diesel 84% • Gas 91%',
              color: const Color(0xFF00F2FE),
            ),
            _buildTelemetryBadge(
              icon: Icons.local_parking,
              label: 'Truck Grid',
              val: '42 / 48 Bays Active',
              color: const Color(0xFF4ADE80),
            ),
            _buildTelemetryBadge(
              icon: Icons.shower_outlined,
              label: 'Showers',
              val: '4 Stalls • 2 In Queue',
              color: const Color(0xFF38BDF8),
            ),
            _buildTelemetryBadge(
              icon: Icons.attach_money,
              label: 'Daily POS',
              val: '\$14,892 Transacted',
              color: const Color(0xFFFBBF24),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Core Capabilities Bullet List
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _buildFeatureBullet('Automatic Tank Gauging'),
            _buildFeatureBullet('RFID House Invoicing'),
            _buildFeatureBullet('Live Shower Dispatch'),
            _buildFeatureBullet('Blackjack Lounge Integration'),
          ],
        ),
      ],
    );
  }

  Widget _buildTelemetryBadge({
    required IconData icon,
    required String label,
    required String val,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                val,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle, size: 16, color: Color(0xFF00F2FE)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.85),
          ),
        ),
      ],
    );
  }
}
