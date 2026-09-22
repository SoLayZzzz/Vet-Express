import 'package:flutter/material.dart';

import 'app_colors.dart';

// Widget globalButton({
//   required BuildContext context,
//   required String buttonText,
//   required Function onPressed,
//   Color buttonColor = AppColors.primaryColor,
//   Color textColor = Colors.white,
//   double fontSize = 16.0,
//   BorderRadius borderRadius = const BorderRadius.all(Radius.circular(6)),
// }) {
//   return InkWell(
//     onTap: () => onPressed(),
//     child: Container(
//       height: 50,
//       width: double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: borderRadius,
//         color: buttonColor,
//       ),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 18.0),
//         child: Text(
//           buttonText,
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: fontSize, color: textColor),
//         ),
//       ),
//     ),
//   );
// }

Widget globalButton({
  required BuildContext context,
  required String buttonText,
  required Function onPressed,
  Color buttonColor = AppColors.primaryColor,
  Color textColor = Colors.white,
  FontWeight fontWeight = FontWeight.w700,
  double fontSize = 16.0,
  BorderRadius borderRadius = const BorderRadius.all(
    Radius.circular(6),
  ),
}) {
  return InkWell(
    onTap: () => onPressed(),
    borderRadius: borderRadius,
    child: Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: buttonColor,
        
      ),
      child: Center(
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: fontWeight,
          ),
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
  FontWeight fontWeight = FontWeight.w400,
  double fontSize = 16.0,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(6)),
}) {
  return InkWell(
    onTap: () => onPressed(),
    child: Container(
      height: 52,
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
          style: TextStyle(fontSize: fontSize, color: textColor,fontWeight: fontWeight,),
        ),
      ),
    ),
  );
}

Widget orangeButton({
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
      height: 60,
      width: 400,
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

Widget blackBoarderButton({
  required BuildContext context,
  required String buttonText,
  required Function onPressed,
 Color buttonColor = Colors.transparent,
  Color textColor = Colors.white,
  double fontSize = 16.0,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(6)),
}) {
  return InkWell(
    onTap: () => onPressed(),
    child: Container(
      height: 60,
      width: 400,
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

Widget orangeBoarderButton({
  required BuildContext context,
  required String buttonText,
  required Function onPressed,
  Color buttonColor = Colors.transparent,
  Color textColor = Colors.white,
  double fontSize = 16.0,
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(6)),
}) {
  return InkWell(
    onTap: () => onPressed(),
    child: Container(
      height: 60,
      width: 400,
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