import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/data/api_catalog.dart';

class DashboardNotifier extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

    _isLoading = false;
    notifyListeners();
  }
}
