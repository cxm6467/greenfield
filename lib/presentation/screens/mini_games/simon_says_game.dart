import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class SimonSaysGame extends StatefulWidget {
  final MiniGameTheme theme;
  final MiniGameType gameType;
  final Function(MiniGameResult) onGameComplete;

  const SimonSaysGame({
    super.key,
    required this.theme,
    required this.gameType,
    required this.onGameComplete,
  });

  @override
  State<SimonSaysGame> createState() => _SimonSaysGameState();
}

class _SimonSaysGameState extends State<SimonSaysGame> {
  final List<int> sequence = [];
  List<int> playerSequence = [];
  bool isPlayingSequence = false;
  bool isWaiting = false;
  int level = 1;
  bool isGameOver = false;
  final colors = [Colors.red, Colors.green, Colors.blue, Colors.yellow];

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    _addToSequence();
  }

  void _addToSequence() async {
    if (!mounted) return;
    sequence.add(Random().nextInt(4));
    playerSequence.clear();
    await _playSequence();
    setState(() {
      isWaiting = true;
    });
  }

  Future<void> _playSequence() async {
    setState(() {
      isPlayingSequence = true;
    });

    for (int i = 0; i < sequence.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      _flashButton(sequence[i]);
      await Future.delayed(const Duration(milliseconds: 400));
    }

    setState(() {
      isPlayingSequence = false;
    });
  }

  void _flashButton(int index) {
    setState(() {
      // Trigger flash animation
    });
  }

  void _onButtonPressed(int index) {
    if (isPlayingSequence || isGameOver) return;

    playerSequence.add(index);
    _flashButton(index);

    if (playerSequence[playerSequence.length - 1] !=
        sequence[playerSequence.length - 1]) {
      // Wrong button
      setState(() {
        isGameOver = true;
      });
      return;
    }

    if (playerSequence.length == sequence.length) {
      // Sequence completed successfully
      setState(() {
        level++;
        isWaiting = false;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _addToSequence();
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
                    'Simon Says - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Level: $level',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: GreenlandsTheme.accentGold,
                ),
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
          if (isPlayingSequence)
            Text(
              'Watch the sequence...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          if (isWaiting)
            Text(
              'Your turn! Repeat the sequence',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          const SizedBox(height: 48),
          // 2x2 grid of colored buttons
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: isPlayingSequence ? null : () => _onButtonPressed(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[index].withValues(
                      alpha: isPlayingSequence ? 0.5 : 0.8,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors[index], width: 2),
                  ),
                  child: Center(
                    child: Text(
                      ['🔴', '🟢', '🔵', '🟡'][index],
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = level > 3; // 3+ levels to win
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
          'Reached Level: $level',
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
                    score: level * 10,
                  )
                : MiniGameResult.lose(
                    gameType: widget.gameType,
                    theme: widget.theme,
                    score: level * 10,
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
