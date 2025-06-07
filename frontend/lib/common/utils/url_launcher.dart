// lib/common/utils/url_launcher_util.dart

import 'package:flutter/material.dart'; // Für ScaffoldMessenger
import 'package:url_launcher/url_launcher.dart';

/// Bietet eine Hilfsfunktion zum sicheren Öffnen von URLs.
class UrlLauncherUtil {
  static Future<void> launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      // Stellen Sie sicher, dass der Kontext noch gültig ist, bevor Sie ScaffoldMessenger verwenden.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }
}