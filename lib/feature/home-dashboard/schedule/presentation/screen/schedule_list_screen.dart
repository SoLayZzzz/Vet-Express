import 'dart:developer';

import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/routes/app_routes.dart';
import '../../data/model/response/schedule_response.dart';
import '../../../../../utils/alert_dialog_schedule.dart';
import '../../../../../utils/app_colors.dart';
import '../controller/schedule_list_controller.dart';

class ScheduleListScreen extends StatelessWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<dynamic, dynamic>?;
    final flowId = (args?['flowId'] as String?) ?? '';
    final isBack = (args?['isBack'] as bool?) ?? false;
    final ScheduleListController controller;
    if (flowId.isEmpty) {
      controller = Get.find<ScheduleListController>();
    } else {
      final tag = '${flowId}_schedule_${isBack ? 'back' : 'go'}';
      controller = Get.find<ScheduleListController>(tag: tag);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor:
            ValueStatic.ticketType == '3'
                ? AppColors.airBusColor
                : AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () => controller.pickDate(context),
            icon: Image.asset(
              AssetImages.date_select,
              width: 24,
              color: AppColors.whiteColor,
            ),
          ),
          const SizedBox(width: 5),
        ],
        centerTitle: true,
        title: Obx(() {
          return Text(
            controller.state.currentDate,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          );
        }),
      ),
      body: Stack(
        children: [
          Obx(
            () => FutureBuilder<ScheduleResponse>(
              future: controller.state.futureSchedule,
              builder: (context, scheduleData) {
                if (scheduleData.connectionState == ConnectionState.waiting) {
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
                if (scheduleData.hasData &&
                    scheduleData.data!.header!.result == true &&
                    scheduleData.data!.header!.statusCode == 200) {
                  if ((scheduleData.data?.body ?? []).isNotEmpty) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 60),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              children: [
                                Image.asset(
                                  AssetImages.location_schedule,
                                  width: 24,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  controller.state.titleRoute,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: scheduleData.data!.body?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              if (controller.state.isBack) {
                                ValueStatic.seatPriceBack =
                                    (scheduleData.data!.body?[index].price)
                                        .toString();
                              } else {
                                ValueStatic.seatPriceGo =
                                    (scheduleData.data!.body?[index].price)
                                        .toString();
                              }

                              return scheduleData.data!.body?[index].status == 2
                                  ? SizedBox.shrink()
                                  : Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (scheduleData
                                                .data!
                                                .body?[index]
                                                .status ==
                                            1) {
                                          controller.openSelectSeat(
                                            scheduleData.data!.body![index],
                                          );
                                        } else if (scheduleData
                                                .data!
                                                .body?[index]
                                                .status ==
                                            2) {
                                          alertDialogSchedule(
                                            title: 'info'.tr,
                                            description: 'bus_left'.tr,
                                            buttonText: 'ok'.tr,
                                          );
                                        } else if (scheduleData
                                                .data!
                                                .body?[index]
                                                .status ==
                                            3) {
                                          alertDialogSchedule(
                                            title: 'info'.tr,
                                            description: 'bus_full'.tr,
                                            buttonText: 'ok'.tr,
                                          );
                                        } else {
                                          return;
                                        }
                                      },
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Image.asset(
                                                      scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .journeyType ==
                                                              1
                                                          ? AssetImages.vet_logo
                                                          : scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .journeyType ==
                                                              2
                                                          ? AssetImages.buva_sea
                                                          : scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .journeyType ==
                                                              3
                                                          ? AssetImages
                                                              .vet_air_bus_schedule
                                                          : AssetImages
                                                              .buva_sea,
                                                      height: 30,
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            (scheduleData
                                                                    .data!
                                                                    .body?[index]
                                                                    .transportationType)
                                                                .toString(),
                                                            style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 14,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              color:
                                                                  AppColors
                                                                      .titleColor,
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text.rich(
                                                                  TextSpan(
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color:
                                                                          AppColors
                                                                              .textColor,
                                                                    ),
                                                                    text:
                                                                        (scheduleData.data!.body?[index].scheduleType)
                                                                            .toString(),
                                                                    children: <
                                                                      TextSpan
                                                                    >[
                                                                      if ((scheduleData.data!.body?[index].nationRoad).toString() !=
                                                                              '' &&
                                                                          (scheduleData.data!.body?[index].nationRoad).toString() !=
                                                                              'null')
                                                                        TextSpan(
                                                                          text:
                                                                              ' - ${(scheduleData.data!.body?[index].nationRoad).toString()}',
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    scheduleData
                                                                .data!
                                                                .body?[index]
                                                                .status ==
                                                            1
                                                        ? Row(
                                                          children: [
                                                            Text(
                                                              (((scheduleData
                                                                          .data!
                                                                          .body?[index]
                                                                          .totalSeat)! -
                                                                      (scheduleData
                                                                          .data!
                                                                          .body?[index]
                                                                          .seatAvailable)!))
                                                                  .toString(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                color:
                                                                    AppColors
                                                                        .primaryColor,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                            Text(
                                                              '/${(scheduleData.data!.body?[index].totalSeat).toString()} ${'seats'.tr}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: const TextStyle(
                                                                color:
                                                                    AppColors
                                                                        .greyColor,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                        : Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                right: 8.0,
                                                                bottom: 10,
                                                              ),
                                                          child: Text(
                                                            scheduleData
                                                                        .data!
                                                                        .body?[index]
                                                                        .status ==
                                                                    3
                                                                ? 'full'.tr
                                                                : scheduleData
                                                                        .data!
                                                                        .body?[index]
                                                                        .status ==
                                                                    4
                                                                ? 'unavailable'
                                                                    .tr
                                                                : 'left'.tr,
                                                            textAlign:
                                                                TextAlign
                                                                    .center,
                                                            style: const TextStyle(
                                                              color:
                                                                  AppColors
                                                                      .primaryColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      DateFormat(
                                                        'HH:mm',
                                                      ).format(
                                                        DateFormat(
                                                          'HH:mm',
                                                        ).parse(
                                                          (scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .departure)
                                                              .toString(),
                                                        ),
                                                      ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Image.asset(
                                                      AssetImages.departure,
                                                      width: 70,
                                                    ),
                                                    Text(
                                                      '${DateFormat('HH:mm').format(DateFormat('HH:mm').parse((scheduleData.data!.body?[index].duration).toString()))}h',
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors
                                                                .secondaryColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    Image.asset(
                                                      AssetImages.arrive,
                                                      width: 70,
                                                    ),
                                                    Text(
                                                      DateFormat(
                                                        'HH:mm',
                                                      ).format(
                                                        DateFormat(
                                                          'HH:mm',
                                                        ).parse(
                                                          (scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .arrival)
                                                              .toString(),
                                                        ),
                                                      ),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 1,
                                            color: Colors.grey[300],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                gotoRateReview(
                                                  controller,
                                                  scheduleData,
                                                  index,
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    controller
                                                        .applySelectedScheduleData(
                                                          scheduleData
                                                              .data!
                                                              .body![index],
                                                        );

                                                    final args =
                                                        Get.arguments
                                                            as Map<
                                                              dynamic,
                                                              dynamic
                                                            >?;
                                                    final flowId =
                                                        (args?['flowId']
                                                            as String?) ??
                                                        '';

                                                    await gotoScheduleDetail(
                                                      scheduleData,
                                                      index,
                                                      controller,
                                                      flowId,
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Ionicons
                                                            .information_circle_outline,
                                                        size: 20,
                                                        color:
                                                            scheduleData
                                                                        .data!
                                                                        .body?[index]
                                                                        .journeyType !=
                                                                    3
                                                                ? AppColors
                                                                    .primaryColor
                                                                : AppColors
                                                                    .airBusColor,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        'trip_info'.tr,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              scheduleData
                                                                          .data!
                                                                          .body?[index]
                                                                          .journeyType !=
                                                                      3
                                                                  ? AppColors
                                                                      .primaryColor
                                                                  : AppColors
                                                                      .airBusColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Visibility(
                                                      visible:
                                                          (scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .priceOriginal !=
                                                              ''),
                                                      child: Text(
                                                        '\$${(scheduleData.data!.body?[index].priceOriginal)}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              AppColors
                                                                  .borderColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                    ),
                                                    if (scheduleData
                                                            .data!
                                                            .body?[index]
                                                            .priceOriginal !=
                                                        '')
                                                      const SizedBox(width: 10),
                                                    Visibility(
                                                      visible:
                                                          (scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .priceOriginal ==
                                                              ''),
                                                      child: Text(
                                                        '\$${(scheduleData.data!.body?[index].price)!.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              AppColors
                                                                  .borderColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                    ),
                                                    if (scheduleData
                                                            .data!
                                                            .body?[index]
                                                            .priceOriginal ==
                                                        '')
                                                      const SizedBox(width: 10),
                                                    Visibility(
                                                      visible:
                                                          (scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .priceOriginal ==
                                                              ''),
                                                      child: Text(
                                                        "\$${(double.parse(controller.state.isBack ? ValueStatic.seatPriceBack : ValueStatic.seatPriceGo) - (double.parse((double.parse(controller.state.isBack ? ValueStatic.seatPriceBack : ValueStatic.seatPriceGo) * 0.05).toStringAsFixed(2)))).toStringAsFixed(2)}",
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              scheduleData
                                                                          .data!
                                                                          .body?[index]
                                                                          .journeyType !=
                                                                      3
                                                                  ? AppColors
                                                                      .primaryColor
                                                                  : AppColors
                                                                      .airBusColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          (scheduleData
                                                                  .data!
                                                                  .body?[index]
                                                                  .priceOriginal !=
                                                              ''),
                                                      child: Text(
                                                        '\$${(scheduleData.data!.body?[index].price)!.toStringAsFixed(2)}',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              scheduleData
                                                                          .data!
                                                                          .body?[index]
                                                                          .journeyType !=
                                                                      3
                                                                  ? AppColors
                                                                      .primaryColor
                                                                  : AppColors
                                                                      .airBusColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  if ((scheduleData.data?.body ?? []).isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetImages.no_schedule,
                            width: 100,
                            color:
                                ValueStatic.ticketType == '3'
                                    ? AppColors.airBusColor
                                    : AppColors.primaryColor,
                          ),
                          Text('no_data'.tr),
                        ],
                      ),
                    );
                  }
                } else if (scheduleData.hasError) {
                  log('error ${scheduleData.error}');
                  return Center(child: Text('Error: ${scheduleData.error}'));
                }

                return Container();
              },
            ),
          ),
          Column(
            children: [
              Container(
                height: 45,
                color: Colors.white,
                child: Row(
                  children: [
                    Container(width: 15),
                    Text(
                      'departure_time'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      'estimate_time'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      'estimate_arrival'.tr,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Container(width: 15),
                  ],
                ),
              ),
              Container(height: 1, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget gotoRateReview(
    ScheduleListController controller,
    AsyncSnapshot<ScheduleResponse> scheduleData,
    int index,
  ) {
    return InkWell(
      onTap: () {
        controller.applySelectedScheduleData(scheduleData.data!.body![index]);

        Get.toNamed(
          AppRoutes.reviewRate,
          arguments: {
            'scheduleId': scheduleData.data!.body![index].scheduleId,
            'status': scheduleData.data!.body![index].status,
            'type': controller.state.isBack ? 2 : 1,
            'id': (scheduleData.data!.body?[index].id).toString(),
          },
        );
      },
      child: Column(
        children: [
          RatingBarIndicator(
            rating: scheduleData.data?.body?[index].totalRate ?? 0.0,
            itemBuilder: (context, _) => Icon(Icons.star, color: Colors.orange),
            itemCount: 5,
            itemSize: 14,
            unratedColor: Colors.grey[300],
            direction: Axis.horizontal,
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: AppColors.textColor),
              children: <TextSpan>[
                TextSpan(
                  text: '${scheduleData.data!.body?[index].totalReview} ',
                ),
                TextSpan(
                  text:
                      scheduleData.data?.body?[index].totalReview == 1 ||
                              scheduleData.data?.body?[index].totalReview == 0
                          ? 'review'
                          : 'reviews',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> gotoScheduleDetail(
    AsyncSnapshot<ScheduleResponse> scheduleData,
    int index,
    ScheduleListController controller,
    String flowId,
  ) async {
    return await Get.toNamed(
      AppRoutes.ticketScheduleCarDetail,
      arguments: {
        'journeyId': (scheduleData.data!.body?[index].id).toString(),
        'carType':
            (scheduleData.data!.body?[index].transportationType).toString(),
        'seat': (scheduleData.data!.body?[index].totalSeat).toString(),
        'image':
            (scheduleData.data!.body?[index].transportationPhoto).toString(),
        'description': (scheduleData.data!.body?[index].note).toString(),
        'status': (scheduleData.data!.body?[index].status)!,
        'type': controller.state.isBack ? 2 : 1,
        'isBack': controller.state.isBack,
        'flowId': flowId,
        'listSlide': scheduleData.data!.body?[index].slidePhoto,
        'listIcon': scheduleData.data!.body?[index].amenities,
        'boardingPoint': scheduleData.data!.body?[index].boardingPointList,
        'dropOffPoint': scheduleData.data!.body?[index].dropOffPointList,
      },
    );
  }
}
