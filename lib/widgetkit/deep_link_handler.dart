import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import '../logic/share_codec.dart';
import '../models/period_models.dart';
import '../screens/import_screen.dart';

/// Listens for incoming share links (cold start + while running) and, when one
/// carries a timetable, opens the Import screen. Wraps the app so it's always
/// active. Uses a global navigator key so it can route from outside a screen.
class DeepLinkHandler extends StatefulWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();

  final Widget child;
  const DeepLinkHandler({super.key, required this.child});

  @override
  State<DeepLinkHandler> createState() => _DeepLinkHandlerState();
}

class _DeepLinkHandlerState extends State<DeepLinkHandler> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    // Links that arrive while the app is already running.
    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
    // A link that cold-started the app.
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) _handle(uri);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handle(Uri uri) {
    final timetable = ShareCodec.tryDecode(uri.toString());
    if (timetable == null) return;
    // Defer until after the current frame so the navigator is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) => _openImport(timetable));
  }

  void _openImport(Timetable timetable) {
    final nav = DeepLinkHandler.navigatorKey.currentState;
    if (nav == null) return;
    nav.push(MaterialPageRoute(
      builder: (_) => ImportScreen(incoming: timetable),
    ));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
