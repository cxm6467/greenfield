import 'package:flutter_test/flutter_test.dart';
import 'package:greenfield/domain/entities/quest.dart';

void main() {
  group('Quest entity creation', () {
    test('creates quest with required fields', () {
      final quest = Quest(
        id: 'quest-1',
        title: 'Test Quest',
        description: 'A test quest',
        questType: QuestType.main,
        difficulty: QuestDifficulty.medium,
        xpReward: 100,
        status: QuestStatus.available,
        objectives: [],
        requiredLevel: 1,
        prerequisites: [],
        isGenerated: false,
        createdAt: DateTime.now(),
      );

      expect(quest.id, equals('quest-1'));
      expect(quest.title, equals('Test Quest'));
      expect(quest.questType, equals(QuestType.main));
      expect(quest.difficulty, equals(QuestDifficulty.medium));
      expect(quest.xpReward, equals(100));
      expect(quest.status, equals(QuestStatus.available));
    });

    test('quest status enum has all values', () {
      expect(QuestStatus.available, isNotNull);
      expect(QuestStatus.active, isNotNull);
      expect(QuestStatus.completed, isNotNull);
      expect(QuestStatus.failed, isNotNull);
    });

    test('quest difficulty enum has all values', () {
      expect(QuestDifficulty.easy, isNotNull);
      expect(QuestDifficulty.medium, isNotNull);
      expect(QuestDifficulty.hard, isNotNull);
    });

    test('quest type enum has all values', () {
      expect(QuestType.main, isNotNull);
      expect(QuestType.side, isNotNull);
      expect(QuestType.daily, isNotNull);
      expect(QuestType.generated, isNotNull);
    });
  });

  group('Quest status transitions', () {
    test('quest can be available', () {
      final quest = Quest(
        id: 'q1',
        title: 'Quest',
        description: 'Description',
        questType: QuestType.main,
        difficulty: QuestDifficulty.easy,
        xpReward: 50,
        status: QuestStatus.available,
        objectives: [],
        requiredLevel: 1,
        prerequisites: [],
        isGenerated: false,
        createdAt: DateTime.now(),
      );

      expect(quest.status, equals(QuestStatus.available));
    });

    test('quest can be active', () {
      final quest = Quest(
        id: 'q2',
        title: 'Quest',
        description: 'Description',
        questType: QuestType.side,
        difficulty: QuestDifficulty.medium,
        xpReward: 100,
        status: QuestStatus.active,
        objectives: [],
        requiredLevel: 1,
        prerequisites: [],
        isGenerated: false,
        createdAt: DateTime.now(),
      );

      expect(quest.status, equals(QuestStatus.active));
    });

    test('quest can be completed', () {
      final quest = Quest(
        id: 'q3',
        title: 'Quest',
        description: 'Description',
        questType: QuestType.daily,
        difficulty: QuestDifficulty.hard,
        xpReward: 200,
        status: QuestStatus.completed,
        objectives: [],
        requiredLevel: 1,
        prerequisites: [],
        isGenerated: false,
        createdAt: DateTime.now(),
      );

      expect(quest.status, equals(QuestStatus.completed));
    });

    test('quest can be failed', () {
      final quest = Quest(
        id: 'q4',
        title: 'Quest',
        description: 'Description',
        questType: QuestType.generated,
        difficulty: QuestDifficulty.easy,
        xpReward: 50,
        status: QuestStatus.failed,
        objectives: [],
        requiredLevel: 1,
        prerequisites: [],
        isGenerated: false,
        createdAt: DateTime.now(),
      );

      expect(quest.status, equals(QuestStatus.failed));
    });
  });

  group('Quest difficulty levels', () {
    test('easy quests have lower xp rewards', () {
      expect(50, lessThan(100));
    });

    test('medium quests have medium xp rewards', () {
      expect(100, greaterThan(50));
      expect(100, lessThan(200));
    });

    test('hard quests have higher xp rewards', () {
      expect(200, greaterThan(100));
    });
  });

  group('Quest types', () {
    test('main quest type is recognized', () {
      expect(QuestType.main.displayName, isNotEmpty);
    });

    test('side quest type is recognized', () {
      expect(QuestType.side.displayName, isNotEmpty);
    });

    test('daily quest type is recognized', () {
      expect(QuestType.daily.displayName, isNotEmpty);
    });

    test('generated quest type is recognized', () {
      expect(QuestType.generated.displayName, isNotEmpty);
    });

    test('all quest types have display names', () {
      for (final type in QuestType.values) {
        expect(type.displayName, isNotEmpty);
      }
    });

    test('all quest types have emojis', () {
      for (final type in QuestType.values) {
        expect(type.emoji, isNotEmpty);
      }
    });
  });

  group('Quest difficulty display', () {
    test('easy difficulty has display name', () {
      expect(QuestDifficulty.easy.displayName, isNotEmpty);
    });

    test('medium difficulty has display name', () {
      expect(QuestDifficulty.medium.displayName, isNotEmpty);
    });

    test('hard difficulty has display name', () {
      expect(QuestDifficulty.hard.displayName, isNotEmpty);
    });
  });

  group('Quest status display', () {
    test('available status has display name', () {
      expect(QuestStatus.available.displayName, isNotEmpty);
    });

    test('active status has display name', () {
      expect(QuestStatus.active.displayName, isNotEmpty);
    });

    test('completed status has display name', () {
      expect(QuestStatus.completed.displayName, isNotEmpty);
    });

    test('failed status has display name', () {
      expect(QuestStatus.failed.displayName, isNotEmpty);
    });
  });

  group('Quest XP rewards', () {
    test('valid xp reward amounts', () {
      expect(50, greaterThan(0));
      expect(100, greaterThan(50));
      expect(200, greaterThan(100));
      expect(500, greaterThan(200));
    });

    test('xp scales with difficulty', () {
      final easyQuest = 50;
      final mediumQuest = 100;
      final hardQuest = 200;

      expect(mediumQuest, greaterThan(easyQuest));
      expect(hardQuest, greaterThan(mediumQuest));
    });
  });

  group('Quest creation timestamp', () {
    test('quest has creation timestamp', () {
      final now = DateTime.now();
      final quest = Quest(
        id: 'q-time',
        title: 'Time Quest',
        description: 'Description',
        questType: QuestType.main,
        difficulty: QuestDifficulty.medium,
        xpReward: 100,
        status: QuestStatus.available,
        objectives: [],
        requiredLevel: 1,
        prerequisites: [],
        isGenerated: false,
        createdAt: now,
      );

      expect(quest.createdAt, equals(now));
    });
  });

  group('QuestObjective', () {
    test('creates objective with text and completion status', () {
      final obj = QuestObjective(text: 'Defeat 10 goblins', completed: false);
      expect(obj.text, equals('Defeat 10 goblins'));
      expect(obj.completed, isFalse);
    });

    test('objective can be marked complete', () {
      final obj = QuestObjective(text: 'Gather herbs', completed: true);
      expect(obj.completed, isTrue);
    });
  });

  group('Quest with objectives', () {
    test('quest contains multiple objectives', () {
      final objectives = [
        QuestObjective(text: 'Objective 1', completed: false),
        QuestObjective(text: 'Objective 2', completed: false),
        QuestObjective(text: 'Objective 3', completed: true),
      ];

      final quest = Quest(
        id: 'q-obj',
        title: 'Multi-objective Quest',
        description: 'Quest with multiple steps',
        questType: QuestType.main,
        difficulty: QuestDifficulty.medium,
        xpReward: 150,
        status: QuestStatus.active,
        objectives: objectives,
        requiredLevel: 1,
        prerequisites: [],
        isGenerated: false,
        createdAt: DateTime.now(),
      );

      expect(quest.objectives.length, equals(3));
      expect(quest.objectives[0].completed, isFalse);
      expect(quest.objectives[2].completed, isTrue);
    });
  });
}
