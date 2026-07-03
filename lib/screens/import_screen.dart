import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_repository.dart';
import '../models/period_models.dart';
import '../providers/community_providers.dart';
import '../providers/widget_providers.dart';
import '../widgets/dhrruwa_footer.dart';
import '../widgets/legal_links.dart';
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
    try {
      // Local, offline, fast — this is what actually imports the timetable.
      await ref.read(timetableProvider.notifier).replaceWith(tt);
      await ref.read(appPrefsProvider.notifier).markOnboarded();
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Couldn't import. Please try again.")),
        );
      }
      return;
    }
    // Best-effort community join in the background — don't block on the network.
    if (tt.meta.isComplete) {
      ref.read(communityRepositoryProvider).join(tt.meta.matchKey).ignore();
    }
    if (!mounted) return;
    Navigator.of(context).popUntil((r) => r.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timetable imported')),
    );
  }

  Future<void> _reportOrBlock() async {
    final key = widget.incoming.meta.matchKey;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report this timetable'),
              subtitle: const Text('Flag incorrect or objectionable content'),
              onTap: () => Navigator.pop(ctx, 'report'),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Block & hide'),
              subtitle: const Text('Hide this from your discovery'),
              onTap: () => Navigator.pop(ctx, 'block'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    final repo = ref.read(communityRepositoryProvider);
    if (choice == 'report') {
      repo.report(key, 'reported from preview').ignore();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Reported — thanks. Our team will review it.')));
    } else {
      await ref.read(appPrefsProvider.notifier).blockKey(key);
      repo.report(key, 'blocked by user').ignore();
      if (!mounted) return;
      Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Blocked — you won't see this again.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final incoming = widget.incoming;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shared timetable'),
        actions: [
          if (incoming.meta.isComplete)
            IconButton(
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Report or block',
              onPressed: _reportOrBlock,
            ),
        ],
      ),
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
          const SizedBox(height: 8),
          const LegalLinks(
              lead: 'Community timetables are user-submitted. By using them you agree to our'),
          const DhrruwaFooter(),
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
