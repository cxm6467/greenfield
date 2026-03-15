enum MiniGameType {
  ringToss,
  memoryMatch,
  diceRoll,
  whackAMole,
  simonSays,
  flappyBird,
  coinCollector,
  patternMatch,
  speedClicker,
}

enum MiniGameTheme {
  goblin,
  elf,
  undead,
  wizard,
  tavern,
  warrior,
  ranger,
  dragon,
}

class MiniGameResult {
  final bool won;
  final int gemsEarned;
  final int score;
  final MiniGameType gameType;
  final MiniGameTheme theme;

  MiniGameResult({
    required this.won,
    required this.gemsEarned,
    required this.score,
    required this.gameType,
    required this.theme,
  });

  factory MiniGameResult.win({
    required MiniGameType gameType,
    required MiniGameTheme theme,
    required int score,
  }) {
    return MiniGameResult(
      won: true,
      gemsEarned: 10 + (score ~/ 10),
      score: score,
      gameType: gameType,
      theme: theme,
    );
  }

  factory MiniGameResult.lose({
    required MiniGameType gameType,
    required MiniGameTheme theme,
    required int score,
  }) {
    return MiniGameResult(
      won: false,
      gemsEarned: 2,
      score: score,
      gameType: gameType,
      theme: theme,
    );
  }
}

extension MiniGameTypeExt on MiniGameType {
  String get displayName {
    switch (this) {
      case MiniGameType.ringToss:
        return 'Ring Toss';
      case MiniGameType.memoryMatch:
        return 'Memory Match';
      case MiniGameType.diceRoll:
        return 'Dice Roll';
      case MiniGameType.whackAMole:
        return 'Whack-a-Mole';
      case MiniGameType.simonSays:
        return 'Simon Says';
      case MiniGameType.flappyBird:
        return 'Flappy Bird';
      case MiniGameType.coinCollector:
        return 'Coin Collector';
      case MiniGameType.patternMatch:
        return 'Pattern Match';
      case MiniGameType.speedClicker:
        return 'Speed Clicker';
    }
  }

  String get emoji {
    switch (this) {
      case MiniGameType.ringToss:
        return '💍';
      case MiniGameType.memoryMatch:
        return '🎴';
      case MiniGameType.diceRoll:
        return '🎲';
      case MiniGameType.whackAMole:
        return '🔨';
      case MiniGameType.simonSays:
        return '🎮';
      case MiniGameType.flappyBird:
        return '🐦';
      case MiniGameType.coinCollector:
        return '🪙';
      case MiniGameType.patternMatch:
        return '🧩';
      case MiniGameType.speedClicker:
        return '⚡';
    }
  }
}

extension MiniGameThemeExt on MiniGameTheme {
  String get displayName {
    switch (this) {
      case MiniGameTheme.goblin:
        return 'Goblin';
      case MiniGameTheme.elf:
        return 'Elf';
      case MiniGameTheme.undead:
        return 'Undead';
      case MiniGameTheme.wizard:
        return 'Wizard';
      case MiniGameTheme.tavern:
        return 'Tavern';
      case MiniGameTheme.warrior:
        return 'Warrior';
      case MiniGameTheme.ranger:
        return 'Ranger';
      case MiniGameTheme.dragon:
        return 'Dragon';
    }
  }

  String get emoji {
    switch (this) {
      case MiniGameTheme.goblin:
        return '🗡️';
      case MiniGameTheme.elf:
        return '🌿';
      case MiniGameTheme.undead:
        return '🧟';
      case MiniGameTheme.wizard:
        return '🧙';
      case MiniGameTheme.tavern:
        return '🍺';
      case MiniGameTheme.warrior:
        return '⚔️';
      case MiniGameTheme.ranger:
        return '🌲';
      case MiniGameTheme.dragon:
        return '🐉';
    }
  }
}
