import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Small "dhrruwa" credit shown at the bottom of pages. Tapping opens the site.
class DhrruwaFooter extends StatelessWidget {
  const DhrruwaFooter({super.key});

  static final Uri _site = Uri.parse('https://dhrruwa.com/');

  Future<void> _open() async {
    try {
      await launchUrl(_site, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
                children: [
                  const TextSpan(text: 'made by '),
                  TextSpan(
                    text: 'dhrruwa',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
