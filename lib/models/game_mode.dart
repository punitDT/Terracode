// GameMode model representing different game modes
enum GameModeType {
  classic,
  battlefield,
  powerMode,
  puzzle
}

class GameMode {
  final GameModeType type;
  final String name;
  final String description;
  final int sourcesPerPlayer;
  final bool hasObstacles;
  final bool hasSpecialCells;
  final bool hasAbilities;
  final bool hasRounds;
  final int maxRounds;
  final Map<String, dynamic> settings;
  
  GameMode({
    required this.type,
    required this.name,
    required this.description,
    this.sourcesPerPlayer = 1,
    this.hasObstacles = false,
    this.hasSpecialCells = false,
    this.hasAbilities = false,
    this.hasRounds = false,
    this.maxRounds = 1,
    this.settings = const {},
  });
  
  factory GameMode.classic() {
    return GameMode(
      type: GameModeType.classic,
      name: 'Classic',
      description: 'One round, place 1 source per player. Simple obstacles.',
      hasObstacles: true,
    );
  }
  
  factory GameMode.battlefield() {
    return GameMode(
      type: GameModeType.battlefield,
      name: 'Battlefield',
      description: 'Multi-round battles with dynamic obstacles and modifiers.',
      sourcesPerPlayer: 2,
      hasObstacles: true,
      hasSpecialCells: true,
      hasRounds: true,
      maxRounds: 3,
    );
  }
  
  factory GameMode.powerMode() {
    return GameMode(
      type: GameModeType.powerMode,
      name: 'Power Mode',
      description: 'Use special abilities (double speed, slow enemy, block area).',
      sourcesPerPlayer: 1,
      hasObstacles: true,
      hasSpecialCells: true,
      hasAbilities: true,
      settings: {
        'availableAbilities': [
          'double_speed',
          'slow_enemy',
          'block_area',
        ],
      },
    );
  }
  
  factory GameMode.puzzle() {
    return GameMode(
      type: GameModeType.puzzle,
      name: 'Puzzle Mode',
      description: 'Pre-defined levels with limited moves and win conditions.',
      sourcesPerPlayer: 1,
      hasObstacles: true,
      hasSpecialCells: true,
      settings: {
        'maxMoves': 5,
        'targetCoverage': 0.6, // 60% coverage to win
      },
    );
  }
}
