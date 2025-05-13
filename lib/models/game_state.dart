// Game state model representing the current state of the game
import 'package:get/get.dart';
import '../models/grid.dart';
import '../models/player.dart';
import '../models/game_mode.dart';

enum GameStatus {
  setup,   // Initial setup phase
  placing, // Placing color sources
  running, // Game is running (colors spreading)
  paused,  // Game is paused
  ended    // Game has ended
}

class GameState {
  final Rx<GameStatus> status = GameStatus.setup.obs;
  final Rx<Grid> grid;
  final RxList<Player> players = <Player>[].obs;
  final Rx<GameMode> gameMode;
  final RxInt currentRound = 1.obs;
  final RxInt currentPlayerIndex = 0.obs;
  final RxInt countdown = 3.obs; // Countdown before starting color spread
  final RxBool isReady = false.obs;
  final RxMap<int, int> coverage = <int, int>{}.obs; // Player ID to cell count

  GameState({
    required int rows,
    required int columns,
    required GameMode mode,
  }) : grid = Grid(rows: rows, columns: columns).obs,
       gameMode = mode.obs;

  // Get the current player
  Player get currentPlayer => players[currentPlayerIndex.value];
  
  // Get the game status as a string
  String get statusText => status.value.toString().split('.').last;
  
  // Check if the game is in setup phase
  bool get isSetup => status.value == GameStatus.setup;
  
  // Check if the game is in placing phase
  bool get isPlacing => status.value == GameStatus.placing;
  
  // Check if the game is running
  bool get isRunning => status.value == GameStatus.running;
  
  // Check if the game is paused
  bool get isPaused => status.value == GameStatus.paused;
  
  // Check if the game has ended
  bool get isEnded => status.value == GameStatus.ended;
  
  // Get the winner of the game
  Player? getWinner() {
    if (!isEnded) return null;
    
    if (players.length == 1) return players[0];
    
    // Find player with highest coverage
    int maxCoverage = 0;
    Player? winner;
    
    for (final player in players) {
      final playerCoverage = coverage[player.id] ?? 0;
      if (playerCoverage > maxCoverage) {
        maxCoverage = playerCoverage;
        winner = player;
      }
    }
    
    return winner;
  }

  // Update player coverage
  void updateCoverage() {
    final Map<int, int> newCoverage = {};
    
    // Reset all player coverage to 0
    for (final player in players) {
      newCoverage[player.id] = 0;
    }
    
    // Count occupied cells for each player
    for (int y = 0; y < grid.value.rows; y++) {
      for (int x = 0; x < grid.value.columns; x++) {
        final cell = grid.value.cells[y][x];
        if (cell.isOccupied && cell.playerId != null) {
          final playerId = cell.playerId!;
          newCoverage[playerId] = (newCoverage[playerId] ?? 0) + 1;
        }
      }
    }
    
    coverage.value = newCoverage;
  }
  
  // Move to the next player
  void nextPlayer() {
    currentPlayerIndex.value = (currentPlayerIndex.value + 1) % players.length;
  }
  
  // Move to the next round
  void nextRound() {
    currentRound.value++;
    currentPlayerIndex.value = 0;
  }
  
  // Reset the game state
  void reset({int? rows, int? columns, GameMode? mode}) {
    status.value = GameStatus.setup;
    if (rows != null && columns != null) {
      grid.value = Grid(rows: rows, columns: columns);
    } else {
      grid.value.reset();
    }
    
    currentRound.value = 1;
    currentPlayerIndex.value = 0;
    countdown.value = 3;
    isReady.value = false;
    coverage.clear();
    
    if (mode != null) {
      gameMode.value = mode;
    }
  }
}
