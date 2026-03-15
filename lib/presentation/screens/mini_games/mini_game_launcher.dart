import 'package:flutter/material.dart';

import '../../../domain/entities/mini_game.dart';
import '../../../presentation/providers/mini_game_provider.dart';
import 'coin_collector_game.dart';
import 'dice_roll_game.dart';
import 'flappy_bird_game.dart';
import 'memory_match_game.dart';
import 'pattern_match_game.dart';
import 'ring_toss_game.dart';
import 'simon_says_game.dart';
import 'speed_clicker_game.dart';
import 'whack_a_mole_game.dart';

class MiniGameLauncher extends StatefulWidget {
  final Function(MiniGameResult)? onGameComplete;
  final bool autoClose;

  const MiniGameLauncher({
    super.key,
    this.onGameComplete,
    this.autoClose = true,
  });

  @override
  State<MiniGameLauncher> createState() => _MiniGameLauncherState();
}

class _MiniGameLauncherState extends State<MiniGameLauncher> {
  late MiniGameType gameType;
  late MiniGameTheme theme;
  MiniGameResult? result;

  @override
  void initState() {
    super.initState();
    final (selectedGame, selectedTheme) = getRandomMiniGame();
    gameType = selectedGame;
    theme = selectedTheme;
  }

  void _onGameComplete(MiniGameResult gameResult) {
    setState(() {
      result = gameResult;
    });

    widget.onGameComplete?.call(gameResult);

    if (widget.autoClose && mounted) {
      Navigator.of(context).pop(gameResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${gameType.emoji} ${gameType.displayName}'),
        centerTitle: true,
      ),
      body: _buildGameWidget(),
    );
  }

  Widget _buildGameWidget() {
    switch (gameType) {
      case MiniGameType.ringToss:
        return RingTossGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.memoryMatch:
        return MemoryMatchGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.diceRoll:
        return DiceRollGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.whackAMole:
        return WhackAMoleGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.simonSays:
        return SimonSaysGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.flappyBird:
        return FlappyBirdGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.coinCollector:
        return CoinCollectorGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.patternMatch:
        return PatternMatchGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
      case MiniGameType.speedClicker:
        return SpeedClickerGame(
          theme: theme,
          gameType: gameType,
          onGameComplete: _onGameComplete,
        );
    }
  }
}
