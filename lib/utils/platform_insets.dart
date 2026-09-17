import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class PlatformInsets {
  static bool get useSafeArea =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static double iosBottomInset({double fallback = 10.0}) {
    final ctx = Get.context;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && ctx != null) {
      return MediaQuery.of(ctx).viewPadding.bottom;
    }
    return fallback;
  }
}
