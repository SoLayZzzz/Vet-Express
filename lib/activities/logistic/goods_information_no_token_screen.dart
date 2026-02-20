import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';

import '../../feature/dash_board/scan_qr/data/model/response/goods_find_response.dart';
import '../../utils/app_colors.dart';

class GoodsInformationNoTokenScreen extends StatefulWidget {
  final Future<GoodsFindResponse> futureData;

  const GoodsInformationNoTokenScreen({super.key, required this.futureData});

  @override
  State<GoodsInformationNoTokenScreen> createState() =>
      _GoodsInformationNoTokenScreenState();
}

class _GoodsInformationNoTokenScreenState
    extends State<GoodsInformationNoTokenScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'goods_information'.tr),
      body: SafeArea(
        child: FutureBuilder<GoodsFindResponse>(
          future: widget.futureData,
          builder: (context, transferData) {
            if (transferData.hasData) {
              if (transferData.data!.header?.statusCode == 200 &&
                  transferData.data!.header?.result == true) {
                if (transferData.data!.body!.data!.isNotEmpty) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //* transfer code
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 0.5,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      labelDisplay(
                                        title: 'tracking_code'.tr,
                                        value:
                                            (transferData
                                                .data!
                                                .body
                                                ?.data?[0]
                                                .code)!,
                                      ),
                                      labelDisplay(
                                        title: 'sender'.tr,
                                        value:
                                            (transferData
                                                .data!
                                                .body
                                                ?.data?[0]
                                                .senderTelephone)!,
                                      ),
                                      labelDisplay(
                                        title: 'from'.tr,
                                        value:
                                            (transferData
                                                .data!
                                                .body
                                                ?.data?[0]
                                                .destinationFromEn
                                                .toString())!,
                                      ),
                                      labelDisplay(
                                        title: 'receiver'.tr,
                                        value:
                                            (transferData
                                                .data!
                                                .body
                                                ?.data?[0]
                                                .receiverTelephone)!,
                                      ),
                                      labelDisplay(
                                        title: 'to'.tr,
                                        value:
                                            (transferData
                                                .data!
                                                .body
                                                ?.data?[0]
                                                .destinationToEn
                                                .toString())!,
                                      ),
                                      labelDisplay(
                                        title: 'qty'.tr,
                                        value:
                                            (transferData
                                                .data!
                                                .body
                                                ?.data?[0]
                                                .qty
                                                .toString())!,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 1,
                                  child: Image.asset(
                                    'assets/icons/icon_tracking_parcel.png',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //* tracking parcel
                        Text(
                          'tracking_detail'.tr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleColor,
                          ),
                        ),

                        //* status of tacking
                        ListView.builder(
                          padding: const EdgeInsets.only(top: 12),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount:
                              transferData
                                  .data!
                                  .body!
                                  .data![0]
                                  .goodsTransferMoveList!
                                  .length,
                          itemBuilder: (context, index) {
                            int? length =
                                transferData
                                    .data!
                                    .body!
                                    .data![0]
                                    .goodsTransferMoveList!
                                    .length;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //* icon tick
                                Column(
                                  children: [
                                    Image.asset(
                                      index == 0
                                          ? 'assets/icons/icon_tick_green.png'
                                          : 'assets/icons/icon_tick_orange.png',
                                      height: 24,
                                    ),
                                    Container(
                                      height: 70,
                                      width: 4,
                                      color:
                                          (index >= length - 1)
                                              ? AppColors.backgroundColor
                                              : AppColors.borderColor,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),

                                //* status
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if ((transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .status)! ==
                                          1)
                                        display(
                                          'assets/images/ic_posting.png',
                                          'posting',
                                          'at',
                                          (transferData
                                                  .data!
                                                  .body
                                                  ?.data?[0]
                                                  .goodsTransferMoveList?[index]
                                                  .msg) ??
                                              '',
                                          (transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .created)!,
                                          colorText:
                                              index == 0
                                                  ? AppColors.greenColor
                                                  : AppColors.textColor,
                                          view: false,
                                        ),
                                      if ((transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .status)! ==
                                          2)
                                        display(
                                          'assets/images/ic_shipping.png',
                                          'shipping',
                                          'from',
                                          (transferData
                                                  .data!
                                                  .body
                                                  ?.data?[0]
                                                  .goodsTransferMoveList?[index]
                                                  .msg) ??
                                              '',
                                          (transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .created)!,
                                          colorText:
                                              index == 0
                                                  ? AppColors.greenColor
                                                  : AppColors.textColor,
                                        ),
                                      if ((transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .status)! ==
                                          3)
                                        display(
                                          'assets/images/ic_arrive.png',
                                          'arrival',
                                          'at',
                                          (transferData
                                                  .data!
                                                  .body
                                                  ?.data?[0]
                                                  .goodsTransferMoveList?[index]
                                                  .msg) ??
                                              '',
                                          (transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .created)!,
                                          colorText:
                                              index == 0
                                                  ? AppColors.greenColor
                                                  : AppColors.textColor,
                                        ),
                                      if ((transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .status)! ==
                                          4)
                                        display(
                                          'assets/images/ic_receive.png',
                                          'received',
                                          '',
                                          (transferData
                                                  .data!
                                                  .body
                                                  ?.data?[0]
                                                  .goodsTransferMoveList?[index]
                                                  .msg) ??
                                              '',
                                          (transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .created)!,
                                          colorText:
                                              index == 0
                                                  ? AppColors.greenColor
                                                  : AppColors.textColor,
                                        ),
                                      if ((transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .status)! ==
                                          5)
                                        display(
                                          'assets/images/ic_arrive.png',
                                          'transit',
                                          'at',
                                          (transferData
                                                  .data!
                                                  .body
                                                  ?.data?[0]
                                                  .goodsTransferMoveList?[index]
                                                  .msg) ??
                                              '',
                                          (transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .created)!,
                                          colorText:
                                              index == 0
                                                  ? AppColors.greenColor
                                                  : AppColors.textColor,
                                        ),
                                      if ((transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .status)! ==
                                          6)
                                        display(
                                          'assets/images/ic_delivery_to_customer.png',
                                          'delivery',
                                          '',
                                          (transferData
                                                  .data!
                                                  .body
                                                  ?.data?[0]
                                                  .goodsTransferMoveList?[index]
                                                  .msg) ??
                                              '',
                                          (transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .created)!,
                                          colorText:
                                              index == 0
                                                  ? AppColors.greenColor
                                                  : AppColors.textColor,
                                        ),
                                      if ((transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .status)! ==
                                          7)
                                        display(
                                          'assets/images/ic_call_to_customer.png',
                                          'call',
                                          '',
                                          (transferData
                                                  .data!
                                                  .body
                                                  ?.data?[0]
                                                  .goodsTransferMoveList?[index]
                                                  .msg) ??
                                              '',
                                          (transferData
                                              .data!
                                              .body
                                              ?.data?[0]
                                              .goodsTransferMoveList?[index]
                                              .created)!,
                                          colorText:
                                              index == 0
                                                  ? AppColors.greenColor
                                                  : AppColors.textColor,
                                          view: false,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              }
            } else if (transferData.hasError) {
              log('error ${transferData.error}');
            }

            return const Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        color: AppColors.primaryColor,
        height: 70,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'thank_for_your_support'.tr,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  display(
    String img,
    String status,
    String des,
    String msg,
    String created, {
    Color colorText = AppColors.textColor,
    bool? view = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(img, width: 28, height: 28),
            const SizedBox(width: 10),
            Text(
              "${status.tr} ${des.tr}",
              style: TextStyle(fontSize: 14, color: colorText),
            ),
            const Spacer(),
            // view == true
            //     ? InkWell(
            //         onTap: () {
            //           Get.bottomSheet(
            //             Container(
            //               padding: const EdgeInsets.all(16),
            //               decoration: const BoxDecoration(
            //                 color: AppColors.whiteColor,
            //                 borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            //               ),
            //               child: Column(
            //                 mainAxisSize: MainAxisSize.min,
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Center(
            //                     child: Container(
            //                         height: 5,
            //                         width: MediaQuery.sizeOf(context).width * 0.25,
            //                         decoration: BoxDecoration(
            //                             color: AppColors.borderColor,
            //                             borderRadius: BorderRadius.circular(10))),
            //                   ),
            //                   const SizedBox(height: 30),
            //                   Row(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     children: [
            //                       Container(
            //                         width: 12,
            //                         height: 12,
            //                         decoration: const BoxDecoration(
            //                           shape: BoxShape.circle,
            //                           color: Colors.green,
            //                         ),
            //                       ),
            //                       const SizedBox(width: 10),
            //                       const Expanded(
            //                         child: Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.start, // Align text to the start
            //                           children: [
            //                             Text(
            //                               "Hello I'm from UDAYA company and want to build something",
            //                               style: TextStyle(
            //                                   fontSize: 14), // Optional: Adjust text style
            //                             ),
            //                             SizedBox(height: 4), // Optional: Add space between texts
            //                             Text(
            //                               "Hello I'm from UDAYA company and want to build something",
            //                               style: TextStyle(
            //                                   fontSize: 14), // Optional: Adjust text style
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     ],
            //                   )
            //                 ],
            //               ),
            //             ),
            //             isScrollControlled: true, // Allows the bottom sheet to be scrollable
            //           );
            //         },
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            //           decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(20),
            //               border: Border.all(color: AppColors.primaryColor)),
            //           child: const Text("View Detail"),
            //         ),
            //       )
            //     : const SizedBox.shrink()
          ],
        ),
        const SizedBox(height: 5),
        Text(
          msg,
          style: const TextStyle(fontSize: 12, color: AppColors.textColor),
        ),
        const SizedBox(height: 5),
        Text(
          created,
          style: const TextStyle(fontSize: 12, color: AppColors.textColor),
        ),
      ],
    );
  }

  labelDisplay({required title, required value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$title:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.titleColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.titleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
