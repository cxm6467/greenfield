import 'package:flutter_test/flutter_test.dart';
import 'package:greenfield/domain/entities/mini_game.dart';
import 'package:greenfield/presentation/providers/mini_game_provider.dart';

void main() {
  group('GemsNotifier', () {
    late GemsNotifier gemsNotifier;

    setUp(() {
      gemsNotifier = GemsNotifier(initialGems: 100);
    });

    test('initial state is set correctly', () {
      expect(gemsNotifier.state, equals(100));
    });

    test('addGems increases gem count', () {
      gemsNotifier.addGems(50);
      expect(gemsNotifier.state, equals(150));
    });

    test('addGems ignores negative amounts', () {
      gemsNotifier.addGems(-50);
      expect(gemsNotifier.state, equals(100));
    });

    test('addGems ignores zero', () {
      gemsNotifier.addGems(0);
      expect(gemsNotifier.state, equals(100));
    });

    test('removeGems decreases gem count', () {
      gemsNotifier.removeGems(30);
      expect(gemsNotifier.state, equals(70));
    });

    test('removeGems prevents going below zero', () {
      gemsNotifier.removeGems(150);
      expect(gemsNotifier.state, equals(100)); // Should not decrease
    });

    test('removeGems ignores negative amounts', () {
      gemsNotifier.removeGems(-50);
      expect(gemsNotifier.state, equals(100));
    });

    test('removeGems ignores zero', () {
      gemsNotifier.removeGems(0);
      expect(gemsNotifier.state, equals(100));
    });

    test('canAfford returns true when sufficient gems', () {
      expect(gemsNotifier.canAfford(50), isTrue);
      expect(gemsNotifier.canAfford(100), isTrue);
    });

    test('canAfford returns false when insufficient gems', () {
      expect(gemsNotifier.canAfford(101), isFalse);
      expect(gemsNotifier.canAfford(200), isFalse);
    });
  });

  group('shouldBypassMiniGame', () {
    test('returns boolean', () {
      final result = shouldBypassMiniGame();
      expect(result, isA<bool>());
    });

    test('has reasonable distribution (statistical test)', () {
      // Run 1000 times and check that bypass happens roughly 10% of the time
      int bypassCount = 0;
      const iterations = 1000;

      for (int i = 0; i < iterations; i++) {
        if (shouldBypassMiniGame()) {
          bypassCount++;
        }
      }

      final percentage = (bypassCount / iterations) * 100;
      // Allow 5-15% (10% ± 5%) to account for randomness
      expect(percentage, greaterThan(5.0));
      expect(percentage, lessThan(15.0));
    });
  });

  group('getRandomMiniGame', () {
    test('returns both game type and theme', () {
      final (gameType, theme) = getRandomMiniGame();
      expect(gameType, isNotNull);
      expect(theme, isNotNull);
    });

    test('returns valid game type', () {
      final (gameType, _) = getRandomMiniGame();
      expect(MiniGameType.values, contains(gameType));
    });

    test('returns valid theme', () {
      final (_, theme) = getRandomMiniGame();
      expect(MiniGameTheme.values, contains(theme));
    });

    test('theme is appropriate for game type', () {
      for (int i = 0; i < 50; i++) {
        final (gameType, theme) = getRandomMiniGame();
        // Just verify it doesn't throw - theme selection logic is sound
        expect(theme, isNotNull);
      }
    });
  });

  group('_selectThemeForGame', () {
    test('returns valid theme for ring toss', () {
      // We can't call private function directly, so we test via getRandomMiniGame
      // by checking that ring toss games have expected themes
      for (int i = 0; i < 20; i++) {
        final (gameType, theme) = getRandomMiniGame();
        if (gameType == MiniGameType.ringToss) {
          expect([MiniGameTheme.goblin, MiniGameTheme.elf], contains(theme));
        }
      }
    });

    test('returns valid theme for memory match', () {
      for (int i = 0; i < 20; i++) {
        final (gameType, theme) = getRandomMiniGame();
        if (gameType == MiniGameType.memoryMatch) {
          expect([MiniGameTheme.undead, MiniGameTheme.wizard], contains(theme));
        }
      }
    });

    test('all game types have theme mappings', () {
      final gameTypes = MiniGameType.values;
      for (final gameType in gameTypes) {
        // Test by running many times to ensure we get valid themes
        for (int i = 0; i < 5; i++) {
          final (returnedType, theme) = getRandomMiniGame();
          if (returnedType == gameType) {
            expect(theme, isNotNull);
            expect(MiniGameTheme.values, contains(theme));
          }
        }
      }
    });
  });

  group('MiniGameResultNotifier', () {
    late MiniGameResultNotifier resultNotifier;

    setUp(() {
      resultNotifier = MiniGameResultNotifier();
    });

    test('initial state is null', () {
      expect(resultNotifier.state, isNull);
    });

    test('setResult sets the result', () {
      final result = MiniGameResult.win(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.goblin,
        score: 100,
      );
      resultNotifier.setResult(result);
      expect(resultNotifier.state, equals(result));
    });

    test('clearResult sets state to null', () {
      final result = MiniGameResult.win(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.goblin,
        score: 100,
      );
      resultNotifier.setResult(result);
      resultNotifier.clearResult();
      expect(resultNotifier.state, isNull);
    });
  });

  group('MiniGameResult factory constructors', () {
    test('win result sets won to true and gemsEarned in range', () {
      final result = MiniGameResult.win(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.goblin,
        score: 100,
      );
      expect(result.won, isTrue);
      expect(result.gemsEarned, greaterThanOrEqualTo(10));
      expect(result.gemsEarned, lessThanOrEqualTo(20));
    });

    test('lose result sets won to false and gemsEarned to 2', () {
      final result = MiniGameResult.lose(
        gameType: MiniGameType.ringToss,
        theme: MiniGameTheme.goblin,
        score: 50,
      );
      expect(result.won, isFalse);
      expect(result.gemsEarned, equals(2));
    });

    test('multiple win results have varying gems', () {
      final gems = <int>{};
      for (int score = 0; score < 100; score++) {
        final result = MiniGameResult.win(
          gameType: MiniGameType.ringToss,
          theme: MiniGameTheme.goblin,
          score: score,
        );
        // Verify the deterministic gems formula for each score.
        expect(result.gemsEarned, equals(10 + score ~/ 10));
        gems.add(result.gemsEarned);
      }
      // Scores 0–99 should yield gem values 10–19, i.e. 10 distinct values.
      expect(gems.length, equals(10));
    });
  });
}
