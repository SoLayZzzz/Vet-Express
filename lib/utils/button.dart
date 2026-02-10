import 'package:flutter/material.dart';

import 'app_colors.dart';

Widget globalButton({
  required BuildContext context,
  required String buttonText,
  required Function onPressed,
  Color buttonColor = AppColors.primaryColor,
  Color textColor = Colors.white,
  double fontSize = 16.0,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(6)),
}) {
  return InkWell(
    onTap: () => onPressed(),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: buttonColor,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
      ),
    ),
  );
}

Widget buttonNoBackground({
  required BuildContext context,
  required String buttonText,
  required Function onPressed,
  Color textColor = AppColors.greyColor,
  double fontSize = 16.0,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(6)),
}) {
  return InkWell(
    onTap: () => onPressed(),
    child: Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: fontSize, color: textColor),
        ),
      ),
    ),
  );
}
