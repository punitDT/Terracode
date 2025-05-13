// Game controller to manage the game logic
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/cell.dart';
import '../models/grid.dart';
import '../models/player.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';

class GameController extends GetxController {
  late GameState gameState;
  late SoundService _soundService;
  Timer? _gameTimer;
  Timer? _countdownTimer;
  final int _timerInterval = 100; // milliseconds

  @override
  void onInit() {
    super.onInit();
    // Initialize sound service
    _soundService = Get.put(SoundService());

    // Initialize with default settings
    resetGame(
      rows: 15,
      columns: 15,
      mode: GameMode.classic(),
      players: [
        Player(id: 1, name: 'Player 1', color: Colors.red),
        Player(id: 2, name: 'Player 2', color: Colors.blue),
      ],
    );
  }

  @override
  void onClose() {
    _stopTimers();
    super.onClose();
  }

  // Reset the game with new settings
  void resetGame({
    required int rows,
    required int columns,
    required GameMode mode,
    required List<Player> players,
  }) {
    _stopTimers();

    // Initialize game state
    gameState = GameState(rows: rows, columns: columns, mode: mode);

    // Set players
    gameState.players.clear();
    gameState.players.addAll(players);

    // If the game mode has obstacles, generate them
    if (mode.hasObstacles) {
      final density = mode.settings['obstacleDensity'] ?? 0.1;
      gameState.grid.value.generateRandomObstacles(density);
    }

    // If the game mode has special cells, place them
    if (mode.hasSpecialCells) {
      final speedBoostCount = mode.settings['speedBoostCount'] ?? 3;
      final absorptionCount = mode.settings['absorptionCount'] ?? 3;
      gameState.grid.value.placeSpecialCells(speedBoostCount, absorptionCount);
    }

    // Move to placing phase
    gameState.status.value = GameStatus.placing;
  }

  // Place a color source on the grid
  bool placeSource(int x, int y) {
    // Check if we are in the placing phase
    if (!gameState.isPlacing) return false;

    // Check if the cell is empty
    final cell = gameState.grid.value.cells[y][x];
    if (!cell.isEmpty) return false;

    // Get the current player
    final player = gameState.currentPlayer;

    // Update the cell
    gameState.grid.value.updateCellAt(
      x,
      y,
      type: CellType.source,
      state: CellState.occupied,
      color: player.color,
      playerId: player.id,
      spreadProgress: 1.0, // Source cells are fully colored
    );

    // Play sound effect for placing source
    _soundService.playSound('place_source');

    // Move to the next player
    gameState.nextPlayer();

    // If all players have placed their sources, we're ready to start
    final sourcesCount = _countSourceCells();
    final expectedSources =
        gameState.players.length * gameState.gameMode.value.sourcesPerPlayer;

    if (sourcesCount >= expectedSources) {
      gameState.isReady.value = true;
    }

    return true;
  }

  // Start the game (begin color spreading)
  void startGame() {
    if (!gameState.isReady.value || !gameState.isPlacing) return;

    // Start countdown
    gameState.status.value = GameStatus.running;
    _startCountdown();
  }

  // Pause the game
  void pauseGame() {
    if (gameState.isRunning) {
      gameState.status.value = GameStatus.paused;
      _gameTimer?.cancel();
    }
  }

  // Resume the game
  void resumeGame() {
    if (gameState.isPaused) {
      gameState.status.value = GameStatus.running;
      _startGameTimer();
    }
  }

  // End the game
  void endGame() {
    _stopTimers();
    gameState.status.value = GameStatus.ended;
    gameState.updateCoverage();

    // Play game over sound
    _soundService.playSound('game_over');
  }

  // Countdown before starting color spread
  void _startCountdown() {
    gameState.countdown.value = 3;

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      gameState.countdown.value--;

      // Play countdown sound
      _soundService.playSound('countdown');

      if (gameState.countdown.value <= 0) {
        timer.cancel();
        _startGameTimer();
      }
    });
  }

  // Start the game timer for color spreading
  void _startGameTimer() {
    _gameTimer = Timer.periodic(Duration(milliseconds: _timerInterval), (
      timer,
    ) {
      _updateColorSpread();

      // Check if the game should end
      if (_shouldEndGame()) {
        endGame();
      }
    });
  }

  // Update color spreading each tick
  void _updateColorSpread() {
    final grid = gameState.grid.value;
    final spreadCandidates = <Cell>[];

    // First pass: Find all cells that can spread to neighbors
    for (int y = 0; y < grid.rows; y++) {
      for (int x = 0; x < grid.columns; x++) {
        final cell = grid.cells[y][x];

        // Only occupied cells can spread
        if (cell.isOccupied && cell.playerId != null) {
          spreadCandidates.add(cell);
        }
      }
    }

    // Second pass: Spread colors to neighbors
    for (final cell in spreadCandidates) {
      _spreadFromCell(cell);
    }

    // Update coverage statistics
    gameState.updateCoverage();
  }

  // Spread color from a single cell to its neighbors
  void _spreadFromCell(Cell cell) {
    final grid = gameState.grid.value;
    final adjacentCells = grid.getAdjacentCells(cell.x, cell.y);

    for (final adjacentCell in adjacentCells) {
      // Skip walls and already colored source cells
      if (adjacentCell.isWall || adjacentCell.isSource) continue;

      // Handle empty cells
      if (adjacentCell.isEmpty) {
        _startSpreadToCell(adjacentCell, cell);
        continue;
      }

      // Handle mixing when colors from different players meet
      if (adjacentCell.isOccupied &&
          adjacentCell.playerId != null &&
          adjacentCell.playerId != cell.playerId) {
        _handleColorMixing(adjacentCell, cell);
        continue;
      }

      // Handle special cells
      if (adjacentCell.isSpeedBoost) {
        _handleSpeedBoost(adjacentCell, cell);
        continue;
      }

      if (adjacentCell.isAbsorption) {
        _handleAbsorption(adjacentCell, cell);
        continue;
      }
    }
  }

  // Start spreading color to an empty cell
  void _startSpreadToCell(Cell targetCell, Cell sourceCell) {
    final player = gameState.players.firstWhere(
      (p) => p.id == sourceCell.playerId,
      orElse: () => gameState.players[0],
    );

    // Calculate spread speed (possibly modified by special cells)
    int spreadSpeed = sourceCell.spreadSpeed;

    // Update the target cell to start spreading
    gameState.grid.value.updateCellAt(
      targetCell.x,
      targetCell.y,
      state: CellState.occupied,
      color: player.color,
      playerId: player.id,
      spreadProgress: 0.1, // Start with a small value
      spreadSpeed: spreadSpeed,
    );
  }

  // Update spreading progress for cells in progress
  void _updateSpreadProgress() {
    final grid = gameState.grid.value;

    for (int y = 0; y < grid.rows; y++) {
      for (int x = 0; x < grid.columns; x++) {
        final cell = grid.cells[y][x];

        // Skip fully spread or non-spreading cells
        if (!cell.isOccupied || cell.spreadProgress >= 1.0) continue;

        // Increase spread progress
        double newProgress = cell.spreadProgress + (0.1 * cell.spreadSpeed);
        newProgress = min(1.0, newProgress); // Cap at 1.0

        grid.updateCellAt(x, y, spreadProgress: newProgress);
      }
    }
  }

  // Handle when colors from different players mix
  void _handleColorMixing(Cell targetCell, Cell sourceCell) {
    // In classic mode, mixing creates a neutral cell
    if (gameState.gameMode.value.type == GameModeType.classic) {
      gameState.grid.value.updateCellAt(
        targetCell.x,
        targetCell.y,
        state: CellState.neutral,
        color: Colors.grey,
        playerId: null,
      );
      return;
    }

    // In other modes, mixing depends on various factors
    // For now, implement a basic version where the stronger color wins
    final Random random = Random();
    final bool sourceWins = random.nextDouble() > 0.5;

    if (sourceWins) {
      gameState.grid.value.updateCellAt(
        targetCell.x,
        targetCell.y,
        color: sourceCell.color,
        playerId: sourceCell.playerId,
      );
    }
    // If target wins, do nothing as it keeps its current color
  }

  // Handle speed boost cells
  void _handleSpeedBoost(Cell targetCell, Cell sourceCell) {
    final player = gameState.players.firstWhere(
      (p) => p.id == sourceCell.playerId,
      orElse: () => gameState.players[0],
    );

    // Convert speed boost to normal cell with increased speed
    gameState.grid.value.updateCellAt(
      targetCell.x,
      targetCell.y,
      type: CellType.empty,
      state: CellState.occupied,
      color: player.color,
      playerId: player.id,
      spreadProgress: 0.1,
      spreadSpeed: 2, // Double spread speed
    );
  }

  // Handle absorption cells
  void _handleAbsorption(Cell targetCell, Cell sourceCell) {
    // Absorption cells slowly convert adjacent enemy cells
    // For simplicity, let's just convert them with a delay
    final player = gameState.players.firstWhere(
      (p) => p.id == sourceCell.playerId,
      orElse: () => gameState.players[0],
    );

    // Convert absorption cell to player's cell but with slow spread
    gameState.grid.value.updateCellAt(
      targetCell.x,
      targetCell.y,
      type: CellType.empty,
      state: CellState.occupied,
      color: player.color,
      playerId: player.id,
      spreadProgress: 0.05, // Start with very small progress
      spreadSpeed: 1, // Normal spread speed
    );
  }

  // Helper function to count source cells
  int _countSourceCells() {
    final grid = gameState.grid.value;
    int count = 0;

    for (int y = 0; y < grid.rows; y++) {
      for (int x = 0; x < grid.columns; x++) {
        if (grid.cells[y][x].isSource) {
          count++;
        }
      }
    }

    return count;
  }

  // Check if the game should end
  bool _shouldEndGame() {
    // Game ends when all cells are colored or no more spreading is possible
    final grid = gameState.grid.value;
    bool canSpreadFurther = false;

    // Count colored cells and check if any cell can still spread
    for (int y = 0; y < grid.rows; y++) {
      for (int x = 0; x < grid.columns; x++) {
        final cell = grid.cells[y][x];

        if (cell.isOccupied) {
          // Check if this cell has empty neighbors (can spread)
          final adjacentCells = grid.getAdjacentCells(x, y);
          for (final adjacentCell in adjacentCells) {
            if (adjacentCell.isEmpty) {
              canSpreadFurther = true;
              break;
            }
          }
        }
      }
    }

    return !canSpreadFurther;
  }

  // Stop all timers
  void _stopTimers() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
  }
}
