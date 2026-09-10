import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/models/fuel_telemetry_aggregator.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/widgets/horizontal_ust_tank.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/widgets/atg_reconciliation_row.dart';

class UstTankCard extends StatelessWidget {
  final TankTelemetryPair tank;
  final StyleTokens tokens;

  const UstTankCard({
    super.key,
    required this.tank,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhysical = tank.physicalGallons != null;
    final fillPctStr = '${tank.fillPercent.toStringAsFixed(1)}%';
    final badgeLabel = hasPhysical
        ? '$fillPctStr IoT Level'
        : 'Book: ${FuelTelemetryAggregator.formatGallons(tank.bookGallons)}';

    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tank Title & Status Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tank.gradeName,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: tokens.textHeader,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tank.gradeSubtitle,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 10,
                      color: tokens.textMain.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: tank.fluidColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: tank.fluidColor.withOpacity(0.3)),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: tank.fluidColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Horizontal Underground Storage Tank Graphic (No Ladders!)
          HorizontalUstTank(
            fillPercent: tank.fillPercent,
            fluidColor: tank.fluidColor,
            tokens: tokens,
            height: 95,
          ),
          const SizedBox(height: 14),

          Divider(color: tokens.border.withOpacity(0.4), height: 1),
          const SizedBox(height: 12),

          // 3. 3-Column ATG Variance Reconciliation Row
          AtgReconciliationRow(
            tank: tank,
            tokens: tokens,
          ),
        ],
      ),
    );
  }
}
