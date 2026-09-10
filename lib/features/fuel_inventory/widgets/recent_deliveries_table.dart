import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/fuel_inventory_notifier.dart';

class RecentDeliveriesTable extends StatefulWidget {
  final FuelInventoryNotifier notifier;
  final StyleTokens tokens;

  const RecentDeliveriesTable({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<RecentDeliveriesTable> createState() => _RecentDeliveriesTableState();
}

class _RecentDeliveriesTableState extends State<RecentDeliveriesTable> {
  int _selectedCount = 5;

  @override
  void initState() {
    super.initState();
    _selectedCount = widget.notifier.deliveryCount;
  }

  Widget _buildTableHeaderCell(String text, {TextAlign align = TextAlign.left, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontFamily: widget.tokens.sansFont,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: widget.tokens.textMain.withOpacity(0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {TextAlign align = TextAlign.left, int flex = 1, bool isMono = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: isMono ? widget.tokens.monoFont : widget.tokens.sansFont,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: widget.tokens.textHeader,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final deliveries = widget.notifier.deliveries;
    final isLoading = widget.notifier.deliveryLoading;

    return Container(
      decoration: tokens.cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Records dropdown & Refresh
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Fuel Deliveries',
                style: TextStyle(
                  fontFamily: tokens.sansFont,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: tokens.textHeader,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Records: ',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 11,
                      color: tokens.textMain.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: tokens.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: tokens.border.withOpacity(0.5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedCount,
                        isDense: true,
                        icon: Icon(Icons.keyboard_arrow_down, size: 14, color: tokens.accent),
                        style: TextStyle(
                          fontFamily: tokens.sansFont,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: tokens.textHeader,
                        ),
                        items: [5, 10, 15, 20].map((int count) {
                          return DropdownMenuItem<int>(
                            value: count,
                            child: Text('$count'),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null && newVal != _selectedCount) {
                            setState(() => _selectedCount = newVal);
                            widget.notifier.fetchDeliveries(newVal);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : () => widget.notifier.fetchDeliveries(_selectedCount),
                    icon: Icon(Icons.refresh, size: 13, color: tokens.accent),
                    label: Text(
                      isLoading ? 'Syncing...' : 'Refresh',
                      style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: tokens.textHeader,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      side: BorderSide(color: tokens.accent.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            decoration: BoxDecoration(
              color: tokens.background.withOpacity(0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                _buildTableHeaderCell('ID', flex: 2),
                _buildTableHeaderCell('COMPANY', flex: 4),
                _buildTableHeaderCell('DELIVERY ID', flex: 3),
                _buildTableHeaderCell('DATE', flex: 3),
                _buildTableHeaderCell('DIESEL (GAL)', align: TextAlign.right, flex: 3),
                _buildTableHeaderCell('REGULAR (GAL)', align: TextAlign.right, flex: 3),
                _buildTableHeaderCell('PREMIUM (GAL)', align: TextAlign.right, flex: 3),
                _buildTableHeaderCell('STATUS', align: TextAlign.center, flex: 3),
              ],
            ),
          ),
          Divider(color: tokens.border.withOpacity(0.4), height: 1),

          // Table Rows
          if (deliveries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No recent delivery manifests recorded.',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: tokens.textMain.withOpacity(0.6),
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: deliveries.length,
              separatorBuilder: (context, index) => Divider(
                color: tokens.border.withOpacity(0.25),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final d = deliveries[index];
                final dieselStr = d.dieselGallons > 0 ? d.dieselGallons.toStringAsFixed(0) : '0';
                final regStr = d.regularGallons > 0 ? d.regularGallons.toStringAsFixed(0) : '0';
                final premStr = d.premiumGallons > 0 ? d.premiumGallons.toStringAsFixed(0) : '0';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      _buildTableCell('${d.id}', flex: 2, isMono: true),
                      _buildTableCell(d.companyName, flex: 4),
                      _buildTableCell(d.fuelDeliveryId, flex: 3, isMono: true),
                      _buildTableCell(d.deliveryDate, flex: 3),
                      _buildTableCell(dieselStr, align: TextAlign.right, flex: 3),
                      _buildTableCell(regStr, align: TextAlign.right, flex: 3),
                      _buildTableCell(premStr, align: TextAlign.right, flex: 3),
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: Colors.teal.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Reconciled',
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
