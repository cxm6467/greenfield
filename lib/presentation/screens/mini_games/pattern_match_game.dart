import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class PatternMatchGame extends StatefulWidget {
  final MiniGameTheme theme;
  final MiniGameType gameType;
  final Function(MiniGameResult) onGameComplete;

  const PatternMatchGame({
    super.key,
    required this.theme,
    required this.gameType,
    required this.onGameComplete,
  });

  @override
  State<PatternMatchGame> createState() => _PatternMatchGameState();
}

class _PatternMatchGameState extends State<PatternMatchGame> {
  late List<String> patterns;
  late int correctIndex;
  int score = 0;
  int round = 1;
  final int maxRounds = 5;
  bool isGameOver = false;
  bool answered = false;

  @override
  void initState() {
    super.initState();
    _generatePattern();
  }

  void _generatePattern() {
    final allPatterns = ['🟥', '🟦', '🟩', '⬛'];
    patterns = allPatterns..shuffle();
    correctIndex = Random().nextInt(3);
    patterns[correctIndex] = '🧩'; // The piece to match
    answered = false;
  }

  void _selectPattern(int index) {
    if (answered || isGameOver) return;

    setState(() {
      answered = true;

      if (index == correctIndex) {
        score += 20;
      } else {
        isGameOver = true;
        return;
      }

      round++;
      if (round > maxRounds) {
        isGameOver = true;
      } else {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _generatePattern();
            });
          }
        });
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
                    'Pattern Match - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Round: $round/$maxRounds',
                    style: Theme.of(context).textTheme.bodyLarge,
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Find the matching piece:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          // Pattern to match (always in center)
          Text(patterns[correctIndex], style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 48),
          Text(
            'Select the matching color:',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          // 3 color options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final colors = [
                '🟥', // Red
                '🟦', // Blue
                '🟩', // Green
              ];

              return GestureDetector(
                onTap: () => _selectPattern(index),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: answered
                          ? (index == correctIndex
                                ? GreenlandsTheme.successGreen
                                : GreenlandsTheme.errorRed)
                          : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    colors[index],
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = score >= 60; // 3+ correct to win
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
