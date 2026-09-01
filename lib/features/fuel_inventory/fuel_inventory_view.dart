import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/fuel_inventory/fuel_inventory_notifier.dart';
import 'package:self_improvement_app/features/fuel_inventory/fuel_inventory_styles.dart';
import 'package:self_improvement_app/features/fuel_inventory/widgets/tank_gauge.dart';
import 'package:self_improvement_app/features/fuel_inventory/widgets/fuel_delivery_grid.dart';

class FuelInventoryView extends StatefulWidget {
  final FuelInventoryNotifier notifier;
  final StyleTokens tokens;

  const FuelInventoryView({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<FuelInventoryView> createState() => _FuelInventoryViewState();
}

class _FuelInventoryViewState extends State<FuelInventoryView> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _deliveryIdController = TextEditingController();
  final _dateController = TextEditingController();

  // Maps to store dynamic controller inputs for each fuel product
  final Map<String, TextEditingController> _gallonsControllers = {};
  final Map<String, TextEditingController> _priceControllers = {};

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toString().substring(0, 10);
  }

  @override
  void dispose() {
    _companyController.dispose();
    _deliveryIdController.dispose();
    _dateController.dispose();
    _gallonsControllers.values.forEach((c) => c.dispose());
    _priceControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  static const Map<String, String> _defaultGallons = {
    '93': '123',
    'Diesel': '345',
    '87': '1000',
  };

  static const Map<String, String> _defaultPrices = {
    '93': '2.59',
    'Diesel': '3.49',
    '87': '3.49',
  };

  void _initializeProductControllers() {
    for (var item in widget.notifier.inventory) {
      if (!_gallonsControllers.containsKey(item.fuelName)) {
        final defaultGal = _defaultGallons[item.fuelName] ?? '0.0';
        final defaultPrice = _defaultPrices[item.fuelName] ?? '0.0';
        _gallonsControllers[item.fuelName] = TextEditingController(text: defaultGal);
        _priceControllers[item.fuelName] = TextEditingController(text: defaultPrice);
      }
    }
  }

  void _submitDelivery(FuelInventoryStyles styles) async {
    if (_formKey.currentState!.validate()) {
      final orders = <String, Map<String, double>>{};
      for (var item in widget.notifier.inventory) {
        final gals = double.tryParse(_gallonsControllers[item.fuelName]?.text ?? '0') ?? 0.0;
        final prc = double.tryParse(_priceControllers[item.fuelName]?.text ?? '0') ?? 0.0;
        orders[item.fuelName] = {'gallons': gals, 'price': prc};
      }

      final success = await widget.notifier.postDelivery(
        _companyController.text,
        _deliveryIdController.text,
        _dateController.text,
        orders,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fuel delivery posted successfully!')),
        );
        // Reset form
        _companyController.clear();
        _deliveryIdController.clear();
        _dateController.text = DateTime.now().toString().substring(0, 10);
        _gallonsControllers.forEach((fuelName, c) => c.text = _defaultGallons[fuelName] ?? '0.0');
        _priceControllers.forEach((fuelName, c) => c.text = _defaultPrices[fuelName] ?? '0.0');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final styles = FuelInventoryStyles(widget.tokens);
    _initializeProductControllers();

    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        if (widget.notifier.loading) {
          return Center(child: CircularProgressIndicator(color: widget.tokens.accent));
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 950;

            final mainContentList = [
              // Tanks visual display grids
              _buildTanksSection(styles),
              const SizedBox(height: 28),
              // Recent Deliveries table
              FuelDeliveryGrid(notifier: widget.notifier, tokens: widget.tokens),
            ];

            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Grid Section (Tanks and Table)
                    Expanded(
                      flex: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: mainContentList,
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Side Panel (Post Delivery Form)
                    Expanded(
                      flex: 4,
                      child: _buildPostDeliveryForm(styles),
                    ),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...mainContentList,
                    const SizedBox(height: 28),
                    _buildPostDeliveryForm(styles),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildTanksSection(FuelInventoryStyles styles) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 600;

      // Calculate available width for the containers
      final containerWidth = isWide ? (constraints.maxWidth - 20) / 2 : constraints.maxWidth;
      final availableWidth = containerWidth - 32 - 10; // subtracting padding (32) and a 10px safety buffer for borders/subpixels

      // Current Inventory card width calculation
      final invCount = widget.notifier.inventory.isEmpty ? 1 : widget.notifier.inventory.length;
      final invCardWidth = ((availableWidth - (invCount - 1) * 12) / invCount).clamp(100.0, 170.0);

      // Actual Tank Readings card width calculation
      final tankCount = widget.notifier.tanks.isEmpty ? 1 : widget.notifier.tanks.length;
      final tankCardWidth = ((availableWidth - (tankCount - 1) * 12) / tankCount).clamp(100.0, 170.0);

      final currentInvGrid = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: widget.tokens.cardDecoration().copyWith(
          border: Border.all(color: widget.tokens.accent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Inventory', style: styles.labelStyle),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.notifier.inventory.map((item) {
                final percent = (item.totalGallons / 10000.0) * 100.0;
                final bool isCompact = invCardWidth < 145;
                return GestureDetector(
                  onTap: () => _showFuelDetailsDialog(item),
                  child: Container(
                    width: invCardWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 10 : 12,
                      vertical: 12,
                    ),
                    decoration: widget.tokens.cardDecoration(),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.fuelName,
                                style: styles.labelStyle.copyWith(fontSize: isCompact ? 11 : 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.totalGallons.toStringAsFixed(0)} gal',
                                style: styles.valueStyle.copyWith(fontSize: isCompact ? 11 : 12),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isCompact ? 6 : 8),
                        TankGauge(
                          percentage: percent,
                          tokens: widget.tokens,
                          width: isCompact ? 36 : 50,
                          height: isCompact ? 90 : 120,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );

      final sensorReadingsGrid = Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: widget.tokens.cardDecoration().copyWith(
          border: Border.all(color: widget.tokens.accent, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Actual Tank Readings', style: styles.labelStyle),
            const SizedBox(height: 12),
            if (widget.notifier.tankLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Loading sensor status...'),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.notifier.tanks.map((tank) {
                  final bool isCompact = tankCardWidth < 145;
                  return GestureDetector(
                    onTap: () => _showTankDetailsDialog(tank),
                    child: Container(
                      width: tankCardWidth,
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompact ? 10 : 12,
                        vertical: 12,
                      ),
                      decoration: widget.tokens.cardDecoration(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tank.tank,
                                  style: styles.labelStyle.copyWith(fontSize: isCompact ? 11 : 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${tank.gallons.toStringAsFixed(0)} gal',
                                  style: styles.valueStyle.copyWith(fontSize: isCompact ? 10 : 11),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Temp: ${tank.temp.toStringAsFixed(1)}°F\nStatus: ${tank.status}',
                                  style: styles.infoTextStyle.copyWith(fontSize: isCompact ? 9 : 11),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: isCompact ? 6 : 8),
                          TankGauge(
                            percentage: tank.percent,
                            tokens: widget.tokens,
                            width: isCompact ? 36 : 50,
                            height: isCompact ? 90 : 120,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      );

      if (isWide) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: currentInvGrid),
            const SizedBox(width: 20),
            Expanded(child: sensorReadingsGrid),
          ],
        );
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            currentInvGrid,
            const SizedBox(height: 20),
            sensorReadingsGrid,
          ],
        );
      }
    });
  }

  Widget _buildPostDeliveryForm(FuelInventoryStyles styles) {
    return Container(
      decoration: widget.tokens.cardDecoration(),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Post Fuel Delivery', style: styles.formTitleStyle),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(labelText: 'Company Name'),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _deliveryIdController,
                    decoration: const InputDecoration(labelText: 'Delivery ID'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            // Product Specific Fields
            Column(
              children: widget.notifier.inventory.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.fuelName, style: styles.labelStyle.copyWith(fontSize: 13)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _gallonsControllers[item.fuelName],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                labelText: 'Gallons',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _priceControllers[item.fuelName],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                isDense: true,
                                labelText: 'Price/Gal',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => _submitDelivery(styles),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.tokens.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Post Fuel Delivery'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Details Modal Dialog for Fuel Inventory Item
  void _showFuelDetailsDialog(FuelItem item) {
    final styles = FuelInventoryStyles(widget.tokens);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final percent = (item.totalGallons / 10000.0) * 100.0;
        return AlertDialog(
          title: Text(item.fuelName, style: styles.formTitleStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current quantity details for ${item.fuelName} stored on-site.',
                style: styles.valueStyle,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL VOLUME', style: styles.labelStyle.copyWith(fontSize: 10)),
                      Text('${item.totalGallons.toStringAsFixed(1)} Gal', style: styles.titleStyle.copyWith(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('CAPACITY USED', style: styles.labelStyle.copyWith(fontSize: 10)),
                      Text('${percent.toStringAsFixed(1)}%', style: styles.titleStyle.copyWith(fontSize: 18)),
                    ],
                  ),
                  TankGauge(percentage: percent, tokens: widget.tokens),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: widget.tokens.accent)),
            )
          ],
        );
      },
    );
  }

  // Details Modal Dialog for Actual Tank sensor reading
  void _showTankDetailsDialog(TankStatus tank) {
    final styles = FuelInventoryStyles(widget.tokens);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tank.tank, style: styles.formTitleStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Live diagnostic readings recorded from physical tank telemetry.',
                style: styles.valueStyle,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TELEMETRY GALLONS', style: styles.labelStyle.copyWith(fontSize: 10)),
                      Text('${tank.gallons.toStringAsFixed(1)} Gal', style: styles.titleStyle.copyWith(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('TEMPERATURE', style: styles.labelStyle.copyWith(fontSize: 10)),
                      Text('${tank.temp.toStringAsFixed(1)}°F', style: styles.titleStyle.copyWith(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('SENSOR STATUS', style: styles.labelStyle.copyWith(fontSize: 10)),
                      Text(tank.status, style: styles.titleStyle.copyWith(fontSize: 16, color: styles.tankColor(tank.percent))),
                    ],
                  ),
                  TankGauge(percentage: tank.percent, tokens: widget.tokens),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: widget.tokens.accent)),
            )
          ],
        );
      },
    );
  }
}
