import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../activities/ticket/value_statics.dart';
import 'app_colors.dart';

//Dialog Schedule
void alertDialogSchedule({
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
            borderRadius: BorderRadius.all(
              Radius.circular(6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Ensure the column takes up minimum space
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Image.asset(
                      ValueStatic.ticketType == "2"
                          ? 'assets/images/ic_schedule_boat.png'
                          : 'assets/images/ic_schedule_bus.png',
                      width: 65,
                    ),
                  ),
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
                      style: const TextStyle(fontSize: 14, color: AppColors.textColor),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: ValueStatic.ticketType == '3'
                            ? AppColors.airBusColor
                            : AppColors.primaryColor,
                      ),
                      child: Center(
                          child: Text(buttonText,
                              style: const TextStyle(
                                  color: AppColors.whiteColor, fontWeight: FontWeight.bold))),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}