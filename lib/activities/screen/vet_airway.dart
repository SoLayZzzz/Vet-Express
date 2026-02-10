import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';

class VetAirway extends StatelessWidget {
  const VetAirway({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'vet_airway'.tr),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/icons/coming-soon.png", height: 100),
            const SizedBox(height: 10),
            Text(
              "coming".tr,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
