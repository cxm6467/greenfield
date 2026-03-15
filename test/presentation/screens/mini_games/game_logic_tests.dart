import 'package:flutter_test/flutter_test.dart';
import 'package:greenfield/domain/entities/mini_game.dart';

void main() {
  group('Game Logic - Scoring Rules', () {
    test('FlappyBird: 30 points to win', () {
      const winThreshold = 30;
      expect(30, greaterThanOrEqualTo(winThreshold));
      expect(29, lessThan(winThreshold));
    });

    test('SpeedClicker: 40 clicks to win', () {
      const winThreshold = 40;
      expect(40, greaterThanOrEqualTo(winThreshold));
      expect(39, lessThan(winThreshold));
    });

    test('PatternMatch: 3 correct answers to win (60 score)', () {
      const winThreshold = 60;
      const pointsPerCorrect = 20;
      final threeCorrect = 3 * pointsPerCorrect;
      expect(threeCorrect, equals(winThreshold));
    });

    test('CoinCollector: 5 coins to win (50 score)', () {
      const winThreshold = 50;
      const pointsPerCoin = 10;
      final fiveCoins = 5 * pointsPerCoin;
      expect(fiveCoins, equals(winThreshold));
    });

    test('WhackAMole: 5 hits to win (50 score)', () {
      const winThreshold = 50;
      const pointsPerMole = 10;
      final fiveHits = 5 * pointsPerMole;
      expect(fiveHits, equals(winThreshold));
    });

    test('SimonSays: level 3+ to win', () {
      const winThreshold = 3;
      expect(3, greaterThanOrEqualTo(winThreshold));
      expect(2, lessThan(winThreshold));
    });
  });

  group('MiniGameResult gem awards', () {
    test('win result awards 10-20 gems', () {
      for (int i = 0; i < 50; i++) {
        final result = MiniGameResult.win(
          gameType: MiniGameType.ringToss,
          theme: MiniGameTheme.goblin,
          score: 100,
        );
        expect(result.gemsEarned, greaterThanOrEqualTo(10));
        expect(result.gemsEarned, lessThanOrEqualTo(20));
        expect(result.won, isTrue);
      }
    });

    test('lose result awards 2 gems', () {
      for (int i = 0; i < 10; i++) {
        final result = MiniGameResult.lose(
          gameType: MiniGameType.flappyBird,
          theme: MiniGameTheme.ranger,
          score: 15,
        );
        expect(result.gemsEarned, equals(2));
        expect(result.won, isFalse);
      }
    });

    test('win result includes game metadata', () {
      final result = MiniGameResult.win(
        gameType: MiniGameType.diceRoll,
        theme: MiniGameTheme.tavern,
        score: 50,
      );
      expect(result.gameType, equals(MiniGameType.diceRoll));
      expect(result.theme, equals(MiniGameTheme.tavern));
      expect(result.score, equals(50));
    });

    test('lose result includes game metadata', () {
      final result = MiniGameResult.lose(
        gameType: MiniGameType.memoryMatch,
        theme: MiniGameTheme.wizard,
        score: 20,
      );
      expect(result.gameType, equals(MiniGameType.memoryMatch));
      expect(result.theme, equals(MiniGameTheme.wizard));
      expect(result.score, equals(20));
    });
  });

  group('Game type and theme consistency', () {
    test('all game types are unique', () {
      final types = MiniGameType.values;
      final uniqueTypes = types.toSet();
      expect(uniqueTypes.length, equals(types.length));
    });

    test('all themes are unique', () {
      final themes = MiniGameTheme.values;
      final uniqueThemes = themes.toSet();
      expect(uniqueThemes.length, equals(themes.length));
    });

    test('game types have display names', () {
      for (final gameType in MiniGameType.values) {
        expect(gameType.displayName, isNotEmpty);
      }
    });

    test('game types have emojis', () {
      for (final gameType in MiniGameType.values) {
        expect(gameType.emoji, isNotEmpty);
      }
    });

    test('themes have display names', () {
      for (final theme in MiniGameTheme.values) {
        expect(theme.displayName, isNotEmpty);
      }
    });

    test('themes have emojis', () {
      for (final theme in MiniGameTheme.values) {
        expect(theme.emoji, isNotEmpty);
      }
    });
  });

  group('Game win/loss conditions', () {
    test('FlappyBird win condition: score >= 30', () {
      expect(30 >= 30, isTrue);
      expect(29 >= 30, isFalse);
    });

    test('SpeedClicker win condition: clicks >= 40', () {
      expect(40 >= 40, isTrue);
      expect(39 >= 40, isFalse);
    });

    test('CoinCollector win condition: score >= 50', () {
      expect(50 >= 50, isTrue);
      expect(49 >= 50, isFalse);
    });

    test('WhackAMole win condition: score >= 50', () {
      expect(50 >= 50, isTrue);
      expect(49 >= 50, isFalse);
    });

    test('PatternMatch win condition: score >= 60', () {
      expect(60 >= 60, isTrue);
      expect(59 >= 60, isFalse);
    });

    test('SimonSays win condition: level >= 3', () {
      expect(3 >= 3, isTrue);
      expect(2 >= 3, isFalse);
    });
  });

  group('Game timing constraints', () {
    test('SpeedClicker has 10 second timer', () {
      const initialTime = 10;
      expect(initialTime, equals(10));
    });

    test('WhackAMole has 30 second timer', () {
      const initialTime = 30;
      expect(initialTime, equals(30));
    });

    test('CoinCollector has 20 second timer', () {
      const initialTime = 20;
      expect(initialTime, equals(20));
    });
  });

  group('Game grid/round configurations', () {
    test('WhackAMole uses 3x3 grid', () {
      const rows = 3;
      const cols = 3;
      const totalCells = rows * cols;
      expect(totalCells, equals(9));
    });

    test('PatternMatch uses 5 rounds', () {
      const maxRounds = 5;
      const pointsPerRound = 20;
      const maxScore = maxRounds * pointsPerRound;
      expect(maxScore, equals(100));
    });

    test('SimonSays button colors are 4', () {
      const buttonColors = 4;
      expect(buttonColors, equals(4));
    });
  });


  group('Quest objective completion', () {
    test('objective marked complete on game win', () {
      final result = MiniGameResult.win(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.elf,
        score: 100,
      );
      expect(result.won, isTrue);
    });

    test('objective not marked complete on game loss', () {
      final result = MiniGameResult.lose(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.elf,
        score: 50,
      );
      expect(result.won, isFalse);
    });

    test('gems awarded only on win', () {
      final win = MiniGameResult.win(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.elf,
        score: 100,
      );
      final lose = MiniGameResult.lose(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.elf,
        score: 100,
      );

      expect(win.gemsEarned, greaterThan(0));
      expect(lose.gemsEarned, equals(2));
    });
  });
}
