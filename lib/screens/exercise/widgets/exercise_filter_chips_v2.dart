import 'package:flutter/material.dart';
import '../../../widgets/common.dart';

// Reusable horizontal chip row for filtering exercises
// Used for both muscle group and level filters
class ExerciseFilterChipsV2 extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const ExerciseFilterChipsV2({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All chip resets the filter
          _Chip(
            label: 'All',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),

          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Chip(
                label: _capitalize(o),
                isSelected: selected == o,

                onTap: () => onSelected(selected == o ? null : o),
              ),
            ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// Single chip — shows selected state with blue color
class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryLight : kWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kPrimary : kDivider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? kPrimary : kTextGrey,
          ),
        ),
      ),
    );
  }
}
