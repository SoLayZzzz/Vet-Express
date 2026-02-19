import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logistic_member_screen.dart';
import 'ticket_member_screen.dart';
import '../binding/member_ship_binding.dart';
import '../controller/member_ship_controller.dart';

class MemberShipScreen extends GetView<MemberShipController> {
  const MemberShipScreen({super.key});

  @override
  MemberShipController get controller {
    if (!Get.isRegistered<MemberShipController>()) {
      MemberShipBinding().dependencies();
    }
    return Get.find<MemberShipController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: AppColors.primaryColor,
        centerTitle: false,
        title: Text(
          'membership_card'.tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15, top: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0XFFE6E8EA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: TabBar(
                    controller: controller.tabController,
                    indicator: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: AppColors.secondaryColor,
                    tabs: [Tab(text: 'ticket'.tr), Tab(text: 'logistic'.tr)],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: controller.tabController,
                children: const [TicketMemberScreen(), LogisticMemberScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
