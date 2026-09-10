class ShiftSalesRecord {
  final int shiftNumber;
  final double salesAmount;

  const ShiftSalesRecord({
    required this.shiftNumber,
    required this.salesAmount,
  });

  factory ShiftSalesRecord.fromJson(Map<String, dynamic> json) {
    return ShiftSalesRecord(
      shiftNumber: (json['shiftNumber'] as num?)?.toInt() ?? 0,
      salesAmount: (json['salesAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get timeWindow {
    switch (shiftNumber) {
      case 1:
        return '00:00 - 06:00';
      case 2:
        return '06:00 - 12:00';
      case 3:
        return '12:00 - 18:00';
      case 4:
        return '18:00 - 24:00';
      default:
        return 'Shift $shiftNumber Window';
    }
  }

  String get operationalRole {
    switch (shiftNumber) {
      case 1:
        return 'Overnight Long-Haul Fleet';
      case 2:
        return 'Morning Commuter & Retail';
      case 3:
        return 'Midday Freight & Rest';
      case 4:
        return 'Evening Inbound Transit';
      default:
        return 'Operational Shift $shiftNumber';
    }
  }
}

class DailySalesTelemetry {
  final DateTime date;
  final List<ShiftSalesRecord> shifts;
  final int requestLatencyMs;
  final List<Map<String, dynamic>> rawJson;

  DailySalesTelemetry({
    required this.date,
    required this.shifts,
    this.requestLatencyMs = 0,
    this.rawJson = const [],
  });

  factory DailySalesTelemetry.fromApiData({
    required DateTime date,
    required List<Map<String, dynamic>> rawData,
    int requestLatencyMs = 0,
  }) {
    final parsed = rawData.map(ShiftSalesRecord.fromJson).toList();
    parsed.sort((a, b) => a.shiftNumber.compareTo(b.shiftNumber));

    return DailySalesTelemetry(
      date: date,
      shifts: parsed,
      requestLatencyMs: requestLatencyMs,
      rawJson: rawData,
    );
  }

  double get totalSales => shifts.fold(0.0, (sum, s) => sum + s.salesAmount);

  double get averageShiftSales => shifts.isNotEmpty ? totalSales / shifts.length : 0.0;

  // Real-time sales velocity ($ / hour) based on 6 hours per recorded shift
  double get salesVelocity => shifts.isNotEmpty ? totalSales / (shifts.length * 6.0) : 0.0;

  ShiftSalesRecord? get peakShift {
    if (shifts.isEmpty) return null;
    ShiftSalesRecord peak = shifts.first;
    for (final s in shifts) {
      if (s.salesAmount > peak.salesAmount) {
        peak = s;
      }
    }
    return peak;
  }

  double get peakConcentrationPercent {
    if (totalSales <= 0 || peakShift == null) return 0.0;
    return (peakShift!.salesAmount / totalSales) * 100;
  }

  double shiftContributionPercent(double amount) {
    if (totalSales <= 0) return 0.0;
    return (amount / totalSales) * 100;
  }

  static String formatCurrency(double value) {
    final isNegative = value < 0;
    final absVal = value.abs();
    final parts = absVal.toStringAsFixed(2).split('.');
    final whole = parts[0];
    final cents = parts[1];

    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedWhole = whole.replaceAllMapped(regExp, (Match m) => '${m[1]},');

    return '${isNegative ? '-' : ''}\$$formattedWhole.$cents';
  }
}
