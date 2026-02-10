import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:external_app_launcher/external_app_launcher.dart';

class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();

  static Future<void> initAppLinks() async {
    try {
      // Handle initial deep link
      final Uri? initialLink = await _appLinks.getInitialLink();

      _handleDeepLink(initialLink);

      // Listen for incoming deep links
      _appLinks.uriLinkStream.listen((Uri? uri) {
        _handleDeepLink(uri);
      });
    } catch (e) {
      log('Error initializing AppLinks: $e');
    }
  }

  static Future<void> _handleDeepLink(Uri? uri) async {
    if (uri != null) {
      log('Received deep link: $uri');
      log('Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}');

      if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'vetapp://payment/') {
        final productId = uri.pathSegments.last; // Extract product ID from the URI
        log('Open Screen: $productId');

            try {
          // Launch an external app (example)
          await LaunchApp.openApp(
            androidPackageName: 'vireak_bunthan.udaya.com.vet_logistic',
            openStore: false,
            iosUrlScheme: 'com.UDAYA.VETLogistic',
          );
        } catch (e) {
          log('Error launching app: $e');
        }
      }
    }
  }
}
