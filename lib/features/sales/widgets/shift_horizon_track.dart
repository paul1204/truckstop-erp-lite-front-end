import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/models/sales_shift_data.dart';

class ShiftHorizonTrack extends StatelessWidget {
  final DailySalesTelemetry telemetry;
  final StyleTokens tokens;

  const ShiftHorizonTrack({
    super.key,
    required this.telemetry,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final shiftMap = <int, ShiftSalesRecord>{};
    for (final s in telemetry.shifts) {
      shiftMap[s.shiftNumber] = s;
    }

    final peakShiftNum = telemetry.peakShift?.shiftNumber;

    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: tokens.accent),
                  const SizedBox(width: 6),
                  Text(
                    '24-HOUR SHIFT HORIZON',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: tokens.accent,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Text(
                '00:00 — 24:00 DIURNAL CYCLE',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: tokens.textMain.withOpacity(0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 24-Hour segmented bar
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 600;

              return Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: isCompact ? 52 : 42,
                      child: Row(
                        children: List.generate(4, (index) {
                          final shiftNumber = index + 1;
                          final record = shiftMap[shiftNumber];
                          final hasSales = record != null && record.salesAmount > 0;
                          final isPeak = shiftNumber == peakShiftNum && (record?.salesAmount ?? 0) > 0;
                          final contribution = record != null
                              ? telemetry.shiftContributionPercent(record.salesAmount)
                              : 0.0;

                          Color blockBg;
                          if (isPeak) {
                            blockBg = tokens.accentSecondary;
                          } else if (hasSales) {
                            blockBg = tokens.accent;
                          } else {
                            blockBg = tokens.border.withOpacity(0.25);
                          }

                          Color textColor;
                          if (hasSales) {
                            textColor = tokens.background;
                          } else {
                            textColor = tokens.textMain.withOpacity(0.5);
                          }

                          return Expanded(
                            child: Container(
                              margin: EdgeInsets.only(right: index < 3 ? 2 : 0),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              color: blockBg,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Shift $shiftNumber',
                                        style: TextStyle(
                                          fontFamily: tokens.sansFont,
                                          fontSize: isCompact ? 10 : 11,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      if (isPeak && !isCompact) ...[
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: tokens.background.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Text(
                                            'PEAK',
                                            style: TextStyle(
                                              fontSize: 7,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  if (hasSales)
                                    Text(
                                      '${contribution.toStringAsFixed(1)}% (${DailySalesTelemetry.formatCurrency(record.salesAmount)})',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: tokens.sansFont,
                                        fontSize: isCompact ? 9 : 10,
                                        fontWeight: FontWeight.w600,
                                        color: textColor.withOpacity(0.9),
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    )
                                  else
                                    Text(
                                      record != null ? '\$0.00' : 'Unlogged',
                                      style: TextStyle(
                                        fontFamily: tokens.sansFont,
                                        fontSize: isCompact ? 9 : 10,
                                        color: textColor,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Time axis tick marks (00:00, 06:00, 12:00, 18:00, 24:00)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('00:00', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      Text('06:00', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      Text('12:00', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      Text('18:00', style: TextStyle(fontSize: 9, color: Colors.grey)),
                      Text('24:00', style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
