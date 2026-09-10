import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/dashboard/dashboard_notifier.dart';
import 'package:truck_stop_erp_lite_front_end/features/dashboard/dashboard_styles.dart';

class DashboardView extends StatelessWidget {
  final DashboardNotifier notifier;
  final StyleTokens tokens;
  final VoidCallback? onViewSalesTap;

  const DashboardView({
    super.key,
    required this.notifier,
    required this.tokens,
    this.onViewSalesTap,
  });

  @override
  Widget build(BuildContext context) {
    final styles = DashboardStyles(tokens);

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        if (notifier.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: tokens.accent),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Daily Operations', style: styles.pageTitleStyle),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        width: 140,
                        color: tokens.accent,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: tokens.accent),
                    onPressed: () => notifier.refreshDashboard(),
                    tooltip: 'Refresh Dashboard',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTodaySalesBox(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTodaySalesBox(BuildContext context) {
    final hasError = notifier.salesError != null;
    final total = notifier.todaySalesTotal;
    final shiftsCount = notifier.todayShiftsCount;

    return Container(
      width: double.infinity,
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, boxConstraints) {
          if (hasError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '💰 TODAY\'S SALES',
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tokens.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tokens.accentSecondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ERROR',
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: tokens.accentSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  notifier.salesError!,
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: tokens.accentSecondary,
                  ),
                ),
              ],
            );
          }

          if (total == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Loading sales data...',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 14,
                    color: tokens.textMain.withOpacity(0.6),
                  ),
                ),
              ),
            );
          }

          // Helper to find a shift amount
          double? getAmountForShift(int shiftNum) {
            for (var item in notifier.rawSalesList) {
              if ((item['shiftNumber'] as num?)?.toInt() == shiftNum) {
                return (item['salesAmount'] as num?)?.toDouble();
              }
            }
            return null;
          }

          // Shift Box builder
          Widget buildShiftBox(int shiftNum) {
            final amount = getAmountForShift(shiftNum);
            final isReported = amount != null;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isReported ? tokens.accent.withOpacity(0.06) : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isReported ? tokens.accent.withOpacity(0.3) : tokens.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SHIFT $shiftNum',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isReported ? tokens.accent : tokens.textMain.withOpacity(0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isReported ? '\$${amount.toStringAsFixed(2)}' : '\$--',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isReported ? tokens.textHeader : tokens.textMain.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            );
          }

          final shiftsRow = Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: buildShiftBox(1)),
              const SizedBox(width: 8),
              Expanded(child: buildShiftBox(2)),
              const SizedBox(width: 8),
              Expanded(child: buildShiftBox(3)),
              const SizedBox(width: 8),
              Expanded(child: buildShiftBox(4)),
            ],
          );

          final totalColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '💰 TODAY\'S TOTAL SALES',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: tokens.accent,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: tokens.textHeader,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '($shiftsCount of 4 shifts reported)',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 11,
                  color: tokens.textMain.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );

          final button = (onViewSalesTap != null)
              ? ElevatedButton.icon(
                  onPressed: onViewSalesTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tokens.accent,
                    foregroundColor: tokens.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Text(
                    'View Shift Details',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  label: const Icon(Icons.arrow_forward, size: 16),
                )
              : null;

          final showWideLayout = boxConstraints.maxWidth > 900;

          if (showWideLayout) {
            return Row(
              children: [
                SizedBox(
                  width: 220,
                  child: totalColumn,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    width: 1,
                    height: 50,
                    color: tokens.border,
                  ),
                ),
                Expanded(
                  child: shiftsRow,
                ),
                if (button != null) ...[
                  const SizedBox(width: 24),
                  button,
                ],
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                totalColumn,
                const SizedBox(height: 16),
                shiftsRow,
                if (button != null) ...[
                  const SizedBox(height: 16),
                  button,
                ],
              ],
            );
          }
        },
      ),
    );
  }
}
