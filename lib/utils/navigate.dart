import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'contains.dart';

final navigatorKey = GlobalKey<NavigatorState>();

BuildContext? getCurrentContext() => navigatorKey.currentContext;

navigateTo({required Widget page}) {
  Get.to(
        () => page,
    transition: Transition.rightToLeft,
    duration: const Duration(milliseconds: Constrains.duration),
  );
}
