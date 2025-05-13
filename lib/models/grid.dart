// Grid model representing the game board
import 'dart:math';
import 'package:flutter/material.dart';
import 'cell.dart';

class Grid {
  final int rows;
  final int columns;
  late List<List<Cell>> cells;

  Grid({required this.rows, required this.columns}) {
    // Initialize grid with empty cells
    cells = List.generate(
      rows,
      (y) => List.generate(columns, (x) => Cell(x: x, y: y)),
    );
  }

  Cell getCellAt(int x, int y) {
    if (x >= 0 && x < columns && y >= 0 && y < rows) {
      return cells[y][x];
    }
    // Return null or throw an exception if out of bounds
    throw RangeError('Cell position out of bounds');
  }

  void setCellAt(int x, int y, Cell cell) {
    if (x >= 0 && x < columns && y >= 0 && y < rows) {
      cells[y][x] = cell;
    } else {
      throw RangeError('Cell position out of bounds');
    }
  }

  void updateCellAt(
    int x,
    int y, {
    CellType? type,
    CellState? state,
    Color? color,
    int? playerId,
    double? spreadProgress,
    int? spreadSpeed,
  }) {
    if (x >= 0 && x < columns && y >= 0 && y < rows) {
      cells[y][x] = cells[y][x].copyWith(
        type: type,
        state: state,
        color: color,
        playerId: playerId,
        spreadProgress: spreadProgress,
        spreadSpeed: spreadSpeed,
      );
    } else {
      throw RangeError('Cell position out of bounds');
    }
  }

  List<Cell> getAdjacentCells(int x, int y) {
    List<Cell> adjacentCells = [];

    // Check all four directions (up, right, down, left)
    final directions = [
      [0, -1], // up
      [1, 0], // right
      [0, 1], // down
      [-1, 0], // left
    ];

    for (final dir in directions) {
      final newX = x + dir[0];
      final newY = y + dir[1];

      try {
        adjacentCells.add(getCellAt(newX, newY));
      } catch (e) {
        // Skip cells that are out of bounds
        continue;
      }
    }

    return adjacentCells;
  }

  // Generate random obstacles
  void generateRandomObstacles(double density) {
    final random = Random();

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        // Skip if cell is already not empty
        if (!cells[y][x].isEmpty) continue;

        // Add wall with probability based on density
        if (random.nextDouble() < density) {
          updateCellAt(x, y, type: CellType.wall);
        }
      }
    }
  }

  // Place special cells like speed boosts or absorption cells
  void placeSpecialCells(int speedBoostCount, int absorptionCount) {
    final random = Random();
    final emptyCells = _getEmptyCells();

    // Place speed boost cells
    for (int i = 0; i < min(speedBoostCount, emptyCells.length); i++) {
      final index = random.nextInt(emptyCells.length);
      final cell = emptyCells[index];
      updateCellAt(cell.x, cell.y, type: CellType.speedBoost);
      emptyCells.removeAt(index);
    }

    // Place absorption cells
    for (int i = 0; i < min(absorptionCount, emptyCells.length); i++) {
      final index = random.nextInt(emptyCells.length);
      final cell = emptyCells[index];
      updateCellAt(cell.x, cell.y, type: CellType.absorption);
      emptyCells.removeAt(index);
    }
  }

  // Helper to get all empty cells
  List<Cell> _getEmptyCells() {
    List<Cell> emptyCells = [];

    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < columns; x++) {
        if (cells[y][x].isEmpty) {
          emptyCells.add(cells[y][x]);
        }
      }
    }

    return emptyCells;
  }

  // Reset the grid to initial state
  void reset() {
    cells = List.generate(
      rows,
      (y) => List.generate(columns, (x) => Cell(x: x, y: y)),
    );
  }
}
