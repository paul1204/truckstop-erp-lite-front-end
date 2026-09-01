import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/fuel_inventory/fuel_inventory_notifier.dart';
import 'package:self_improvement_app/features/fuel_inventory/fuel_inventory_styles.dart';

class FuelDeliveryGrid extends StatefulWidget {
  final FuelInventoryNotifier notifier;
  final StyleTokens tokens;

  const FuelDeliveryGrid({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<FuelDeliveryGrid> createState() => _FuelDeliveryGridState();
}

class _FuelDeliveryGridState extends State<FuelDeliveryGrid> {
  final TextEditingController _recordsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _recordsController.text = widget.notifier.deliveryCount.toString();
  }

  @override
  void dispose() {
    _recordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styles = FuelInventoryStyles(widget.tokens);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table Controls Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Fuel Deliveries', style: styles.formTitleStyle),
            Row(
              children: [
                Text('Records: ', style: styles.valueStyle),
                const SizedBox(width: 4),
                SizedBox(
                  width: 50,
                  height: 32,
                  child: TextField(
                    controller: _recordsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: styles.valueStyle,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.tokens.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.tokens.accent),
                      ),
                    ),
                    onSubmitted: (val) {
                      final count = int.tryParse(val) ?? 5;
                      widget.notifier.fetchDeliveries(count);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: widget.notifier.deliveryLoading
                      ? null
                      : () {
                          final count = int.tryParse(_recordsController.text) ?? 5;
                          widget.notifier.fetchDeliveries(count);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.tokens.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    widget.notifier.deliveryLoading ? 'Refreshing...' : 'Refresh',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: widget.tokens.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth - 2, // Account for border width to prevent false scrolling
                  ),
                  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.all(widget.tokens.border.withOpacity(0.2)),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Company')),
                      DataColumn(label: Text('Delivery ID')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Diesel (gal)')),
                      DataColumn(label: Text('Diesel Price')),
                      DataColumn(label: Text('Regular (gal)')),
                      DataColumn(label: Text('Regular Price')),
                      DataColumn(label: Text('Premium (gal)')),
                      DataColumn(label: Text('Premium Price')),
                    ],
                    rows: widget.notifier.deliveries.map((delivery) {
                      final formattedDate = DateTime.tryParse(delivery.deliveryDate) != null
                          ? DateTime.parse(delivery.deliveryDate).toLocal().toString().substring(0, 10)
                          : delivery.deliveryDate;

                      return DataRow(
                        cells: [
                          DataCell(Text(delivery.id.toString())),
                          DataCell(Text(delivery.companyName)),
                          DataCell(Text(delivery.fuelDeliveryId)),
                          DataCell(Text(formattedDate)),
                          DataCell(Text(delivery.dieselGallons.toStringAsFixed(0))),
                          DataCell(_buildPriceInputCell(delivery.id, 'dieselRetailPrice', delivery.dieselRetailPrice)),
                          DataCell(Text(delivery.regularGallons.toStringAsFixed(0))),
                          DataCell(_buildPriceInputCell(delivery.id, 'regularRetailPrice', delivery.regularRetailPrice)),
                          DataCell(Text(delivery.premiumGallons.toStringAsFixed(0))),
                          DataCell(_buildPriceInputCell(delivery.id, 'premiumRetailPrice', delivery.premiumRetailPrice)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceInputCell(int id, String field, double value) {
    return Container(
      width: 60,
      height: 32,
      alignment: Alignment.center,
      child: Focus(
        onFocusChange: (hasFocus) {
          // Can save on focus lost/blur
        },
        child: TextFormField(
          initialValue: value.toStringAsFixed(2),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: widget.tokens.monoFont,
            fontSize: 13,
            color: widget.tokens.textMain,
          ),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            border: InputBorder.none,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.teal),
            ),
          ),
          onFieldSubmitted: (newVal) {
            final doublePrice = double.tryParse(newVal) ?? 0.0;
            widget.notifier.updateDeliveryPrice(id, field, doublePrice);
          },
        ),
      ),
    );
  }
}
