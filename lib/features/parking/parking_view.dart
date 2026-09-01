import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/parking/parking_notifier.dart';
import 'package:self_improvement_app/features/parking/parking_styles.dart';
import 'package:self_improvement_app/ui/core/offline_error_widget.dart';

class ParkingView extends StatelessWidget {
  final ParkingNotifier notifier;
  final StyleTokens tokens;

  const ParkingView({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final styles = ParkingStyles(tokens);

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Parking Spots', style: styles.titleStyle),
                  const SizedBox(height: 4),
                  Container(height: 4, width: 100, color: tokens.accent),
                ],
              ),
              const SizedBox(height: 24),

              if (notifier.loading)
                Center(child: CircularProgressIndicator(color: tokens.accent))
              else if (notifier.error != null)
                OfflineErrorWidget(
                  tokens: tokens,
                  error: notifier.error!,
                  onRetry: notifier.fetchSpots,
                )
              else
                _buildParkingGrid(context, styles),
            ],
          ),
        );
      },
    );
  }

  Widget _buildParkingGrid(BuildContext context, ParkingStyles styles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1100) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 500) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
          ),
          itemCount: notifier.spots.length,
          itemBuilder: (context, index) {
            final spot = notifier.spots[index];
            return _buildSpotCard(context, spot, styles);
          },
        );
      },
    );
  }

  Widget _buildSpotCard(BuildContext context, ParkingSpot spot, ParkingStyles styles) {
    final badgeColor = styles.getOccupiedColor(spot.occupied);

    return InkWell(
      onTap: () => _showSpotDetailsDialog(context, spot, styles),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: tokens.cardDecoration(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    spot.occupied ? 'Occupied' : 'Available',
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),

            // Spot Number & Registration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spot ${spot.spotNumber}', style: styles.spotNumberStyle),
                Text(
                  spot.occupied ? spot.vehicleRegistration : 'No Vehicle',
                  style: TextStyle(
                    fontFamily: tokens.sansFont,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: spot.occupied ? tokens.textHeader : tokens.textMain.withOpacity(0.4),
                  ),
                ),
              ],
            ),

            // Rate and Cost metrics
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rate Type', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text(spot.rateType.isEmpty ? 'N/A' : spot.rateType, style: styles.valueStyle),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Cost', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text('\$${spot.totalCost.toStringAsFixed(2)}', style: styles.valueStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSpotDetailsDialog(BuildContext context, ParkingSpot spot, ParkingStyles styles) {
    final badgeColor = styles.getOccupiedColor(spot.occupied);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final formattedSince = spot.occupiedSince.isNotEmpty
            ? DateTime.tryParse(spot.occupiedSince) != null
                ? DateTime.parse(spot.occupiedSince).toLocal().toString().substring(0, 16)
                : spot.occupiedSince
            : 'N/A';

        final formattedUntil = spot.reservedUntil.isNotEmpty
            ? DateTime.tryParse(spot.reservedUntil) != null
                ? DateTime.parse(spot.reservedUntil).toLocal().toString().substring(0, 16)
                : spot.reservedUntil
            : 'N/A';

        return AlertDialog(
          title: Text('Spot Details: ${spot.spotNumber}', style: styles.spotNumberStyle.copyWith(fontSize: 20)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Status & Vehicle'),
                  _buildDetailRowWidget(
                    'Status',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        spot.occupied ? 'Occupied' : 'Available',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                    ),
                  ),
                  _buildDetailRow('Registration', spot.occupied ? spot.vehicleRegistration : 'N/A'),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Time & Billing'),
                  _buildDetailRow('Occupied Since', formattedSince),
                  _buildDetailRow('Reserved Until', formattedUntil),
                  _buildDetailRow('Rate Type', spot.rateType.isEmpty ? 'N/A' : spot.rateType),
                  _buildDetailRow('Total Cost', '\$${spot.totalCost.toStringAsFixed(2)}'),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Notes'),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      spot.message.isNotEmpty ? spot.message : 'No additional information.',
                      style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, color: tokens.textMain),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: tokens.accent)),
            )
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: tokens.sansFont,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: tokens.accent,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, color: tokens.textMain.withOpacity(0.6))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, fontWeight: FontWeight.w600, color: tokens.textHeader),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWidget(String label, Widget widgetValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: tokens.sansFont, fontSize: 13, color: tokens.textMain.withOpacity(0.6))),
          widgetValue,
        ],
      ),
    );
  }
}
