import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/models/sales_shift_data.dart';

class ShiftPacingChart extends StatelessWidget {
  final DailySalesTelemetry telemetry;
  final StyleTokens tokens;

  const ShiftPacingChart({
    super.key,
    required this.telemetry,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final shifts = telemetry.shifts;
    final maxSales = telemetry.peakShift?.salesAmount ?? 0.0;
    final avgSales = telemetry.averageShiftSales;

    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PERFORMANCE & PACING',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: tokens.accent,
                  letterSpacing: 0.5,
                ),
              ),
              if (avgSales > 0)
                Text(
                  'Avg: ${DailySalesTelemetry.formatCurrency(avgSales)}',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: tokens.textMain.withOpacity(0.6),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Render comparative pacing bars
          ...shifts.map((shift) {
            final amount = shift.salesAmount;
            final isPeak = shift.shiftNumber == telemetry.peakShift?.shiftNumber;
            final progress = maxSales > 0 ? (amount / maxSales).clamp(0.02, 1.0) : 0.0;
            final vsAvgPercent = avgSales > 0 ? ((amount - avgSales) / avgSales) * 100 : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Shift ${shift.shiftNumber}',
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tokens.textHeader,
                            ),
                          ),
                          if (isPeak) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: tokens.accentSecondary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(3),
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
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          if (avgSales > 0 && shifts.length > 1) ...[
                            Text(
                              vsAvgPercent >= 0
                                  ? '+${vsAvgPercent.toStringAsFixed(0)}% vs avg'
                                  : '${vsAvgPercent.toStringAsFixed(0)}% vs avg',
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: vsAvgPercent >= 0 ? tokens.accent : tokens.accentSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            DailySalesTelemetry.formatCurrency(amount),
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tokens.textHeader,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: tokens.border.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPeak
                                  ? [tokens.accentSecondary, tokens.accentSecondary.withOpacity(0.8)]
                                  : [tokens.accent, tokens.accent.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Average benchmark indicator line note
          if (shifts.length > 1 && avgSales > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 2,
                  color: tokens.textMain.withOpacity(0.4),
                ),
                const SizedBox(width: 6),
                Text(
                  'Daily benchmark average: ${DailySalesTelemetry.formatCurrency(avgSales)} per shift',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: tokens.textMain.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
