import 'package:express_vet/utils/app_pref.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

ThemeData getAppTheme(context) {
  return ThemeData(
    useMaterial3: false,
    primaryColor: AppColors.primaryColor,
    fontFamily: _getFontFamily(),
  ).copyWith(
    scaffoldBackgroundColor: AppColors.backgroundColor,
    cardColor: AppColors.whiteColor,
    colorScheme: ThemeData().colorScheme.copyWith(
      primary: AppColors.primaryColor,
    ),
  );
}

String _getFontFamily() {
  final locale = AppPref.getLanguage();

  if (locale == null || locale == 'km') {
    return 'Battambang'; // Default font when locale is null
  }

  // Use OpenSans for all other languages (English, Chinese, etc.)
  return 'OpenSans';
}
