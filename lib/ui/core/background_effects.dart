import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

/// Painter for drawing the stipple (dot grid) pattern on the background.
class StippleGridPainter extends CustomPainter {
  final Color dotColor;
  StippleGridPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const double spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.75, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StippleGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor;
  }
}

/// Helper model for animating floating background elements
class FloatingParticle {
  double xPct; // horizontal percentage (0.0 to 1.0)
  final double yPct; // vertical percentage (0.0 to 1.0)
  final double speed; // speed coefficient
  final double scale;
  final String content; // Emoji or text representation
  final double angle; // Rotation angle
  final bool isCloud;

  FloatingParticle({
    required this.xPct,
    required this.yPct,
    required this.speed,
    required this.scale,
    required this.content,
    this.angle = 0.0,
    this.isCloud = false,
  });
}

class FloatingBackground extends StatefulWidget {
  final StyleTokens tokens;
  final Widget child;

  const FloatingBackground({
    super.key,
    required this.tokens,
    required this.child,
  });

  @override
  State<FloatingBackground> createState() => _FloatingBackgroundState();
}

class _FloatingBackgroundState extends State<FloatingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 300),
    )..repeat();

    _initializeParticles();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initializeParticles() {
    // 1. Add Clouds (organic soft floating elements)
    final cloudConfigs = [
      {'y': 0.08, 'speed': 0.015, 'scale': 1.6},
      {'y': 0.22, 'speed': 0.02, 'scale': 2.2},
      {'y': 0.31, 'speed': 0.012, 'scale': 1.1},
      {'y': 0.48, 'speed': 0.018, 'scale': 1.8},
      {'y': 0.70, 'speed': 0.014, 'scale': 1.3},
      {'y': 0.82, 'speed': 0.022, 'scale': 1.9},
    ];

    for (var cfg in cloudConfigs) {
      _particles.add(FloatingParticle(
        xPct: _random.nextDouble(),
        yPct: cfg['y'] as double,
        speed: cfg['speed'] as double,
        scale: cfg['scale'] as double,
        content: '☁️',
        isCloud: true,
      ));
    }

    // 2. Add Office and Truck Stop Emoji Supplies
    final supplyConfigs = [
      {'emoji': '📠', 'y': 0.15, 'speed': 0.010, 'scale': 0.9},
      {'emoji': '🖊️', 'y': 0.35, 'speed': 0.015, 'scale': 0.7},
      {'emoji': '📂', 'y': 0.75, 'speed': 0.008, 'scale': 1.0},
      {'emoji': '📟', 'y': 0.55, 'speed': 0.011, 'scale': 0.8},
      {'emoji': '☕', 'y': 0.60, 'speed': 0.012, 'scale': 0.9},
      {'emoji': '⛽', 'y': 0.12, 'speed': 0.014, 'scale': 1.1},
      {'emoji': '💸', 'y': 0.38, 'speed': 0.013, 'scale': 0.9},
      {'emoji': '🥨', 'y': 0.65, 'speed': 0.011, 'scale': 0.8},
      {'emoji': '🌯', 'y': 0.52, 'speed': 0.012, 'scale': 1.0},
      {'emoji': '🍩', 'y': 0.78, 'speed': 0.010, 'scale': 1.1},
      {'emoji': '🚚', 'y': 0.88, 'speed': 0.016, 'scale': 1.2},
      {'emoji': '📠', 'y': 0.25, 'speed': 0.012, 'scale': 0.8},
      {'emoji': '☕', 'y': 0.70, 'speed': 0.014, 'scale': 1.0},
      // Bottom/Above footer area additions
      {'emoji': '🍔', 'y': 0.80, 'speed': 0.013, 'scale': 1.0},
      {'emoji': '🔧', 'y': 0.83, 'speed': 0.011, 'scale': 0.9},
      {'emoji': '🥤', 'y': 0.85, 'speed': 0.015, 'scale': 0.8},
      {'emoji': '🛞', 'y': 0.87, 'speed': 0.012, 'scale': 1.1},
      {'emoji': '📋', 'y': 0.89, 'speed': 0.009, 'scale': 1.0},
      {'emoji': '🛣️', 'y': 0.91, 'speed': 0.010, 'scale': 1.2},
      {'emoji': '🚛', 'y': 0.92, 'speed': 0.017, 'scale': 1.3},
      {'emoji': '💵', 'y': 0.86, 'speed': 0.014, 'scale': 0.9},
      {'emoji': '🔑', 'y': 0.84, 'speed': 0.012, 'scale': 0.7},
      // Additional general background elements
      {'emoji': '📦', 'y': 0.42, 'speed': 0.010, 'scale': 1.0},
      {'emoji': '🍕', 'y': 0.47, 'speed': 0.013, 'scale': 0.9},
      {'emoji': '🚦', 'y': 0.72, 'speed': 0.011, 'scale': 1.0},
    ];

    for (var cfg in supplyConfigs) {
      _particles.add(FloatingParticle(
        xPct: _random.nextDouble(),
        yPct: cfg['y'] as double,
        speed: cfg['speed'] as double,
        scale: cfg['scale'] as double,
        content: cfg['emoji'] as String,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update positions on every tick
        for (var p in _particles) {
          p.xPct += p.speed * 0.015; // Slow movement factor
          if (p.xPct > 1.15) {
            p.xPct = -0.15; // Wrap back to left side
          }
        }

        return Stack(
          children: [
            // 1. Grid Background Canvas
            Positioned.fill(
              child: CustomPaint(
                painter: StippleGridPainter(
                  dotColor: widget.tokens.stippleColor,
                ),
              ),
            ),

            // 2. Floating Objects Layer (behind content)
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _particles.map((p) {
                      final double left = p.xPct * constraints.maxWidth;
                      final double top = p.yPct * constraints.maxHeight;

                      // Make office supply emojis very subtle
                      final double opacity = p.isCloud
                          ? (widget.tokens.profile == AppProfile.profileB ? 0.35 : 0.20)
                          : (widget.tokens.profile == AppProfile.profileB ? 0.25 : 0.15);

                      return Positioned(
                        left: left,
                        top: top,
                        child: Transform.scale(
                          scale: p.scale,
                          child: Opacity(
                            opacity: opacity,
                            child: Text(
                              p.content,
                              style: TextStyle(
                                fontSize: p.isCloud ? 24 : 32,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // 3. Ambient Color Gradients (Redwood style corner highlights)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.8, -0.8),
                    radius: 1.2,
                    colors: [
                      widget.tokens.accentSecondary.withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.8, 0.8),
                    radius: 1.2,
                    colors: [
                      widget.tokens.accent.withOpacity(0.04),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // 4. Main Foreground Content Widget
            Positioned.fill(
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}
