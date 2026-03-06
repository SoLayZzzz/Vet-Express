import 'dart:developer';

import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../home-dashboard/notifications/presentation/screen/goods_information_screen.dart';
import 'review_screen.dart';
import '../../../../../feature/home-dashboard/self_service/presentation/screen/self_service_qr_list_screen.dart';
import '../../data/model/response/transfer_list_response.dart';
import '../../../../../models/request_transfer/self_service_response.dart';
import '../../../../../utils/alert_dialog_filter.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/contains.dart';
import '../controller/goods_transfer_history_controller.dart';

class GoodsTransferHistoryScreen
    extends GetView<GoodsTransferHistoryController> {
  const GoodsTransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'goods_transfer_new'.tr),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  color: const Color(0XFFE6E8EA),
                  child: TabBar(
                    controller: controller.tabController,
                    labelColor: AppColors.titleColor,
                    unselectedLabelColor: AppColors.titleColor,
                    indicator: const UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 3,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 15),
                    ),
                    tabs: [
                      Tab(text: 'sending'.tr),
                      Tab(text: 'receiving'.tr),
                      Tab(text: 'vet_self_service'.tr),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: controller.tabController,
                    children: [
                      _transferTab(context: context, type: 1),
                      _transferTab(context: context, type: 2),
                      _selfServiceTab(context: context),
                    ],
                  ),
                ),
              ],
            ),
            Obx(() {
              if (!controller.isFiltering.value) return const SizedBox.shrink();
              return Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 5.0,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _selfServiceTab({required BuildContext context}) {
    return Obx(() {
      final future = controller.state.futureSelfService;
      if (future == null) {
        return const Center(
          child: SizedBox(
            height: 50.0,
            width: 50.0,
            child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
          ),
        );
      }

      return FutureBuilder<RequestGoodsTransferResponse>(
        future: future,
        builder: (context, data) {
          if (data.hasData) {
            if ((data.data?.header?.result) == true &&
                (data.data?.header?.statusCode) == 200) {
              if ((data.data?.body?.data)!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: (data.data?.body?.data)!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(top: 12.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.whiteColor,
                          border: Border.all(
                            width: 0.5,
                            color: AppColors.borderColor,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Get.to(
                              () => SelfServiceQRListScreen(
                                qrCode:
                                    (data.data?.body?.data?[index].code)
                                        .toString(),
                              ),
                              transition: Transition.rightToLeft,
                              duration: const Duration(
                                milliseconds: Constrains.duration,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'sender_tel'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'phone_of_receiver'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (data
                                            .data
                                            ?.body
                                            ?.data?[index]
                                            .senderTelephone)
                                        .toString(),
                                  ),
                                  Text(
                                    (data
                                            .data
                                            ?.body
                                            ?.data?[index]
                                            .receiverTelephone)
                                        .toString(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'destination'.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                (data.data?.body?.data?[index].destinationTo)
                                    .toString(),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'item_price'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    'amount'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "\$${data.data?.body?.data?[index].itemValue}",
                                  ),
                                  Text(
                                    "${data.data?.body?.data?[index].itemQty} ${data.data?.body?.data?[index].uomName}",
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'date'.tr,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    (data.data?.body?.data?[index].date)
                                        .toString(),
                                  ),
                                  Text(
                                    'view_qr_code'.tr,
                                    style: const TextStyle(
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              if ((data.data?.body?.data)!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AssetImages.ic_empty,
                        width: 150,
                        height: 150,
                      ),
                      Text(
                        'no_data'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
          } else if (data.hasError) {
            log('error ${data.error}');
          }
          return const Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
            ),
          );
        },
      );
    });
  }

  Widget _transferTab({required BuildContext context, required int type}) {
    return Obx(() {
      final future =
          type == 1
              ? controller.state.futureSending
              : controller.state.futureReceiving;

      if (future == null) {
        controller.loadTransferList(context: context, type: type);
        return const Center(
          child: SizedBox(
            height: 50.0,
            width: 50.0,
            child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
          ),
        );
      }

      return FutureBuilder<TransferListResponse>(
        future: future,
        builder: (context, data) {
          if (data.hasData) {
            if ((data.data?.header?.result) == true &&
                (data.data?.header?.statusCode) == 200) {
              if ((data.data?.body?.data)!.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Stack(
                    children: [
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: (data.data?.body?.data)!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(top: 12.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppColors.whiteColor,
                              border: Border.all(
                                width: 0.5,
                                color: AppColors.borderColor,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                Get.to(
                                  () => GoodsInformationScreen(
                                    id:
                                        (data.data?.body?.data?[index].id)!
                                            .toInt(),
                                  ),
                                  transition: Transition.rightToLeft,
                                  duration: const Duration(
                                    milliseconds: Constrains.duration,
                                  ),
                                );
                                log(
                                  "Good ID : ${(data.data?.body?.data?[index].id)!.toInt()}",
                                );
                              },
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${data.data?.body?.data?[index].code}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.titleColor,
                                        ),
                                      ),
                                      Text(
                                        "${data.data?.body?.data?[index].date}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.titleColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(height: 20),
                                          Image.asset(
                                            AssetImages.ic_posting,
                                            width: 40,
                                            height: 40,
                                          ),
                                        ],
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              _returnStatus(
                                                (data
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .status)!,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: AppColors.secondaryColor,
                                              ),
                                            ),
                                            Image.asset(
                                              AssetImages.ic_tracking_line,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          const SizedBox(height: 20),
                                          Image.asset(
                                            AssetImages.ic_receive,
                                            width: 40,
                                            height: 40,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          (data
                                                  .data
                                                  ?.body
                                                  ?.data?[index]
                                                  .destinationFromEn)
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          (data
                                                  .data
                                                  ?.body
                                                  ?.data?[index]
                                                  .destinationToEn)
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        (data
                                                .data
                                                ?.body
                                                ?.data?[index]
                                                .senderTelephone)
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        (data
                                                .data
                                                ?.body
                                                ?.data?[index]
                                                .receiverTelephone)
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              AssetImages.ic_qty,
                                              width: 24,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Qty: ${(data.data?.body?.data?[index].qty).toString()}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if ((data
                                                        .data
                                                        ?.body
                                                        ?.data?[index]
                                                        .isSurveyReceiver)
                                                    .toString() ==
                                                '0' &&
                                            type == 2)
                                          _surveyButton(
                                            context: context,
                                            goodsTransferId:
                                                (data
                                                        .data
                                                        ?.body
                                                        ?.data?[index]
                                                        .id)
                                                    .toString(),
                                            type: type,
                                          ),
                                        if ((data
                                                        .data
                                                        ?.body
                                                        ?.data?[index]
                                                        .isSurveySender)
                                                    .toString() ==
                                                '0' &&
                                            type == 1)
                                          _surveyButton(
                                            context: context,
                                            goodsTransferId:
                                                (data
                                                        .data
                                                        ?.body
                                                        ?.data?[index]
                                                        .id)
                                                    .toString(),
                                            type: type,
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
                      _filterButton(context: context),
                    ],
                  ),
                );
              }
              if ((data.data?.body?.data)!.isEmpty) {
                return Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetImages.ic_empty,
                            width: 150,
                            height: 150,
                          ),
                          Text(
                            'no_data'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _filterButton(context: context),
                  ],
                );
              }
            }
          } else if (data.hasError) {
            log('error ${data.error}');
          }
          return const Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
            ),
          );
        },
      );
    });
  }

  Widget _surveyButton({
    required BuildContext context,
    required String goodsTransferId,
    required int type,
  }) {
    return Row(
      children: [
        const Icon(
          Ionicons.chatbubble_ellipses_outline,
          color: AppColors.primaryColor,
        ),
        const SizedBox(width: 6),
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () async {
            final result = await Get.to(
              () => ReviewScreen(
                goodsTransferID: goodsTransferId,
                type: type.toString(),
              ),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: Constrains.duration),
            );
            if (result != null) {
              controller.loadTransferList(context: Get.context!, type: type);
            }
          },
          child: Text(
            'take_survey'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Positioned _filterButton({required BuildContext context}) {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 15),
        child: InkWell(
          onTap: () async {
            final result = await Get.dialog<List<int>>(
              const AlertDialogFilter(),
              barrierColor: Colors.black26,
            );

            if (result == null) return;
            controller.applyFilter(
              context: context,
              desFrom: result[0],
              desTo: result[1],
              status: result[2],
            );
          },
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              color: AppColors.primaryColor,
            ),
            child: const Icon(
              Icons.filter_alt_outlined,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  String _returnStatus(int status) {
    String txtStatus = '';
    if (status == 1) {
      txtStatus = "posting".tr;
    } else if (status == 2) {
      txtStatus = "shipping".tr;
    } else if (status == 3) {
      txtStatus = "arrival".tr;
    } else if (status == 4) {
      txtStatus = "received".tr;
    }
    return txtStatus;
  }
}
