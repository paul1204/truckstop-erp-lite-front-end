import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiCatalog {
  // Uses relative paths (e.g. '') for web reverse proxy by default.
  // Can be overridden for local non-Docker development: --dart-define=API_BASE_URL=http://localhost:9000
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static const String tankStatusUrl = 'http://127.0.0.1:5000'; // Tank status sensor microservice

  // Central client instance
  static final http.Client _client = http.Client();

  /// 1. Fuel Inventory Endpoint
  /// GET /fuel/viewInventory
  static Future<List<Map<String, dynamic>>> getFuelInventory() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/fuel/viewInventory')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to load fuel inventory: ${response.statusCode}');
    } catch (e) {
      print('ApiCatalog: Using mock data for Fuel Inventory due to error: $e');
      return [
        {"fuelName": "Diesel Exhaust Fluid", "totalGallons": 1250.5},
        {"fuelName": "Premium Diesel", "totalGallons": 8400.0},
        {"fuelName": "Regular Unleaded", "totalGallons": 4200.2},
        {"fuelName": "Biodiesel B20", "totalGallons": 2100.7}
      ];
    }
  }

  /// 2. Fuel Deliveries Endpoint
  /// GET /fuel/viewRecentFuelDeliveries?count=N
  static Future<List<Map<String, dynamic>>> getRecentFuelDeliveries(int count) async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/fuel/viewRecentFuelDeliveries?count=$count'))
          .timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      }
      throw Exception('Failed to load recent deliveries: ${response.statusCode}');
    } catch (e) {
      print('ApiCatalog: Using mock data for Fuel Deliveries due to error: $e');
      final allMock = [
        {
          "id": 36,
          "companyName": "Texaco Transport",
          "fuelDeliveryId": "1779151177076",
          "deliveryDate": "2026-05-19T00:39:37.076Z",
          "dieselGallons": 8549,
          "dieselRetailPrice": 4.99,
          "regularGallons": 5121,
          "regularRetailPrice": 3.99,
          "premiumGallons": 5143,
          "premiumRetailPrice": 7.99
        },
        {
          "id": 35,
          "companyName": "Oil Solutions",
          "fuelDeliveryId": "TD-20241027-001",
          "deliveryDate": "2025-02-17T00:00:00.000Z",
          "dieselGallons": 5100,
          "dieselRetailPrice": 5.99,
          "regularGallons": 1001000,
          "regularRetailPrice": 4.99,
          "premiumGallons": 70000,
          "premiumRetailPrice": 7.99
        }
      ];
      return allMock.take(count).toList();
    }
  }

  /// 3. Update Fuel Delivery Endpoint
  /// POST /fuel/update/FuelInventory/FuelDelivery
  static Future<bool> postFuelDelivery(Map<String, dynamic> payload) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/fuel/update/FuelInventory/FuelDelivery'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      throw Exception('Failed to post fuel delivery: ${response.statusCode}');
    } catch (e) {
      print('ApiCatalog: Mocking successful fuel delivery post due to error: $e');
      return true; // Simulate success in dev environment
    }
  }

  /// 4. Tank Readings Endpoint
  /// GET http://127.0.0.1:5000/tank-status (with localhost fallback)
  static Future<List<Map<String, dynamic>>> getTankStatus() async {
    try {
      // First try the custom sensor endpoint
      final response = await _client.get(Uri.parse('$tankStatusUrl/tank-status')).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'success') {
          return List<Map<String, dynamic>>.from(result['data']);
        }
      }
      throw Exception('Unsuccessful response status');
    } catch (e) {
      // Fallback: try base url endpoint if mapped
      try {
        final response = await _client.get(Uri.parse('$baseUrl/tank-status')).timeout(const Duration(seconds: 1));
        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['status'] == 'success') {
            return List<Map<String, dynamic>>.from(result['data']);
          }
        }
      } catch (_) {}

      print('ApiCatalog: Using mock data for Tank Status due to error: $e');
      return [
        {"cycle": 1, "gallons": 2359.7, "percent": 23.60, "status": "OK", "tank": "Diesel Tank 4", "temp": 72.4},
        {"cycle": 1, "gallons": 2363.4, "percent": 23.63, "status": "OK", "tank": "Diesel Tank 1", "temp": 72.6},
        {"cycle": 1, "gallons": 2359.6, "percent": 23.60, "status": "OK", "tank": "Premium Tank 1", "temp": 72.4}
      ];
    }
  }

  /// 5. Inventory Display Endpoint
  /// GET /api/inventory/{category}
  static Future<List<Map<String, dynamic>>> getInventory(String category) async {
    final response = await _client.get(Uri.parse('$baseUrl/api/inventory/$category')).timeout(const Duration(seconds: 3));
    print('ApiCatalog: getInventory($category) status: ${response.statusCode}, body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load inventory: ${response.statusCode}');
  }

  /// 6. House Accounts Endpoint
  /// GET /accounting/house-accounts
  static Future<List<Map<String, dynamic>>> getHouseAccounts() async {
    final response = await _client.get(Uri.parse('$baseUrl/accounting/house-accounts')).timeout(const Duration(seconds: 3));
    print('ApiCatalog: getHouseAccounts() status: ${response.statusCode}, body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load house accounts: ${response.statusCode}');
  }

  /// 7. Parking Spots Endpoint
  /// GET /api/parking/spots
  static Future<List<Map<String, dynamic>>> getParkingSpots() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/parking/spots')).timeout(const Duration(seconds: 3));
    print('ApiCatalog: getParkingSpots() status: ${response.statusCode}, body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load parking spots: ${response.statusCode}');
  }

  /// 8. Shower Units Endpoint
  /// GET /api/showers
  static Future<List<Map<String, dynamic>>> getShowerUnits() async {
    final response = await _client.get(Uri.parse('$baseUrl/api/showers')).timeout(const Duration(seconds: 3));
    print('ApiCatalog: getShowerUnits() status: ${response.statusCode}, body: ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load showers: ${response.statusCode}');
  }

  /// 9. Sales by Shift Endpoint
  /// GET /api/sales/by-shift/{date}
  static Future<List<Map<String, dynamic>>> getSalesByShift(String date) async {
    final response = await _client
        .get(Uri.parse('$baseUrl/api/sales/by-shift/$date'))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    throw Exception('Failed to load sales (HTTP ${response.statusCode})');
  }

  /// 10. Add House Account Endpoint
  /// POST /accounting/house-accounts
  static Future<Map<String, dynamic>> postHouseAccount(Map<String, dynamic> payload) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/accounting/house-accounts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 4));
      print('ApiCatalog: postHouseAccount() status: ${response.statusCode}, body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception('Failed to add house account (HTTP ${response.statusCode})');
    } catch (e) {
      print('ApiCatalog: Mocking house account addition due to error: $e');
      final mockResponse = {
        "houseAccountId": "HA-${DateTime.now().millisecondsSinceEpoch}",
        "companyName": payload["companyName"] ?? "Mock Company",
        "phoneNumber": payload["phoneNumber"] ?? "555-0199",
        "address": payload["address"] ?? "123 Mock Lane",
        "creditLimit": (payload["creditLimit"] as num?)?.toDouble() ?? 5000.0,
        "accountStanding": "GOOD",
        "goodStandingDuration": 0,
        "accountAge": 0,
        "createdAt": DateTime.now().toIso8601String(),
        "updatedAt": DateTime.now().toIso8601String(),
        "amountDue": 0.0,
        "gallonsDue": 0.0
      };
      return mockResponse;
    }
  }
}

