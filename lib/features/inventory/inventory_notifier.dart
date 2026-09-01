import 'package:flutter/material.dart';
import 'package:self_improvement_app/data/api_catalog.dart';

class ProductDelivery {
  final String deliveryDate;
  final int qtyOrdered;
  final double costPerUnit;
  final double retailPrice;

  ProductDelivery({
    required this.deliveryDate,
    required this.qtyOrdered,
    required this.costPerUnit,
    required this.retailPrice,
  });

  factory ProductDelivery.fromJson(Map<String, dynamic> json) {
    return ProductDelivery(
      deliveryDate: json['deliveryDate'] as String? ?? '',
      qtyOrdered: (json['qtyOrdered'] as num?)?.toInt() ?? 0,
      costPerUnit: (json['costPerUnit'] as num?)?.toDouble() ?? 0.0,
      retailPrice: (json['retailPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Product {
  final String skuCode;
  final String name;
  final double costOfGoods;
  final double retailPrice;
  final String brand;
  final int qty;
  final int maxCapacity;
  final String size;
  final String lastDeliveryDate;
  final List<ProductDelivery> deliveries;

  Product({
    required this.skuCode,
    required this.name,
    required this.costOfGoods,
    required this.retailPrice,
    required this.brand,
    required this.qty,
    required this.maxCapacity,
    required this.size,
    required this.lastDeliveryDate,
    required this.deliveries,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var rawDeliveries = json['deliveries'] as List<dynamic>? ?? [];
    return Product(
      skuCode: json['skuCode'] as String? ?? '',
      name: json['name'] as String? ?? '',
      costOfGoods: (json['costOfGoods'] as num?)?.toDouble() ?? 0.0,
      retailPrice: (json['retailPrice'] as num?)?.toDouble() ?? 0.0,
      brand: json['brand'] as String? ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 0,
      size: json['size'] as String? ?? '',
      lastDeliveryDate: json['lastDeliveryDate'] as String? ?? '',
      deliveries: rawDeliveries.map((d) => ProductDelivery.fromJson(d)).toList(),
    );
  }
}

class InventoryNotifier extends ChangeNotifier {
  String _category = 'packagedFood'; // 'packagedFood' or 'bottledBeverages'
  String get category => _category;

  String _animationType = 'Fade'; // 'Fade', 'Scale', 'Slide', 'Flip', 'Bounce'
  String get animationType => _animationType;

  List<Product> _products = [];
  List<Product> get products => _products;

  bool _loading = false;
  get loading => _loading;

  String? _error;
  String? get error => _error;

  InventoryNotifier() {
    fetchInventory();
  }

  void setCategory(String newCategory) {
    if (_category != newCategory) {
      _category = newCategory;
      fetchInventory();
    }
  }

  void setAnimationType(String newType) {
    if (_animationType != newType) {
      _animationType = newType;
      notifyListeners();
    }
  }

  Future<void> fetchInventory() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await ApiCatalog.getInventory(_category);
      _products = raw.map((json) => Product.fromJson(json)).toList();

      // Asynchronously pre-cache and pre-resolve all images in the background
      for (final product in _products) {
        final provider = ResizeImage(
          AssetImage('assets/Photos/inventory-photos/${product.skuCode}.png'),
          width: 600,
        );
        provider.resolve(ImageConfiguration.empty);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
