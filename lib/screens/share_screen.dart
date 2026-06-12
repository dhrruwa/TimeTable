import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/dhrruwa_footer.dart';

import '../data/community_repository.dart';
import '../logic/share_codec.dart';
import '../models/period_models.dart';
import '../providers/community_providers.dart';
import '../providers/widget_providers.dart';
import '../widgets/timetable_summary.dart';
import 'import_screen.dart';
import 'scan_screen.dart';

/// Share the current timetable via a self-contained link, manage its community
/// metadata, and (for the creator) publish updates — or suggest changes /
/// report if it isn't yours.
class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  late final TextEditingController _university;
  late final TextEditingController _branch;
  late final TextEditingController _semester;
  late final TextEditingController _section;
  late final TextEditingController _creator;

  @override
  void initState() {
    super.initState();
    final m = ref.read(timetableProvider).meta;
    _university = TextEditingController(text: m.university);
    _branch = TextEditingController(text: m.branch);
    _semester = TextEditingController(text: m.semester);
    _section = TextEditingController(text: m.section);
    _creator = TextEditingController(text: m.creatorName ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _university,
      _branch,
      _semester,
      _section,
      _creator,
      _joinController
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  TimetableMeta _editedMeta(TimetableMeta base, String deviceId) => base.copyWith(
        university: _university.text.trim(),
        branch: _branch.text.trim(),
        semester: _semester.text.trim(),
        section: _section.text.trim(),
        creatorName: _creator.text.trim().isEmpty ? null : _creator.text.trim(),
        creatorId: base.creatorId ?? deviceId,
        updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      );

  Future<void> _saveMeta() async {
    final deviceId = ref.read(appPrefsProvider).deviceId;
    final meta = _editedMeta(ref.read(timetableProvider).meta, deviceId);
    await ref.read(timetableProvider.notifier).setMeta(meta);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Details saved')));
    }
  }

  final _joinController = TextEditingController();

  Future<void> _share() async {
    final tt = ref.read(timetableProvider);
    final link = ShareCodec.encode(tt);
    final label = tt.meta.isComplete ? ' (${tt.meta.label})' : '';
    await SharePlus.instance.share(ShareParams(
      subject: 'Class timetable',
      text: 'Here is our class timetable$label — open it in the Timetable app '
          'to import:\n\n$link',
    ));
  }

  Future<void> _copyLink() async {
    final link = ShareCodec.encode(ref.read(timetableProvider));
    await Clipboard.setData(ClipboardData(text: link));
    _toast('Copied!');
  }

  void _join() {
    final tt = ShareCodec.tryDecode(_joinController.text.trim());
    if (tt == null) {
      _toast("That doesn't look like a timetable link");
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ImportScreen(incoming: tt)),
    );
  }

  Future<void> _scan() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );
    if (raw == null) return;
    final tt = ShareCodec.tryDecode(raw);
    if (tt == null) {
      _toast('That QR is not a timetable');
      return;
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ImportScreen(incoming: tt)),
    );
  }

  Future<void> _publish() async {
    await _saveMeta();
    final tt = ref.read(timetableProvider);
    if (!tt.meta.isComplete) {
      _toast('Add university, branch, semester & section first');
      return;
    }
    await ref.read(communityRepositoryProvider).publish(tt);
    _toast('Published to community');
    setState(() {});
  }

  Future<void> _suggestOrReport(String matchKey, bool report) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(report ? 'Report incorrect timetable' : 'Suggest a change'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: report
                ? "What's wrong with this timetable?"
                : 'Describe the change you suggest',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Send')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(communityRepositoryProvider);
    if (report) {
      await repo.report(matchKey, controller.text);
    } else {
      await repo.suggestChange(matchKey, controller.text);
    }
    _toast(report ? 'Report sent — thanks!' : 'Suggestion sent — thanks!');
  }

  void _toast(String m) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = ref.watch(timetableProvider);
    final deviceId = ref.watch(appPrefsProvider).deviceId;
    final isCreator =
        tt.meta.creatorId == null || tt.meta.creatorId == deviceId;

    return Scaffold(
      appBar: AppBar(title: const Text('Share & community')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // --- Role badge -----------------------------------------------
          Align(
            alignment: Alignment.centerLeft,
            child: _RoleBadge(isCreator: isCreator),
          ),
          const SizedBox(height: 14),

          // --- Share + copy link ----------------------------------------
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _share,
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _copyLink,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Link'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'The link contains the whole timetable — anyone can open it in the '
            'app and import it. Works on WhatsApp, Telegram, email, etc.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _QrCard(link: ShareCodec.encode(tt)),

          const Divider(height: 32),

          // --- Join a timetable -----------------------------------------
          Text('Join a timetable',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _joinController,
            decoration: InputDecoration(
              labelText: 'Paste a shared link',
              prefixIcon: const Icon(Icons.link),
              suffixIcon: TextButton(
                onPressed: _join,
                child: const Text('Import'),
              ),
            ),
            onSubmitted: (_) => _join(),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _scan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan a QR code'),
          ),

          const Divider(height: 32),

          // --- Class details (meta) -------------------------------------
          Text('Class details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Used for community search & discovery.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          _field(_university, 'University'),
          _field(_branch, 'Branch'),
          Row(children: [
            Expanded(child: _field(_semester, 'Semester')),
            const SizedBox(width: 12),
            Expanded(child: _field(_section, 'Section')),
          ]),
          _field(_creator, 'Your name (optional)'),
          const SizedBox(height: 4),

          // --- Community popularity + actions ---------------------------
          FutureBuilder<CommunityEntry?>(
            future: tt.meta.isComplete
                ? ref.read(communityRepositoryProvider).findMatch(tt.meta)
                : Future.value(null),
            builder: (context, snap) {
              final entry = snap.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (entry != null) ...[
                    const SizedBox(height: 8),
                    TimetableMetaCard(
                        meta: entry.meta, userCount: entry.userCount),
                    const SizedBox(height: 12),
                  ],
                  if (isCreator)
                    FilledButton.tonalIcon(
                      onPressed: _publish,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: Text(entry == null
                          ? 'Publish to community'
                          : 'Save & update published timetable'),
                    )
                  else ...[
                    Text('Only the creator can edit this timetable.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () =>
                          _suggestOrReport(tt.meta.matchKey, false),
                      icon: const Icon(Icons.edit_note),
                      label: const Text('Suggest changes'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _suggestOrReport(tt.meta.matchKey, true),
                      icon: const Icon(Icons.flag_outlined),
                      label: const Text('Report incorrect timetable'),
                    ),
                  ],
                  if (isCreator) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _saveMeta,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save details'),
                    ),
                  ],
                ],
              );
            },
          ),

          const Divider(height: 32),

          // --- Support & feedback ---------------------------------------
          Text('Support', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _sendFeedback,
            icon: const Icon(Icons.feedback_outlined),
            label: const Text('Send feedback / report a problem'),
          ),
          const SizedBox(height: 4),
          Text(
            'Tell us what to add or change — we read every message.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),

          const DhrruwaFooter(),
        ],
      ),
    );
  }

  Future<void> _sendFeedback() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@dhrruwa.com',
      query: 'subject=${Uri.encodeComponent('Timetable App Feedback')}'
          '&body=${Uri.encodeComponent('\n\n— What would you like to change or add?')}',
    );
    try {
      await launchUrl(uri);
    } catch (_) {
      _toast('No email app found');
    }
  }

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: label),
        ),
      );
}

/// Shows whether this device created the timetable (full edit) or joined it.
class _RoleBadge extends StatelessWidget {
  final bool isCreator;
  const _RoleBadge({required this.isCreator});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = isCreator ? scheme.primaryContainer : scheme.secondaryContainer;
    final fg =
        isCreator ? scheme.onPrimaryContainer : scheme.onSecondaryContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isCreator ? Icons.edit : Icons.visibility_outlined,
              size: 15, color: fg),
          const SizedBox(width: 6),
          Text(isCreator ? 'Creator · full edit' : 'Viewing only',
              style: TextStyle(
                  color: fg, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// A scannable QR code of the share link (on a white card so it scans in dark
/// mode too). The link carries the whole timetable, so the QR is dense — show
/// it large and steady.
class _QrCard extends StatelessWidget {
  final String link;
  const _QrCard({required this.link});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            QrImageView(
              data: link,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.L,
            ),
            const SizedBox(height: 6),
            const Text('Scan to import',
                style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
