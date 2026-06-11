import 'package:flutter/material.dart';

/// A subtle motivational/contextual note card shown on Today (and mirrored on
/// the widget). Uses the theme's primary color at low opacity — auto light/dark.
class NoteCard extends StatelessWidget {
  final String note;
  final IconData? icon;

  const NoteCard({super.key, required this.note, this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.18)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon ?? Icons.auto_awesome, size: 18, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              note,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface,
                    height: 1.3,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
