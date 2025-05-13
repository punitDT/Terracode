// Game model class
import 'package:flutter/material.dart';
import 'game_mode.dart';
import 'player.dart';

class Game {
  final GameMode mode;
  final int rows;
  final int columns;
  final List<Player> players;
  
  Game({
    required this.mode,
    this.rows = 15,
    this.columns = 15,
    required this.players,
  });
  
  // Factory method for default 2-player game
  factory Game.defaultTwoPlayer(GameMode mode) {
    return Game(
      mode: mode,
      players: [
        Player(
          id: 1,
          name: 'Player 1',
          color: Colors.red,
        ),
        Player(
          id: 2,
          name: 'Player 2',
          color: Colors.blue,
        ),
      ],
    );
  }
  
  // Factory method for classic mode
  factory Game.classic() {
    return Game.defaultTwoPlayer(GameMode.classic());
  }
  
  // Factory method for battlefield mode
  factory Game.battlefield() {
    return Game.defaultTwoPlayer(GameMode.battlefield());
  }
  
  // Factory method for power mode
  factory Game.powerMode() {
    return Game.defaultTwoPlayer(GameMode.powerMode());
  }
  
  // Factory method for puzzle mode (single player)
  factory Game.puzzle() {
    return Game(
      mode: GameMode.puzzle(),
      players: [
        Player(
          id: 1,
          name: 'Player',
          color: Colors.green,
        ),
      ],
    );
  }
  
  // Create a copy with modified attributes
  Game copyWith({
    GameMode? mode,
    int? rows,
    int? columns,
    List<Player>? players,
  }) {
    return Game(
      mode: mode ?? this.mode,
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      players: players ?? List.from(this.players),
    );
  }
}
