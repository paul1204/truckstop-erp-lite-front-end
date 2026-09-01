import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/data/api_catalog.dart';

class SalesView extends StatefulWidget {
  final StyleTokens tokens;

  const SalesView({super.key, required this.tokens});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>> _shiftSales = [];
  String? _errorMessage;

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

  String _formatFriendlyDate(DateTime date) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  Future<void> _fetchSalesData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final dateStr = _formatQueryDate(_selectedDate);
    try {
      final data = await ApiCatalog.getSalesByShift(dateStr);
      
      // Sort shifts numerically by shift number
      final sortedData = List<Map<String, dynamic>>.from(data);
      sortedData.sort((a, b) {
        final int aShift = (a['shiftNumber'] as num?)?.toInt() ?? 0;
        final int bShift = (b['shiftNumber'] as num?)?.toInt() ?? 0;
        return aShift.compareTo(bShift);
      });

      setState(() {
        _shiftSales = sortedData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _shiftSales = [];
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
        _isLoading = false;
      });
    }
  }

  void _adjustDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _fetchSalesData();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: widget.tokens.accent,
              brightness: widget.tokens.brightness,
              primary: widget.tokens.accent,
              onPrimary: widget.tokens.background,
              surface: widget.tokens.cardBg,
              onSurface: widget.tokens.textHeader,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchSalesData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    // Calculate aggregations
    double totalSales = 0.0;
    double maxShiftSales = 0.0;
    int highestShiftNum = 0;

    for (var shift in _shiftSales) {
      final amount = (shift['salesAmount'] as num?)?.toDouble() ?? 0.0;
      final shiftNum = (shift['shiftNumber'] as num?)?.toInt() ?? 0;
      totalSales += amount;
      if (amount > maxShiftSales) {
        maxShiftSales = amount;
        highestShiftNum = shiftNum;
      }
    }

    final avgSales = _shiftSales.isNotEmpty ? totalSales / _shiftSales.length : 0.0;

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
                  Text(
                    'Sales Operations',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: tokens.textHeader,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(height: 4, width: 100, color: tokens.accent),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: tokens.accent),
                onPressed: _fetchSalesData,
                tooltip: 'Refresh Sales',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Premium Date Selector Bar
          Container(
            decoration: tokens.cardDecoration(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left, color: tokens.accent),
                  onPressed: () => _adjustDate(-1),
                  tooltip: 'Previous Day',
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 16, color: tokens.accent),
                          const SizedBox(width: 10),
                          Text(
                            _formatFriendlyDate(_selectedDate),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tokens.textHeader,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right, color: tokens.accent),
                  onPressed: () => _adjustDate(1),
                  tooltip: 'Next Day',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Main Content Area (Handles Loading and Error States)
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: Center(
                child: CircularProgressIndicator(color: tokens.accent),
              ),
            )
          else if (_errorMessage != null)
            _buildErrorState(tokens)
          else if (_shiftSales.isEmpty)
            _buildEmptyState(tokens)
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shift list and metrics (Flex 7)
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildAggregationsRow(tokens, totalSales, avgSales, maxShiftSales, highestShiftNum),
                            const SizedBox(height: 20),
                            _buildShiftDetailsList(tokens, totalSales, maxShiftSales),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Graphical Comparison Card (Flex 5)
                      Expanded(
                        flex: 5,
                        child: _buildVisualComparisonCard(tokens, maxShiftSales),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAggregationsGrid(tokens, totalSales, avgSales, maxShiftSales, highestShiftNum),
                      const SizedBox(height: 20),
                      _buildVisualComparisonCard(tokens, maxShiftSales),
                      const SizedBox(height: 20),
                      _buildShiftDetailsList(tokens, totalSales, maxShiftSales),
                    ],
                  );
                }
              },
            ),
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

  Widget _buildEmptyState(StyleTokens tokens) {
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
            'No Sales Logged',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: tokens.textHeader,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no shift sales reported for this date in the system.',
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

  Widget _buildAggregationsRow(StyleTokens tokens, double total, double avg, double max, int highestShift) {
    return Row(
      children: [
        Expanded(child: _buildMetricCard(tokens, 'TOTAL SALES', '\$${total.toStringAsFixed(2)}', tokens.accent)),
        const SizedBox(width: 12),
        Expanded(child: _buildMetricCard(tokens, 'SHIFT AVERAGE', '\$${avg.toStringAsFixed(2)}', tokens.textMain)),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            tokens,
            'PEAK SHIFT',
            max > 0 ? 'Shift $highestShift' : 'N/A',
            tokens.accentSecondary,
            subtitle: max > 0 ? '\$${max.toStringAsFixed(2)}' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildAggregationsGrid(StyleTokens tokens, double total, double avg, double max, int highestShift) {
    return Column(
      children: [
        _buildMetricCard(tokens, 'TOTAL SALES', '\$${total.toStringAsFixed(2)}', tokens.accent),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(tokens, 'SHIFT AVERAGE', '\$${avg.toStringAsFixed(2)}', tokens.textMain)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                tokens,
                'PEAK SHIFT',
                max > 0 ? 'Shift $highestShift' : 'N/A',
                tokens.accentSecondary,
                subtitle: max > 0 ? '\$${max.toStringAsFixed(2)}' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(StyleTokens tokens, String label, String value, Color accentColor, {String? subtitle}) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: tokens.textMain.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: tokens.sansFont,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: tokens.textMain.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftDetailsList(StyleTokens tokens, double totalSales, double maxSales) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHIFT BREAKDOWN',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _shiftSales.length,
            separatorBuilder: (context, index) => Divider(color: tokens.border, height: 1),
            itemBuilder: (context, index) {
              final shift = _shiftSales[index];
              final num amount = shift['salesAmount'] ?? 0.0;
              final int shiftNum = shift['shiftNumber'] ?? 0;
              
              final percentTotal = totalSales > 0 ? (amount / totalSales) * 100 : 0.0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: tokens.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: tokens.accent.withOpacity(0.3)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$shiftNum',
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: tokens.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Shift $shiftNum',
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: tokens.textHeader,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${percentTotal.toStringAsFixed(1)}% of today\'s total',
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 11,
                              color: tokens.textMain.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tokens.textHeader,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVisualComparisonCard(StyleTokens tokens, double maxSales) {
    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISUAL PERFORMANCE',
            style: TextStyle(
              fontFamily: tokens.sansFont,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: tokens.accent,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Render beautiful graphical bars
          ..._shiftSales.map((shift) {
            final double amount = (shift['salesAmount'] as num?)?.toDouble() ?? 0.0;
            final int shiftNum = (shift['shiftNumber'] as num?)?.toInt() ?? 0;
            
            // Normalize width relative to peak shift
            final double progress = maxSales > 0 ? (amount / maxSales) : 0.0;
            final isPeak = amount == maxSales && maxSales > 0;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Shift $shiftNum',
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: tokens.textHeader,
                            ),
                          ),
                          if (isPeak) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '\$${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: tokens.textHeader,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: tokens.border.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.02, 1.0), // ensure minimal visible width if > 0
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isPeak 
                                ? [tokens.accentSecondary, tokens.accentSecondary.withOpacity(0.7)]
                                : [tokens.accent, tokens.accent.withOpacity(0.7)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
