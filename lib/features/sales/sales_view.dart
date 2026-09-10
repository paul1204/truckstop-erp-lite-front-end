import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/data/api_catalog.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/models/sales_shift_data.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/widgets/sales_date_selector.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/widgets/sales_kpi_cards.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/widgets/shift_horizon_track.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/widgets/shift_reconciliation_ledger.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/widgets/shift_pacing_chart.dart';
import 'package:truck_stop_erp_lite_front_end/features/sales/widgets/sales_logistics_brief.dart';

class SalesView extends StatefulWidget {
  final StyleTokens tokens;

  const SalesView({super.key, required this.tokens});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  DailySalesTelemetry? _telemetry;

  @override
  void initState() {
    super.initState();
    _fetchSalesData();
  }

  String _formatQueryDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$month-$day-$year';
  }

  Future<void> _fetchSalesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dateStr = _formatQueryDate(_selectedDate);
    final stopwatch = Stopwatch()..start();

    try {
      final data = await ApiCatalog.getSalesByShift(dateStr);
      stopwatch.stop();

      setState(() {
        _telemetry = DailySalesTelemetry.fromApiData(
          date: _selectedDate,
          rawData: data,
          requestLatencyMs: stopwatch.elapsedMilliseconds,
        );
        _isLoading = false;
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _telemetry = null;
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _onDateSelected(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _fetchSalesData();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final dateStr = _formatQueryDate(_selectedDate);
    final telemetry = _telemetry;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Sales Operations',
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: tokens.textHeader,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: tokens.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: tokens.accent.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: tokens.accent,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Live Feed',
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: tokens.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(height: 4, width: 120, color: tokens.accent),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: tokens.accent),
                onPressed: _fetchSalesData,
                tooltip: 'Refresh Sales',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. Modular Date Selector Bar
          SalesDateSelector(
            selectedDate: _selectedDate,
            tokens: tokens,
            onDateSelected: _onDateSelected,
            onRefresh: _fetchSalesData,
          ),
          const SizedBox(height: 18),

          // 3. Main Content
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 80),
              child: Center(
                child: CircularProgressIndicator(color: tokens.accent),
              ),
            )
          else if (_errorMessage != null)
            _buildErrorState(tokens)
          else if (telemetry == null || telemetry.shifts.isEmpty)
            _buildEmptyState(tokens, dateStr)
          else ...[
            // 4. KPI Summary Cards (Total, Velocity, Peak, Concentration)
            SalesKpiCards(
              telemetry: telemetry,
              tokens: tokens,
            ),
            const SizedBox(height: 16),

            // 5. 24-Hour Shift Horizon Ribbon
            ShiftHorizonTrack(
              telemetry: telemetry,
              tokens: tokens,
            ),
            const SizedBox(height: 16),

            // 6. Split Pane: Reconciliation Ledger (Left) + Performance Pacing (Right)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 860;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: ShiftReconciliationLedger(
                          telemetry: telemetry,
                          tokens: tokens,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: ShiftPacingChart(
                          telemetry: telemetry,
                          tokens: tokens,
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    ShiftReconciliationLedger(
                      telemetry: telemetry,
                      tokens: tokens,
                    ),
                    const SizedBox(height: 16),
                    ShiftPacingChart(
                      telemetry: telemetry,
                      tokens: tokens,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // 7. Operational Logistics Brief + API Telemetry Button
            SalesLogisticsBrief(
              telemetry: telemetry,
              dateString: dateStr,
              tokens: tokens,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(StyleTokens tokens) {
    return Container(
      width: double.infinity,
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: tokens.accentSecondary),
          const SizedBox(height: 16),
          Text(
            'Endpoint Retrieval Failed',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tokens.textHeader,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 13,
              color: tokens.textMain.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchSalesData,
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.accent,
              foregroundColor: tokens.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(StyleTokens tokens, String dateStr) {
    return Container(
      width: double.infinity,
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(Icons.query_stats, size: 48, color: tokens.textMain.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No Shifts Recorded',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tokens.textHeader,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no shift sales reported for $dateStr in the system.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 13,
              color: tokens.textMain.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
