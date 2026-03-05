import 'dart:convert';
import 'dart:developer';

import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/home-dashboard/seat/presentation/controller/select_seat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/button.dart';
import '../controller/seat_data.dart';
import '../../../../../utils/app_colors.dart';

class SelectSeatScreen extends StatelessWidget {
  const SelectSeatScreen({super.key});

  double calculateImageSize(BuildContext context, int columns) {
    double availableWidth = MediaQuery.of(context).size.width - 30;
    double size = availableWidth / columns;
    size = size.clamp(24.0, 44.0);
    if (ValueStatic.ticketType == '2') {
      size = size.clamp(20.0, 30.0);
    }
    return size;
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<dynamic, dynamic>?;
    final flowId = (args?['flowId'] as String?) ?? '';
    final isBack = (args?['isBack'] as bool?) ?? false;
    final SelectSeatController controller;
    if (flowId.isEmpty) {
      controller = Get.find<SelectSeatController>();
    } else {
      final tag = '${flowId}_seat_${isBack ? 'back' : 'go'}';
      controller = Get.find<SelectSeatController>(tag: tag);
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          return AppBarVET().appBar(context, controller.state.title);
        }),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                right: 15,
                left: 15,
                bottom: 12,
              ),
              child: Text(
                'choose_seat'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.titleColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0, left: 15, right: 15),
              child: Row(
                children: [
                  _buildColorSeat('available'.tr, AppColors.whiteColor),
                  const SizedBox(width: 12),
                  _buildColorSeat('selected'.tr, AppColors.secondaryColor),
                  const SizedBox(width: 12),
                  _buildColorSeat('unavailable'.tr, AppColors.redColor),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Obx(() {
                  return FutureBuilder<Map<dynamic, dynamic>>(
                    future: controller.state.futureSeatLayout,
                    builder: (context, seatData) {
                      if (seatData.hasData) {
                        List<dynamic> result = json.decode(
                          seatData.data?['body'][0]['layout'],
                        );
                        var colJson = jsonEncode(result[2]['col']);
                        List<dynamic> col = json.decode(colJson);
                        int columns = col.length;

                        double imageSize = calculateImageSize(context, columns);

                        final seats = controller.buildSeatListFromLayout(
                          seatData.data?['body'][0]['layout'],
                        );

                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 30,
                            ),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: columns,
                              childAspectRatio:
                                  (1 / (imageSize > 30 ? 1.2 : 2)),
                              mainAxisSpacing: 0,
                              crossAxisSpacing: 0,
                              children: List.generate(seats.length, (index) {
                                if (seats[index].seatLabel == '') {
                                  return const SizedBox.shrink();
                                }

                                final int seatType =
                                    (seatData.data?['body'][0]['seatType'] ?? 1)
                                        as int;

                                return Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      final label =
                                          seats[index].seatLabel.toString();
                                      final value =
                                          seats[index].seatValue.toString();

                                      if (label != '' &&
                                          !controller.checkUnavailable(value) &&
                                          label != 'Captain' &&
                                          label != 'Down Stair' &&
                                          label != 'Up Stair' &&
                                          label != 'Toilet' &&
                                          label != 'Hostess' &&
                                          label != 'Door') {
                                        controller.toggleSeat(
                                          seatLabel: label,
                                          seatValue: value,
                                        );
                                      }
                                    },
                                    child: _buildSeatCell(
                                      index: index,
                                      seatType: seatType,
                                      imageSize: imageSize,
                                      controller: controller,
                                      seat: seats[index],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      } else if (seatData.hasError) {
                        log('error ${seatData.error}');
                        return Center(
                          child: Text(
                            'Error loading seat data: ${seatData.error}',
                          ),
                        );
                      }

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
                    },
                  );
                }),
              ),
            ),
            Obx(() {
              return controller.state.selectedSeat.isNotEmpty
                  ? Container(
                    width: double.infinity,
                    color: AppColors.whiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: globalButton(
                      context: context,
                      buttonText: 'next1'.tr,
                      buttonColor:
                          ValueStatic.ticketType == '3'
                              ? AppColors.airBusColor
                              : AppColors.primaryColor,
                      onPressed: controller.next,
                    ),
                  )
                  : const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSeat(String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: Colors.black),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(color: AppColors.textColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSeatCell({
    required int index,
    required int seatType,
    required double imageSize,
    required SelectSeatController controller,
    required SeatData seat,
  }) {
    final label = seat.seatLabel;
    final value = seat.seatValue.toString();

    if (label == 'Hostess' ||
        label == 'Down Stair' ||
        label == 'Up Stair' ||
        label == 'Toilet' ||
        label == 'Captain' ||
        label == 'Door') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (label == 'Hostess')
                  Image.asset(AssetImages.hostess, height: imageSize),
                if (label == 'Captain')
                  Image.asset(AssetImages.steering, height: imageSize),
                if (label != 'Hostess' && label != 'Captain')
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label.toString().replaceAll(' ', '').tr),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        !controller.checkUnavailable(value)
            ? !controller.checkSelected(label.toString())
                ? Image.asset(
                  seatType == 2
                      ? AssetImages.seat_sleep_free
                      : AssetImages.seat_free,
                  height: imageSize,
                )
                : Image.asset(
                  seatType == 2
                      // ? 'assets/images/ic_seat_sleep_selected.png'
                      // : 'assets/images/ic_seat_select.png',
                      ? AssetImages.seat_sleep_selected
                      : AssetImages.seat_selected,
                  height: imageSize,
                )
            : Image.asset(
              seatType == 2
                  // ? 'assets/images/ic_seat_sleep_not_free.png'
                  // : 'assets/images/ic_seat_not_free.png',
                  ? AssetImages.seat_sleep_not_free
                  : AssetImages.seat_not_free,
              height: imageSize,
            ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            (label.toString() + controller.checkUnavailableGender(value)),
            style: TextStyle(fontSize: imageSize > 30 ? 14 : 12),
          ),
        ),
      ],
    );
  }
}
