import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_repository.dart';
import '../models/period_models.dart';
import '../providers/community_providers.dart';
import '../providers/widget_providers.dart';
import 'import_screen.dart';

/// First-launch discovery: ask university / branch / semester / section, search
/// the community database, and let the student join an existing timetable with
/// one tap instead of recreating it.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _university = TextEditingController();
  final _branch = TextEditingController();
  final _semester = TextEditingController();
  final _section = TextEditingController();

  bool _searched = false;
  bool _searching = false;
  CommunityEntry? _exact;
  List<CommunityEntry> _others = [];

  @override
  void dispose() {
    for (final c in [_university, _branch, _semester, _section]) {
      c.dispose();
    }
    super.dispose();
  }

  TimetableMeta get _meta => TimetableMeta(
        university: _university.text.trim(),
        branch: _branch.text.trim(),
        semester: _semester.text.trim(),
        section: _section.text.trim(),
      );

  Future<void> _search() async {
    FocusScope.of(context).unfocus();
    setState(() => _searching = true);
    final repo = ref.read(communityRepositoryProvider);
    final exact = await repo.findMatch(_meta);
    final others = await repo.search(
      university: _meta.university,
      branch: _meta.branch,
    );
    if (!mounted) return;
    setState(() {
      _exact = exact;
      _others = others.where((e) => e.meta.matchKey != exact?.meta.matchKey).toList();
      _searched = true;
      _searching = false;
    });
  }

  void _useExisting(CommunityEntry entry) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ImportScreen(incoming: entry.timetable, fromDiscovery: true),
    ));
  }

  Future<void> _createNew() async {
    // Stamp the entered meta + creator id onto the starter timetable, publish it
    // to the community so others can find it, then enter the app.
    final deviceId = ref.read(appPrefsProvider).deviceId;
    final notifier = ref.read(timetableProvider.notifier);
    final meta = _meta.copyWith(
      creatorId: deviceId,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await notifier.setMeta(meta);
    if (meta.isComplete) {
      await ref.read(communityRepositoryProvider).publish(
            ref.read(timetableProvider),
          );
    }
    await ref.read(appPrefsProvider.notifier).markOnboarded();
  }

  Future<void> _skip() => ref.read(appPrefsProvider.notifier).markOnboarded();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final canSearch = _meta.isComplete;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your class'),
        actions: [TextButton(onPressed: _skip, child: const Text('Skip'))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            '60 students, one timetable. Tell us your class — if it already '
            'exists, join it with one tap instead of building it again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          _field(_university, 'University', Icons.account_balance_outlined),
          _field(_branch, 'Branch (e.g. CSE)', Icons.school_outlined),
          Row(
            children: [
              Expanded(
                  child: _field(_semester, 'Semester', Icons.calendar_today_outlined,
                      keyboard: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(_section, 'Section', Icons.groups_outlined)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canSearch && !_searching ? _search : null,
              icon: _searching
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.search),
              label: const Text('Search timetables'),
            ),
          ),
          if (_searched) ...[
            const SizedBox(height: 22),
            if (_exact != null) _exactCard(_exact!),
            if (_others.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text('Other timetables at this college',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              for (final e in _others) _otherTile(e),
            ],
            if (_exact == null && _others.isEmpty) _noMatch(),
            const SizedBox(height: 18),
            _createNewButton(filled: _exact == null),
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        textCapitalization: TextCapitalization.characters,
        onChanged: (_) => setState(() {}),
        decoration:
            InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget _exactCard(CommunityEntry e) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Existing timetable found',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimaryContainer)),
              ),
              if (e.meta.verified)
                Icon(Icons.verified, size: 18, color: scheme.primary),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A timetable for ${e.meta.branch} · Semester ${e.meta.semester} · '
            'Section ${e.meta.section} is already used by ${e.userCount} students.',
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _useExisting(e),
              icon: const Icon(Icons.group_add),
              label: const Text('Use Existing Timetable'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _otherTile(CommunityEntry e) {
    return Card(
      child: ListTile(
        onTap: () => _useExisting(e),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(e.meta.section.isEmpty ? '?' : e.meta.section[0],
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text('${e.meta.branch} · Sem ${e.meta.semester} · Sec ${e.meta.section}'),
        subtitle: Text('${e.userCount} students'
            '${e.meta.verified ? ' · verified' : ''}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _noMatch() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Icon(Icons.search_off, color: scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          const Text('No existing timetable found for this class.',
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text('Be the first to create it for your class!',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _createNewButton({required bool filled}) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [Icon(Icons.add), SizedBox(width: 8), Text('Create New Timetable')],
    );
    return SizedBox(
      width: double.infinity,
      child: filled
          ? FilledButton(onPressed: _createNew, child: child)
          : OutlinedButton(onPressed: _createNew, child: child),
    );
  }
}
