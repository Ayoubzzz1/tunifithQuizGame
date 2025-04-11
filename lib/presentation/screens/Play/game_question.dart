// models/game_question.dart
import 'suggestion.dart';

class GameQuestion {
  final String theme;
  final String question;
  final List<Suggestion> suggestions;

  GameQuestion({
    required this.theme,
    required this.question,
    required this.suggestions,
  });
}