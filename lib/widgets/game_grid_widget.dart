// Widget for displaying and interacting with the game grid
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../models/game_state.dart';
import 'grid_painter.dart';

class GameGridWidget extends StatelessWidget {
  final GameController gameController;
  final double gridSize;

  const GameGridWidget({
    Key? key,
    required this.gameController,
    this.gridSize = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final grid = gameController.gameState.grid.value;

      return GestureDetector(
        onTapUp: (details) => _handleGridTap(context, details),
        child: Container(
          width: gridSize,
          height: gridSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black45, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: CustomPaint(
            painter: GridPainter(grid: grid, showGridLines: true),
            size: Size(gridSize, gridSize),
          ),
        ),
      );
    });
  }

  void _handleGridTap(BuildContext context, TapUpDetails details) {
    final gameState = gameController.gameState;

    // Only handle taps during the placing phase
    if (!gameState.isPlacing) return;

    // Get the local position inside the grid
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    // Calculate grid coordinates
    final grid = gameState.grid.value;
    final cellWidth = gridSize / grid.columns;
    final cellHeight = gridSize / grid.rows;

    final x = (localPosition.dx / cellWidth).floor();
    final y = (localPosition.dy / cellHeight).floor();

    // Ensure coordinates are within bounds
    if (x >= 0 && x < grid.columns && y >= 0 && y < grid.rows) {
      // Place a source at the tapped position
      gameController.placeSource(x, y);
    }
  }
}
