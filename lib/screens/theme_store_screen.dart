import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/community_providers.dart';
import '../providers/providers.dart';
import '../theme/theme_catalog.dart';
import '../theme/theme_model.dart';
import 'theme_preview_screen.dart';

/// Wallpaper-forward theme picker. The active pack sits in a large featured
/// card; every other pack is a tap-to-apply tile. Applying re-skins the app and
/// all home-screen widgets instantly (via [AppPrefsNotifier.setTheme]).
class ThemeStoreScreen extends ConsumerWidget {
  const ThemeStoreScreen({super.key});

  void _apply(WidgetRef ref, ThemeModel t) {
    HapticFeedback.selectionClick();
    ref.read(appPrefsProvider.notifier).setTheme(t.id);
  }

  void _preview(BuildContext context, ThemeModel t) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ThemePreviewScreen(theme: t)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final selectedId = ref.watch(selectedThemeIdProvider);
    final current = kThemePacks.firstWhere((t) => t.id == selectedId,
        orElse: () => kThemePacks.first);
    final others = kThemePacks.where((t) => t.id != current.id).toList();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Themes',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            )),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to apply instantly — your home-screen widgets re-skin too.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: _FeaturedCard(
                  theme: current,
                  onPreview: () => _preview(context, current),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 16, 20, 8),
                child: Text('ALL THEMES',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: scheme.onSurfaceVariant,
                    )),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 210,
                  mainAxisExtent: 216,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final t = others[i];
                    return _ThemeTile(
                      theme: t,
                      index: i,
                      onApply: () => _apply(ref, t),
                      onPreview: () => _preview(context, t),
                    );
                  },
                  childCount: others.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Background: a vibrant swatch built from the pack's own colors, so each theme
/// reads as a distinct, premium tile (was a photo wallpaper; now color-only).
Widget _themeBackground(ThemeModel theme) {
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [theme.primary, theme.secondary, theme.background.bottom],
        stops: const [0.0, 0.5, 1.0],
      ),
    ),
  );
}

const _scrim = DecoratedBox(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0x00000000), Color(0x40000000), Color(0xCC000000)],
      stops: [0.35, 0.7, 1.0],
    ),
  ),
);

/// Large hero for the currently-applied theme.
class _FeaturedCard extends StatelessWidget {
  final ThemeModel theme;
  final VoidCallback onPreview;
  const _FeaturedCard({required this.theme, required this.onPreview});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _themeBackground(theme),
            const Positioned.fill(child: _scrim),
            // Applied badge.
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_rounded, size: 15, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Applied',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('CURRENT THEME',
                            style: TextStyle(
                                color: theme.accent,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2)),
                        const SizedBox(height: 3),
                        Text(theme.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(theme.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 12.5)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.tonalIcon(
                    onPressed: onPreview,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.fullscreen, size: 18),
                    label: const Text('Preview'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tap-to-apply wallpaper tile.
class _ThemeTile extends StatelessWidget {
  final ThemeModel theme;
  final int index;
  final VoidCallback onApply;
  final VoidCallback onPreview;
  const _ThemeTile({
    required this.theme,
    required this.index,
    required this.onApply,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 260 + 30 * (index % 6)),
      curve: Curves.easeOut,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 10), child: child),
      ),
      child: GestureDetector(
        onTap: onApply,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _themeBackground(theme),
              const Positioned.fill(child: _scrim),
              // Preview affordance.
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onPreview,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.fullscreen, size: 16, color: Colors.white),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(theme.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('Tap to apply',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
