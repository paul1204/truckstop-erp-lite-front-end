import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class AboutView extends StatelessWidget {
  final StyleTokens tokens;

  const AboutView({super.key, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Content Area',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: tokens.textHeader,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 100,
            color: tokens.accent,
          ),
          const SizedBox(height: 24),
          Text(
            'Truck Stop LTE ERP Store 1 version 2.0. Built with Flutter for multi-platform web and mobile execution.',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 16,
              color: tokens.textMain,
            ),
          ),
        ],
      ),
    );
  }
}
