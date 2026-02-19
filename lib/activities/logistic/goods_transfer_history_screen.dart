import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/activities/logistic/goods_information_screen.dart';
import 'package:express_vet/feature/home-dashboard/self_service/presentation/screen/self_service_qr_list_screen.dart';
import 'package:express_vet/activities/screen/review_screen.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';

import '../../api/goods_transfer.dart';
import '../../models/goods_transfer/transfer_list_response.dart';
import '../../models/request_transfer/self_service_response.dart';
import '../../utils/alert_dialog_filter.dart';
import '../../utils/contains.dart';

class GoodsTransferHistoryScreen extends StatefulWidget {
  const GoodsTransferHistoryScreen({super.key});

  @override
  GoodsTransferHistoryScreenState createState() =>
      GoodsTransferHistoryScreenState();
}

class GoodsTransferHistoryScreenState extends State<GoodsTransferHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // for navigate pop back data return
  int desFromId = 0;
  int desToId = 0;
  int statusId = 0;

  int type = 1;

  late Future<TransferListResponse> futureGoodsTransfer;
  late Future<RequestGoodsTransferResponse> futureGoodsTransferList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    futureGoodsTransfer = GoodsTransfer().getTransferList(
      context,
      1,
      100,
      desFromId,
      desToId,
      type,
      statusId,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'goods_transfer_new'.tr),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0XFFE6E8EA),
              child: TabBar(
                controller: _tabController,
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
                controller: _tabController,
                children: [
                  Center(child: tabView(1)),
                  Center(child: tabView(2)),
                  Center(child: selfService()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //* for selfService
  FutureBuilder<RequestGoodsTransferResponse> selfService() {
    futureGoodsTransferList = GoodsTransfer().selfService(context);

    return FutureBuilder<RequestGoodsTransferResponse>(
      future: futureGoodsTransferList,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              return Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/ic_empty.png',
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
                  //  filterButton()
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
  }

  //* For tracking parcel
  FutureBuilder<TransferListResponse> tabView(int type) {
    this.type = type;
    futureGoodsTransfer = GoodsTransfer().getTransferList(
      context,
      1,
      100,
      desFromId,
      desToId,
      type,
      statusId,
    );

    return FutureBuilder<TransferListResponse>(
      future: futureGoodsTransfer,
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
                                //* code, date
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

                                //* status and image
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Image.asset(
                                          'assets/images/ic_posting.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Text(
                                            returnStatus(
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
                                            'assets/icons/icon_tracking_line.png',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Image.asset(
                                          'assets/images/ic_receive.png',
                                          width: 40,
                                          height: 40,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                //* destination
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

                                //* phone number
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

                                //* qty and survey
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/icon_qty.png',
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
                                        Row(
                                          children: [
                                            const Icon(
                                              Ionicons
                                                  .chatbubble_ellipses_outline,
                                              color: AppColors.primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () async {
                                                var result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ReviewScreen(
                                                          goodsTransferID:
                                                              (data
                                                                      .data
                                                                      ?.body
                                                                      ?.data?[index]
                                                                      .id)
                                                                  .toString(),
                                                          type: type.toString(),
                                                        ),
                                                  ),
                                                );
                                                if (result != null) {
                                                  futureGoodsTransfer =
                                                      GoodsTransfer()
                                                          .getTransferList(
                                                            context,
                                                            1,
                                                            100,
                                                            desFromId,
                                                            desToId,
                                                            type,
                                                            statusId,
                                                          );
                                                  setState(() {});
                                                }
                                              },
                                              child: Text(
                                                'take_survey'.tr,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      if ((data
                                                      .data
                                                      ?.body
                                                      ?.data?[index]
                                                      .isSurveySender)
                                                  .toString() ==
                                              '0' &&
                                          type == 1)
                                        Row(
                                          children: [
                                            const Icon(
                                              Ionicons
                                                  .chatbubble_ellipses_outline,
                                              color: AppColors.primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              onTap: () async {
                                                var result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (
                                                          context,
                                                        ) => ReviewScreen(
                                                          goodsTransferID:
                                                              (data
                                                                      .data
                                                                      ?.body
                                                                      ?.data?[index]
                                                                      .id)
                                                                  .toString(),
                                                          type: type.toString(),
                                                        ),
                                                  ),
                                                );
                                                if (result != null) {
                                                  futureGoodsTransfer =
                                                      GoodsTransfer()
                                                          .getTransferList(
                                                            context,
                                                            1,
                                                            100,
                                                            desFromId,
                                                            desToId,
                                                            type,
                                                            statusId,
                                                          );
                                                  setState(() {});
                                                }
                                              },
                                              child: Text(
                                                'take_survey'.tr,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
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
                    filterButton(),
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
                          'assets/images/ic_empty.png',
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
                  filterButton(),
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
  }

  String returnStatus(int status) {
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

  Positioned filterButton() {
    return Positioned(
      bottom: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20, right: 15),
        child: InkWell(
          onTap: () async {
            final result = await showDialog(
              barrierColor: Colors.black26,
              context: context,
              builder: (context) {
                return const AlertDialogFilter();
              },
            );
            setState(() {
              desFromId = result[0];
              desToId = result[1];
              statusId = result[2];
              futureGoodsTransfer = GoodsTransfer().getTransferList(
                context,
                1,
                100,
                desFromId,
                desToId,
                1,
                statusId,
              );
            });
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
}
