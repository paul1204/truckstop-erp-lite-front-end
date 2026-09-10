import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/models/sales_shift_data.dart';

class SalesKpiCards extends StatelessWidget {
  final DailySalesTelemetry telemetry;
  final StyleTokens tokens;

  const SalesKpiCards({
    super.key,
    required this.telemetry,
    required this.tokens,
  });

  Widget _buildCard({
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
    Widget? trailingBadge,
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
                  letterSpacing: 0.6,
                ),
              ),
              if (trailingBadge != null) trailingBadge,
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
    final hasData = telemetry.shifts.isNotEmpty;
    final total = DailySalesTelemetry.formatCurrency(telemetry.totalSales);
    final velocity = DailySalesTelemetry.formatCurrency(telemetry.salesVelocity);
    final peak = telemetry.peakShift;
    final peakText = peak != null ? 'Shift ${peak.shiftNumber}' : 'N/A';
    final peakAmount = peak != null ? DailySalesTelemetry.formatCurrency(peak.salesAmount) : '\$0.00';
    final concentration = hasData ? '${telemetry.peakConcentrationPercent.toStringAsFixed(1)}%' : '0.0%';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final isMedium = constraints.maxWidth > 550 && !isWide;

        final cardTotal = _buildCard(
          title: 'TOTAL GROSS SALES',
          value: total,
          valueColor: tokens.accent,
          subtitle: hasData ? '${telemetry.shifts.length} shifts recorded' : 'No shifts reported',
        );

        final cardVelocity = _buildCard(
          title: 'SALES VELOCITY',
          value: '$velocity / hr',
          valueColor: tokens.textHeader,
          subtitle: hasData ? '${telemetry.shifts.length * 6} operating hours' : 'Awaiting shifts',
        );

        final cardPeak = _buildCard(
          title: 'PEAK VOLUME SHIFT',
          value: peakText,
          valueColor: tokens.accentSecondary,
          subtitle: peak != null ? peakAmount : 'None',
          trailingBadge: peak != null
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: tokens.accentSecondary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'PEAK',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: tokens.accentSecondary,
                    ),
                  ),
                )
              : null,
        );

        final cardConcentration = _buildCard(
          title: 'PEAK CONCENTRATION',
          value: concentration,
          valueColor: tokens.accentOrange,
          subtitle: peak != null ? 'of daily sales in Shift ${peak.shiftNumber}' : 'Even distribution',
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: cardTotal),
              const SizedBox(width: 12),
              Expanded(child: cardVelocity),
              const SizedBox(width: 12),
              Expanded(child: cardPeak),
              const SizedBox(width: 12),
              Expanded(child: cardConcentration),
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
                  Expanded(child: cardVelocity),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: cardPeak),
                  const SizedBox(width: 12),
                  Expanded(child: cardConcentration),
                ],
              ),
            ],
          );
        }

        return Column(
          children: [
            cardTotal,
            const SizedBox(height: 10),
            cardVelocity,
            const SizedBox(height: 10),
            cardPeak,
            const SizedBox(height: 10),
            cardConcentration,
          ],
        );
      },
    );
  }
}
