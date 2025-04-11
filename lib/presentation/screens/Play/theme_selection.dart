class ThemeSelectionManager {
  // Static variable to hold the selected themes
  static List<String> _selectedThemes = ['Select All'];

  // Method to update the selected themes
  static void updateSelectedThemes(List<String> themes) {
    _selectedThemes = themes;
  }

  // Method to get the currently selected themes
  static List<String> getSelectedThemes() {
    return List<String>.from(_selectedThemes);
  }
}