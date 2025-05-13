// Cell model representing a grid cell in the game
import 'package:flutter/material.dart';

enum CellType { empty, wall, source, speedBoost, absorption }

enum CellState { neutral, occupied, mixing }

class Cell {
  final int x;
  final int y;
  CellType type;
  CellState state;
  Color? color;
  int? playerId;
  double spreadProgress; // 0.0 to 1.0 for animation
  int spreadSpeed;

  Cell({
    required this.x,
    required this.y,
    this.type = CellType.empty,
    this.state = CellState.neutral,
    this.color,
    this.playerId,
    this.spreadProgress = 0.0,
    this.spreadSpeed = 1,
  });

  bool get isEmpty => type == CellType.empty && state == CellState.neutral;
  bool get isWall => type == CellType.wall;
  bool get isSource => type == CellType.source;
  bool get isSpeedBoost => type == CellType.speedBoost;
  bool get isAbsorption => type == CellType.absorption;
  bool get isOccupied => state == CellState.occupied;
  bool get isMixing => state == CellState.mixing;

  Cell copyWith({
    int? x,
    int? y,
    CellType? type,
    CellState? state,
    Color? color,
    int? playerId,
    double? spreadProgress,
    int? spreadSpeed,
  }) {
    return Cell(
      x: x ?? this.x,
      y: y ?? this.y,
      type: type ?? this.type,
      state: state ?? this.state,
      color: color ?? this.color,
      playerId: playerId ?? this.playerId,
      spreadProgress: spreadProgress ?? this.spreadProgress,
      spreadSpeed: spreadSpeed ?? this.spreadSpeed,
    );
  }
}
