import 'package:flutter/material.dart';
import 'suggestion.dart';
import 'suggestion_item.dart';

class SuggestionsList extends StatelessWidget {
  final List<Suggestion> suggestions;
  final bool isTimerRunning;
  final bool showResults;
  final Function(int) onSuggestionSelected;

  const SuggestionsList({
    Key? key,
    required this.suggestions,
    required this.isTimerRunning,
    required this.showResults,
    required this.onSuggestionSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return SuggestionItem(
          suggestion: suggestions[index],
          isSelectable: isTimerRunning && !showResults,
          showValue: true, // ✅ Always show value
          onTap: () => onSuggestionSelected(index),
        );
      },
    );
  }
}
