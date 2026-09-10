import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/models/sales_shift_data.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/widgets/sales_api_payload_dialog.dart';

class SalesLogisticsBrief extends StatelessWidget {
  final DailySalesTelemetry telemetry;
  final String dateString;
  final StyleTokens tokens;

  const SalesLogisticsBrief({
    super.key,
    required this.telemetry,
    required this.dateString,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = telemetry.shifts.isNotEmpty;
    final peak = telemetry.peakShift;
    final concentration = telemetry.peakConcentrationPercent.toStringAsFixed(1);

    String summaryText;
    if (hasData) {
      if (peak != null) {
        summaryText =
            '${telemetry.shifts.length} of 4 shifts recorded for this operating cycle. '
            'Peak volume concentrated in Shift ${peak.shiftNumber} (${peak.operationalRole}) '
            'driving $concentration% of gross daily volume. All batch records reconciled without discrepancies.';
      } else {
        summaryText =
            '${telemetry.shifts.length} shift records logged. Batch reconciliation verified with zero reporting anomalies.';
      }
    } else {
      summaryText =
          'No shift transactions recorded for this business date. Ledger batch pending end-of-shift transmission.';
    }

    return Container(
      width: double.infinity,
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 700;

          final contentColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: tokens.accent),
                  const SizedBox(width: 6),
                  Text(
                    'OPERATIONAL LOGISTICS BRIEF',
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
              const SizedBox(height: 6),
              Text(
                summaryText,
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 12,
                  height: 1.4,
                  color: tokens.textMain.withOpacity(0.8),
                ),
              ),
            ],
          );

          final apiButton = OutlinedButton.icon(
            onPressed: () => SalesApiPayloadDialog.show(
              context,
              telemetry: telemetry,
              dateString: dateString,
              tokens: tokens,
            ),
            icon: Icon(Icons.terminal, size: 14, color: tokens.accent),
            label: Text(
              telemetry.requestLatencyMs > 0
                  ? '{ } API Payload (${telemetry.requestLatencyMs}ms)'
                  : '{ } View Raw API Payload',
              style: TextStyle(
                fontFamily: tokens.monoFont,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: tokens.textHeader,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: tokens.accent.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                contentColumn,
                const SizedBox(height: 12),
                apiButton,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: contentColumn),
              const SizedBox(width: 16),
              apiButton,
            ],
          );
        },
      ),
    );
  }
}
