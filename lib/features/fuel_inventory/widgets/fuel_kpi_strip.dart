import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/models/fuel_telemetry_aggregator.dart';

class FuelKpiStrip extends StatelessWidget {
  final FuelTelemetryAggregator telemetry;
  final StyleTokens tokens;

  const FuelKpiStrip({
    super.key,
    required this.telemetry,
    required this.tokens,
  });

  Widget _buildKpiCard({
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
    Widget? trailingIcon,
  }) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: tokens.textMain.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
              if (trailingIcon != null) trailingIcon,
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: tokens.sansFont,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: tokens.textMain.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalGallonsStr = FuelTelemetryAggregator.formatGallons(telemetry.totalFuelOnHand);
    final latestDropGallonsStr = telemetry.latestDropGallons > 0
        ? FuelTelemetryAggregator.formatGallons(telemetry.latestDropGallons)
        : 'None Logged';
    final isIotOnline = telemetry.isIotActive;

    final cardTotal = _buildKpiCard(
      title: 'TOTAL FUEL ON HAND',
      value: totalGallonsStr,
      valueColor: tokens.accent,
      subtitle: 'Across 3 underground storage grades',
      trailingIcon: Icon(Icons.water_drop, size: 16, color: tokens.accent),
    );

    final cardLatestDrop = _buildKpiCard(
      title: 'LATEST DELIVERY DROP',
      value: latestDropGallonsStr,
      valueColor: tokens.textHeader,
      subtitle: telemetry.latestDropBol != null
          ? 'BOL: ${telemetry.latestDropBol} • ${telemetry.latestDropDate ?? ""}'
          : 'No deliveries on record',
      trailingIcon: Icon(Icons.local_shipping, size: 16, color: tokens.accent),
    );

    final cardDeliveries = _buildKpiCard(
      title: 'DELIVERIES LOGGED',
      value: '${telemetry.totalDeliveriesCount} Drops',
      valueColor: tokens.textHeader,
      subtitle: 'Active delivery audit history',
      trailingIcon: Icon(Icons.history, size: 16, color: tokens.accent),
    );

    final cardIot = _buildKpiCard(
      title: 'IOT SENSOR PROBE',
      value: isIotOnline ? 'Active Stream' : 'Not Connected',
      valueColor: isIotOnline ? Colors.teal.shade800 : Colors.red.shade700,
      subtitle: isIotOnline ? 'Python probe streaming live' : 'Port 5000 unavailable',
      trailingIcon: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isIotOnline ? Colors.teal : Colors.red.shade600,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isMedium = constraints.maxWidth > 550 && !isWide;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: cardTotal),
              const SizedBox(width: 12),
              Expanded(child: cardLatestDrop),
              const SizedBox(width: 12),
              Expanded(child: cardDeliveries),
              const SizedBox(width: 12),
              Expanded(child: cardIot),
            ],
          );
        }

        if (isMedium) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: cardTotal),
                  const SizedBox(width: 12),
                  Expanded(child: cardLatestDrop),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: cardDeliveries),
                  const SizedBox(width: 12),
                  Expanded(child: cardIot),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            cardTotal,
            const SizedBox(height: 10),
            cardLatestDrop,
            const SizedBox(height: 10),
            cardDeliveries,
            const SizedBox(height: 10),
            cardIot,
          ],
        );
      },
    );
  }
}
