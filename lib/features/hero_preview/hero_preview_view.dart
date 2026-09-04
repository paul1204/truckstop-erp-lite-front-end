import 'package:flutter/material.dart';
import 'package:self_improvement_app/features/hero_preview/variants/hero_variant_1.dart';
import 'package:self_improvement_app/features/hero_preview/variants/hero_variant_2.dart';
import 'package:self_improvement_app/features/hero_preview/variants/hero_variant_3.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

/// Modular preview container allowing side-by-side evaluation of 3 Hero+Login concepts.
class HeroPreviewView extends StatefulWidget {
  final StyleTokens tokens;
  final VoidCallback? onNavigateToApp;

  const HeroPreviewView({
    super.key,
    required this.tokens,
    this.onNavigateToApp,
  });

  @override
  State<HeroPreviewView> createState() => _HeroPreviewViewState();
}

class _HeroPreviewViewState extends State<HeroPreviewView> {
  int _selectedVariant = 0;

  final List<Map<String, String>> _variants = [
    {
      'title': 'Variant 1: Industrial Fleet Command',
      'subtitle': 'Dark Slate • Telematics Ticker • Glassmorphism Card',
      'icon': '🛰️',
    },
    {
      'title': 'Variant 2: Route 66 Americana',
      'subtitle': 'Highway Oasis • Heritage Badges • Warm Diner Portal',
      'icon': '🛣️',
    },
    {
      'title': 'Variant 3: Modern Enterprise SaaS',
      'subtitle': 'Linear/Stripe Aesthetic • Interactive Module Tour',
      'icon': '⚡',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return Column(
      children: [
        // 1. Variant Switcher Control Bar
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: tokens.navBg,
            border: Border(bottom: BorderSide(color: tokens.border, width: 1)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Info Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: tokens.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tokens.accent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.science_outlined, size: 16, color: tokens.accent),
                      const SizedBox(width: 6),
                      Text(
                        'HERO LAB (Credentials: Admin / Admin)',
                        style: TextStyle(
                          fontFamily: tokens.monoFont,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: tokens.accent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Variant Selector Tabs
                ...List.generate(_variants.length, (index) {
                  final v = _variants[index];
                  final isSelected = _selectedVariant == index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedVariant = index),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? tokens.accent : tokens.background.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? tokens.accent : tokens.border.withOpacity(0.5),
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: tokens.accent.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Text(v['icon']!, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 8),
                            Text(
                              v['title']!,
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : tokens.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // 2. Active Variant Canvas
        Expanded(
          child: _buildActiveVariant(tokens),
        ),
      ],
    );
  }

  Widget _buildActiveVariant(StyleTokens tokens) {
    switch (_selectedVariant) {
      case 0:
        return HeroVariant1(
          tokens: tokens,
          onNavigateToApp: widget.onNavigateToApp,
        );
      case 1:
        return HeroVariant2(
          tokens: tokens,
          onNavigateToApp: widget.onNavigateToApp,
        );
      case 2:
      default:
        return HeroVariant3(
          tokens: tokens,
          onNavigateToApp: widget.onNavigateToApp,
        );
    }
  }
}
