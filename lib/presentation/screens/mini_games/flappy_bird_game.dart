import 'package:flutter/material.dart';

import '../../../core/config/theme_config.dart';
import '../../../domain/entities/mini_game.dart';

class FlappyBirdGame extends StatefulWidget {
  final MiniGameTheme theme;
  final MiniGameType gameType;
  final Function(MiniGameResult) onGameComplete;

  const FlappyBirdGame({
    super.key,
    required this.theme,
    required this.gameType,
    required this.onGameComplete,
  });

  @override
  State<FlappyBirdGame> createState() => _FlappyBirdGameState();
}

class _FlappyBirdGameState extends State<FlappyBirdGame>
    with TickerProviderStateMixin {
  late AnimationController _gameController;
  double birdY = 0.5;
  double birdVelocity = 0;
  int score = 0;
  bool isGameOver = false;
  List<double> pipePositions = [2.0];
  final double birdSize = 40;
  final double pipeWidth = 60;
  final double gapSize = 150;
  final double gravity = 0.4;

  @override
  void initState() {
    super.initState();
    _gameController = AnimationController(
      duration: const Duration(milliseconds: 30),
      vsync: this,
    )..repeat();

    _gameController.addListener(_updateGame);
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  void _updateGame() {
    if (isGameOver) return;

    setState(() {
      // Apply gravity
      birdVelocity += gravity;
      birdY += birdVelocity * 0.05;

      // Check bounds
      if (birdY < 0 || birdY > 1) {
        isGameOver = true;
      }

      // Update pipe positions
      for (int i = 0; i < pipePositions.length; i++) {
        pipePositions[i] -= 0.02;

        // Check collision with pipes
        if (_checkCollision(i)) {
          isGameOver = true;
        }

        // Passed through pipe
        if (pipePositions[i] < -0.2 && pipePositions[i] > -0.25) {
          score += 10;
        }
      }

      // Remove off-screen pipes and add new ones
      if (pipePositions.first < -0.3) {
        pipePositions.removeAt(0);
        pipePositions.add(2.0);
      }
    });
  }

  bool _checkCollision(int pipeIndex) {
    final pipePos = pipePositions[pipeIndex];

    // Bird horizontal position is roughly centered
    const birdXStart = 0.35;
    const birdXEnd = 0.65;

    if (pipePos > birdXStart && pipePos < birdXEnd + 0.1) {
      // Check vertical collision
      final topPipeEnd = 0.3; // Gap starts at 30% from top
      final bottomPipeStart = topPipeEnd + gapSize / 800;

      if (birdY < topPipeEnd || birdY > bottomPipeStart) {
        return true;
      }
    }

    return false;
  }

  void _flap() {
    if (!isGameOver) {
      birdVelocity = -10;
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
                    'Flappy Bird - ${widget.theme.displayName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Score: $score',
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
    return GestureDetector(
      onTap: _flap,
      child: Container(
        color: Colors.blue[900],
        child: Stack(
          children: [
            // Bird
            Positioned(
              left: MediaQuery.of(context).size.width * 0.35,
              top: MediaQuery.of(context).size.height * birdY,
              child: Text('🐦', style: TextStyle(fontSize: birdSize)),
            ),
            // Pipes
            ...List.generate(pipePositions.length, (index) {
              final xPos =
                  MediaQuery.of(context).size.width * (pipePositions[index]);
              return Stack(
                children: [
                  // Top pipe
                  Positioned(
                    left: xPos,
                    top: 0,
                    child: Container(
                      width: pipeWidth,
                      height: MediaQuery.of(context).size.height * 0.3,
                      color: GreenlandsTheme.primaryGreen,
                      child: const Center(
                        child: Text('🌳', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                  // Bottom pipe
                  Positioned(
                    left: xPos,
                    top:
                        MediaQuery.of(context).size.height *
                        (0.3 + gapSize / 800),
                    child: Container(
                      width: pipeWidth,
                      height:
                          MediaQuery.of(context).size.height * 0.7 -
                          (gapSize / 800 * MediaQuery.of(context).size.height),
                      color: GreenlandsTheme.primaryGreen,
                      child: const Center(
                        child: Text('🌳', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                  ),
                ],
              );
            }),
            // Instructions
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Tap to flap',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    final won = score >= 30; // 3+ pipes to win
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
