import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import '../value_statics.dart';
import 'app_colors.dart';

class AppBarVET {
  // For app bar
  AppBar appBar(context, title) {
    return AppBar(
      elevation: 0.2,
      backgroundColor:
          ValueStatic.ticketType == '3'
              ? AppColors.airBusColor
              : AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(
          Ionicons.chevron_back_outline,
          color: AppColors.whiteColor,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  AppBar appBarNotBack(context, title) {
    return AppBar(
      elevation: 0.0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: Text(
        title,
        style: const TextStyle(color: AppColors.whiteColor, fontSize: 16),
      ),
    );
  }
}
