// Sound service for managing game audio
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class SoundService extends GetxService {
  late AudioCache _audioCache;
  late AudioPlayer _backgroundMusicPlayer;
  final RxBool soundEnabled = true.obs;
  final RxBool musicEnabled = true.obs;
  final RxDouble soundVolume = 0.7.obs;
  final RxDouble musicVolume = 0.5.obs;

  @override
  void onInit() {
    super.onInit();
    _audioCache = AudioCache();
    _backgroundMusicPlayer = AudioPlayer();
    _preloadSounds();
  }

  Future<void> _preloadSounds() async {
    await _audioCache.loadAll([
      'sounds/place_source.mp3',
      'sounds/color_spread.mp3',
      'sounds/wall_hit.mp3',
      'sounds/game_win.mp3',
      'sounds/game_lose.mp3',
      'sounds/menu_click.mp3',
      'sounds/ability_activate.mp3',
    ]);
  }

  Future<void> playSound(String soundName) async {
    if (soundEnabled.value) {
      await _audioCache.play(
        'sounds/$soundName.mp3',
        volume: soundVolume.value,
      );
    }
  }

  Future<void> playBackgroundMusic(String musicName) async {
    if (musicEnabled.value) {
      // Stop any currently playing music
      await _backgroundMusicPlayer.stop();

      // Play new background music
      final url = await _audioCache.load('music/$musicName.mp3');
      await _backgroundMusicPlayer.play(DeviceFileSource(url.path));
      await _backgroundMusicPlayer.setVolume(musicVolume.value);
      await _backgroundMusicPlayer.setReleaseMode(ReleaseMode.loop);
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundMusicPlayer.stop();
  }

  void toggleSound() {
    soundEnabled.value = !soundEnabled.value;
  }

  void toggleMusic() {
    musicEnabled.value = !musicEnabled.value;
    if (musicEnabled.value) {
      playBackgroundMusic('background');
    } else {
      stopBackgroundMusic();
    }
  }

  void setSoundVolume(double volume) {
    soundVolume.value = volume;
  }

  void setMusicVolume(double volume) {
    musicVolume.value = volume;
    _backgroundMusicPlayer.setVolume(volume);
  }
}
