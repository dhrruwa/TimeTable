// Build-time wallpaper generator for the Widget Theme Packs.
//
// Generates premium background artwork for each theme pack using Google's Imagen
// API (the same GEMINI_API_KEY this project already uses for Gemini OCR), then
// crops each master image into the widget sizes the app consumes. Files are
// flattened into one folder per pack (Flutter doesn't bundle nested asset dirs):
//
//   assets/theme_packs/<pack>/<index>_small.png      (1:1)
//   assets/theme_packs/<pack>/<index>_medium.png     (2:1)
//   assets/theme_packs/<pack>/<index>_large.png      (~360:376)
//   assets/theme_packs/<pack>/<index>_lockscreen.png (tall phone)
//   assets/theme_packs/<pack>/preview.png            (store card, from index 1)
//   assets/theme_packs/manifest.json                 ({ "<pack>": <count> })
//
// Multiple wallpapers per pack let the widget rotate one at random per refresh.
//
// Usage:
//   GEMINI_API_KEY=xxxx dart run tool/generate_wallpapers.dart
//   GEMINI_API_KEY=xxxx dart run tool/generate_wallpapers.dart --packs=anime,space --count=4 --force
//
// Providers (set IMAGE_MODEL):
//   imagen-4.0-generate-001 (default) — Google Imagen, best quality, needs a
//                                       GEMINI_API_KEY on a *billed* project.
//   gemini-2.5-flash-image            — Google Gemini image, also needs billing.
//   pollinations                      — free, keyless (Flux). No billing, no key.
//
// Env:
//   IMAGE_MODEL                          — provider/model (see above)
//   GEMINI_API_KEY (or GOOGLE_API_KEY)   — required for the Google providers only
//
// Notes:
//   * Imagen is a paid API — `--count` controls images per pack (cost = packs ×
//     count API calls). Default 3. Existing files are skipped unless --force.
//   * No app code references generated files by name; the app reads manifest.json
//     and the per-index folders, so adding/removing wallpapers needs no code change.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const _endpointBase = 'https://generativelanguage.googleapis.com/v1beta/models';

/// Master aspect requested from Imagen (tall mobile wallpaper); every widget
/// size is center-cropped out of this.
const _masterAspect = '9:16';

/// Shared trailing guidance appended to every prompt for cohesive, text-free art.
const _styleSuffix =
    'vertical mobile wallpaper, cinematic lighting, ultra detailed, high quality, '
    '4k, no text, no words, no letters, no watermark, no logo, no UI, no people '
    'staring at camera, clean composition with calm negative space in the upper third';

/// Target widget sizes: name -> (aspectW, aspectH, outW, outH).
const _sizes = <String, List<int>>{
  'small': [1, 1, 512, 512],
  'medium': [2, 1, 768, 384],
  'large': [45, 47, 720, 752], // ~ widget large 360:376
  'lockscreen': [9, 19, 540, 1140],
  'preview': [3, 4, 600, 800],
};

/// Per-pack art direction + scene list (from the design brief).
final _packs = <String, _Pack>{
  'liquid_glass': _Pack(
    'frosted translucent glass aesthetic, soft blurred colorful bokeh behind '
        'frosted glass, premium Apple-style abstract, gentle gradients diffused '
        'through glass, modern minimal',
    [
      'frosted glass over a soft blue-to-violet abstract gradient',
      'blurred colorful liquid glass with light refractions',
      'premium abstract glass panels, pastel bokeh',
      'modern minimal frosted glass with subtle rainbow caustics',
      'smooth blurred glass morphism, calm blue tones',
    ],
  ),
  'anime': _Pack(
    'anime key-visual style, Makoto Shinkai inspired, vivid skies, soft cel '
        'shading, lens flare, emotional atmosphere',
    [
      'serene Japanese high-school classroom by a sunlit window, anime style',
      'cherry blossom street in spring, falling sakura petals, anime style',
      'neon Tokyo street at night in the rain, anime style',
      'dramatic anime sky with towering clouds at golden hour',
      'rainy city crossing with umbrellas and reflections, anime style',
      'quiet mountain shrine with torii gate at dusk, anime style',
    ],
  ),
  'space': _Pack(
    'photoreal astronomy, deep space, NASA-grade, dramatic cosmic lighting',
    [
      'spiral galaxy with glowing core in deep space',
      'colorful nebula clouds, pink and teal, star fields',
      'Earth from orbit with the sun cresting the horizon',
      'lone astronaut floating against a starfield',
      'cratered moon surface under a black star-filled sky',
      'deep universe with distant galaxies and cosmic dust',
    ],
  ),
  'marvel': _Pack(
    'cinematic superhero concept art, futuristic HUD, metallic sheen, energy '
        'glow, comic-inspired but realistic',
    [
      'glowing arc-reactor energy core, high-tech metallic chamber',
      'futuristic heads-up display interface with holographic rings',
      'red and gold metallic armor surface, polished, dramatic light',
      'comic-style city skyline at dusk with dynamic energy streaks',
      'high-tech command interface with glowing data panels',
      'sleek hero gauntlet emitting energy, dark studio backdrop',
    ],
  ),
  'cyberpunk': _Pack(
    'cyberpunk neon, blade-runner mood, magenta and cyan, volumetric haze, wet '
        'reflective streets, holograms',
    [
      'neon cyberpunk city street drenched in magenta and cyan light',
      'purple-lit alley with holographic signs and rain',
      'floating holograms over a futuristic skyline at night',
      'rain-soaked neon street with mirror reflections',
      'glowing digital grid receding into a neon horizon',
      'towering futuristic skyline with neon haze',
    ],
  ),
  'gaming': _Pack(
    'gamer aesthetic, RGB lighting, dark setup, dramatic colored rim light, '
        'esports vibe',
    [
      'dark gaming setup glowing with RGB lighting',
      'close-up of a glowing game controller on a dark desk',
      'esports arena with colored stage lights and crowd haze',
      'moody gaming room with RGB strips and a glowing monitor',
      'mechanical keyboard with rainbow RGB backlight, macro shot',
      'abstract dark wallpaper with neon RGB light streaks',
    ],
  ),
  'formula1': _Pack(
    'motorsport telemetry aesthetic, carbon fiber, red and carbon-black, '
        'high-speed cinematic, racing energy',
    [
      'formula one race track from above with grid markings',
      'pit lane with motion blur and racing lights',
      'glowing speedometer and telemetry dashboard, red accents',
      'carbon fiber texture surface with red highlight',
      'racing telemetry overlay graphics on a dark track background',
      'racing cockpit view down a straight at high speed',
    ],
  ),
  'music': _Pack(
    'moody music aesthetic, warm studio lighting, green accent glow, premium, '
        'shallow depth of field',
    [
      'close-up of a spinning vinyl record under warm light',
      'studio headphones on a dark surface with green glow',
      'concert stage with green and white lights and haze',
      'recording studio mixing desk, moody lighting',
      'grand piano keys lit dramatically in the dark',
      'electric guitar leaning in a dim studio with green rim light',
    ],
  ),
  'nature': _Pack(
    'landscape photography, golden hour, lush, serene, depth, natural light',
    [
      'misty mountain range at sunrise',
      'sunlit deep green forest with light rays',
      'waterfall cascading into a turquoise pool',
      'vivid sunrise over rolling hills',
      'warm sunset over a calm valley',
      'still mountain lake reflecting the sky at dawn',
    ],
  ),
  'pixel': _Pack(
    '16-bit pixel art, retro game wallpaper, crisp pixels, limited palette, '
        'nostalgic, dithered shading',
    [
      'pixel art mountain landscape at sunset, 16-bit',
      'retro pixel city skyline at night, 16-bit',
      '8-bit mountains with a pixel sun and clouds',
      'retro arcade scene in pixel art, neon signs',
      'pixel art sunset over the ocean, 16-bit palette',
    ],
  ),
};

Future<int> main(List<String> argv) async {
  final args = _Args(argv);
  final model = Platform.environment['IMAGE_MODEL'] ?? 'imagen-4.0-generate-001';
  final usePollinations = model == 'pollinations';
  final key = Platform.environment['GEMINI_API_KEY'] ??
      Platform.environment['GOOGLE_API_KEY'] ??
      '';
  if (!usePollinations && key.isEmpty) {
    stderr.writeln(
        'ERROR: set GEMINI_API_KEY (or GOOGLE_API_KEY), or use IMAGE_MODEL=pollinations.');
    return 2;
  }
  final count = args.intOption('count', 3);
  final force = args.flag('force');
  final only = args.listOption('packs');

  final outRoot = Directory('assets/theme_packs');
  outRoot.createSync(recursive: true);
  final client = HttpClient()
    ..idleTimeout = const Duration(seconds: 120)
    ..connectionTimeout = const Duration(seconds: 60);
  final manifest = <String, int>{};
  var generated = 0, skipped = 0, failed = 0;

  for (final entry in _packs.entries) {
    final pack = entry.key;
    if (only.isNotEmpty && !only.contains(pack)) continue;
    final p = entry.value;
    final n = count.clamp(1, p.scenes.length);
    stdout.writeln('\n== $pack ($n wallpaper${n == 1 ? '' : 's'}) ==');

    final dir = Directory('${outRoot.path}/$pack');
    dir.createSync(recursive: true);
    var made = 0;
    for (var i = 1; i <= n; i++) {
      final marker = File('${dir.path}/${i}_large.jpg');
      if (!force && marker.existsSync()) {
        stdout.writeln('  [$i] exists, skipping');
        made = i;
        skipped++;
        continue;
      }
      final prompt = '${p.scenes[(i - 1) % p.scenes.length]}, ${p.style}, $_styleSuffix';
      stdout.writeln('  [$i] generating…');
      // Route to the selected provider. Imagen → :predict, Gemini image →
      // :generateContent, Pollinations → keyless GET.
      final bytes = usePollinations
          ? await _pollinations(client, prompt, i * 100003 + pack.hashCode)
          : model.startsWith('imagen')
              ? await _imagen(client, model, key, prompt)
              : await _geminiImage(client, model, key, prompt);
      if (bytes == null) {
        stderr.writeln('  [$i] FAILED (see error above)');
        failed++;
        continue;
      }
      final master = img.decodeImage(bytes);
      if (master == null) {
        stderr.writeln('  [$i] FAILED to decode image');
        failed++;
        continue;
      }
      for (final s in _sizes.entries) {
        if (s.key == 'preview') continue; // preview written once per pack below
        _writeVariant(master, s.value, '${dir.path}/${i}_${s.key}.jpg');
      }
      if (i == 1) {
        _writeVariant(master, _sizes['preview']!, '${dir.path}/preview.jpg');
      }
      made = i;
      generated++;
    }
    if (made > 0) manifest[pack] = made;
  }

  client.close();
  File('${outRoot.path}/manifest.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));
  stdout.writeln(
      '\nDone. generated=$generated skipped=$skipped failed=$failed → ${outRoot.path}/manifest.json');
  stdout.writeln('Now run: flutter pub get  (pubspec already declares assets/theme_packs/)');
  return failed > 0 ? 1 : 0;
}

/// Calls Imagen `:predict` and returns raw image bytes, or null on failure.
Future<Uint8List?> _imagen(
    HttpClient client, String model, String key, String prompt) async {
  final uri = Uri.parse('$_endpointBase/$model:predict?key=$key');
  final body = jsonEncode({
    'instances': [
      {'prompt': prompt}
    ],
    'parameters': {
      'sampleCount': 1,
      'aspectRatio': _masterAspect,
      'personGeneration': 'allow_adult',
    },
  });
  try {
    final req = await client.postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(body);
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      stderr.writeln('    HTTP ${res.statusCode}: ${_trim(text)}');
      return null;
    }
    final json = jsonDecode(text) as Map<String, dynamic>;
    final preds = json['predictions'] as List?;
    if (preds == null || preds.isEmpty) {
      stderr.writeln('    no predictions: ${_trim(text)}');
      return null;
    }
    final pred = preds.first as Map<String, dynamic>;
    final b64 = (pred['bytesBase64Encoded'] ??
        (pred['image'] is Map ? pred['image']['imageBytes'] : null)) as String?;
    if (b64 == null) {
      stderr.writeln('    no image bytes in prediction');
      return null;
    }
    return base64Decode(b64);
  } catch (e) {
    stderr.writeln('    request error: $e');
    return null;
  }
}

/// Calls a Gemini image model (`:generateContent`) and returns image bytes, or
/// null on failure. Works on the free tier (unlike Imagen). The model returns a
/// roughly square image; the variant cropper derives every widget size from it.
Future<Uint8List?> _geminiImage(
    HttpClient client, String model, String key, String prompt) async {
  final uri = Uri.parse('$_endpointBase/$model:generateContent?key=$key');
  final body = jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': '$prompt. Output a single tall vertical 9:16 wallpaper image.'}
        ]
      }
    ],
    'generationConfig': {
      'responseModalities': ['IMAGE'],
    },
  });
  try {
    final req = await client.postUrl(uri);
    req.headers.contentType = ContentType.json;
    req.write(body);
    final res = await req.close();
    final text = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      stderr.writeln('    HTTP ${res.statusCode}: ${_trim(text)}');
      return null;
    }
    final json = jsonDecode(text) as Map<String, dynamic>;
    final cands = json['candidates'] as List?;
    if (cands == null || cands.isEmpty) {
      stderr.writeln('    no candidates: ${_trim(text)}');
      return null;
    }
    final content = (cands.first as Map)['content'] as Map?;
    final parts = content?['parts'] as List?;
    if (parts != null) {
      for (final p in parts) {
        final inline = (p as Map)['inlineData'] ?? p['inline_data'];
        if (inline is Map && inline['data'] is String) {
          return base64Decode(inline['data'] as String);
        }
      }
    }
    stderr.writeln('    no inline image in response: ${_trim(text)}');
    return null;
  } catch (e) {
    stderr.writeln('    request error: $e');
    return null;
  }
}

/// Free, keyless image generation via Pollinations.ai (Flux). Requests a tall
/// master directly; the variant cropper derives every widget size from it.
Future<Uint8List?> _pollinations(
    HttpClient client, String prompt, int seed) async {
  final enc = Uri.encodeComponent(prompt);
  final uri = Uri.parse('https://image.pollinations.ai/prompt/$enc'
      '?width=768&height=1365&nologo=true&model=flux&seed=${seed & 0x7fffffff}');
  try {
    final req = await client.getUrl(uri);
    req.headers.set(HttpHeaders.userAgentHeader, 'timetable-wallpaper-gen');
    final res = await req.close();
    if (res.statusCode != 200) {
      final text = await res.transform(utf8.decoder).join();
      stderr.writeln('    HTTP ${res.statusCode}: ${_trim(text)}');
      return null;
    }
    final bytes = <int>[];
    await for (final chunk in res) {
      bytes.addAll(chunk);
    }
    if (bytes.isEmpty) {
      stderr.writeln('    empty image response');
      return null;
    }
    return Uint8List.fromList(bytes);
  } catch (e) {
    stderr.writeln('    request error: $e');
    return null;
  }
}

/// Center-crops [master] to the variant aspect and resizes to its output size.
void _writeVariant(img.Image master, List<int> spec, String path) {
  final aspectW = spec[0], aspectH = spec[1], outW = spec[2], outH = spec[3];
  final cropped = _centerCrop(master, aspectW / aspectH);
  final resized = img.copyResize(cropped, width: outW, height: outH);
  // JPEG keeps the app bundle small (photos compress far better than PNG).
  File(path).writeAsBytesSync(img.encodeJpg(resized, quality: 80));
}

img.Image _centerCrop(img.Image src, double targetAspect) {
  final srcAspect = src.width / src.height;
  int cw, ch;
  if (srcAspect > targetAspect) {
    ch = src.height;
    cw = (src.height * targetAspect).round();
  } else {
    cw = src.width;
    ch = (src.width / targetAspect).round();
  }
  final x = ((src.width - cw) / 2).round();
  final y = ((src.height - ch) / 2).round();
  return img.copyCrop(src, x: x, y: y, width: cw, height: ch);
}

String _trim(String s) => s.length > 300 ? '${s.substring(0, 300)}…' : s;

class _Pack {
  final String style;
  final List<String> scenes;
  _Pack(this.style, this.scenes);
}

class _Args {
  final List<String> raw;
  _Args(this.raw);
  String? _val(String name) {
    final pre = '--$name=';
    for (final a in raw) {
      if (a.startsWith(pre)) return a.substring(pre.length);
    }
    return null;
  }

  bool flag(String name) => raw.contains('--$name');
  int intOption(String name, int def) => int.tryParse(_val(name) ?? '') ?? def;
  List<String> listOption(String name) =>
      (_val(name) ?? '').split(',').where((s) => s.isNotEmpty).toList();
}
