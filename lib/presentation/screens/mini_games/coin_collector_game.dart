import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class CoinCollectorGame extends StatefulWidget {
  final MiniGameTheme theme;
  final MiniGameType gameType;
  final Function(MiniGameResult) onGameComplete;

  const CoinCollectorGame({
    super.key,
    required this.theme,
    required this.gameType,
    required this.onGameComplete,
  });

  @override
  State<CoinCollectorGame> createState() => _CoinCollectorGameState();
}

class _CoinCollectorGameState extends State<CoinCollectorGame> {
  late Timer _gameTimer;
  int score = 0;
  int timeLeft = 20;
  bool isGameOver = false;
  List<Coin> coins = [];
  final random = Random();

  @override
  void initState() {
    super.initState();
    _generateCoins();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
  }

  void _generateCoins() {
    coins.clear();
    for (int i = 0; i < 5; i++) {
      coins.add(
        Coin(
          x: random.nextDouble() * 0.8 + 0.1,
          y: random.nextDouble() * 0.6 + 0.2,
        ),
      );
    }
  }

  void _startGame() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          isGameOver = true;
          _gameTimer.cancel();
        }
      });
    });
  }

  void _collectCoin(int index) {
    if (isGameOver || index >= coins.length) return;

    setState(() {
      score += 10;
      coins.removeAt(index);

      if (coins.isEmpty) {
        _generateCoins();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.theme.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Coin Collector - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time: ${timeLeft}s',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: timeLeft <= 3
                          ? GreenlandsTheme.errorRed
                          : Colors.white,
                    ),
                  ),
                  Text(
                    'Score: $score',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: GreenlandsTheme.accentGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        // Game area
        Expanded(
          child: isGameOver ? _buildGameOverScreen() : _buildGameScreen(),
        ),
      ],
    );
  }

  Widget _buildGameScreen() {
    return Container(
      color: GreenlandsTheme.primaryGreen.withValues(alpha: 0.3),
      child: Stack(
        children: [
          // Coins
          ...List.generate(coins.length, (index) {
            final coin = coins[index];
            return Positioned(
              left: MediaQuery.of(context).size.width * coin.x,
              top: MediaQuery.of(context).size.height * coin.y,
              child: GestureDetector(
                onTap: () => _collectCoin(index),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GreenlandsTheme.accentGold.withValues(alpha: 0.8),
                    border: Border.all(
                      color: GreenlandsTheme.accentGold,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Text('🪙', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
            );
          }),
          // Instructions
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Tap coins to collect them',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = score >= 50; // 5+ coins to win
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          won ? 'YOU WIN! 🎉' : 'GAME OVER',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: won
                ? GreenlandsTheme.successGreen
                : GreenlandsTheme.errorRed,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Final Score: $score',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: GreenlandsTheme.accentGold,
          ),
        ),
        const SizedBox(height: 48),
        ElevatedButton.icon(
          onPressed: () {
            final result = won
                ? MiniGameResult.win(
                    gameType: widget.gameType,
                    theme: widget.theme,
                    score: score,
                  )
                : MiniGameResult.lose(
                    gameType: widget.gameType,
                    theme: widget.theme,
                    score: score,
                  );
            widget.onGameComplete(result);
          },
          icon: const Icon(Icons.check),
          label: const Text('CONTINUE'),
        ),
      ],
    );
  }
}

class Coin {
  final double x;
  final double y;

  Coin({required this.x, required this.y});
}
