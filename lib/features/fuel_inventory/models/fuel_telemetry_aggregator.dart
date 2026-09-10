import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/fuel_inventory_notifier.dart';

class TankTelemetryPair {
  final String gradeName;
  final String gradeSubtitle;
  final String gradeKey;
  final double bookGallons;
  final double? physicalGallons;
  final double? probeTempF;
  final int? probeCycle;
  final String? probeStatus;
  final double? probePercent;
  final Color fluidColor;
  final String? lastDeliveryDate;

  const TankTelemetryPair({
    required this.gradeName,
    required this.gradeSubtitle,
    required this.gradeKey,
    required this.bookGallons,
    this.physicalGallons,
    this.probeTempF,
    this.probeCycle,
    this.probeStatus,
    this.probePercent,
    required this.fluidColor,
    this.lastDeliveryDate,
  });

  double get displayGallons => physicalGallons ?? bookGallons;

  double get fillPercent => probePercent ?? (bookGallons > 0 ? 75.0 : 0.0);

  double? get varianceGallons => physicalGallons != null ? (physicalGallons! - bookGallons) : null;

  double? get variancePercent {
    if (varianceGallons == null) return null;
    if (bookGallons <= 0) return 0.0;
    return (varianceGallons! / bookGallons) * 100.0;
  }

  bool get isInTolerance => variancePercent != null ? variancePercent!.abs() <= 1.0 : true;
}

class FuelTelemetryAggregator {
  final List<TankTelemetryPair> tanks;
  final bool isIotActive;
  final double totalFuelOnHand;
  final double latestDropGallons;
  final String? latestDropBol;
  final String? latestDropDate;
  final int totalDeliveriesCount;

  FuelTelemetryAggregator({
    required this.tanks,
    required this.isIotActive,
    required this.totalFuelOnHand,
    required this.latestDropGallons,
    this.latestDropBol,
    this.latestDropDate,
    required this.totalDeliveriesCount,
  });

  factory FuelTelemetryAggregator.fromNotifier(
    FuelInventoryNotifier notifier, {
    required Color dieselColor,
    required Color regColor,
    required Color premColor,
  }) {
    // 1. Map inventory items by lower-case key
    final invMap = <String, double>{};
    for (final item in notifier.inventory) {
      final key = item.fuelName.toLowerCase().trim();
      invMap[key] = item.totalGallons;
    }

    // 2. Map IoT tanks by lower-case key
    final tankMap = <String, TankStatus>{};
    for (final tank in notifier.tanks) {
      final key = tank.tank.toLowerCase().trim();
      tankMap[key] = tank;
    }

    // Helper to find IoT tank
    TankStatus? findTank(String query) {
      for (final entry in tankMap.entries) {
        if (entry.key.contains(query)) return entry.value;
      }
      return null;
    }

    // Helper to find Book inventory gallons
    double findBook(String query) {
      for (final entry in invMap.entries) {
        if (entry.key.contains(query)) return entry.value;
      }
      return 0.0;
    }

    // Latest delivery date if available
    String? latestDeliveryDate;
    if (notifier.deliveries.isNotEmpty) {
      latestDeliveryDate = notifier.deliveries.first.deliveryDate;
    }

    // Diesel
    final dieselIoT = findTank('diesel');
    final dieselBook = findBook('diesel');
    final dieselPair = TankTelemetryPair(
      gradeName: 'Diesel #2',
      gradeSubtitle: 'Underground Tank 1',
      gradeKey: 'diesel',
      bookGallons: dieselBook,
      physicalGallons: dieselIoT?.gallons,
      probeTempF: dieselIoT?.temp,
      probeCycle: dieselIoT?.cycle,
      probeStatus: dieselIoT?.status,
      probePercent: dieselIoT?.percent,
      fluidColor: dieselColor,
      lastDeliveryDate: latestDeliveryDate,
    );

    // Regular Unleaded 87
    final regIoT = findTank('87') ?? findTank('regular');
    final regBook = findBook('87') != 0.0 ? findBook('87') : findBook('regular');
    final regPair = TankTelemetryPair(
      gradeName: 'Regular Unleaded (87)',
      gradeSubtitle: 'Underground Tank 2',
      gradeKey: '87',
      bookGallons: regBook,
      physicalGallons: regIoT?.gallons,
      probeTempF: regIoT?.temp,
      probeCycle: regIoT?.cycle,
      probeStatus: regIoT?.status,
      probePercent: regIoT?.percent,
      fluidColor: regColor,
      lastDeliveryDate: latestDeliveryDate,
    );

    // Premium Unleaded 93
    final premIoT = findTank('93') ?? findTank('premium');
    final premBook = findBook('93') != 0.0 ? findBook('93') : findBook('premium');
    final premPair = TankTelemetryPair(
      gradeName: 'Premium Unleaded (93)',
      gradeSubtitle: 'Underground Tank 3',
      gradeKey: '93',
      bookGallons: premBook,
      physicalGallons: premIoT?.gallons,
      probeTempF: premIoT?.temp,
      probeCycle: premIoT?.cycle,
      probeStatus: premIoT?.status,
      probePercent: premIoT?.percent,
      fluidColor: premColor,
      lastDeliveryDate: latestDeliveryDate,
    );

    final tanksList = [dieselPair, regPair, premPair];
    final iotActive = notifier.tanks.isNotEmpty;

    // Sum totals strictly from real API data
    double totalOnHand = 0.0;
    for (final t in tanksList) {
      totalOnHand += t.displayGallons;
    }

    // Latest delivery drop details strictly from GET /fuel/viewRecentFuelDeliveries
    double latestDropGals = 0.0;
    String? latestDropBol;
    String? latestDropDate;
    final totalDeliveriesCount = notifier.deliveries.length;

    if (notifier.deliveries.isNotEmpty) {
      final latest = notifier.deliveries.first;
      latestDropGals = latest.dieselGallons + latest.regularGallons + latest.premiumGallons;
      latestDropBol = latest.fuelDeliveryId;
      latestDropDate = latest.deliveryDate;
    }

    return FuelTelemetryAggregator(
      tanks: tanksList,
      isIotActive: iotActive,
      totalFuelOnHand: totalOnHand,
      latestDropGallons: latestDropGals,
      latestDropBol: latestDropBol,
      latestDropDate: latestDropDate,
      totalDeliveriesCount: totalDeliveriesCount,
    );
  }

  static String formatGallons(double value) {
    final isNegative = value < 0;
    final absVal = value.abs();
    final parts = absVal.toStringAsFixed(0).split('.');
    final whole = parts[0];

    final regExp = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedWhole = whole.replaceAllMapped(regExp, (Match m) => '${m[1]},');

    return '${isNegative ? '-' : ''}$formattedWhole GAL';
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
