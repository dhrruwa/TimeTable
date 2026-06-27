import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/community_providers.dart';
import '../providers/providers.dart';
import '../theme/theme_model.dart';
import '../theme/wallpaper_packs.dart';
import '../widgets/theme_mock.dart';

/// Full-screen preview of a theme pack: the home/lock surface tint plus the
/// three widget sizes rendered with the pack's tokens, and an Apply CTA. Does
/// not mutate the live theme until the user taps Apply.
class ThemePreviewScreen extends ConsumerWidget {
  final ThemeModel theme;
  const ThemePreviewScreen({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedThemeIdProvider) == theme.id;
    final onBg = theme.onBg;
    final now = DateTime.now();
    String? wp(String size) => WallpaperPacks.asset(theme.assetPack, size, now);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: onBg,
        title: Text(theme.name, style: TextStyle(color: onBg)),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.background.linearGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: [
              Text(theme.description,
                  style: TextStyle(color: onBg.withValues(alpha: 0.75), fontSize: 14)),
              const SizedBox(height: 24),
              _label('SMALL', onBg),
              const SizedBox(height: 10),
              Center(
                  child: ThemeMock(
                      theme: theme,
                      width: 170,
                      height: 170,
                      compact: true,
                      imageAsset: wp('small'))),
              const SizedBox(height: 28),
              _label('MEDIUM', onBg),
              const SizedBox(height: 10),
              ThemeMock(
                  theme: theme,
                  width: double.infinity,
                  height: 170,
                  imageAsset: wp('medium')),
              const SizedBox(height: 28),
              _label('LARGE', onBg),
              const SizedBox(height: 10),
              ThemeMock(
                  theme: theme,
                  width: double.infinity,
                  height: 320,
                  imageAsset: wp('large')),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.accent,
            foregroundColor: ThemeData.estimateBrightnessForColor(theme.accent) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black,
            minimumSize: const Size.fromHeight(54),
          ),
          onPressed: selected
              ? null
              : () {
                  ref.read(appPrefsProvider.notifier).setTheme(theme.id);
                  Navigator.of(context).pop();
                },
          child: Text(selected ? 'Applied' : 'Apply ${theme.name}'),
        ),
      ),
    );
  }

  Widget _label(String s, Color onBg) => Text(s,
      style: TextStyle(
          color: onBg.withValues(alpha: 0.6),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4));
}
