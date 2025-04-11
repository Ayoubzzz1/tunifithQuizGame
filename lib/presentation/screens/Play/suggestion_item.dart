// components/suggestion_item.dart
import 'package:flutter/material.dart';
import 'suggestion.dart';

class SuggestionItem extends StatelessWidget {
  final Suggestion suggestion;
  final bool isSelectable;
  final bool showValue;
  final VoidCallback onTap;

  const SuggestionItem({
    Key? key,
    required this.suggestion,
    required this.isSelectable,
    required this.showValue,
    required this.onTap,
  }) : super(key: key);

  Color _getValueColor(int value) {
    if (value >= 5) return Colors.green[700]!;
    if (value >= 3) return Colors.orange[700]!;
    return Colors.red[700]!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSelectable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: suggestion.selected
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: suggestion.selected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                suggestion.text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: suggestion.selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            if (showValue)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getValueColor(suggestion.value),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${suggestion.value}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}