import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/app_colors.dart';
import '../../controller/dash_board_controller.dart';

class DashboardScreen extends StatefulWidget {
  final int from;

  const DashboardScreen({super.key, required this.from});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashBoardController controller;

  @override
  void initState() {
    super.initState();
    controller =
        Get.isRegistered<DashBoardController>()
            ? Get.find<DashBoardController>()
            : Get.put(DashBoardController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.handleInitialNavigation(from: widget.from);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.state.selectedIndex;
      return Scaffold(
        body: controller.selectedPage,
        bottomNavigationBar: SafeArea(
          child: Container(
            color: AppColors.whiteColor,
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildNavItem(
                  selectedIndex == 0
                      ? AssetImages.home_active
                      : AssetImages.home,
                  'home'.tr,
                  0,
                ),
                buildNavItem(
                  selectedIndex == 1
                      ? AssetImages.tracking_active
                      : AssetImages.tracking,
                  'history'.tr,
                  1,
                ),
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: FloatingActionButton(
                    onPressed: () => controller.setSelectedIndex(2),
                    backgroundColor: AppColors.secondaryColor,
                    elevation: 0,
                    child: Image.asset(AssetImages.scan, width: 24, height: 24),
                  ),
                ),
                buildNavItem(
                  selectedIndex == 3
                      ? AssetImages.membership_active
                      : AssetImages.membership,
                  'membership_card'.tr,
                  3,
                ),
                buildNavItem(
                  selectedIndex == 4
                      ? AssetImages.location_active
                      : AssetImages.location_in_active,
                  'location'.tr,
                  4,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget buildNavItem(String assetImage, String label, int index) {
    return InkWell(
      onTap: () => controller.onItemTapped(index),
      child: SizedBox(
        height: double.infinity,
        width: MediaQuery.of(context).size.width * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetImage, width: 24, height: 24),
            Text(
              label,
              style: TextStyle(
                color:
                    controller.state.selectedIndex == index
                        ? AppColors.primaryColor
                        : AppColors.greyColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
