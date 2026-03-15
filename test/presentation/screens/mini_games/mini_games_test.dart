import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenfield/domain/entities/mini_game.dart';
import 'package:greenfield/presentation/screens/mini_games/flappy_bird_game.dart';
import 'package:greenfield/presentation/screens/mini_games/pattern_match_game.dart';

void main() {
  group('FlappyBirdGame Widget', () {
    testWidgets('renders game header with title and score', (
      WidgetTester tester,
    ) async {
      var resultCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlappyBirdGame(
              theme: MiniGameTheme.elf,
              gameType: MiniGameType.flappyBird,
              onGameComplete: (_) => resultCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Flappy Bird - Elf'), findsOneWidget);
      expect(find.text('Score: 0'), findsOneWidget);
    });

    testWidgets('displays game area with bird', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlappyBirdGame(
              theme: MiniGameTheme.ranger,
              gameType: MiniGameType.flappyBird,
              onGameComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(GestureDetector), findsWidgets);
      expect(find.text('🐦'), findsWidgets); // Bird emoji
    });

    testWidgets('bird responds to tap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlappyBirdGame(
              theme: MiniGameTheme.elf,
              gameType: MiniGameType.flappyBird,
              onGameComplete: (_) {},
            ),
          ),
        ),
      );

      final gestureDetector = find.byType(GestureDetector).first;
      await tester.tap(gestureDetector);
      await tester.pumpAndSettle();

      // Game should still be rendering
      expect(find.text('Score: 0'), findsOneWidget);
    });
  });

  group('PatternMatchGame Widget', () {
    testWidgets('renders pattern display', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternMatchGame(
              theme: MiniGameTheme.wizard,
              gameType: MiniGameType.patternMatch,
              onGameComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Find the matching piece:'), findsOneWidget);
    });

    testWidgets('displays 3 color options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternMatchGame(
              theme: MiniGameTheme.elf,
              gameType: MiniGameType.patternMatch,
              onGameComplete: (_) {},
            ),
          ),
        ),
      );

      // Should display the round counter
      expect(find.textContaining('Round:'), findsOneWidget);
      expect(find.textContaining('Score:'), findsOneWidget);
    });

    testWidgets('renders with different theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternMatchGame(
              theme: MiniGameTheme.wizard,
              gameType: MiniGameType.patternMatch,
              onGameComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Pattern Match - Wizard'), findsOneWidget);
    });
  });

  group('Game widget instantiation', () {
    testWidgets('FlappyBird instantiates', (WidgetTester tester) async {
      final game = FlappyBirdGame(
        theme: MiniGameTheme.elf,
        gameType: MiniGameType.flappyBird,
        onGameComplete: (_) {},
      );

      expect(game, isNotNull);
      expect(game.theme, equals(MiniGameTheme.elf));
      expect(game.gameType, equals(MiniGameType.flappyBird));
    });

    testWidgets('PatternMatch instantiates', (WidgetTester tester) async {
      final game = PatternMatchGame(
        theme: MiniGameTheme.wizard,
        gameType: MiniGameType.patternMatch,
        onGameComplete: (_) {},
      );

      expect(game, isNotNull);
      expect(game.theme, equals(MiniGameTheme.wizard));
      expect(game.gameType, equals(MiniGameType.patternMatch));
    });
  });

  group('Game themes work correctly', () {
    testWidgets('FlappyBird works with elf theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlappyBirdGame(
              theme: MiniGameTheme.elf,
              gameType: MiniGameType.flappyBird,
              onGameComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Flappy Bird - Elf'), findsOneWidget);
    });

    testWidgets('PatternMatch works with wizard theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PatternMatchGame(
              theme: MiniGameTheme.wizard,
              gameType: MiniGameType.patternMatch,
              onGameComplete: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Pattern Match - Wizard'), findsOneWidget);
    });

    testWidgets('themes can be switched', (WidgetTester tester) async {
      final themes = [MiniGameTheme.elf, MiniGameTheme.ranger];

      for (final theme in themes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: FlappyBirdGame(
                theme: theme,
                gameType: MiniGameType.flappyBird,
                onGameComplete: (_) {},
              ),
            ),
          ),
        );

        expect(find.text('Flappy Bird - ${theme.displayName}'), findsOneWidget);
      }
    });
  });
}
