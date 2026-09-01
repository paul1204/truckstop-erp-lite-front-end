import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/showers/showers_notifier.dart';
import 'package:self_improvement_app/features/showers/showers_styles.dart';
import 'package:self_improvement_app/ui/core/offline_error_widget.dart';
import 'package:self_improvement_app/features/showers/widgets/shower_stall_widget.dart';

class ShowersViewV2 extends StatefulWidget {
  final ShowersNotifier notifier;
  final StyleTokens tokens;

  const ShowersViewV2({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  State<ShowersViewV2> createState() => _ShowersViewV2State();
}

class _ShowersViewV2State extends State<ShowersViewV2> {
  bool _showMap = true; // Default to Corridor Map View

  @override
  Widget build(BuildContext context) {
    final styles = ShowersStyles(widget.tokens);

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
                      Text('Shower Units V2', style: styles.titleStyle),
                      const SizedBox(height: 4),
                      Container(height: 4, width: 100, color: widget.tokens.accent),
                    ],
                  ),
                  
                  // View Toggle Switch
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
                      Text('Corridor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                  onRetry: widget.notifier.fetchShowers,
                )
              else
                _showMap
                    ? _buildCorridorView(context, styles)
                    : _buildShowersGrid(context, styles),
            ],
          ),
        );
      },
    );
  }

  // --- Skeuomorphic Corridor View ---
  Widget _buildCorridorView(BuildContext context, ShowersStyles styles) {
    final int totalShowers = widget.notifier.showers.length;
    if (totalShowers == 0) {
      return Center(
        child: Text(
          'No shower units available.',
          style: TextStyle(fontFamily: widget.tokens.sansFont, color: widget.tokens.textMain),
        ),
      );
    }

    // Split the list of shower units into rows of at most 6 stalls
    final List<Widget> hallwayRows = [];
    for (int i = 0; i < totalShowers; i += 6) {
      final List<ShowerUnit> rowShowers = widget.notifier.showers.sublist(
        i,
        math.min(i + 6, totalShowers),
      );
      hallwayRows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _buildHallwayRow(context, rowShowers, styles),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: hallwayRows,
    );
  }

  Widget _buildHallwayRow(
    BuildContext context,
    List<ShowerUnit> rowShowers,
    ShowersStyles styles,
  ) {
    final int placeholderCount = 6 - rowShowers.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double hallwayWidth = math.max(constraints.maxWidth, 920.0);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            width: hallwayWidth,
            height: 330,
            decoration: BoxDecoration(
              color: widget.tokens.brightness == Brightness.dark
                  ? const Color(0xFF1B2327) // Dark wall corridor
                  : const Color(0xFFECEFF1), // Light corridor
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.tokens.border.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: widget.tokens.shadowColor.withOpacity(0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 1. Tiled corridor floor at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 50,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.tokens.brightness == Brightness.dark
                          ? const Color(0xFF455A64) // Slate floor tiles
                          : const Color(0xFFCFD8DC),
                      border: Border(
                        top: BorderSide(
                          color: widget.tokens.brightness == Brightness.dark
                              ? const Color(0xFF37474F)
                              : const Color(0xFF90A4AE),
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: CustomPaint(
                      painter: _FloorGridPainter(
                        lineColor: widget.tokens.brightness == Brightness.dark
                            ? const Color(0xFF263238)
                            : const Color(0xFFB0BEC5),
                      ),
                    ),
                  ),
                ),

                // 2. Row of Shower Stall doors + placeholders
                Positioned(
                  left: 30,
                  right: 30,
                  bottom: 25, // rested right on top of floor border
                  height: 240,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ...rowShowers.map((shower) {
                        return Tooltip(
                          message: _getTooltipMessage(shower),
                          textStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 11),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: ShowerStallWidget(
                            shower: shower,
                            tokens: widget.tokens,
                            onTap: () => _showShowerDetailsDialog(context, shower, styles),
                          ),
                        );
                      }),
                      // Padding placeholders to align them vertically in a grid pattern
                      ...List.generate(
                        placeholderCount,
                        (_) => const SizedBox(width: 120),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getTooltipMessage(ShowerUnit shower) {
    if (shower.cleaning) {
      return 'Unit ${shower.showerNumber}: Under Maintenance\nCleaning until: ${shower.cleaningUntil ?? 'N/A'}';
    } else if (shower.occupied) {
      return 'Unit ${shower.showerNumber}: Occupied\nCustomer: ${shower.customerName}\nReserved until: ${shower.reservedUntil ?? 'N/A'}';
    } else {
      return 'Unit ${shower.showerNumber}: Available\nRate: \$${shower.totalCost.toStringAsFixed(2)} / hr';
    }
  }

  // --- Original Grid View (Backup / Alternate) ---
  Widget _buildShowersGrid(BuildContext context, ShowersStyles styles) {
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
            childAspectRatio: 1.25,
          ),
          itemCount: widget.notifier.showers.length,
          itemBuilder: (context, index) {
            final shower = widget.notifier.showers[index];
            return _buildShowerCard(context, shower, styles);
          },
        );
      },
    );
  }

  Widget _buildShowerCard(BuildContext context, ShowerUnit shower, ShowersStyles styles) {
    final badgeColor = styles.getStatusColor(shower.occupied, shower.cleaning);

    String statusText = 'Available';
    if (shower.cleaning) {
      statusText = 'Cleaning';
    } else if (shower.occupied) {
      statusText = 'Occupied';
    }

    String subText = 'Ready';
    if (shower.cleaning) {
      subText = 'Maintenance';
    } else if (shower.occupied) {
      subText = shower.customerName;
    }

    final formattedSince = shower.occupiedSince != null
        ? DateTime.tryParse(shower.occupiedSince!) != null
            ? DateTime.parse(shower.occupiedSince!).toLocal().toString().substring(11, 16)
            : shower.occupiedSince!
        : 'N/A';

    final formattedUntil = shower.reservedUntil != null
        ? DateTime.tryParse(shower.reservedUntil!) != null
            ? DateTime.parse(shower.reservedUntil!).toLocal().toString().substring(11, 16)
            : shower.reservedUntil!
        : 'N/A';

    return InkWell(
      onTap: () => _showShowerDetailsDialog(context, shower, styles),
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
                    statusText,
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

            // Shower Number
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Unit ${shower.showerNumber}', style: styles.unitNumberStyle),
                Expanded(
                  child: Text(
                    subText,
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: widget.tokens.sansFont,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: shower.occupied || shower.cleaning ? widget.tokens.textHeader : widget.tokens.textMain.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),

            // Time & cost info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Occupied Since', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text(formattedSince, style: styles.valueStyle),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reserved Until', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text(formattedUntil, style: styles.valueStyle),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Cost', style: styles.labelStyle),
                    const SizedBox(height: 2),
                    Text('\$${shower.totalCost.toStringAsFixed(2)}', style: styles.valueStyle),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShowerDetailsDialog(BuildContext context, ShowerUnit shower, ShowersStyles styles) {
    final badgeColor = styles.getStatusColor(shower.occupied, shower.cleaning);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String statusText = 'Available';
        if (shower.cleaning) {
          statusText = 'Cleaning';
        } else if (shower.occupied) {
          statusText = 'Occupied';
        }

        final formattedSince = shower.occupiedSince != null
            ? DateTime.tryParse(shower.occupiedSince!) != null
                ? DateTime.parse(shower.occupiedSince!).toLocal().toString().substring(0, 16)
                : shower.occupiedSince!
            : 'N/A';

        final formattedUntil = shower.reservedUntil != null
            ? DateTime.tryParse(shower.reservedUntil!) != null
                ? DateTime.parse(shower.reservedUntil!).toLocal().toString().substring(0, 16)
                : shower.reservedUntil!
            : 'N/A';

        final formattedCleaning = shower.cleaningUntil != null
            ? DateTime.tryParse(shower.cleaningUntil!) != null
                ? DateTime.parse(shower.cleaningUntil!).toLocal().toString().substring(0, 16)
                : shower.cleaningUntil!
            : 'N/A';

        return AlertDialog(
          title: Text('Shower Details: ${shower.showerNumber}', style: styles.unitNumberStyle.copyWith(fontSize: 20)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Status & Occupant'),
                  _buildDetailRowWidget(
                    'Current Status',
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                    ),
                  ),
                  _buildDetailRow('Customer', shower.occupied ? shower.customerName : 'N/A'),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Schedule & Billing'),
                  _buildDetailRow('Occupied Since', formattedSince),
                  _buildDetailRow('Reserved Until', formattedUntil),
                  _buildDetailRow('Cleaning Until', formattedCleaning),
                  _buildDetailRow('Total Cost', '\$${shower.totalCost.toStringAsFixed(2)}'),

                  const SizedBox(height: 16),
                  _buildSectionHeader('Notes'),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      shower.message.isNotEmpty ? shower.message : 'No additional information.',
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

// Floor joints grid with perspective effect
class _FloorGridPainter extends CustomPainter {
  final Color lineColor;
  _FloorGridPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // Draw horizontal grout lines
    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), paint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width, size.height * 0.66), paint);

    // Draw receding perspective floor joints
    const double spacing = 64.0;
    for (double x = -40; x < size.width + 40; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x + 24, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FloorGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
