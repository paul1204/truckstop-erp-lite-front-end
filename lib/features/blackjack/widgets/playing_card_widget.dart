import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';

class PlayingCardWidget extends StatelessWidget {
  final String suit;
  final String rank;
  final String file;
  final bool isBack;
  final StyleTokens tokens;

  const PlayingCardWidget({
    super.key,
    required this.suit,
    required this.rank,
    required this.file,
    this.isBack = false,
    required this.tokens,
  });

  String get _rankAbbreviation {
    switch (rank.toLowerCase()) {
      case 'ace':
        return 'A';
      case 'jack':
        return 'J';
      case 'queen':
        return 'Q';
      case 'king':
        return 'K';
      default:
        return rank;
    }
  }

  String get _suitSymbol {
    switch (suit.toLowerCase()) {
      case 'hearts':
        return '♥';
      case 'diamonds':
        return '♦';
      case 'spades':
        return '♠';
      case 'clubs':
        return '♣';
      default:
        return '?';
    }
  }

  Color get _suitColor {
    final s = suit.toLowerCase();
    if (s == 'hearts' || s == 'diamonds') {
      return const Color(0xFFC7462B); // Redwood red/terracotta
    }
    return const Color(0xFF201E1C);
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = 80;
    final double cardHeight = 120;

    if (isBack) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: tokens.profile == AppProfile.profileB ? tokens.accent : const Color(0xFF00363A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'assets/Photos/blackjack-photos/card_back.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Custom pattern fallback
              return CustomPaint(
                painter: CardBackPainter(color: Colors.white.withOpacity(0.15)),
              );
            },
          ),
        ),
      );
    }

    // Try loading Card Face PNG
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8E6E1), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          'assets/Photos/blackjack-photos/$file',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // High quality fallback vector card
            return Padding(
              padding: const EdgeInsets.all(6.0),
              child: Stack(
                children: [
                  // Top Left Rank & Suit
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _rankAbbreviation,
                          style: TextStyle(
                            fontFamily: tokens.sansFont,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _suitColor,
                          ),
                        ),
                        Text(
                          _suitSymbol,
                          style: TextStyle(
                            fontSize: 12,
                            color: _suitColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Center Suit Symbol
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      _suitSymbol,
                      style: TextStyle(
                        fontSize: 32,
                        color: _suitColor,
                      ),
                    ),
                  ),

                  // Bottom Right Rank & Suit (Inverted)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _rankAbbreviation,
                            style: TextStyle(
                              fontFamily: tokens.sansFont,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _suitColor,
                            ),
                          ),
                          Text(
                            _suitSymbol,
                            style: TextStyle(
                              fontSize: 12,
                              color: _suitColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class CardBackPainter extends CustomPainter {
  final Color color;
  CardBackPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0;

    // Draw diamond lattices
    double spacing = 12;
    for (double i = -size.height; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
      canvas.drawLine(Offset(i + size.height, 0), Offset(i, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
