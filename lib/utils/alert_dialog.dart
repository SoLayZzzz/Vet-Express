import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../feature/dash_board/presentation/screen/dashboard_screen.dart';
import '../activities/ticket/value_statics.dart';
import 'app_colors.dart';
import 'button.dart';

//* Dialog One Button
alertDialogOneButton({
  required String title,
  required String description,
  required String buttonText,
}) {
  Get.dialog(
    Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize:
                    MainAxisSize
                        .min, // Ensure the column takes up minimum space
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            ValueStatic.ticketType == '3'
                                ? AppColors.airBusColor
                                : AppColors.primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

//* Dialog travel package
alertDialogTravelPackage({
  required String title,
  required String description,
  required String buttonText,
  required VoidCallback onButtonPressed,
}) {
  Get.dialog(
    Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize:
                    MainAxisSize
                        .min, // Ensure the column takes up minimum space
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onButtonPressed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color:
                            ValueStatic.ticketType == '3'
                                ? AppColors.airBusColor
                                : AppColors.primaryColor,
                      ),
                      child: Center(
                        child: Text(
                          buttonText,
                          style: const TextStyle(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

//* Dialog Two Buttons
alertDialogTwoButton({
  required String title,
  required String description,
  required String buttonText1,
  required String buttonText2,
  required VoidCallback onButtonPressed1,
  required VoidCallback onButtonPressed2,
  /* Color? color1 = AppColors.primaryColor,
    Color? color2 = AppColors.primaryColor*/
}) {
  Get.dialog(
    Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize:
                    MainAxisSize
                        .min, // Ensure the column takes up minimum space
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.titleColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: onButtonPressed1,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Center(
                              child: Text(
                                buttonText1,
                                style: TextStyle(
                                  color:
                                      ValueStatic.ticketType == '3'
                                          ? AppColors.airBusColor
                                          : AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: onButtonPressed2,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color:
                                  ValueStatic.ticketType == '3'
                                      ? AppColors.airBusColor
                                      : AppColors.primaryColor,
                            ),
                            child: Center(
                              child: Text(
                                buttonText2,
                                style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

//* Dialog Vehicle Rental
alertDialogRental({context, required List<Map<String, String>> details}) {
  Get.dialog(
    PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              //* The Dialog Box
              Container(
                margin: const EdgeInsets.only(top: 40),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30), // Space for the icon
                      Text(
                        'thz'.tr,
                        style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.titleColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'thz_info'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Image.asset('assets/images/dots_line_rental.png'),
                      const SizedBox(height: 10),
                      ...details.map(
                        (detail) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    detail.keys.first,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textColor,
                                    ),
                                  ),
                                ),
                                const Text(":"),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    detail.values.first,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      globalButton(
                        context: context,
                        buttonText: 'home'.tr,
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const DashboardScreen(from: 0),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              //* The Icon
              Positioned(
                top: 0,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/images/ic_tick_green.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
