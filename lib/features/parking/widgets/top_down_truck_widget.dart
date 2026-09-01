import 'package:flutter/material.dart';

class TopDownTruckWidget extends StatelessWidget {
  final Color cabColor;
  final String registration;

  const TopDownTruckWidget({
    super.key,
    required this.cabColor,
    required this.registration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Trailer / Cargo Box (Top)
        Container(
          width: 28,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: const Color(0xFFCCCCCC), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Vertical door dividing line
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 1,
                  color: const Color(0xFFDDDDDD),
                ),
              ),
              // Corrugation lines (horizontal ribs on top of trailer)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  8,
                  (index) => Container(
                    height: 1,
                    color: const Color(0xFFE2E2E2),
                  ),
                ),
              ),
              // Registration / Fleet text
              Center(
                child: RotatedBox(
                  quarterTurns: 1,
                  child: Text(
                    registration.length > 7
                        ? registration.substring(0, 7).toUpperCase()
                        : registration.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: 'Courier', // Monospace style stenciling
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF666666),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Connector / Coupling Gap (Middle)
        Container(
          width: 8,
          height: 4,
          color: const Color(0xFF424242),
        ),

        // 3. Cabin (Bottom)
        Container(
          width: 24,
          height: 20,
          decoration: BoxDecoration(
            color: cabColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(5),
              topLeft: Radius.circular(1.5),
              topRight: Radius.circular(1.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Front Windshield (near the bottom because cabin faces down)
              Positioned(
                bottom: 3,
                left: 3,
                right: 3,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B), // Dark tinted glass
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              // Sunroof / Roof details
              Positioned(
                top: 3,
                left: 7,
                right: 7,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
