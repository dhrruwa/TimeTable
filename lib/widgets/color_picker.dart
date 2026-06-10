import 'package:flutter/material.dart';

/// A compact preset color palette picker. Keeps "add a course" fast — tap a
/// swatch, done. Returns the selected ARGB int via [onChanged].
class CoursePalettePicker extends StatelessWidget {
  final int selectedColor;
  final ValueChanged<int> onChanged;

  const CoursePalettePicker({
    super.key,
    required this.selectedColor,
    required this.onChanged,
  });

  /// A curated Material palette that looks good color-coded on a grid.
  static const List<int> palette = [
    0xFFE53935, // red
    0xFFD81B60, // pink
    0xFF8E24AA, // purple
    0xFF5E35B1, // deep purple
    0xFF3949AB, // indigo
    0xFF1E88E5, // blue
    0xFF039BE5, // light blue
    0xFF00ACC1, // cyan
    0xFF00897B, // teal
    0xFF43A047, // green
    0xFF7CB342, // light green
    0xFFC0CA33, // lime
    0xFFFDD835, // yellow
    0xFFFFB300, // amber
    0xFFFB8C00, // orange
    0xFFF4511E, // deep orange
    0xFF6D4C41, // brown
    0xFF757575, // grey
    0xFF546E7A, // blue grey
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final value in palette)
          _Swatch(
            color: Color(value),
            selected: value == selectedColor,
            onTap: () => onChanged(value),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final check = color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: selected ? Icon(Icons.check, color: check, size: 22) : null,
      ),
    );
  }
}
