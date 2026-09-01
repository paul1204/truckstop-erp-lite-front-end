import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/parking/parking_notifier.dart';
import 'package:self_improvement_app/features/parking/parking_styles.dart';
import 'package:self_improvement_app/ui/core/offline_error_widget.dart';
import 'package:self_improvement_app/features/parking/widgets/top_down_truck_widget.dart';
import 'package:self_improvement_app/ui/core/background_effects.dart';

class ParkingViewV2 extends StatefulWidget {
  final ParkingNotifier notifier;
  final StyleTokens tokens;

  const ParkingViewV2({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<ParkingViewV2> createState() => _ParkingViewV2State();
}

class _ParkingViewV2State extends State<ParkingViewV2> {
  bool _showMap = true; // Default to the visual Yard Map View

  @override
  Widget build(BuildContext context) {
    final styles = ParkingStyles(widget.tokens);

    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row with Toggle Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Parking Spots V2', style: styles.titleStyle),
                      const SizedBox(height: 4),
                      Container(height: 4, width: 100, color: widget.tokens.accent),
                    ],
                  ),
                  
                  // View Toggle Button
                  ToggleButtons(
                    isSelected: [_showMap, !_showMap],
                    onPressed: (index) {
                      setState(() {
                        _showMap = index == 0;
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    borderWidth: 1.5,
                    borderColor: widget.tokens.border,
                    selectedBorderColor: widget.tokens.accent,
                    selectedColor: Colors.white,
                    fillColor: widget.tokens.accent,
                    color: widget.tokens.textMain,
                    constraints: const BoxConstraints(minHeight: 32, minWidth: 80),
                    children: const [
                      Text('Yard Map', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('List Grid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (widget.notifier.loading)
                Center(child: CircularProgressIndicator(color: widget.tokens.accent))
              else if (widget.notifier.error != null)
                OfflineErrorWidget(
                  tokens: widget.tokens,
                  error: widget.notifier.error!,
                  onRetry: widget.notifier.fetchSpots,
                )
              else
                _showMap
                    ? _buildYardMapView(context, styles)
                    : _buildParkingGrid(context, styles),
            ],
          ),
        );
      },
    );
  }

  // --- Redesigned Visual Yard Map Layout ---
  Widget _buildYardMapView(BuildContext context, ParkingStyles styles) {
    final int totalSpots = widget.notifier.spots.length;
    if (totalSpots == 0) {
      return Center(
        child: Text(
          'No parking spots available.',
          style: TextStyle(fontFamily: widget.tokens.sansFont, color: widget.tokens.textMain),
        ),
      );
    }

    // Split the list of parking spots dynamically into two rows/lanes
    final int halfCount = (totalSpots / 2).ceil();
    final List<ParkingSpot> topSpots = widget.notifier.spots.take(halfCount).toList();
    final List<ParkingSpot> bottomSpots = widget.notifier.spots.skip(halfCount).toList();

    final bool isDark = widget.tokens.brightness == Brightness.dark;
    final Color asphaltColor = isDark
        ? const Color(0xFF232323) // Dark asphalt
        : const Color(0xFFE5E2DA); // Light concrete gravel

    final Color dotColor = isDark
        ? Colors.white
        : widget.tokens.stippleColor;

    final double dotOpacity = isDark ? 0.12 : 0.45;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double lotWidth = math.max(constraints.maxWidth, 1000.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: lotWidth,
            height: 480,
            decoration: BoxDecoration(
              color: asphaltColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.tokens.border.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: widget.tokens.shadowColor.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
            // 1. Asphalt Grid texture overlay
            Positioned.fill(
              child: Opacity(
                opacity: dotOpacity,
                child: CustomPaint(
                  painter: StippleGridPainter(
                    dotColor: dotColor,
                  ),
                ),
              ),
            ),

            // 2. Grassy Island on the left (analogous to the photo)
            Positioned(
              left: 20,
              top: 50,
              bottom: 50,
              width: 120,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32), // Rich grass green
                  borderRadius: BorderRadius.circular(60),
                  border: Border.all(color: const Color(0xFF1B5E20), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: 35,
                      child: Text('🌲', style: TextStyle(fontSize: 28)),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 45,
                      child: Text('🌳', style: TextStyle(fontSize: 24)),
                    ),
                    Positioned(
                      top: 170,
                      left: 30,
                      child: Text('🌲', style: TextStyle(fontSize: 26)),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Central Driveway / Driving Lane Arrows
            Positioned(
              left: 170,
              right: 40,
              top: 220,
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRoadArrow(),
                  _buildRoadArrow(),
                  _buildRoadArrow(),
                ],
              ),
            ),

            // 4. Top Parking Lane (Spots 1-8) - Angled 45 degrees
            Positioned(
              left: 170,
              right: 40,
              top: 20,
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: topSpots
                    .map((spot) => _buildParkingSlot(context, spot, true, styles))
                    .toList(),
              ),
            ),

            // 5. Bottom Parking Lane (Spots 9-16) - Angled -45 degrees
            Positioned(
              left: 170,
              right: 40,
              bottom: 20,
              height: 180,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: bottomSpots
                    .map((spot) => _buildParkingSlot(context, spot, false, styles))
                    .toList(),
              ),
            ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildRoadArrow() {
    final bool isDark = widget.tokens.brightness == Brightness.dark;
    return Opacity(
      opacity: 0.15,
      child: Text(
        '➡',
        style: TextStyle(
          color: isDark ? Colors.white : widget.tokens.textMain,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildParkingSlot(
    BuildContext context,
    ParkingSpot spot,
    bool isTopRow,
    ParkingStyles styles,
  ) {
    final bool isDark = widget.tokens.brightness == Brightness.dark;
    final double angle = isTopRow ? (math.pi / 4) : (-math.pi / 4);

    final Color linePaintColor = isDark
        ? const Color(0xFFFFCA28).withOpacity(0.4) // Yellow stripe painter
        : const Color(0xFFB38F00).withOpacity(0.5); // Darker mustard stripe painter
    final Color truckCabColor = _getTruckColor(spot.id);

    final String tooltipMsg = spot.occupied
        ? 'Spot ${spot.spotNumber}: Occupied\nReg: ${spot.vehicleRegistration}\nRate: ${spot.rateType}\nCost: \$${spot.totalCost.toStringAsFixed(2)}'
        : 'Spot ${spot.spotNumber}: Available\nRate: ${spot.rateType.isEmpty ? 'N/A' : spot.rateType}';

    return Tooltip(
      message: tooltipMsg,
      textStyle: const TextStyle(
        fontFamily: 'Inter',
        color: Colors.white,
        fontSize: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.95),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      preferBelow: isTopRow,
      child: Transform.rotate(
        angle: angle,
        child: InkWell(
          onTap: () => _showSpotDetailsDialog(context, spot, styles),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 58,
            height: 140,
            decoration: BoxDecoration(
              // Yellow parking stencils
              border: Border(
                left: BorderSide(color: linePaintColor, width: 1.5),
                right: BorderSide(color: linePaintColor, width: 1.5),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Stenciled parking number + status indicator on asphalt
                Positioned(
                  top: isTopRow ? 18 : null,
                  bottom: isTopRow ? null : 18,
                  child: Opacity(
                    opacity: spot.occupied ? 0.35 : 0.75,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          spot.spotNumber.length > 3
                              ? spot.spotNumber.substring(spot.spotNumber.length - 2)
                              : spot.spotNumber,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : widget.tokens.textMain,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          spot.occupied ? '✘' : '✔',
                          style: TextStyle(
                            color: spot.occupied ? const Color(0xFFC62828) : const Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Large checkmark in the center if available
                if (!spot.occupied)
                  Center(
                    child: Text(
                      '✔',
                      style: TextStyle(
                        color: const Color(0xFF2E7D32).withOpacity(0.85),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Top-down semi-truck if slot is occupied
                if (spot.occupied)
                  Positioned(
                    top: isTopRow ? 40 : 15,
                    child: TopDownTruckWidget(
                      cabColor: truckCabColor,
                      registration: spot.vehicleRegistration,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTruckColor(int id) {
    final colors = [
      const Color(0xFFC62828), // Red
      const Color(0xFF1565C0), // Blue
      const Color(0xFF2E7D32), // Green
      const Color(0xFFEF6C00), // Orange
      const Color(0xFF4A148C), // Purple
      const Color(0xFF00838F), // Cyan
    ];
    return colors[id % colors.length];
  }

  // --- Original Standard Grid Layout (Backup / Switch option) ---
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
          itemCount: widget.notifier.spots.length,
          itemBuilder: (context, index) {
            final spot = widget.notifier.spots[index];
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
        decoration: widget.tokens.cardDecoration(),
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
                      fontFamily: widget.tokens.sansFont,
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
                    fontFamily: widget.tokens.sansFont,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: spot.occupied ? widget.tokens.textHeader : widget.tokens.textMain.withOpacity(0.4),
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
                      style: TextStyle(fontFamily: widget.tokens.sansFont, fontSize: 13, color: widget.tokens.textMain),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontFamily: widget.tokens.sansFont,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: widget.tokens.accent,
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
          Text(label, style: TextStyle(fontFamily: widget.tokens.sansFont, fontSize: 13, color: widget.tokens.textMain.withOpacity(0.6))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(fontFamily: widget.tokens.sansFont, fontSize: 13, fontWeight: FontWeight.w600, color: widget.tokens.textHeader),
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
          Text(label, style: TextStyle(fontFamily: widget.tokens.sansFont, fontSize: 13, color: widget.tokens.textMain.withOpacity(0.6))),
          widgetValue,
        ],
      ),
    );
  }
}
