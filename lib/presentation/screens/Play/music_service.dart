import 'package:audioplayers/audioplayers.dart';

class MusicService {
  static final MusicService _instance = MusicService._internal();
  factory MusicService() => _instance;

  late final AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  bool _isMusicEnabled = true;

  MusicService._internal() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> initializeMusic() async {
    if (!_isInitialized) {
      if (_isMusicEnabled) {
        await _audioPlayer.setSource(AssetSource('audio/background.mp3'));
      }
      _isInitialized = true;
    }
  }

  Future<void> playMusic() async {
    await initializeMusic();
    if (_isMusicEnabled) {
      await _audioPlayer.play(AssetSource('audio/background.mp3'));
    }
  }

  Future<void> stopMusic() async {
    await _audioPlayer.stop();
  }

  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
  }

  Future<void> resumeMusic() async {
    await initializeMusic();
    if (_isMusicEnabled) {
      await _audioPlayer.resume();
    }
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _isMusicEnabled = enabled;
    if (enabled) {
      await resumeMusic();
    } else {
      await pauseMusic();
    }
  }

  bool get isMusicEnabled => _isMusicEnabled;
}