import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../routes/app_routes.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: AppColors.primaryColor,
        centerTitle: false,
        title: Text(
          'history'.tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/images/image_tracking.png"),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  view(
                    "assets/icons/icon_ticket.png",
                    'ticket_history_new_1'.tr,
                    onTap: () {
                      Get.toNamed(AppRoutes.ticketHistory);
                    },
                  ),
                  view(
                    "assets/icons/icon_luggage.png",
                    'travel_package_history'.tr,
                    onTap: () {
                      Get.toNamed(AppRoutes.packageHistory);
                    },
                  ),
                  view(
                    "assets/icons/icon_parcel.png",
                    'goods_transfer_new'.tr,
                    onTap: () {
                      Get.toNamed(AppRoutes.goodsTransferHistory);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Padding view(
    String img,
    String title, {
    String? subTitle,
    required void Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.whiteColor,
            border: Border.all(width: 0.2, color: AppColors.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Image.asset(img, height: 32),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      subTitle == null
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.titleColor,
                      ),
                    ),
                    if (subTitle != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        subTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
