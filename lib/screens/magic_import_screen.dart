import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/timetable_import_service.dart';
import '../logic/import_mapper.dart';
import '../providers/providers.dart';
import '../widgets/dhrruwa_footer.dart';
import 'import_review_screen.dart';

/// "Magic import" entry point: pick a photo/PDF of a timetable, send it to the
/// Gemini-backed Edge Function, then hand the parsed result to the editable
/// [ImportReviewScreen]. Nothing is saved here — review + confirm comes next.
class MagicImportScreen extends ConsumerStatefulWidget {
  const MagicImportScreen({super.key});

  @override
  ConsumerState<MagicImportScreen> createState() => _MagicImportScreenState();
}

class _MagicImportScreenState extends ConsumerState<MagicImportScreen> {
  bool _busy = false;
  String _status = '';

  static const _exts = ['jpg', 'jpeg', 'png', 'webp', 'pdf'];

  Future<void> _pickAndExtract() async {
    setState(() {
      _busy = true;
      _status = 'Opening file…';
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: _exts,
        withData: true, // load bytes into memory for base64
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _busy = false); // user cancelled
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;
      final ext = (file.extension ?? '').toLowerCase();
      if (bytes == null || bytes.isEmpty) {
        throw const ImportException('Couldn’t read that file. Try another.');
      }
      final mime = _mimeFor(ext);
      if (mime == null) {
        throw const ImportException('Unsupported file. Use a JPG, PNG, or PDF.');
      }

      setState(() => _status = 'Reading your timetable…');
      final service = ref.read(timetableImportServiceProvider);
      final json = await service.extract(bytes: bytes, mime: mime);

      final draft = mapGeminiJson(json);
      if (draft.periodCount == 0) {
        throw const ImportException(
          'No classes were found. Try a clearer, fuller photo of the grid.',
        );
      }

      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ImportReviewScreen(draft: draft)),
      );
      // If review saved + popped to root, this screen is already gone.
      if (mounted) setState(() => _busy = false);
    } on ImportException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showError(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showError('Something went wrong. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? _mimeFor(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Import timetable')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            Icon(Icons.auto_awesome, size: 56, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Magic import',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload a photo or PDF of your class timetable and we’ll read it '
              'into the app. You’ll review and fix anything before it’s saved.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 28),
            _tip(context, Icons.photo_camera_outlined,
                'Use a straight, well-lit photo of the full grid.'),
            _tip(context, Icons.picture_as_pdf_outlined,
                'PDFs work too — even multi-format college layouts.'),
            _tip(context, Icons.edit_outlined,
                'Times come from your Schedule settings; only the order is read.'),
            const SizedBox(height: 28),
            if (_busy) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ] else
              FilledButton.icon(
                onPressed: _pickAndExtract,
                icon: const Icon(Icons.upload_file),
                label: const Text('Choose photo or PDF'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            const DhrruwaFooter(),
          ],
        ),
      ),
    );
  }

  Widget _tip(BuildContext context, IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
