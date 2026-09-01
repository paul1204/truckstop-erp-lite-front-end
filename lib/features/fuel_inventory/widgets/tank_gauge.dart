import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/fuel_inventory/fuel_inventory_styles.dart';

class TankGauge extends StatelessWidget {
  final double percentage;
  final StyleTokens tokens;
  final double width;
  final double height;

  const TankGauge({
    super.key,
    required this.percentage,
    required this.tokens,
    this.width = 50,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    final styles = FuelInventoryStyles(tokens);
    final fillPercent = percentage.clamp(0.0, 100.0);
    final color = styles.tankColor(fillPercent);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: tokens.border.withOpacity(0.2),
        border: Border.all(color: tokens.border, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fillHeight = constraints.maxHeight * (fillPercent / 100.0);

          return Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: fillHeight,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(2.5),
                      bottomRight: const Radius.circular(2.5),
                      topLeft: fillPercent >= 98.0 ? const Radius.circular(2.5) : Radius.zero,
                      topRight: fillPercent >= 98.0 ? const Radius.circular(2.5) : Radius.zero,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: fillPercent > 15.0
                      ? FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(
                              '${fillPercent.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontFamily: tokens.sansFont,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
              ),
              if (fillPercent <= 15.0)
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Text(
                    '${fillPercent.toStringAsFixed(1)}%',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: tokens.sansFont,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tokens.textMain,
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
