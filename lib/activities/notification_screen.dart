import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../api/notifications.dart';
import '../models/notification/notification_response.dart';
import '../utils/app_colors.dart';
import '../utils/contains.dart';
import 'logistic/goods_information_screen.dart';
import 'menu_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<NotificationResponse> futureData;

  @override
  void initState() {
    super.initState();
    futureData = Notifications().getNotification(context, 1, 100);
    Notifications().readAll(context);
    MenuScreen.badge = 0;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) {
        Navigator.pop(context, 'set');
      }
    },
    child: Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back_outline, color: AppColors.whiteColor),
          onPressed: () {
            Navigator.of(context).pop('set');
          },
        ),
        centerTitle: true,
        actions: [
          InkWell(
            radius: 20,
            onTap: () {
              Notifications().readAll(context);
              setState(() {
                MenuScreen.badge = 0;
              });
            },
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'read_all'.tr,
                  style: const TextStyle(color: AppColors.whiteColor, fontSize: 14),
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
          child: FutureBuilder<NotificationResponse>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text("Error loading notifications"));
              } else if (snapshot.hasData &&
                  snapshot.data!.header?.statusCode == 200 &&
                  snapshot.data!.header?.result == true &&
                  snapshot.data!.body!.data!.isNotEmpty) {
                return ListView.builder(
                  itemCount: snapshot.data!.body?.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final notification = snapshot.data!.body?.data?[index];
                    return Card(
                      color: notification?.isRead == 1 ? Colors.white : Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                        onTap: () async {
                          if (notification.type == 'TRACK' &&
                              notification.goodsTransferId != null &&
                              notification.goodsTransferId != 0) {

                            Notifications().readNotification(context, notification.id.toString());

                            var result = await Get.to(
                              () => GoodsInformationScreen(id: notification.goodsTransferId!),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: Constrains.duration),
                            );

                            if (result == null) {
                              setState(() {
                                futureData = Notifications().getNotification(context, 1, 100);
                              });
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${notification!.title}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5),
                                        child: Text('${notification.message}'),
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
                      Image.asset('assets/images/ic_no_notification.png', height: 84),
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
