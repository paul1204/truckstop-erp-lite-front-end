import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';

class SalesDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final StyleTokens tokens;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onRefresh;

  const SalesDateSelector({
    super.key,
    required this.selectedDate,
    required this.tokens,
    required this.onDateSelected,
    required this.onRefresh,
  });

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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: tokens.accent,
              brightness: tokens.brightness,
              primary: tokens.accent,
              onPrimary: tokens.background,
              surface: tokens.cardBg,
              onSurface: tokens.textHeader,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && !_isSameDay(picked, selectedDate)) {
      onDateSelected(picked);
    }
  }

  Widget _buildQuickPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? tokens.accent.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? tokens.accent : tokens.border.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: tokens.sansFont,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? tokens.accent : tokens.textMain,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday = _isSameDay(selectedDate, now);
    final isYesterday = _isSameDay(selectedDate, now.subtract(const Duration(days: 1)));
    final isTwoDaysAgo = _isSameDay(selectedDate, now.subtract(const Duration(days: 2)));

    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 650;

          final stepperWidget = Row(
            mainAxisSize: isCompact ? MainAxisSize.max : MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: tokens.accent, size: 20),
                onPressed: () => onDateSelected(selectedDate.subtract(const Duration(days: 1))),
                tooltip: 'Previous Day',
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                flex: isCompact ? 1 : 0,
                child: InkWell(
                  onTap: () => _pickDate(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 15, color: tokens.accent),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _formatFriendlyDate(selectedDate),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: tokens.textHeader,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: tokens.accent, size: 20),
                onPressed: () => onDateSelected(selectedDate.add(const Duration(days: 1))),
                tooltip: 'Next Day',
                visualDensity: VisualDensity.compact,
              ),
            ],
          );

          final quickPills = Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.end,
            children: [
              _buildQuickPill(
                label: 'Today',
                isSelected: isToday,
                onTap: () => onDateSelected(now),
              ),
              _buildQuickPill(
                label: 'Yesterday',
                isSelected: isYesterday,
                onTap: () => onDateSelected(now.subtract(const Duration(days: 1))),
              ),
              _buildQuickPill(
                label: '-2 Days',
                isSelected: isTwoDaysAgo,
                onTap: () => onDateSelected(now.subtract(const Duration(days: 2))),
              ),
              _buildQuickPill(
                label: 'Calendar 📅',
                isSelected: !isToday && !isYesterday && !isTwoDaysAgo,
                onTap: () => _pickDate(context),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                stepperWidget,
                const SizedBox(height: 10),
                Center(child: quickPills),
              ],
            );
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              stepperWidget,
              quickPills,
            ],
          );
        },
      ),
    );
  }
}
