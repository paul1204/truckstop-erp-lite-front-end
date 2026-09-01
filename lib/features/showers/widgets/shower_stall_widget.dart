import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/showers/showers_notifier.dart';

class ShowerStallWidget extends StatefulWidget {
  final ShowerUnit shower;
  final StyleTokens tokens;
  final VoidCallback onTap;

  const ShowerStallWidget({
    super.key,
    required this.shower,
    required this.tokens,
    required this.onTap,
  });

  @override
  State<ShowerStallWidget> createState() => _ShowerStallWidgetState();
}

class _ShowerStallWidgetState extends State<ShowerStallWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _steamController;

  @override
  void initState() {
    super.initState();
    if (widget.shower.occupied && !widget.shower.cleaning) {
      _steamController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ShowerStallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool currentlyOccupied = widget.shower.occupied && !widget.shower.cleaning;
    final bool previouslyOccupied = oldWidget.shower.occupied && !oldWidget.shower.cleaning;

    if (currentlyOccupied && !previouslyOccupied) {
      _steamController ??= AnimationController(
        vsync: this,
        duration: const Duration(seconds: 3),
      );
      _steamController!.repeat();
    } else if (!currentlyOccupied && previouslyOccupied) {
      _steamController?.stop();
    }
  }

  @override
  void dispose() {
    _steamController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.tokens.brightness == Brightness.dark;

    // Wall Tile Color
    final Color wallColor = isDark
        ? const Color(0xFF37474F) // Dark Slate tiles
        : const Color(0xFFECEFF1); // Light grey tiles

    final Color wallLineColor = isDark
        ? const Color(0xFF263238)
        : const Color(0xFFCFD8DC);

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 120,
        height: 240,
        decoration: BoxDecoration(
          color: wallColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: wallLineColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: widget.tokens.shadowColor.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // 1. Tile grid background lines
            Positioned.fill(
              child: CustomPaint(
                painter: _TileLinesPainter(lineColor: wallLineColor),
              ),
            ),

            // 2. Door Frame Archway
            Positioned(
              bottom: 0,
              width: 80,
              height: 185,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  border: Border.all(
                    color: isDark ? const Color(0xFF455A64) : const Color(0xFF90A4AE),
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(37),
                    topRight: Radius.circular(37),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Inside of the stall (Visible when door is open/available)
                      _buildStallInterior(),

                      // The Door (Only shows if occupied or cleaning)
                      if (widget.shower.occupied || widget.shower.cleaning)
                        _buildClosedDoor(),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Status Sign / Indicator above the door
            Positioned(
              top: 20,
              child: _buildStatusIndicatorLed(),
            ),

            // 4. Room Number plate
            Positioned(
              top: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37), // Brass plate
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0xFFAA8000), width: 1),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1)),
                  ],
                ),
                child: Text(
                  widget.shower.showerNumber,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E1C0C),
                  ),
                ),
              ),
            ),

            // 5. Caution Sign in front of the door (if cleaning)
            if (widget.shower.cleaning)
              Positioned(
                bottom: 8,
                child: _buildCautionSign(),
              ),

            // 6. Animated Steam Clouds (if occupied)
            if (widget.shower.occupied && !widget.shower.cleaning && _steamController != null)
              Positioned(
                top: -18,
                child: _buildSteamAnimation(),
              ),
          ],
        ),
      ),
    );
  }

  // Draw inside of the shower stall
  Widget _buildStallInterior() {
    return Container(
      color: const Color(0xFFE0F2F1), // Clean teal tiles
      width: double.infinity,
      height: double.infinity,
      child: const Stack(
        alignment: Alignment.center,
        children: [
          // Styled showerhead
          Positioned(
            top: 35,
            child: Text(
              '🚿',
              style: TextStyle(fontSize: 28),
            ),
          ),
          Positioned(
            bottom: 35,
            child: Text(
              'READY',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00796B),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Draw the closed wood stall door
  Widget _buildClosedDoor() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF8D6E63), // Wood panel door
        border: Border(
          left: BorderSide(color: Color(0xFF5D4037), width: 1.5),
          right: BorderSide(color: Color(0xFF5D4037), width: 1.5),
          top: BorderSide(color: Color(0xFF5D4037), width: 1.5),
        ),
      ),
      child: Stack(
        children: [
          // Door panelling lines
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 60,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF5D4037).withOpacity(0.5), width: 1),
              ),
            ),
          ),
          // Brass doorknob
          Positioned(
            right: 8,
            top: 90,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFFD4AF37),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.black45, blurRadius: 1, offset: Offset(0.5, 0.5)),
                ],
              ),
            ),
          ),
          // Glow under the door (if occupied)
          if (widget.shower.occupied && !widget.shower.cleaning)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD54F).withOpacity(0.9),
                      blurRadius: 4,
                      spreadRadius: 1.5,
                    ),
                  ],
                ),
              ),
            ),
          // Occupied Sign
          if (widget.shower.occupied && !widget.shower.cleaning)
            Positioned(
              top: 65,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828), // In-use red
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: const Text(
                    'IN USE',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Circular indicator light above door frame
  Widget _buildStatusIndicatorLed() {
    Color ledColor = const Color(0xFF4CAF50); // Green for Available
    if (widget.shower.cleaning) {
      ledColor = const Color(0xFFFFB300); // Yellow for Cleaning
    } else if (widget.shower.occupied) {
      ledColor = const Color(0xFFF44336); // Red for Occupied
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: ledColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black26, width: 1),
        boxShadow: [
          BoxShadow(
            color: ledColor.withOpacity(0.8),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  // Yellow A-frame caution sign
  Widget _buildCautionSign() {
    return Container(
      width: 28,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD54F), // Yellow caution board
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(3),
          topRight: Radius.circular(3),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black38, blurRadius: 2, offset: Offset(0, 1.5)),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '⚠️',
            style: TextStyle(fontSize: 12),
          ),
          Text(
            'WET',
            style: TextStyle(
              fontSize: 6,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Steam particle animation
  Widget _buildSteamAnimation() {
    return AnimatedBuilder(
      animation: _steamController!,
      builder: (context, child) {
        final val = _steamController!.value;
        final double op1 = math.max(0.0, 1.0 - (val / 0.8));
        final double pos1 = val * -22.0;

        final double val2 = (val + 0.5) % 1.0;
        final double op2 = math.max(0.0, 1.0 - (val2 / 0.8));
        final double pos2 = val2 * -22.0;

        return SizedBox(
          width: 60,
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 15,
                top: pos1,
                child: Opacity(
                  opacity: op1 * 0.45,
                  child: const Text('☁️', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ),
              ),
              Positioned(
                right: 15,
                top: pos2,
                child: Opacity(
                  opacity: op2 * 0.45,
                  child: const Text('💨', style: TextStyle(fontSize: 10, color: Colors.white54)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TileLinesPainter extends CustomPainter {
  final Color lineColor;
  _TileLinesPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    const double rowHeight = 36.0;
    for (double y = rowHeight; y < size.height; y += rowHeight) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    const double colWidth = 48.0;
    int rowCount = 0;
    for (double y = 0; y < size.height; y += rowHeight) {
      final double offset = (rowCount % 2 == 0) ? 0.0 : colWidth / 2;
      for (double x = offset; x < size.width; x += colWidth) {
        canvas.drawLine(Offset(x, y), Offset(x, y + rowHeight), paint);
      }
      rowCount++;
    }
  }

  @override
  bool shouldRepaint(covariant _TileLinesPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor;
  }
}
