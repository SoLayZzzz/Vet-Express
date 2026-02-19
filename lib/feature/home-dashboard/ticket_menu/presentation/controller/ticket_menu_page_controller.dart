import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../controller/slide_controller.dart';
import 'ticket_menu_form_controller.dart';

class TicketMenuPageController extends GetxController {
  final SlideController slideController = Get.find<SlideController>();
  final TicketMenuFormController formController =
      Get.find<TicketMenuFormController>();

  late final int type;
  late final String appBarTitle;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<dynamic, dynamic>?;
    type = (args?['type'] as int?) ?? 1;
    appBarTitle = (args?['appBarTitle'] as String?) ?? '';

    formController.setNow();
  }

  @override
  void onReady() {
    super.onReady();
    _preCacheRelevantImages();
  }

  void _preCacheRelevantImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final images =
          type == 2 ? slideController.imgListBoat : slideController.imgListBus;
      if (images.isNotEmpty) {
        log('✅ TicketMenuScreen: Pre-cached relevant images for type $type');
      }
    });
  }
}
