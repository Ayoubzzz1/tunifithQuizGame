import 'package:flutter/material.dart';

class CategoryToggle extends StatelessWidget {
  final String category;
  final bool isSelected;
  final IconData icon;
  final Function(bool) onToggle;

  const CategoryToggle({
    super.key,
    required this.category,
    required this.isSelected,
    required this.icon,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onToggle(!isSelected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? Colors.white : Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              category,
              style: TextStyle(
                fontSize: 18,
                fontWeight: category == 'Select All' ? FontWeight.bold : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Switch(
              value: isSelected,
              activeColor: Theme.of(context).primaryColor,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}