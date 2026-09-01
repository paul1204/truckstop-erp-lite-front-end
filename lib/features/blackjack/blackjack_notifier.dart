import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum BlackjackStatus { idle, playing, dealerTurn, gameOver }

class BlackjackCard {
  final String suit;
  final String rank;
  final String file;

  BlackjackCard({
    required this.suit,
    required this.rank,
    required this.file,
  });
}

class BlackjackNotifier extends ChangeNotifier {
  static const List<String> suits = ['hearts', 'spades', 'diamonds', 'clubs'];
  static const List<String> ranks = [
    'ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'jack', 'queen', 'king'
  ];

  String _viewMode = 'game'; // 'game' or 'deck'
  String get viewMode => _viewMode;

  List<BlackjackCard> _deck = [];
  List<BlackjackCard> _playerHand = [];
  List<BlackjackCard> get playerHand => _playerHand;

  List<BlackjackCard> _dealerHand = [];
  List<BlackjackCard> get dealerHand => _dealerHand;

  BlackjackStatus _gameStatus = BlackjackStatus.idle;
  BlackjackStatus get gameStatus => _gameStatus;

  String _message = '';
  String get message => _message;

  void setViewMode(String mode) {
    if (_viewMode != mode) {
      _viewMode = mode;
      notifyListeners();
    }
  }

  void startNewGame() {
    _deck = _initializeDeck();
    _playerHand = [_deck.removeLast(), _deck.removeLast()];
    _dealerHand = [_deck.removeLast(), _deck.removeLast()];
    _gameStatus = BlackjackStatus.playing;
    _message = '';
    _viewMode = 'game';

    final pScore = calculateScore(_playerHand);
    if (pScore == 21) {
      _gameStatus = BlackjackStatus.gameOver;
      _message = 'Blackjack! You win!';
    }
    notifyListeners();
  }

  void hit() {
    if (_gameStatus != BlackjackStatus.playing) return;

    _playerHand.add(_deck.removeLast());
    final score = calculateScore(_playerHand);

    if (score > 21) {
      _gameStatus = BlackjackStatus.gameOver;
      _message = 'Bust! Dealer wins.';
    }
    notifyListeners();
  }

  void stand() {
    if (_gameStatus != BlackjackStatus.playing) return;
    _gameStatus = BlackjackStatus.dealerTurn;
    notifyListeners();
    _playDealerTurn();
  }

  Future<void> _playDealerTurn() async {
    while (calculateScore(_dealerHand) < 17) {
      await Future.delayed(const Duration(milliseconds: 600));
      _dealerHand.add(_deck.removeLast());
      notifyListeners();
    }

    final dScore = calculateScore(_dealerHand);
    final pScore = calculateScore(_playerHand);

    if (dScore > 21) {
      _message = 'Dealer busts! You win!';
    } else if (dScore > pScore) {
      _message = 'Dealer wins!';
    } else if (dScore < pScore) {
      _message = 'You win!';
    } else {
      _message = 'Push (Tie)!';
    }
    _gameStatus = BlackjackStatus.gameOver;
    notifyListeners();
  }

  List<BlackjackCard> _initializeDeck() {
    final List<BlackjackCard> newDeck = [];
    for (var suit in suits) {
      for (var rank in ranks) {
        newDeck.add(BlackjackCard(
          suit: suit,
          rank: rank,
          file: '${suit}_$rank.png',
        ));
      }
    }
    _shuffle(newDeck);
    return newDeck;
  }

  void _shuffle(List<BlackjackCard> list) {
    final random = math.Random();
    for (int i = list.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[j];
      list[j] = temp;
    }
  }

  int calculateScore(List<BlackjackCard> hand) {
    int score = 0;
    int aces = 0;

    for (var card in hand) {
      if (card.rank == 'ace') {
        aces += 1;
        score += 11;
      } else if (card.rank == 'jack' || card.rank == 'queen' || card.rank == 'king') {
        score += 10;
      } else {
        score += int.tryParse(card.rank) ?? 0;
      }
    }

    while (score > 21 && aces > 0) {
      score -= 10;
      aces -= 1;
    }
    return score;
  }
}
