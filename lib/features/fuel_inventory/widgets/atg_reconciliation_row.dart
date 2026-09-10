import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/models/fuel_telemetry_aggregator.dart';

class AtgReconciliationRow extends StatelessWidget {
  final TankTelemetryPair tank;
  final StyleTokens tokens;

  const AtgReconciliationRow({
    super.key,
    required this.tank,
    required this.tokens,
  });

  Widget _buildMetricCol({
    required String title,
    required String mainValue,
    required Color valueColor,
    required String subValue,
    Widget? badge,
    CrossAxisAlignment crossAlign = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAlign,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: tokens.sansFont,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: tokens.textMain.withOpacity(0.55),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            mainValue,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subValue,
          style: TextStyle(
            fontFamily: tokens.sansFont,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: tokens.textMain.withOpacity(0.7),
          ),
        ),
        if (badge != null) ...[
          const SizedBox(height: 4),
          badge,
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhysical = tank.physicalGallons != null;
    final physicalStr = hasPhysical
        ? FuelTelemetryAggregator.formatGallons(tank.physicalGallons!)
        : 'Not Connected';

    final physicalSub = hasPhysical
        ? 'Temp: ${tank.probeTempF != null ? "${tank.probeTempF!.toStringAsFixed(1)}°F" : "0.0°F"} • Cyc: ${tank.probeCycle ?? 0}'
        : 'Port 5000 unavailable';

    final bookStr = FuelTelemetryAggregator.formatGallons(tank.bookGallons);
    final bookSub = tank.lastDeliveryDate != null && tank.lastDeliveryDate!.isNotEmpty
        ? 'Last Delivery: ${tank.lastDeliveryDate}'
        : 'Ledger balance';

    // Variance calculations
    String varianceMain;
    Widget varianceBadge;
    Color varianceColor = tokens.accent;

    if (hasPhysical) {
      final delta = tank.varianceGallons ?? 0.0;
      final pct = tank.variancePercent ?? 0.0;
      final sign = delta >= 0 ? '+' : '';
      varianceMain = '$sign${delta.toStringAsFixed(0)} Gal ($sign${pct.toStringAsFixed(2)}%)';

      if (delta.abs() < 1.0) {
        varianceBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Text(
            'Calibrated ✓',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        );
      } else if (tank.isInTolerance) {
        varianceBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.teal.withOpacity(0.3)),
          ),
          child: Text(
            'In Tolerance ✓',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade800,
            ),
          ),
        );
      } else {
        varianceColor = tokens.accentSecondary;
        varianceBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: tokens.accentSecondary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: tokens.accentSecondary.withOpacity(0.3)),
          ),
          child: Text(
            'Check Variance',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: tokens.accentSecondary,
            ),
          ),
        );
      }
    } else {
      varianceMain = '0 Gal (0.0%)';
      varianceBadge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: tokens.border.withOpacity(0.2),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: tokens.border.withOpacity(0.4)),
        ),
        child: Text(
          'Book Baseline',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: tokens.textMain.withOpacity(0.8),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: _buildMetricCol(
            title: 'PHYSICAL (IoT Probe)',
            mainValue: physicalStr,
            valueColor: hasPhysical ? tokens.textHeader : tokens.textMain.withOpacity(0.5),
            subValue: physicalSub,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: _buildMetricCol(
            title: 'BOOK (ERP Database)',
            mainValue: bookStr,
            valueColor: tokens.textHeader,
            subValue: bookSub,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 4,
          child: _buildMetricCol(
            title: 'VARIANCE',
            mainValue: varianceMain,
            valueColor: varianceColor,
            subValue: hasPhysical ? 'Real-time delta' : 'Awaiting sensor stream',
            badge: varianceBadge,
          ),
        ),
      ],
    );
  }
}
