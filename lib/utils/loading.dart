import 'package:flutter/material.dart';

import '../activities/ticket/value_statics.dart';
import 'app_colors.dart';

class Loading {
  void loadingShow(context) {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.white.withValues(alpha: 0.7),
      //Colors.white.withOpacity(0.7),
      context: context,
      builder: (context) {
        return Center(
          child: SizedBox(
            height: 50.0,
            width: 50.0,
            child: CircularProgressIndicator(
              value: null,
              color:
                  ValueStatic.ticketType == '3' ? AppColors.secondaryColor : AppColors.primaryColor,
              strokeWidth: 5.0,
            ),
          ),
        );
      },
    );
  }

  void loadingClose(context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }
}
