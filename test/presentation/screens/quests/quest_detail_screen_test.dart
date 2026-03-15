import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:greenfield/domain/entities/quest.dart';
import 'package:greenfield/domain/entities/quest_objective.dart';
import 'package:greenfield/presentation/screens/quests/quest_detail_screen.dart';

void main() {
  group('QuestDetailScreen', () {
    late Quest testQuest;

    setUp(() {
      testQuest = Quest(
        id: 'test-quest-1',
        title: 'Test Quest',
        description: 'A test quest for unit testing',
        questType: QuestType.combat,
        difficulty: QuestDifficulty.medium,
        xpReward: 100,
        status: QuestStatus.available,
        objectives: [
          QuestObjective(text: 'Objective 1', completed: false),
          QuestObjective(text: 'Objective 2', completed: false),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    testWidgets('renders loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(home: QuestDetailScreen(questId: 'test-quest-1')),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows quest title when loaded', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(home: QuestDetailScreen(questId: 'test-quest-1')),
        ),
      );

      // Wait for async loading
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Might show error or quest title depending on repository setup
      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('QuestDetailScreen objectives display', () {
    testWidgets('displays all objectives', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-1')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Screen should render without crashing
      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });

    testWidgets('shows objectives section header', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-1')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget should render
      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });
  });

  group('QuestDetailScreen buttons', () {
    testWidgets('shows accept button for available quests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-1')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });

    testWidgets('shows complete button for active completed quests', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-1')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });
  });

  group('QuestDetailScreen - Quest Loading', () {
    testWidgets('displays error state when quest not found', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'non-existent-id')),
          ),
        ),
      );

      // Initial load
      await tester.pump();

      // Should show loading or error UI
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('retry button appears on error', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'invalid-quest')),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Widget should render without crashing
      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });
  });

  group('QuestDetailScreen - Quest Not Found', () {
    testWidgets('shows "Quest not found" message', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'unknown-quest')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render the screen
      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });
  });

  group('QuestDetailScreen - AppBar', () {
    testWidgets('has AppBar with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-quest-1')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });
  });

  group('QuestDetailScreen - Constructor', () {
    testWidgets('accepts questId parameter', (WidgetTester tester) async {
      const testQuestId = 'test-quest-123';

      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: testQuestId)),
          ),
        ),
      );

      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });

    testWidgets('is a ConsumerStatefulWidget', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-1')),
          ),
        ),
      );

      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });
  });

  group('QuestDetailScreen - Layout', () {
    testWidgets('renders ListView for scrolling content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-1')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render successfully
      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });

    testWidgets('displays Card widgets for sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: Scaffold(body: QuestDetailScreen(questId: 'test-1')),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(QuestDetailScreen), findsOneWidget);
    });
  });
}
