import 'package:flutter/material.dart';
import 'package:self_improvement_app/data/api_catalog.dart';

class ShowerUnit {
  final int id;
  final String showerNumber;
  final bool occupied;
  final bool cleaning;
  final String customerName;
  final String? occupiedSince;
  final String? reservedUntil;
  final String? cleaningUntil;
  final double totalCost;
  final String message;

  ShowerUnit({
    required this.id,
    required this.showerNumber,
    required this.occupied,
    required this.cleaning,
    required this.customerName,
    this.occupiedSince,
    this.reservedUntil,
    this.cleaningUntil,
    required this.totalCost,
    required this.message,
  });

  factory ShowerUnit.fromJson(Map<String, dynamic> json) {
    return ShowerUnit(
      id: (json['id'] as num).toInt(),
      showerNumber: json['showerNumber'] as String,
      occupied: json['occupied'] as bool,
      cleaning: json['cleaning'] as bool,
      customerName: json['customerName'] as String? ?? '',
      occupiedSince: json['occupiedSince'] as String?,
      reservedUntil: json['reservedUntil'] as String?,
      cleaningUntil: json['cleaningUntil'] as String?,
      totalCost: (json['totalCost'] as num).toDouble(),
      message: json['message'] as String? ?? '',
    );
  }
}

class ShowersNotifier extends ChangeNotifier {
  List<ShowerUnit> _showers = [];
  List<ShowerUnit> get showers => _showers;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ShowersNotifier() {
    fetchShowers();
  }

  Future<void> fetchShowers() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await ApiCatalog.getShowerUnits();
      _showers = raw.map((json) => ShowerUnit.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
