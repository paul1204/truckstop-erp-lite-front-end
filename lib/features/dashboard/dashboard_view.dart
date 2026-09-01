import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/dashboard/dashboard_notifier.dart';
import 'package:self_improvement_app/features/dashboard/dashboard_styles.dart';

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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

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
                  _buildTodaySalesBox(context, styles),
                  const SizedBox(height: 20),

                  if (isWide) ...[
                    // Row 1: Facility Overview (Flex 8) and System Status (Flex 4)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 8,
                          child: _buildFacilityOverview(styles),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: _buildSystemStatus(styles),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Row 2: Recent Incidents (Flex 6) and Current Shift (Flex 6)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildRecentIncidents(styles),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 6,
                          child: _buildCurrentShift(styles),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Stack vertically for mobile/narrow screens
                    _buildFacilityOverview(styles),
                    const SizedBox(height: 20),
                    _buildSystemStatus(styles),
                    const SizedBox(height: 20),
                    _buildRecentIncidents(styles),
                    const SizedBox(height: 20),
                    _buildCurrentShift(styles),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTodaySalesBox(BuildContext context, DashboardStyles styles) {
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

  // Facility Overview Card ( spns 8 )
  Widget _buildFacilityOverview(DashboardStyles styles) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Facility Overview', style: styles.cardTitleStyle),
          const SizedBox(height: 20),
          // Metric Items Layout
          LayoutBuilder(
            builder: (context, constraints) {
              final double spacing = 16.0;
              final double cardWidth = (constraints.maxWidth - spacing * 4) / 5;
              final useWrap = cardWidth < 100; // Too small, wrap to rows

              if (useWrap) {
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: notifier.metrics.map((m) => _buildMetricItem(m, styles)).toList(),
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: notifier.metrics.map((m) {
                  return Expanded(child: _buildMetricItem(m, styles));
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(DashboardMetric metric, DashboardStyles styles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(metric.label.toUpperCase(), style: styles.metricLabelStyle),
        const SizedBox(height: 4),
        Text(
          metric.value,
          style: styles.metricValueStyle.copyWith(
            color: metric.isUrgent ? tokens.accentSecondary : tokens.accent,
          ),
        ),
      ],
    );
  }

  // System Status Card ( spns 4 )
  Widget _buildSystemStatus(DashboardStyles styles) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Status', style: styles.cardTitleStyle),
          const SizedBox(height: 16),
          Column(
            children: notifier.systemStatuses.map((sys) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: tokens.border, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: styles.statusColor(sys['status']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(sys['name'], style: styles.itemTitleStyle),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tokens.border.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        sys['tag'],
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 10,
                          color: tokens.textMain.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Recent Operational Events Card ( spns 6 )
  Widget _buildRecentIncidents(DashboardStyles styles) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent Incidents', style: styles.cardTitleStyle),
          const SizedBox(height: 16),
          Column(
            children: notifier.incidents.map((inc) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: tokens.border, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inc.title, style: styles.itemTitleStyle),
                        const SizedBox(height: 2),
                        Text(inc.sub, style: styles.itemSubStyle),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: inc.isNew
                            ? tokens.accentSecondary.withOpacity(0.1)
                            : tokens.border.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        inc.tag,
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 10,
                          color: inc.isNew ? tokens.accentSecondary : tokens.textMain.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Shift Schedule Card ( spns 6 )
  Widget _buildCurrentShift(DashboardStyles styles) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Shift', style: styles.cardTitleStyle),
          const SizedBox(height: 16),
          Column(
            children: notifier.shiftStaff.map((staff) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: tokens.border, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(staff.name, style: styles.itemTitleStyle),
                        const SizedBox(height: 2),
                        Text(staff.role, style: styles.itemSubStyle),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: tokens.border.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        staff.status,
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 10,
                          color: tokens.textMain.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
