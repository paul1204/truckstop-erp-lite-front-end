import 'package:flutter/material.dart';
import 'package:self_improvement_app/ui/core/style_tokens.dart';
import 'package:self_improvement_app/features/blackjack/blackjack_notifier.dart';
import 'package:self_improvement_app/features/blackjack/blackjack_styles.dart';
import 'package:self_improvement_app/features/blackjack/widgets/playing_card_widget.dart';

class BlackjackView extends StatelessWidget {
  final BlackjackNotifier notifier;
  final StyleTokens tokens;

  const BlackjackView({
    super.key,
    required this.notifier,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final styles = BlackjackStyles(tokens);

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Tabs row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blackjack', style: TextStyle(
                        fontFamily: tokens.sansFont,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: tokens.textHeader,
                      )),
                      const SizedBox(height: 4),
                      Container(height: 4, width: 100, color: tokens.accent),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => notifier.setViewMode('game'),
                        style: TextButton.styleFrom(
                          backgroundColor: notifier.viewMode == 'game'
                              ? tokens.accent
                              : Colors.transparent,
                          foregroundColor: notifier.viewMode == 'game'
                              ? Colors.white
                              : tokens.textMain,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Play Game'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => notifier.setViewMode('deck'),
                        style: TextButton.styleFrom(
                          backgroundColor: notifier.viewMode == 'deck'
                              ? tokens.accent
                              : Colors.transparent,
                          foregroundColor: notifier.viewMode == 'deck'
                              ? Colors.white
                              : tokens.textMain,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('View Deck'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // View Selector
              if (notifier.viewMode == 'deck')
                _buildDeckView(styles)
              else
                _buildGameView(styles),
            ],
          ),
        );
      },
    );
  }

  // Renders all 52 cards in the deck
  Widget _buildDeckView(BlackjackStyles styles) {
    // Generate all cards in deck sequentially
    final List<BlackjackCard> allCards = [];
    for (var suit in BlackjackNotifier.suits) {
      for (var rank in BlackjackNotifier.ranks) {
        allCards.add(BlackjackCard(suit: suit, rank: rank, file: '${suit}_$rank.png'));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Cards in Deck (${allCards.length})',
          style: TextStyle(
            fontFamily: tokens.sansFont,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: tokens.textHeader,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: allCards.map((card) {
            return PlayingCardWidget(
              suit: card.suit,
              rank: card.rank,
              file: card.file,
              tokens: tokens,
            );
          }).toList(),
        ),
      ],
    );
  }

  // Renders the interactive game felt board
  Widget _buildGameView(BlackjackStyles styles) {
    final bool isIdle = notifier.gameStatus == BlackjackStatus.idle;
    final bool isPlaying = notifier.gameStatus == BlackjackStatus.playing;
    final bool isDealerTurn = notifier.gameStatus == BlackjackStatus.dealerTurn;
    final bool isGameOver = notifier.gameStatus == BlackjackStatus.gameOver;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 500),
      decoration: BoxDecoration(
        color: styles.feltBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5D4037), width: 6), // Wooden frame border
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Dealer's Section
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Dealer's Hand", style: styles.titleStyle),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPlaying ? '?' : '${notifier.calculateScore(notifier.dealerHand)}',
                      style: styles.scoreTextStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isIdle)
                _buildCardPlaceholder()
              else
                Wrap(
                  spacing: 10,
                  children: notifier.dealerHand.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final card = entry.value;
                    return PlayingCardWidget(
                      suit: card.suit,
                      rank: card.rank,
                      file: card.file,
                      isBack: isPlaying && idx == 1,
                      tokens: tokens,
                    );
                  }).toList(),
                ),
            ],
          ),

          // 2. Middle Game Message / Controls Section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                if (notifier.message.isNotEmpty) ...[
                  Text(notifier.message, style: styles.bannerMessageStyle),
                  const SizedBox(height: 16),
                ],
                if (isIdle || isGameOver)
                  ElevatedButton(
                    onPressed: () => notifier.startNewGame(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tokens.accentSecondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: styles.buttonStyle,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: Text(isIdle ? 'Deal Cards' : 'New Game'),
                  )
                else if (isPlaying)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () => notifier.hit(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: styles.buttonStyle,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Hit'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () => notifier.stand(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tokens.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: styles.buttonStyle,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text('Stand'),
                      ),
                    ],
                  )
                else if (isDealerTurn)
                  Text(
                    'Dealer is playing...',
                    style: styles.scoreTextStyle.copyWith(fontSize: 16, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),

          // 3. Player's Section
          Column(
            children: [
              if (isIdle)
                _buildCardPlaceholder()
              else
                Wrap(
                  spacing: 10,
                  children: notifier.playerHand.map((card) {
                    return PlayingCardWidget(
                      suit: card.suit,
                      rank: card.rank,
                      file: card.file,
                      tokens: tokens,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Your Hand", style: styles.titleStyle),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isIdle ? '0' : '${notifier.calculateScore(notifier.playerHand)}',
                      style: styles.scoreTextStyle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardPlaceholder() {
    return Container(
      width: 80,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Icon(Icons.help_outline, color: Colors.white24, size: 28),
      ),
    );
  }
}
