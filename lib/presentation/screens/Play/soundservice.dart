import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  late final AudioPlayer _audioPlayer;
  bool _isSoundEnabled = true; // Default to enabled

  SoundService._internal() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
  }

  Future<void> playButtonSound() async {
    if (_isSoundEnabled) {
      await _audioPlayer.play(AssetSource('audio/button1.mp3'));
    }
  }

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  bool get isSoundEnabled => _isSoundEnabled;
}