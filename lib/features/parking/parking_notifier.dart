import 'package:flutter/material.dart';
import 'package:self_improvement_app/data/api_catalog.dart';

class ParkingSpot {
  final int id;
  final String spotNumber;
  final bool occupied;
  final String vehicleRegistration;
  final String rateType;
  final String occupiedSince;
  final String reservedUntil;
  final double totalCost;
  final String message;

  ParkingSpot({
    required this.id,
    required this.spotNumber,
    required this.occupied,
    required this.vehicleRegistration,
    required this.rateType,
    required this.occupiedSince,
    required this.reservedUntil,
    required this.totalCost,
    required this.message,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: (json['id'] as num).toInt(),
      spotNumber: json['spotNumber'] as String? ?? '',
      occupied: json['occupied'] as bool? ?? false,
      vehicleRegistration: json['vehicleRegistration'] as String? ?? '',
      rateType: json['rateType'] as String? ?? '',
      occupiedSince: json['occupiedSince'] as String? ?? '',
      reservedUntil: json['reservedUntil'] as String? ?? '',
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String? ?? '',
    );
  }
}

class ParkingNotifier extends ChangeNotifier {
  List<ParkingSpot> _spots = [];
  List<ParkingSpot> get spots => _spots;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  ParkingNotifier() {
    fetchSpots();
  }

  Future<void> fetchSpots() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await ApiCatalog.getParkingSpots();
      _spots = raw.map((json) => ParkingSpot.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
