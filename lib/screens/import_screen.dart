import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_repository.dart';
import '../models/period_models.dart';
import '../providers/community_providers.dart';
import '../providers/widget_providers.dart';
import '../widgets/timetable_summary.dart';

/// Shown when a shared link (or a community pick) is opened: previews the
/// timetable's metadata + subjects/faculty, then imports it with one tap.
class ImportScreen extends ConsumerStatefulWidget {
  final Timetable incoming;

  /// If true (came from community/onboarding), importing also marks onboarding
  /// done and returns to Home.
  final bool fromDiscovery;

  const ImportScreen({
    super.key,
    required this.incoming,
    this.fromDiscovery = false,
  });

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _busy = false;

  Future<void> _import() async {
    setState(() => _busy = true);
    final tt = widget.incoming;
    await ref.read(timetableProvider.notifier).replaceWith(tt);
    if (tt.meta.isComplete) {
      await ref.read(communityRepositoryProvider).join(tt.meta.matchKey);
    }
    await ref.read(appPrefsProvider.notifier).markOnboarded();
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timetable imported')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incoming = widget.incoming;
    return Scaffold(
      appBar: AppBar(title: const Text('Shared timetable')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Text('Someone shared this timetable with you',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          FutureBuilder<CommunityEntry?>(
            future: incoming.meta.isComplete
                ? ref.read(communityRepositoryProvider).findMatch(incoming.meta)
                : Future.value(null),
            builder: (context, snap) => TimetableMetaCard(
              meta: incoming.meta,
              userCount: snap.data?.userCount,
            ),
          ),
          const SizedBox(height: 22),
          Text('Subjects', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          SubjectFacultyList(timetable: incoming),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _busy ? null : _import,
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_done),
                  label: const Text('Import Timetable'),
                ),
              ),
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).maybePop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
