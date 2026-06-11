import 'package:flutter/material.dart';

import '../models/period_models.dart';

/// Card showing a timetable's identifying metadata + popularity.
class TimetableMetaCard extends StatelessWidget {
  final TimetableMeta meta;
  final int? userCount;
  const TimetableMetaCard({super.key, required this.meta, this.userCount});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final rows = <(IconData, String, String)>[
      if (meta.university.isNotEmpty)
        (Icons.account_balance_outlined, 'University', meta.university),
      if (meta.branch.isNotEmpty) (Icons.school_outlined, 'Branch', meta.branch),
      if (meta.semester.isNotEmpty)
        (Icons.calendar_today_outlined, 'Semester', meta.semester),
      if (meta.section.isNotEmpty) (Icons.groups_outlined, 'Section', meta.section),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  meta.label.isEmpty ? 'Untitled timetable' : meta.label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (meta.verified)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(Icons.verified, color: scheme.primary, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 12),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(r.$1, size: 17, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 78,
                    child: Text(r.$2,
                        style: TextStyle(
                            fontSize: 12.5, color: scheme.onSurfaceVariant)),
                  ),
                  Expanded(
                    child: Text(r.$3,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          const Divider(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              if (userCount != null)
                _stat(context, Icons.people_outline,
                    '$userCount ${userCount == 1 ? 'student' : 'students'}'),
              if (meta.creatorName != null && meta.creatorName!.isNotEmpty)
                _stat(context, Icons.person_outline, 'by ${meta.creatorName}'),
              if (meta.updatedAtMs > 0)
                _stat(context, Icons.update, 'Updated ${_ago(meta.updatedAtMs)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(BuildContext context, IconData icon, String text) {
    final c = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12.5, color: c)),
      ],
    );
  }

  static String _ago(int ms) {
    final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (d.inDays >= 1) return '${d.inDays}d ago';
    if (d.inHours >= 1) return '${d.inHours}h ago';
    return 'just now';
  }
}

/// Lists each subject in the timetable with its faculty + rooms (derived from
/// the week's periods).
class SubjectFacultyList extends StatelessWidget {
  final Timetable timetable;
  const SubjectFacultyList({super.key, required this.timetable});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // subjectId -> teachers/rooms/count
    final agg = <String, ({Set<String> teachers, Set<String> rooms, int count})>{};
    for (final periods in timetable.week.values) {
      for (final p in periods) {
        final cur = agg[p.subjectId] ??
            (teachers: <String>{}, rooms: <String>{}, count: 0);
        if (p.teacher != null && p.teacher!.isNotEmpty) cur.teachers.add(p.teacher!);
        if (p.room != null && p.room!.isNotEmpty) cur.rooms.add(p.room!);
        agg[p.subjectId] =
            (teachers: cur.teachers, rooms: cur.rooms, count: cur.count + 1);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final s in timetable.subjects)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                      color: Color(s.color), shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.name,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      if (agg[s.id] != null)
                        Text(
                          [
                            if (agg[s.id]!.teachers.isNotEmpty)
                              agg[s.id]!.teachers.join(', '),
                            if (agg[s.id]!.rooms.isNotEmpty)
                              agg[s.id]!.rooms.join(', '),
                            '${agg[s.id]!.count}/week',
                          ].join('  ·  '),
                          style: TextStyle(
                              fontSize: 12.5, color: scheme.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (timetable.subjects.isEmpty)
          Text('No subjects', style: TextStyle(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
