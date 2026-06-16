import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Result of preparing a file for upload: the (possibly re-encoded) bytes and
/// the mime type to send with them.
class PreparedUpload {
  final Uint8List bytes;
  final String mime;
  const PreparedUpload(this.bytes, this.mime);
}

/// Downscales + re-encodes a photo so the upload is small and Gemini's vision
/// pass is fast. A full-resolution phone photo (10+ MP, several MB) is the main
/// cause of the ~60s timeout; a timetable is fully legible at ~1600px.
///
/// PDFs and already-small images are passed through untouched. Designed to run
/// off the UI isolate via `compute()` — it's a pure top-level function.
PreparedUpload prepareForUpload(PrepareRequest req) {
  // Never touch PDFs (vector/text — already compact and not decodable here).
  if (req.mime == 'application/pdf') {
    return PreparedUpload(req.bytes, req.mime);
  }

  final decoded = img.decodeImage(req.bytes);
  if (decoded == null) {
    // Unknown/corrupt — let the server decide; sending the original is safest.
    return PreparedUpload(req.bytes, req.mime);
  }

  // Bake in EXIF orientation so a sideways phone photo reads upright for OCR.
  final oriented = img.bakeOrientation(decoded);

  const maxDim = 1600;
  final longest =
      oriented.width >= oriented.height ? oriented.width : oriented.height;

  final resized = longest > maxDim
      ? img.copyResize(
          oriented,
          width: oriented.width >= oriented.height ? maxDim : null,
          height: oriented.height > oriented.width ? maxDim : null,
          interpolation: img.Interpolation.average,
        )
      : oriented;

  final jpg = img.encodeJpg(resized, quality: 85);
  return PreparedUpload(Uint8List.fromList(jpg), 'image/jpeg');
}

/// Input for [prepareForUpload] (a single argument so it can cross an isolate).
class PrepareRequest {
  final Uint8List bytes;
  final String mime;
  const PrepareRequest(this.bytes, this.mime);
}
