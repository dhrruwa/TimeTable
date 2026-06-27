import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../theme/effects/effect_layer.dart';
import 'subjects_screen.dart';
import 'theme_store_screen.dart';
import 'today_screen.dart';
import 'week_screen.dart';

/// Root scaffold with bottom navigation. Today is index 0 (default landing).
///
/// There is intentionally NO in-app "Widgets" screen: widgets exist only as
/// native home-screen widgets (Android App Widgets + iOS WidgetKit), added from
/// the device's own widget gallery.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  static const _tabs = [
    TodayScreen(),
    WeekScreen(),
    SubjectsScreen(),
    ThemeStoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(activeThemeProvider);
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _index, children: _tabs),
          // Decorative, non-interactive theme effect above content.
          Positioned.fill(
            child: IgnorePointer(child: effectFor(theme.effect, theme)),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Week',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette),
            label: 'Subjects',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Themes',
          ),
        ],
      ),
    );
  }
}
