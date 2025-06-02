import 'package:flutter/material.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;

  const FilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: const Color(0xFF1E1E1E),
      selectedColor: const Color(0xFF6C5CE7).withOpacity(0.2),
      checkmarkColor: const Color(0xFF6C5CE7),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[300],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey[700]!,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
} 