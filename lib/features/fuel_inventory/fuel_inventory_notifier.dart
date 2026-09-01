import 'package:flutter/material.dart';
import 'package:self_improvement_app/data/api_catalog.dart';

class FuelItem {
  final String fuelName;
  final double totalGallons;

  FuelItem({required this.fuelName, required this.totalGallons});

  factory FuelItem.fromJson(Map<String, dynamic> json) {
    return FuelItem(
      fuelName: json['fuelName'] as String? ?? '',
      totalGallons: (json['totalGallons'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TankStatus {
  final String tank;
  final double gallons;
  final double percent;
  final String status;
  final double temp;
  final int cycle;

  TankStatus({
    required this.tank,
    required this.gallons,
    required this.percent,
    required this.status,
    required this.temp,
    required this.cycle,
  });

  factory TankStatus.fromJson(Map<String, dynamic> json) {
    return TankStatus(
      tank: json['tank'] as String? ?? '',
      gallons: (json['gallons'] as num?)?.toDouble() ?? 0.0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      cycle: (json['cycle'] as num?)?.toInt() ?? 0,
    );
  }
}

class FuelDelivery {
  final int id;
  final String companyName;
  final String fuelDeliveryId;
  final String deliveryDate;
  final double dieselGallons;
  double dieselRetailPrice;
  final double regularGallons;
  double regularRetailPrice;
  final double premiumGallons;
  double premiumRetailPrice;

  FuelDelivery({
    required this.id,
    required this.companyName,
    required this.fuelDeliveryId,
    required this.deliveryDate,
    required this.dieselGallons,
    required this.dieselRetailPrice,
    required this.regularGallons,
    required this.regularRetailPrice,
    required this.premiumGallons,
    required this.premiumRetailPrice,
  });

  factory FuelDelivery.fromJson(Map<String, dynamic> json) {
    return FuelDelivery(
      id: (json['id'] as num?)?.toInt() ?? 0,
      companyName: json['companyName'] as String? ?? '',
      fuelDeliveryId: json['fuelDeliveryId'] as String? ?? '',
      deliveryDate: json['deliveryDate'] as String? ?? '',
      dieselGallons: (json['dieselGallons'] as num?)?.toDouble() ?? 0.0,
      dieselRetailPrice: (json['dieselRetailPrice'] as num?)?.toDouble() ?? 0.0,
      regularGallons: (json['regularGallons'] as num?)?.toDouble() ?? 0.0,
      regularRetailPrice: (json['regularRetailPrice'] as num?)?.toDouble() ?? 0.0,
      premiumGallons: (json['premiumGallons'] as num?)?.toDouble() ?? 0.0,
      premiumRetailPrice: (json['premiumRetailPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class FuelInventoryNotifier extends ChangeNotifier {
  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  List<FuelItem> _inventory = [];
  List<FuelItem> get inventory => _inventory;

  List<TankStatus> _tanks = [];
  List<TankStatus> get tanks => _tanks;
  bool _tankLoading = false;
  bool get tankLoading => _tankLoading;

  List<FuelDelivery> _deliveries = [];
  List<FuelDelivery> get deliveries => _deliveries;
  bool _deliveryLoading = false;
  bool get deliveryLoading => _deliveryLoading;
  int _deliveryCount = 5;
  int get deliveryCount => _deliveryCount;

  FuelInventoryNotifier() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    _loading = true;
    _error = null;
    notifyListeners();

    await fetchInventory();
    await fetchTankStatus();
    await fetchDeliveries(_deliveryCount);

    _loading = false;
    notifyListeners();
  }

  Future<void> fetchInventory() async {
    try {
      final raw = await ApiCatalog.getFuelInventory();
      _inventory = raw.map((json) => FuelItem.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> fetchTankStatus() async {
    _tankLoading = true;
    notifyListeners();
    try {
      final raw = await ApiCatalog.getTankStatus();
      _tanks = raw.map((json) => TankStatus.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching tank status: $e');
    } finally {
      _tankLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDeliveries(int count) async {
    _deliveryLoading = true;
    _deliveryCount = count;
    notifyListeners();
    try {
      final raw = await ApiCatalog.getRecentFuelDeliveries(count);
      _deliveries = raw.map((json) => FuelDelivery.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching deliveries: $e');
    } finally {
      _deliveryLoading = false;
      notifyListeners();
    }
  }

  void updateDeliveryPrice(int id, String field, double newPrice) {
    final index = _deliveries.indexWhere((d) => d.id == id);
    if (index != -1) {
      if (field == 'dieselRetailPrice') {
        _deliveries[index].dieselRetailPrice = newPrice;
      } else if (field == 'regularRetailPrice') {
        _deliveries[index].regularRetailPrice = newPrice;
      } else if (field == 'premiumRetailPrice') {
        _deliveries[index].premiumRetailPrice = newPrice;
      }
      notifyListeners();
    }
  }

  Future<bool> postDelivery(
    String company,
    String deliveryId,
    String date,
    Map<String, Map<String, double>> orders,
  ) async {
    final Map<String, dynamic> payload = {
      "companyName": company,
      "fuelDeliveryId": deliveryId,
      "deliveryDate": date,
    };

    orders.forEach((fuelName, valueMap) {
      final key = fuelName.toLowerCase().contains('diesel') ? 'dieselOrder' : 
                  fuelName.toLowerCase().contains('regular') ? 'regularOctaneOrder' :
                  fuelName.toLowerCase().contains('premium') ? 'premiumOctaneOrder' : 
                  '${fuelName.replaceAll(" ", "")}Order';
      
      payload[key] = {
        "octane": fuelName.toLowerCase().contains('regular') ? 87 : 
                  fuelName.toLowerCase().contains('premium') ? 93 : 0,
        "pricePerGallon": valueMap['price'] ?? 0.0,
        "totalGallons": valueMap['gallons'] ?? 0.0,
      };
    });

    final success = await ApiCatalog.postFuelDelivery(payload);
    if (success) {
      // Reload lists
      await fetchInventory();
      await fetchDeliveries(_deliveryCount);
    }
    return success;
  }
}
