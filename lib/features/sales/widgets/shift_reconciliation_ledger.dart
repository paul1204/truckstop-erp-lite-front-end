import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/models/sales_shift_data.dart';

class ShiftReconciliationLedger extends StatelessWidget {
  final DailySalesTelemetry telemetry;
  final StyleTokens tokens;

  const ShiftReconciliationLedger({
    super.key,
    required this.telemetry,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final shifts = telemetry.shifts;
    final total = telemetry.totalSales;

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
                'SHIFT RECONCILIATION LEDGER',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: tokens.accent,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 11, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text(
                      'BATCH AUDITED',
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Table column headers
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  child: Text(
                    'SHIFT',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tokens.textMain.withOpacity(0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Text(
                    'OPERATIONAL WINDOW',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tokens.textMain.withOpacity(0.5),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'CONTRIBUTION',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tokens.textMain.withOpacity(0.5),
                    ),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    'GROSS REVENUE',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: tokens.textMain.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: tokens.border.withOpacity(0.5), height: 1),

          // Shift rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: shifts.length,
            separatorBuilder: (context, index) => Divider(
              color: tokens.border.withOpacity(0.3),
              height: 1,
            ),
            itemBuilder: (context, index) {
              final shift = shifts[index];
              final share = telemetry.shiftContributionPercent(shift.salesAmount);
              final isPeak = shift.shiftNumber == telemetry.peakShift?.shiftNumber;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    // Shift number avatar
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isPeak
                            ? tokens.accentSecondary.withOpacity(0.12)
                            : tokens.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isPeak
                              ? tokens.accentSecondary.withOpacity(0.4)
                              : tokens.accent.withOpacity(0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${shift.shiftNumber}',
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isPeak ? tokens.accentSecondary : tokens.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Operational Window & Role
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shift.timeWindow,
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tokens.textHeader,
                            ),
                          ),
                          Text(
                            shift.operationalRole,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 10,
                              color: tokens.textMain.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contribution sparkbar + %
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${share.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isPeak ? tokens.accentSecondary : tokens.textHeader,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(height: 3),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: total > 0 ? (shift.salesAmount / total).clamp(0.0, 1.0) : 0.0,
                                minHeight: 4,
                                backgroundColor: tokens.border.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isPeak ? tokens.accentSecondary : tokens.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Gross Sales Amount
                    SizedBox(
                      width: 110,
                      child: Text(
                        DailySalesTelemetry.formatCurrency(shift.salesAmount),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: tokens.textHeader,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          Divider(color: tokens.border, height: 1),

          // Total Reconciliation Footer
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL RECONCILED',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: tokens.accent,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  DailySalesTelemetry.formatCurrency(total),
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: tokens.accent,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
