import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/models/sales_shift_data.dart';

class SalesApiPayloadDialog extends StatelessWidget {
  final DailySalesTelemetry telemetry;
  final String dateString;
  final StyleTokens tokens;

  const SalesApiPayloadDialog({
    super.key,
    required this.telemetry,
    required this.dateString,
    required this.tokens,
  });

  static void show(
    BuildContext context, {
    required DailySalesTelemetry telemetry,
    required String dateString,
    required StyleTokens tokens,
  }) {
    showDialog(
      context: context,
      builder: (context) => SalesApiPayloadDialog(
        telemetry: telemetry,
        dateString: dateString,
        tokens: tokens,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const encoder = JsonEncoder.withIndent('  ');
    final formattedJson = encoder.convert(telemetry.rawJson);

    return Dialog(
      backgroundColor: tokens.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: tokens.border),
      ),
      child: Container(
        width: 650,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.code, color: tokens.accent, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'API Contract & Telemetry Inspector',
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tokens.textHeader,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: tokens.textMain),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Endpoint & metadata bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: tokens.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: tokens.border.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: tokens.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      'GET',
                      style: TextStyle(
                        fontFamily: tokens.monoFont,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: tokens.accent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '/api/sales/by-shift/$dateString',
                      style: TextStyle(
                        fontFamily: tokens.monoFont,
                        fontSize: 11,
                        color: tokens.textHeader,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '200 OK',
                      style: TextStyle(
                        fontFamily: tokens.monoFont,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                  if (telemetry.requestLatencyMs > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${telemetry.requestLatencyMs}ms',
                      style: TextStyle(
                        fontFamily: tokens.monoFont,
                        fontSize: 10,
                        color: tokens.textMain.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              'RAW JSON RESPONSE BODY (${telemetry.shifts.length} records)',
              style: TextStyle(
                fontFamily: tokens.sansFont,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: tokens.textMain.withOpacity(0.6),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),

            // Monospace code block container
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tokens.background,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: tokens.border.withOpacity(0.4)),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    formattedJson.isNotEmpty ? formattedJson : '[]',
                    style: TextStyle(
                      fontFamily: tokens.monoFont,
                      fontSize: 12,
                      color: tokens.textHeader,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: formattedJson));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('API payload copied to clipboard'),
                        backgroundColor: tokens.accent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Copy JSON'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: tokens.textHeader,
                    side: BorderSide(color: tokens.border),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.background,
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
