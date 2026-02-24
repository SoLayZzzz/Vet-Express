import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../value_statics.dart';
import 'app_colors.dart';

class Loading {
  void loadingShow() {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 0.7),
      context: Get.context!,
      builder: (context) {
        return Center(
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
        );
      },
    );
  }

  void loadingClose() {
    if (Navigator.canPop(Get.context!)) Navigator.pop(Get.context!);
  }
}
