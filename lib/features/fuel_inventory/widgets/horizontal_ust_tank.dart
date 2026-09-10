import 'package:flutter/material.dart';
import 'package:truck_stop_erp_lite_front_end/ui/core/style_tokens.dart';

class HorizontalUstTank extends StatelessWidget {
  final double fillPercent;
  final Color fluidColor;
  final StyleTokens tokens;
  final double height;

  const HorizontalUstTank({
    super.key,
    required this.fillPercent,
    required this.fluidColor,
    required this.tokens,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    final clampedPercent = fillPercent.clamp(0.0, 100.0);
    final fillFactor = clampedPercent / 100.0;

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final tankHeight = height * 0.72;
          final riserHeight = height * 0.14;
          final saddleHeight = height * 0.14;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Manway Riser & Sensor Probe Fitting (Ground level collar)
              SizedBox(
                height: riserHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Primary ATG inspection manway
                    Container(
                      width: 28,
                      height: riserHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B7280),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                        border: Border.all(color: const Color(0xFF4B5563), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Secondary probe / vent fitting
                    Container(
                      width: 14,
                      height: riserHeight * 0.8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9CA3AF),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                        border: Border.all(color: const Color(0xFF6B7280), width: 1),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main Cylindrical Pressure Vessel Body (No ladders!)
              Container(
                height: tankHeight,
                width: width,
                decoration: BoxDecoration(
                  color: tokens.cardBg,
                  borderRadius: BorderRadius.circular(tankHeight / 2),
                  border: Border.all(color: const Color(0xFF4B5563), width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(tankHeight / 2 - 2),
                  child: Stack(
                    children: [
                      // Empty tank interior background (soft industrial steel)
                      Container(
                        color: const Color(0xFFE5E7EB),
                      ),

                      // Fluid fill level rising from bottom
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: tankHeight * fillFactor,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                fluidColor.withOpacity(0.9),
                                fluidColor,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Fluid meniscus line / wave accent
                      if (fillFactor > 0.02 && fillFactor < 0.98)
                        Positioned(
                          bottom: (tankHeight * fillFactor) - 2,
                          left: 0,
                          right: 0,
                          height: 2,
                          child: Container(
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),

                      // Capacity calibration tick marks (25%, 50%, 75%)
                      Positioned(
                        left: 20,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 8, height: 1, color: const Color(0xFF6B7280)),
                            Container(width: 14, height: 1.5, color: const Color(0xFF4B5563)),
                            Container(width: 8, height: 1, color: const Color(0xFF6B7280)),
                          ],
                        ),
                      ),

                      // Glass sheen highlight over upper cylinder
                      Positioned(
                        top: 2,
                        left: 16,
                        right: 16,
                        height: tankHeight * 0.28,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(tankHeight),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.45),
                                Colors.white.withOpacity(0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Underground Concrete Mounting Saddles (Foundation cradles)
              SizedBox(
                height: saddleHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 22,
                        height: saddleHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B5563),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                          border: Border.all(color: const Color(0xFF374151), width: 1),
                        ),
                      ),
                      Container(
                        width: 22,
                        height: saddleHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4B5563),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3)),
                          border: Border.all(color: const Color(0xFF374151), width: 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
