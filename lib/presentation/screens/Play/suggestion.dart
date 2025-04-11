// models/suggestion.dart
class Suggestion {
  final String text;
  final int value;
  bool selected;

  Suggestion({
    required this.text,
    required this.value,
    this.selected = false,
  });
}

