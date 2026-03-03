import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../value_statics.dart';
import 'app_colors.dart';

class Loading {
  void loadingShow() {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      Center(
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: CircularProgressIndicator(
            value: null,
            color:
                ValueStatic.ticketType == '3'
                    ? AppColors.secondaryColor
                    : AppColors.primaryColor,
            strokeWidth: 5.0,
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 0.7),
    );
  }

  void loadingClose() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
