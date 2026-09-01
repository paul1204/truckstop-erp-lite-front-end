import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class IncidentsView extends StatelessWidget {
  final StyleTokens tokens;

  const IncidentsView({super.key, required this.tokens});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Incidents Content Area',
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
            'Incident logs and reporting dashboard. Features will be modularized here.',
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
