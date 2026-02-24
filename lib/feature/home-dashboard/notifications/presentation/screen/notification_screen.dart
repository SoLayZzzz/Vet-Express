import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import 'package:express_vet/feature/home-dashboard/menu/data/model/response/notification_response.dart';
import 'package:express_vet/feature/home-dashboard/menu/presentation/binding/menu_binding.dart';
import 'package:express_vet/feature/home-dashboard/menu/presentation/controller/menu_controller.dart'
    as menu;
import 'package:express_vet/feature/home-dashboard/notifications/presentation/binding/notifications_binding.dart';
import 'package:express_vet/feature/home-dashboard/notifications/presentation/controller/notifications_controller.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/contains.dart';
import 'package:express_vet/feature/home-dashboard/notifications/presentation/screen/goods_information_screen.dart';

class NotificationScreen extends GetView<NotificationsController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure required bindings are available when route omits binding.
    MenuBinding().dependencies();
    NotificationsBinding().dependencies();

    final menu.MenuController _menuController = Get.find<menu.MenuController>();
    final NotificationsController _notificationsController =
        Get.find<NotificationsController>();

    // Initial load and read-all once
    if (_notificationsController.state.futureList == null) {
      _notificationsController.loadList(
        context: context,
        page: 1,
        rowsPerPage: 100,
      );
      _notificationsController.readAll(context: context);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _menuController.clearBadge();
      });
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Get.back(result: 'set');
          },
        ),
        centerTitle: true,
        actions: [
          InkWell(
            radius: 20,
            onTap: () {
              _notificationsController.readAll(context: context);
              _menuController.clearBadge();
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'read_all'.tr,
                  style: const TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
        title: Text(
          'notification'.tr,
          style: const TextStyle(color: AppColors.whiteColor, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Obx(
            () => FutureBuilder<NotificationResponse>(
              future: _notificationsController.state.futureList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text("Error loading notifications"),
                  );
                } else if (snapshot.hasData &&
                    snapshot.data!.header?.statusCode == 200 &&
                    snapshot.data!.header?.result == true &&
                    snapshot.data!.body!.data!.isNotEmpty) {
                  return ListView.builder(
                    itemCount: snapshot.data!.body?.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      final notification = snapshot.data!.body?.data?[index];
                      return Card(
                        color:
                            notification?.isRead == 1
                                ? Colors.white
                                : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () async {
                            if (notification.type == 'TRACK' &&
                                notification.goodsTransferId != null &&
                                notification.goodsTransferId != 0) {
                              _notificationsController.readNotification(
                                context: context,
                                id: notification.id.toString(),
                              );

                              var result = await Get.to(
                                () => GoodsInformationScreen(
                                  id: notification.goodsTransferId!,
                                ),
                                transition: Transition.rightToLeft,
                                duration: const Duration(
                                  milliseconds: Constrains.duration,
                                ),
                              );

                              if (result == null) {
                                _notificationsController.loadList(
                                  context: Get.context!,
                                  page: 1,
                                  rowsPerPage: 100,
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${notification!.title}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                          ),
                                          child: Text(
                                            '${notification.message}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AssetImages.no_notification, height: 84),
                        Text('no_notification'.tr),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
