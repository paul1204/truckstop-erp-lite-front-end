import 'package:flutter/material.dart';
import 'package:self_improvement_app/data/api_catalog.dart';

class DashboardMetric {
  final String label;
  final String value;
  final bool isUrgent;

  DashboardMetric({required this.label, required this.value, this.isUrgent = false});
}

class DashboardIncident {
  final String title;
  final String sub;
  final String tag;
  final bool isNew;

  DashboardIncident({required this.title, required this.sub, required this.tag, this.isNew = false});
}

class ShiftStaff {
  final String name;
  final String role;
  final String status;

  ShiftStaff({required this.name, required this.role, required this.status});
}

class DashboardNotifier extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DashboardMetric> _metrics = [];
  List<DashboardMetric> get metrics => _metrics;

  List<Map<String, dynamic>> _systemStatuses = [];
  List<Map<String, dynamic>> get systemStatuses => _systemStatuses;

  List<DashboardIncident> _incidents = [];
  List<DashboardIncident> get incidents => _incidents;

  List<ShiftStaff> _shiftStaff = [];
  List<ShiftStaff> get shiftStaff => _shiftStaff;

  double? _todaySalesTotal;
  double? get todaySalesTotal => _todaySalesTotal;

  int _todayShiftsCount = 0;
  int get todayShiftsCount => _todayShiftsCount;

  List<Map<String, dynamic>> _rawSalesList = [];
  List<Map<String, dynamic>> get rawSalesList => _rawSalesList;

  String? _salesError;
  String? get salesError => _salesError;

  DashboardNotifier() {
    refreshDashboard();
  }

  String _getTodayDateString() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final year = now.year.toString();
    return '$month-$day-$year';
  }

  Future<void> refreshDashboard() async {
    _isLoading = true;
    notifyListeners();

    // Fetch today's sales
    final todayStr = _getTodayDateString();
    try {
      final rawSales = await ApiCatalog.getSalesByShift(todayStr);
      double sum = 0.0;
      for (var item in rawSales) {
        sum += (item['salesAmount'] as num).toDouble();
      }
      _todaySalesTotal = sum;
      _todayShiftsCount = rawSales.length;
      _rawSalesList = rawSales;
      _salesError = null;
    } catch (e) {
      _todaySalesTotal = null;
      _todayShiftsCount = 0;
      _rawSalesList = [];
      _salesError = e.toString().replaceAll('Exception:', '').trim();
    }

    _metrics = [
      DashboardMetric(label: "Diesel Inventory", value: "8,400 gal"),
      DashboardMetric(label: "Unleaded", value: "4,200 gal"),
      DashboardMetric(label: "DEF", value: "1,250 gal"),
      DashboardMetric(
        label: "Today's Sales",
        value: _todaySalesTotal != null
            ? "\$${_todaySalesTotal!.toStringAsFixed(2)}"
            : (_salesError != null ? "Error" : "Loading..."),
        isUrgent: _salesError != null,
      ),
      DashboardMetric(label: "Staff on Shift", value: "6"),
    ];

    _systemStatuses = [
      {"name": "POS Systems", "status": "online", "tag": "Operational"},
      {"name": "Fuel Monitors", "status": "online", "tag": "Operational"},
      {"name": "HVAC Unit 2", "status": "alert", "tag": "Fault Detected"},
    ];

    _incidents = [
      DashboardIncident(title: "Pump 4 Slow Flow", sub: "Reported 20m ago • Maintenance Req.", tag: "New", isNew: true),
      DashboardIncident(title: "Counter Spill (Store)", sub: "Resolved 1h ago • Cleared by J. Doe", tag: "Closed"),
    ];

    _shiftStaff = [
      ShiftStaff(name: "Sarah Miller", role: "Supervisor • 08:00 - 16:00", status: "On Duty"),
      ShiftStaff(name: "Mike Ross", role: "Attendant • 14:00 - 22:00", status: "Incoming"),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
