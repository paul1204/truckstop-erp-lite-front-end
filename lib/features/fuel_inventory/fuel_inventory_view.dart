import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/fuel_inventory_notifier.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/models/fuel_telemetry_aggregator.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/widgets/fuel_kpi_strip.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/widgets/ust_tanks_section.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/widgets/post_fuel_delivery_card.dart';
import 'package:truck_stop_erp_lite_front_end/features/fuel_inventory/widgets/recent_deliveries_table.dart';

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
  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;

    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        if (widget.notifier.loading) {
          return Center(
            child: CircularProgressIndicator(color: tokens.accent),
          );
        }

        final telemetry = FuelTelemetryAggregator.fromNotifier(
          widget.notifier,
          dieselColor: tokens.accent,
          regColor: const Color(0xFF2E6B55),
          premColor: tokens.accentSecondary,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Page Header & Gateway Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Fuel Inventory & IoT Telemetry',
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: tokens.textHeader,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(height: 4, width: 140, color: tokens.accent),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: tokens.accent),
                    onPressed: () => widget.notifier.loadAllData(),
                    tooltip: 'Refresh Fuel Inventory',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. Top KPI Summary Strip
              FuelKpiStrip(
                telemetry: telemetry,
                tokens: tokens,
              ),
              const SizedBox(height: 18),

              // 3. Underground Storage Tanks (UST) Section with ATG Reconciliation (No Ladders!)
              UstTanksSection(
                telemetry: telemetry,
                tokens: tokens,
              ),
              const SizedBox(height: 18),

              // 4. Swapped Bottom Section: Form on Left (40%), Deliveries on Right (60%)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 950;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: PostFuelDeliveryCard(
                            key: const ValueKey('post_fuel_delivery_card_v4'),
                            notifier: widget.notifier,
                            tokens: tokens,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 6,
                          child: RecentDeliveriesTable(
                            notifier: widget.notifier,
                            tokens: tokens,
                          ),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      PostFuelDeliveryCard(
                        key: const ValueKey('post_fuel_delivery_card_v4'),
                        notifier: widget.notifier,
                        tokens: tokens,
                      ),
                      const SizedBox(height: 16),
                      RecentDeliveriesTable(
                        notifier: widget.notifier,
                        tokens: tokens,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
