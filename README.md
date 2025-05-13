# 🎮 Flow Grid: Color Clash

A 2D color strategy game built with Flutter where players conquer a dynamic grid by placing color sources and watching their colors spread in real-time.

---

## 📦 Features

### 🧠 Gameplay Mechanics

- **Grid-Based Combat**: A turn-based, grid-based arena where players compete to control territory.
- **Color Spreading**: Each player places color source cells. Once the round starts, colors spread in waves across the grid.
- **Collision Handling**: If two colors meet in the same cell, it becomes neutral or creates a “mixed” state depending on game mode.
- **Strategic Play**: Place sources strategically to control key zones and block opponents.
- **Obstacles & Boosters**:
  - Walls block color flow.
  - Speed Boost Cells accelerate spreading.
  - Absorption Cells steal adjacent enemy tiles slowly.

### 🎮 Game Modes

| Mode         | Description |
|--------------|-------------|
| Classic      | One round, place 1 source per player. Simple obstacles. |
| Battlefield  | Multi-round battles with dynamic obstacles and modifiers. |
| Power Mode   | Use special abilities (double speed, slow enemy, block area). |
| Puzzle Mode  | Pre-defined levels with limited moves and win conditions. |

### ✨ Visuals & UX

- Custom grid animations using Flutter's `CustomPainter` or `Flame`.
- Smooth color wave animation.
- Responsive UI for Android, iOS, and Web.
- Sound effects and visual feedback for each move.

---

## 🧩 Tech Stack

- **Framework**: Flutter (3.x+)
- **State Management**: GetX
- **Game Engine**: Custom 2D logic / Optional `flame` for enhancements
- **State Management**: Riverpod or Bloc
- **Rendering**: `CustomPainter` or Flame canvas
- **Audio**: `audioplayers` or `just_audio`
- **Persistence**: `shared_preferences` or `hive`

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK installed
- Dart enabled
- Android Studio / VS Code
- Optional: GitHub Copilot enabled

### Installation

```bash
git clone https://github.com/punitDT/Terracode.git
cd flow-grid-color-clash
flutter pub get
flutter run
