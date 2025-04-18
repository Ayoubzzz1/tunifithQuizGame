import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Play/music_service.dart';
import 'package:flutter/services.dart';
import 'soundservice.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isMusicEnabled = true;
  bool isSoundEffectsEnabled = true;
  final MusicService _musicService = MusicService();
  final SoundService _soundService = SoundService();

  // Memory cache for preferences to avoid excessive disk reads
  static final Map<String, bool> _prefsCache = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Try to load from memory cache first
    if (_prefsCache.containsKey('isMusicEnabled') &&
        _prefsCache.containsKey('isSoundEffectsEnabled')) {
      setState(() {
        isMusicEnabled = _prefsCache['isMusicEnabled']!;
        isSoundEffectsEnabled = _prefsCache['isSoundEffectsEnabled']!;
      });
      return;
    }

    // Otherwise load from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final musicEnabled = prefs.getBool('isMusicEnabled') ?? true;
    final soundEnabled = prefs.getBool('isSoundEffectsEnabled') ?? true;

    // Update memory cache
    _prefsCache['isMusicEnabled'] = musicEnabled;
    _prefsCache['isSoundEffectsEnabled'] = soundEnabled;

    setState(() {
      isMusicEnabled = musicEnabled;
      isSoundEffectsEnabled = soundEnabled;
    });
  }

  Future<void> _saveMusicSetting(bool value) async {
    // Update memory cache immediately
    _prefsCache['isMusicEnabled'] = value;

    // Save to disk
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isMusicEnabled', value);

    setState(() {
      isMusicEnabled = value;
    });

    if (value) {
      _musicService.resumeMusic();
    } else {
      _musicService.pauseMusic();
    }
  }

  Future<void> _saveSoundEffectsSetting(bool value) async {
    // Update memory cache immediately
    _prefsCache['isSoundEffectsEnabled'] = value;

    // Save to disk
    await _soundService.setSoundEnabled(value);

    setState(() {
      isSoundEffectsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
              Colors.white.withOpacity(0.9),
            ],
            stops: const [0.0, 0.4, 0.9],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Audio Settings Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.headphones,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'Audio Settings',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, height: 1),
                        _buildAnimatedSettingTile(
                          title: 'Background Music',
                          subtitle: 'Enable or disable background music',
                          value: isMusicEnabled,
                          onChanged: _saveMusicSetting,
                          icon: Icons.music_note,
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16),
                        _buildAnimatedSettingTile(
                          title: 'Sound Effects',
                          subtitle: 'Toggle button sound effects',
                          value: isSoundEffectsEnabled,
                          onChanged: _saveSoundEffectsSetting,
                          icon: Icons.volume_up,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // About Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.info,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'About',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, height: 1),
                        _buildInfoTile(
                          title: 'Version',
                          value: '1.0.0',
                          icon: Icons.new_releases,
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16),
                        _buildInfoTile(
                          title: 'Developer',
                          value: 'Tunisia Guess Game Team',
                          icon: Icons.code,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),

                  // Support Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.support,
                                  color: Theme.of(context).primaryColor,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Text(
                                'Support',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(thickness: 1, height: 1),
                        _buildActionTile(
                          title: 'Rate App',
                          subtitle: 'Support us with a rating',
                          icon: Icons.star,
                          onTap: () {
                            // Add rating functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Rating the app...')),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16),
                        _buildActionTile(
                          title: 'Share App',
                          subtitle: 'Share with friends',
                          icon: Icons.share,
                          onTap: () {
                            // Add share functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sharing the app...')),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSettingTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        trailing: Switch.adaptive(
          value: value,
          onChanged: (newValue) {
            // Add haptic feedback
            HapticFeedback.lightImpact();
            onChanged(newValue);
          },
          activeColor: Theme.of(context).primaryColor,
          activeTrackColor: Theme.of(context).primaryColor.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 28,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: ListTile(
          leading: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}