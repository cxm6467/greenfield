import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class SpeedClickerGame extends StatefulWidget {
  final MiniGameTheme theme;
  final MiniGameType gameType;
  final Function(MiniGameResult) onGameComplete;

  const SpeedClickerGame({
    super.key,
    required this.theme,
    required this.gameType,
    required this.onGameComplete,
  });

  @override
  State<SpeedClickerGame> createState() => _SpeedClickerGameState();
}

class _SpeedClickerGameState extends State<SpeedClickerGame> {
  late Timer _gameTimer;
  int clicks = 0;
  int timeLeft = 10;
  bool isGameOver = false;
  bool isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    super.dispose();
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

  void _click() {
    if (!isGameOver) {
      setState(() {
        clicks++;
        isButtonPressed = true;
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            isButtonPressed = false;
          });
        }
      });
    }
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
                    'Speed Clicker - ${widget.theme.displayName}',
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
                      color: timeLeft <= 2
                          ? GreenlandsTheme.errorRed
                          : Colors.white,
                    ),
                  ),
                  Text(
                    'Clicks: $clicks',
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Click as fast as you can!',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _click,
              child: AnimatedScale(
                scale: isButtonPressed ? 0.9 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: GreenlandsTheme.accentGold.withValues(
                      alpha: isButtonPressed ? 0.9 : 0.7,
                    ),
                    border: Border.all(
                      color: GreenlandsTheme.accentGold,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: GreenlandsTheme.accentGold.withValues(
                          alpha: isButtonPressed ? 0.8 : 0.3,
                        ),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⚡', style: TextStyle(fontSize: 56)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Current Score: $clicks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: GreenlandsTheme.accentGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = clicks >= 40; // 40+ clicks to win
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
          'Total Clicks: $clicks',
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
                    score: clicks,
                  )
                : MiniGameResult.lose(
                    gameType: widget.gameType,
                    theme: widget.theme,
                    score: clicks,
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
