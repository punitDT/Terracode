// Main game screen that hosts the game grid and controls
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/game.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../widgets/game_grid_widget.dart';

class GameScreen extends StatelessWidget {
  final Game game;
  late final GameController gameController;

  GameScreen({Key? key, required this.game}) : super(key: key) {
    gameController = Get.put(GameController());
    // Initialize the game with the provided settings
    gameController.resetGame(
      rows: game.rows,
      columns: game.columns,
      mode: game.mode,
      players: game.players,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Grid: Color Clash'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Restart Game',
          ),
        ],
      ),
      body: Obx(() {
        final gameState = gameController.gameState;

        return Column(
          children: [
            // Game status bar
            _buildStatusBar(gameState),

            // Main game content
            Expanded(
              child: Center(
                child: Row(
                  children: [
                    // Player 1 info
                    if (gameState.players.isNotEmpty)
                      _buildPlayerInfo(gameState.players[0], gameState),

                    // Game grid
                    Expanded(
                      child: Center(
                        child: GameGridWidget(
                          gameController: gameController,
                          gridSize: 480, // Adjust based on screen size
                        ),
                      ),
                    ),

                    // Player 2 info
                    if (gameState.players.length > 1)
                      _buildPlayerInfo(gameState.players[1], gameState),
                  ],
                ),
              ),
            ),

            // Game controls
            _buildGameControls(gameState),
          ],
        );
      }),
    );
  }

  Widget _buildStatusBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Game mode
          Text(
            'Mode: ${gameState.gameMode.value.name}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // Game status
          Text(
            'Status: ${gameState.statusText}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          // Current round (if applicable)
          if (gameState.gameMode.value.hasRounds)
            Text(
              'Round: ${gameState.currentRound}/${gameState.gameMode.value.maxRounds}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

          // Countdown (if running)
          if (gameState.isRunning && gameState.countdown.value > 0)
            Text(
              'Starting in: ${gameState.countdown.value}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(Player player, GameState gameState) {
    final isCurrentPlayer =
        gameState.isPlacing &&
        gameState.currentPlayerIndex.value == gameState.players.indexOf(player);

    final coverage = gameState.coverage[player.id] ?? 0;
    final totalCells = gameState.grid.value.rows * gameState.grid.value.columns;
    final coveragePercent =
        totalCells > 0
            ? (coverage / totalCells * 100).toStringAsFixed(1)
            : '0.0';

    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.grey.shade200 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player color indicator
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: player.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black45),
            ),
          ),
          const SizedBox(height: 8),

          // Player name
          Text(
            player.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCurrentPlayer ? Colors.black : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),

          // Player score/coverage
          Text(
            'Coverage: $coveragePercent%',
            style: TextStyle(
              fontSize: 14,
              color: isCurrentPlayer ? Colors.black : Colors.black54,
            ),
          ),

          if (isCurrentPlayer && gameState.isPlacing)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Your Turn',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          if (gameState.isEnded && gameState.getWinner()?.id == player.id)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'WINNER!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameControls(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Start button (during placing phase)
          if (gameState.isPlacing && gameState.isReady.value)
            ElevatedButton.icon(
              onPressed: () => gameController.startGame(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

          // Pause/Resume button (during running phase)
          if (gameState.isRunning)
            ElevatedButton.icon(
              onPressed: () => gameController.pauseGame(),
              icon: const Icon(Icons.pause),
              label: const Text('Pause'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

          if (gameState.isPaused)
            ElevatedButton.icon(
              onPressed: () => gameController.resumeGame(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),

          // Restart button (always available)
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('New Game'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _resetGame() {
    gameController.resetGame(
      rows: game.rows,
      columns: game.columns,
      mode: game.mode,
      players: game.players,
    );
  }
}
