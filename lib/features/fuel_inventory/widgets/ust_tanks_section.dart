import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/models/fuel_telemetry_aggregator.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/widgets/ust_tank_card.dart';

class UstTanksSection extends StatelessWidget {
  final FuelTelemetryAggregator telemetry;
  final StyleTokens tokens;

  const UstTanksSection({
    super.key,
    required this.telemetry,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final tanks = telemetry.tanks;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 950;

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < tanks.length; i++) ...[
                Expanded(
                  child: UstTankCard(
                    tank: tanks[i],
                    tokens: tokens,
                  ),
                ),
                if (i < tanks.length - 1) const SizedBox(width: 14),
              ],
            ],
          );
        }

        return Column(
          children: [
            for (int i = 0; i < tanks.length; i++) ...[
              UstTankCard(
                tank: tanks[i],
                tokens: tokens,
              ),
              if (i < tanks.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}
