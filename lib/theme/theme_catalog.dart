import 'package:flutter/material.dart';

import 'theme_model.dart';

/// The id of the default pack — reproduces the app's original look exactly.
const String kDefaultThemeId = 'liquid_glass';

/// All available theme packs. Adding a theme = appending one [ThemeModel] here.
/// Each pack is pure data; no widget logic references a specific pack.
const List<ThemeModel> kThemePacks = [
  _liquidGlass,
  _anime,
  _space,
  _hero,
  _cyberpunk,
  _gaming,
  _racing,
  _music,
  _nature,
  _retroPixel,
];

/// Resolve a pack by id, falling back to the default if unknown (e.g. a theme
/// removed in a later build but still persisted on a device).
ThemeModel themeById(String id) =>
    kThemePacks.firstWhere((t) => t.id == id, orElse: () => kThemePacks.first);

/// The theme the home-screen widgets should render in for the app's current
/// appearance. The widgets follow the app's Light/Dark choice: a light variant
/// of the default look for [Brightness.light], the standard dark look otherwise.
ThemeModel widgetThemeFor(Brightness brightness) =>
    brightness == Brightness.light ? _liquidGlassLight : _liquidGlass;

/// Light-appearance counterpart of the default [_liquidGlass] — a soft frosted
/// light surface with dark text, so the widget matches a light-themed app.
const _liquidGlassLight = ThemeModel(
  id: 'liquid_glass_light',
  assetPack: 'liquid_glass',
  name: 'Frosted Glass Light',
  description: 'Light frosted glass — matches a light-themed app.',
  brightness: Brightness.light,
  primary: Color(0xFF5965C8),
  secondary: Color(0xFF8A93E0),
  accent: Color(0xFF5965C8),
  onBg: Color(0xFF1B1E27), // dark text on light surface
  background: BgSpec.gradient(
    [Color(0xFFF6F8FC), Color(0xFFEDF0F7), Color(0xFFE3E7F1)],
  ),
  glass: GlassSpec(
    blur: true,
    blurSigma: 18,
    cardOpacity: 0.92,
    hairline: Color(0x14000000), // subtle dark hairline
    topSheen: 0.0, // no white sheen on a light card
    shadow: [BoxShadow(color: Color(0x14000000), blurRadius: 30, offset: Offset(0, 2))],
  ),
  cardStyle: CardStyle.glass,
  progressRamp: ProgressRamp.redGreen,
  borderRadius: 26,
  effect: ThemeEffect.none,
  labels: ThemeLabels(),
);

// ── 1. Liquid Glass (default) — must reproduce the original look ──────────────
const _liquidGlass = ThemeModel(
  id: 'liquid_glass',
  assetPack: 'liquid_glass',
  name: 'Frosted Glass',
  description: 'Calm glossy dark glass — the signature look.',
  brightness: Brightness.dark,
  primary: Color(0xFF5965C8),
  secondary: Color(0xFF8A93E0),
  accent: Color(0xFF5965C8),
  onBg: Colors.white,
  background: BgSpec.gradient(
    [Color(0xFF323B4A), Color(0xFF232A35), Color(0xFF161B22)],
  ),
  glass: GlassSpec(
    blur: true,
    blurSigma: 18,
    cardOpacity: 0.92,
    hairline: Color(0x1AFFFFFF),
    topSheen: 0.10,
    shadow: [BoxShadow(color: Color(0x2E000000), blurRadius: 30, offset: Offset(0, 2))],
  ),
  cardStyle: CardStyle.glass,
  progressRamp: ProgressRamp.redGreen,
  borderRadius: 26,
  effect: ThemeEffect.none,
  labels: ThemeLabels(),
);

// ── 2. Anime ──────────────────────────────────────────────────────────────────
const _anime = ThemeModel(
  id: 'anime',
  assetPack: 'anime',
  name: 'Anime',
  description: 'Deep blue night with sakura-pink glow.',
  brightness: Brightness.dark,
  primary: Color(0xFFFF6F9C),
  secondary: Color(0xFF6FA8FF),
  accent: Color(0xFFFF6F9C),
  onBg: Color(0xFFF2F5FF),
  background: BgSpec.gradient([Color(0xFF1B2A52), Color(0xFF141C38), Color(0xFF0C1124)]),
  typography: ThemeTypography(headingWeight: FontWeight.w700),
  glass: GlassSpec(
    blur: true,
    blurSigma: 16,
    cardOpacity: 0.88,
    hairline: Color(0x33FF9CC0),
    topSheen: 0.12,
    shadow: [BoxShadow(color: Color(0x55FF6F9C), blurRadius: 26)],
  ),
  cardStyle: CardStyle.glass,
  progressRamp: ProgressRamp.redGreen,
  borderRadius: 22,
  effect: ThemeEffect.sakura,
  labels: ThemeLabels(currentClass: 'NOW', upNext: 'NEXT'),
);

// ── 3. Space ──────────────────────────────────────────────────────────────────
const _space = ThemeModel(
  id: 'space',
  assetPack: 'space',
  name: 'Space',
  description: 'Nebula gradient, drifting stars, cosmic glow.',
  brightness: Brightness.dark,
  primary: Color(0xFF9B6CFF),
  secondary: Color(0xFF5BA9FF),
  accent: Color(0xFFB388FF),
  onBg: Color(0xFFEDE7FF),
  background: BgSpec.gradient([Color(0xFF2A1A5E), Color(0xFF181438), Color(0xFF070416)]),
  glass: GlassSpec(
    blur: true,
    blurSigma: 18,
    cardOpacity: 0.86,
    hairline: Color(0x33B388FF),
    topSheen: 0.10,
    shadow: [BoxShadow(color: Color(0x559B6CFF), blurRadius: 28)],
  ),
  cardStyle: CardStyle.glass,
  progressRamp: ProgressRamp.mono,
  borderRadius: 22,
  effect: ThemeEffect.starfield,
  labels: ThemeLabels(),
);

// ── 4. Hero HUD — futuristic sci-fi HUD ──────────────────────────────────────
const _hero = ThemeModel(
  id: 'hero',
  assetPack: 'hero',
  name: 'Hero HUD',
  description: 'Holographic HUD, energy glow, scan lines.',
  brightness: Brightness.dark,
  primary: Color(0xFFE23636),
  secondary: Color(0xFFE0A93B),
  accent: Color(0xFFFFC444),
  onBg: Color(0xFFF5F1E6),
  background: BgSpec.gradient([Color(0xFF2A2D33), Color(0xFF1A1C20), Color(0xFF0C0D0F)]),
  typography: ThemeTypography(headingWeight: FontWeight.w800, letterSpacingDelta: 0.4),
  glass: GlassSpec(
    blur: false,
    cardOpacity: 0.9,
    hairline: Color(0x66FFC444),
    topSheen: 0.08,
    shadow: [BoxShadow(color: Color(0x66E23636), blurRadius: 22)],
  ),
  cardStyle: CardStyle.neon,
  progressRamp: ProgressRamp.redGreen,
  borderRadius: 8,
  effect: ThemeEffect.scanlines,
  labels: ThemeLabels(
    currentClass: 'MISSION',
    upNext: 'BRIEFING',
    onBreak: 'STANDBY',
    attendance: 'Power Level',
    dayOver: 'Missions complete',
  ),
);

// ── 5. Cyberpunk ──────────────────────────────────────────────────────────────
const _cyberpunk = ThemeModel(
  id: 'cyberpunk',
  assetPack: 'cyberpunk',
  name: 'Cyberpunk',
  description: 'Neon grid, magenta on cyan, holographic edges.',
  brightness: Brightness.dark,
  primary: Color(0xFFFF2D95),
  secondary: Color(0xFF05D9E8),
  accent: Color(0xFF39FF14),
  onBg: Color(0xFFEAFBFF),
  background: BgSpec.gradient([Color(0xFF1A0033), Color(0xFF0D001A), Color(0xFF02000A)]),
  typography: ThemeTypography(letterSpacingDelta: 0.4, headingWeight: FontWeight.w800),
  glass: GlassSpec(
    blur: false,
    cardOpacity: 0.85,
    hairline: Color(0x6605D9E8),
    topSheen: 0.0,
    shadow: [BoxShadow(color: Color(0x66FF2D95), blurRadius: 24)],
  ),
  cardStyle: CardStyle.neon,
  progressRamp: ProgressRamp.neon,
  borderRadius: 6,
  effect: ThemeEffect.neonGrid,
  labels: ThemeLabels(
    currentClass: 'RUNNING',
    upNext: 'QUEUED',
    onBreak: 'STANDBY',
    attendance: 'Sync Level',
    dayOver: 'Session ended',
  ),
);

// ── 6. Gaming — Xbox / Steam / PlayStation ───────────────────────────────────
const _gaming = ThemeModel(
  id: 'gaming',
  assetPack: 'gaming',
  name: 'Gaming',
  description: 'XP bars, quests, console-grade cards.',
  brightness: Brightness.dark,
  primary: Color(0xFF57D957),
  secondary: Color(0xFF3BA0FF),
  accent: Color(0xFF7CFF6B),
  onBg: Color(0xFFEAF7EA),
  background: BgSpec.gradient([Color(0xFF14261A), Color(0xFF0E1A12), Color(0xFF07100A)]),
  typography: ThemeTypography(headingWeight: FontWeight.w800),
  glass: GlassSpec(
    blur: false,
    cardOpacity: 0.9,
    hairline: Color(0x3357D957),
    topSheen: 0.08,
    shadow: [BoxShadow(color: Color(0x5557D957), blurRadius: 22)],
  ),
  cardStyle: CardStyle.flat,
  progressRamp: ProgressRamp.neon,
  borderRadius: 14,
  effect: ThemeEffect.none,
  labels: ThemeLabels(
    currentClass: 'ACTIVE QUEST',
    upNext: 'NEXT QUEST',
    onBreak: 'RESPAWN',
    attendance: 'XP',
    dayOver: 'Quests cleared',
  ),
);

// ── 7. Racing — telemetry ────────────────────────────────────────────────────
const _racing = ThemeModel(
  id: 'racing',
  assetPack: 'racing',
  name: 'Racing',
  description: 'Telemetry dashboard in red and carbon black.',
  brightness: Brightness.dark,
  primary: Color(0xFFE10600),
  secondary: Color(0xFFCFCFCF),
  accent: Color(0xFFE10600),
  onBg: Color(0xFFF4F4F4),
  background: BgSpec.gradient([Color(0xFF24262A), Color(0xFF161719), Color(0xFF0A0A0B)]),
  typography: ThemeTypography(headingWeight: FontWeight.w800, letterSpacingDelta: 0.5),
  glass: GlassSpec(
    blur: false,
    cardOpacity: 0.92,
    hairline: Color(0x33FFFFFF),
    topSheen: 0.06,
    shadow: [BoxShadow(color: Color(0x66E10600), blurRadius: 20)],
  ),
  cardStyle: CardStyle.flat,
  progressRamp: ProgressRamp.redGreen,
  borderRadius: 10,
  effect: ThemeEffect.none,
  labels: ThemeLabels(
    currentClass: 'CURRENT LAP',
    upNext: 'NEXT LAP',
    onBreak: 'PIT STOP',
    attendance: 'Fuel',
    dayOver: 'Race finished',
  ),
);

// ── 8. Music — Spotify ───────────────────────────────────────────────────────
const _music = ThemeModel(
  id: 'music',
  assetPack: 'music',
  name: 'Music',
  description: 'Now-playing card with green playback glow.',
  brightness: Brightness.dark,
  primary: Color(0xFF1DB954),
  secondary: Color(0xFF1ED760),
  accent: Color(0xFF1DB954),
  onBg: Color(0xFFEDEDED),
  background: BgSpec.gradient([Color(0xFF1E1E1E), Color(0xFF151515), Color(0xFF000000)]),
  glass: GlassSpec(
    blur: false,
    cardOpacity: 0.94,
    hairline: Color(0x22FFFFFF),
    topSheen: 0.06,
    shadow: [BoxShadow(color: Color(0x551DB954), blurRadius: 22)],
  ),
  cardStyle: CardStyle.flat,
  progressRamp: ProgressRamp.mono,
  borderRadius: 16,
  effect: ThemeEffect.nowPlaying,
  labels: ThemeLabels(
    currentClass: 'NOW PLAYING',
    upNext: 'UP NEXT',
    onBreak: 'PAUSED',
    attendance: 'Listens',
    dayOver: 'Queue finished',
  ),
);

// ── 9. Nature ─────────────────────────────────────────────────────────────────
const _nature = ThemeModel(
  id: 'nature',
  assetPack: 'nature',
  name: 'Nature',
  description: 'Forest greens, soft leaves, minimal cards.',
  brightness: Brightness.dark,
  primary: Color(0xFF4CAF6E),
  secondary: Color(0xFF8FCB6A),
  accent: Color(0xFF7BC47F),
  onBg: Color(0xFFEFF6EC),
  background: BgSpec.gradient([Color(0xFF1F3326), Color(0xFF16261C), Color(0xFF0C1711)]),
  glass: GlassSpec(
    blur: true,
    blurSigma: 14,
    cardOpacity: 0.9,
    hairline: Color(0x337BC47F),
    topSheen: 0.10,
    shadow: [BoxShadow(color: Color(0x444CAF6E), blurRadius: 22)],
  ),
  cardStyle: CardStyle.glass,
  progressRamp: ProgressRamp.redGreen,
  borderRadius: 20,
  effect: ThemeEffect.none,
  labels: ThemeLabels(),
);

// ── 10. Retro Pixel — GameBoy ────────────────────────────────────────────────
const _retroPixel = ThemeModel(
  id: 'retro_pixel',
  assetPack: 'pixel',
  name: 'Retro Pixel',
  description: '8-bit GameBoy greens, pixel borders.',
  brightness: Brightness.dark,
  primary: Color(0xFF9BBC0F),
  secondary: Color(0xFF8BAC0F),
  accent: Color(0xFF9BBC0F),
  onBg: Color(0xFFE0F8D0),
  background: BgSpec.gradient([Color(0xFF1B2A1B), Color(0xFF14201A), Color(0xFF0B130F)]),
  typography: ThemeTypography(letterSpacingDelta: 0.5, headingWeight: FontWeight.w700),
  glass: GlassSpec(
    blur: false,
    cardOpacity: 1.0,
    hairline: Color(0x669BBC0F),
    topSheen: 0.0,
    shadow: [],
  ),
  cardStyle: CardStyle.pixel,
  progressRamp: ProgressRamp.mono,
  borderRadius: 2,
  effect: ThemeEffect.pixel,
  labels: ThemeLabels(
    currentClass: 'PLAYING',
    upNext: 'NEXT',
    onBreak: 'PAUSE',
    attendance: 'Lives',
  ),
);
