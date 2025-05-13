// Home screen with game mode selection
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/game.dart';
import '../models/game_mode.dart';
import '../services/sound_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure sound service is initialized
    Get.put(SoundService());
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.deepPurple.shade800],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game title
                const Spacer(),
                const Text(
                  'Flow Grid: Color Clash',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black45,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'A 2D color strategy game',
                  style: TextStyle(fontSize: 18, color: Colors.white70),                ),
                const Spacer(),

                // Settings button
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      // Navigate to settings screen
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                      
                      // Play click sound
                      final soundService = Get.find<SoundService>();
                      if (soundService.soundEnabled.value) {
                        soundService.playSound('menu_click');
                      }
                    },
                    tooltip: 'Settings',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

                // Game mode cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGameModeCard(
                        context,
                        game: Game.classic(),
                        icon: Icons.grid_on,
                      ),
                      const SizedBox(width: 16),
                      _buildGameModeCard(
                        context,
                        game: Game.battlefield(),
                        icon: Icons.domain,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGameModeCard(
                        context,
                        game: Game.powerMode(),
                        icon: Icons.flash_on,
                      ),
                      const SizedBox(width: 16),
                      _buildGameModeCard(
                        context,
                        game: Game.puzzle(),
                        icon: Icons.extension,
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Credits
                const Text(
                  '© 2025 Terracode',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context, {
    required Game game,
    required IconData icon,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => _startGame(context, game),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: Colors.deepPurple),
                const SizedBox(height: 16),
                Text(
                  game.mode.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  game.mode.description,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, Game game) {
    // Navigate to the game screen
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => GameScreen(game: game)));
  }
}
