// Settings screen for game configuration
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({Key? key}) : super(key: key);

  final SoundService _soundService = Get.find<SoundService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.deepPurple],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Audio Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSoundToggle(),
                const SizedBox(height: 16),
                _buildSoundVolumeSlider(),
                const SizedBox(height: 16),
                _buildMusicToggle(),
                const SizedBox(height: 16),
                _buildMusicVolumeSlider(),
                const SizedBox(height: 32),
                const Text(
                  'Game Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                _buildGridSizeOption(context),
                const SizedBox(height: 16),
                _buildDifficultyOption(context),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Reset all settings to default
                      _soundService.soundEnabled.value = true;
                      _soundService.musicEnabled.value = true;
                      _soundService.setSoundVolume(0.7);
                      _soundService.setMusicVolume(0.5);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings reset to defaults'),
                        ),
                      );
                    },
                    child: const Text(
                      'Reset to Default',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoundToggle() {
    return Obx(
      () => SwitchListTile(
        title: const Text(
          'Sound Effects',
          style: TextStyle(color: Colors.white),
        ),
        value: _soundService.soundEnabled.value,
        onChanged: (value) {
          _soundService.toggleSound();
          if (value) {
            _soundService.playSound('menu_click');
          }
        },
        activeColor: Colors.deepPurpleAccent,
        tileColor: Colors.white10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildSoundVolumeSlider() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sound Volume: ${(_soundService.soundVolume.value * 100).toInt()}%',
              style: const TextStyle(color: Colors.white70),
            ),
            Slider(
              value: _soundService.soundVolume.value,
              onChanged:
                  _soundService.soundEnabled.value
                      ? (value) {
                        _soundService.setSoundVolume(value);
                      }
                      : null,
              activeColor: Colors.deepPurpleAccent,
              inactiveColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicToggle() {
    return Obx(
      () => SwitchListTile(
        title: const Text(
          'Background Music',
          style: TextStyle(color: Colors.white),
        ),
        value: _soundService.musicEnabled.value,
        onChanged: (value) {
          _soundService.toggleMusic();
          if (_soundService.soundEnabled.value) {
            _soundService.playSound('menu_click');
          }
        },
        activeColor: Colors.deepPurpleAccent,
        tileColor: Colors.white10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildMusicVolumeSlider() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Music Volume: ${(_soundService.musicVolume.value * 100).toInt()}%',
              style: const TextStyle(color: Colors.white70),
            ),
            Slider(
              value: _soundService.musicVolume.value,
              onChanged:
                  _soundService.musicEnabled.value
                      ? (value) {
                        _soundService.setMusicVolume(value);
                      }
                      : null,
              activeColor: Colors.deepPurpleAccent,
              inactiveColor: Colors.white24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridSizeOption(BuildContext context) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grid Size',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSizeButton(context, 'Small', 10),
                _buildSizeButton(context, 'Medium', 15),
                _buildSizeButton(context, 'Large', 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeButton(BuildContext context, String label, int size) {
    return ElevatedButton(
      onPressed: () {
        // Save grid size preference
        if (_soundService.soundEnabled.value) {
          _soundService.playSound('menu_click');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Grid size set to $label')));
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
      child: Text(label),
    );
  }

  Widget _buildDifficultyOption(BuildContext context) {
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Difficulty',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDifficultyButton(context, 'Easy'),
                _buildDifficultyButton(context, 'Medium'),
                _buildDifficultyButton(context, 'Hard'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyButton(BuildContext context, String level) {
    return ElevatedButton(
      onPressed: () {
        // Save difficulty preference
        if (_soundService.soundEnabled.value) {
          _soundService.playSound('menu_click');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Difficulty set to $level')));
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
      child: Text(level),
    );
  }
}
