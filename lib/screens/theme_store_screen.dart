import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/community_providers.dart';
import '../providers/providers.dart';
import '../theme/theme_catalog.dart';
import '../theme/theme_model.dart';
import '../widgets/theme_mock.dart';
import 'theme_preview_screen.dart';

/// Browse, preview, and apply theme packs. Applying updates the in-app UI and
/// every home-screen widget instantly (via [AppPrefsNotifier.setTheme] →
/// [selectedThemeIdProvider] → the widget refresh listener).
class ThemeStoreScreen extends ConsumerWidget {
  const ThemeStoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedThemeIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Store'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                '${kThemePacks.length} packs — re-skins the app and your widgets',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisExtent: 300,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: kThemePacks.length,
        itemBuilder: (context, i) {
          final theme = kThemePacks[i];
          return _ThemeCard(
            theme: theme,
            selected: theme.id == selectedId,
            index: i,
            onApply: () => ref.read(appPrefsProvider.notifier).setTheme(theme.id),
            onPreview: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ThemePreviewScreen(theme: theme)),
            ),
          );
        },
      ),
    );
  }
}

class _ThemeCard extends StatefulWidget {
  final ThemeModel theme;
  final bool selected;
  final int index;
  final VoidCallback onApply;
  final VoidCallback onPreview;
  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.index,
    required this.onApply,
    required this.onPreview,
  });

  @override
  State<_ThemeCard> createState() => _ThemeCardState();
}

class _ThemeCardState extends State<_ThemeCard> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // Staggered fade-in as the grid builds.
    Future.delayed(Duration(milliseconds: 40 * (widget.index % 8)), () {
      if (mounted) setState(() => _opacity = 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = widget.theme;
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: Offset(0, _opacity == 1 ? 0 : 0.05),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.selected ? t.accent : scheme.outlineVariant.withValues(alpha: 0.5),
              width: widget.selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview area (tap to open full preview).
              Expanded(
                child: GestureDetector(
                  onTap: widget.onPreview,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: ThemeMock(
                              theme: t,
                              width: 160,
                              height: 150,
                              compact: true,
                            ),
                          ),
                        ),
                      ),
                      if (widget.selected)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: t.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                    const SizedBox(height: 2),
                    Text(
                      t.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onPreview,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text('Preview'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: widget.selected ? null : widget.onApply,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 36),
                            ),
                            child: Text(widget.selected ? 'Applied' : 'Apply'),
                          ),
                        ),
                      ],
                    ),
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
