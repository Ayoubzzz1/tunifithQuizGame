import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;

  late final AudioPlayer _audioPlayer;
  bool _isSoundEnabled = true;

  SoundService._internal() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setPlayerMode(PlayerMode.lowLatency);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isSoundEnabled = prefs.getBool('isSoundEffectsEnabled') ?? true;
  }

  Future<void> playButtonSound() async {
    await _loadSettings(); // Refresh settings before playing
    if (_isSoundEnabled) {
      await _audioPlayer.play(AssetSource('audio/button1.mp3'));
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _isSoundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEffectsEnabled', enabled);
  }

  bool get isSoundEnabled => _isSoundEnabled;
}