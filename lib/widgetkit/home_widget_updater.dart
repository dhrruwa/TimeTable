import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../providers/widget_providers.dart';
import 'home_widget_service.dart';

/// Keeps the home-screen widgets in sync with the live schedule: refreshes on
/// first frame, on resume, on every clock tick, and whenever the timetable is
/// edited.
class HomeWidgetUpdater extends ConsumerStatefulWidget {
  final Widget child;
  const HomeWidgetUpdater({super.key, required this.child});

  @override
  ConsumerState<HomeWidgetUpdater> createState() => _HomeWidgetUpdaterState();
}

class _HomeWidgetUpdaterState extends ConsumerState<HomeWidgetUpdater>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _push());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _push();
  }

  void _push({DateTime? now}) {
    HomeWidgetService.refresh(ref.read(timetableProvider), now: now);
  }

  @override
  Widget build(BuildContext context) {
    // Re-render when the minute ticks or the timetable is edited.
    ref.listen(clockProvider, (_, next) {
      final now = next.value;
      if (now != null) _push(now: now);
    });
    ref.listen(timetableProvider, (_, __) => _push());
    return widget.child;
  }
}
