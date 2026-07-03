import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public legal pages (served by the Next.js site). Update the base if the
/// production domain differs.
const String kSiteBase = 'https://classsync.dhrruwa.com';
const String kTermsUrl = '$kSiteBase/terms';
const String kPrivacyUrl = '$kSiteBase/privacy';

Future<void> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// A small "By continuing you agree to our Terms & Privacy Policy" line with
/// tappable links — shown before/at community (user-generated content) actions.
class LegalLinks extends StatelessWidget {
  final String lead;
  const LegalLinks({super.key, this.lead = 'By continuing you agree to our'});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant);
    final link =
        muted.copyWith(color: scheme.primary, fontWeight: FontWeight.w600);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('$lead ', style: muted),
          GestureDetector(
              onTap: () => openUrl(kTermsUrl),
              child: Text('Terms', style: link)),
          Text(' & ', style: muted),
          GestureDetector(
              onTap: () => openUrl(kPrivacyUrl),
              child: Text('Privacy Policy', style: link)),
        ],
      ),
    );
  }
}
