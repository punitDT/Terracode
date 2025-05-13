// Player model representing a game player
import 'package:flutter/material.dart';

class Player {
  final int id;
  final String name;
  final Color color;
  int score;
  List<String> abilities; // For power mode
  bool isActive;

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.score = 0,
    this.abilities = const [],
    this.isActive = true,
  });

  void addScore(int points) {
    score += points;
  }

  Player copyWith({
    int? id,
    String? name,
    Color? color,
    int? score,
    List<String>? abilities,
    bool? isActive,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      score: score ?? this.score,
      abilities: abilities ?? this.abilities,
      isActive: isActive ?? this.isActive,
    );
  }
}
