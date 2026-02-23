import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../../value_statics.dart';
import '../../../../../utils/app_colors.dart';
import '../controller/select_ticket_controller.dart';

class SelectDestinationScreen extends GetView<SelectDestinationController> {
  const SelectDestinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            ValueStatic.ticketType == '3'
                ? AppColors.airBusColor
                : AppColors.primaryColor,

        elevation: 0.2,
        leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
        title: Card(
          child: Container(
            height: 45,
            color: Colors.white,
            child: TextField(
              onChanged: controller.load,
              decoration: InputDecoration(
                hintText: 'search_ticket'.tr,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                suffixIcon: const Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(
                  value: null,
                  color:
                      ValueStatic.ticketType == '3'
                          ? AppColors.airBusColor
                          : AppColors.primaryColor,
                  strokeWidth: 5.0,
                ),
              ),
            );
          }

          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ValueStatic.ticketType == '1' || ValueStatic.ticketType == '3'
                      ? Image.asset(AssetImages.empty_bus, height: 80)
                      : Image.asset(AssetImages.empty_boat, height: 80),
                  const SizedBox(height: 20),
                  Text(
                    'data_not_found'.tr,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: controller.items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = controller.items[index];
              return InkWell(
                onTap: () => controller.selectItem(item),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  child: Text(item.name?.toString() ?? ''),
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider();
            },
          );
        }),
      ),
    );
  }
}
