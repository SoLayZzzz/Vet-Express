import 'dart:developer';
import 'package:app_links/app_links.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/presentation/controller/ev_top_up_controller.dart';
import 'package:get/get.dart';


class DeepLinkHandler {
  static final AppLinks _appLinks = AppLinks();
  static bool isDeepLinkHandled = false;

  /// Call this once in main.dart (after GetMaterialApp)
  static Future<void> initAppLinks() async {
    try {
      // 1. Handle cold start (app was killed)
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        await _handleDeepLink(initialLink as String);
      }

      // 2. Listen for deep links while app is running
      _appLinks.stringLinkStream.listen((data) async {
        if (data != null) {
          await _handleDeepLink(data);
        }
      });

      log('✅ DeepLinkHandler initialized');
    } catch (e) {
      log('❌ AppLinks init error: $e');
    }
  }

  static Future<void> _handleDeepLink(String data) async {
    log('🔗 Received deep link: $data');

    if (data.startsWith('vetapp://payment')) {
      isDeepLinkHandled = true;

      // Force immediate payment status check
      final controller = Get.find<EvTopUpController>();
      if (controller.currentTransactionId.value.isNotEmpty) {
        log('🔄 Deep link received → Checking payment status now');
        await controller.checkPaymentStatusManually();
      }
    }
  }

  /// Call this after successfully showing the success screen
  static void resetFlag() {
    isDeepLinkHandled = false;
    log('🔄 Deep link flag reset to false');
  }
}