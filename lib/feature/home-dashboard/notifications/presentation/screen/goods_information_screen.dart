import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';

import '../../../../dash_board/scan_qr/presentation/binding/scan_qr_binding.dart';
import '../../../../dash_board/scan_qr/presentation/controller/scan_qr_controller.dart';
import '../../../../dash_board/scan_qr/data/model/response/goods_find_response.dart';
import '../../../../../utils/app_colors.dart';

class GoodsInformationScreen extends StatefulWidget {
  final int id;

  const GoodsInformationScreen({super.key, required this.id});

  @override
  State<GoodsInformationScreen> createState() => _GoodsInformationScreenState();
}

class _GoodsInformationScreenState extends State<GoodsInformationScreen> {
  late Future<GoodsFindResponse> futureData;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ScanQrController>()) {
      ScanQrBinding().dependencies();
    }
    futureData = Get.find<ScanQrController>().scanQrUseCase.findGoodsTransfer(
      context: context,
      id: widget.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'goods_information'.tr),
      body: SafeArea(
        child: FutureBuilder<GoodsFindResponse>(
          future: futureData,
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
                        _buildParcelInfo(transferData),

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
                                          'from_info',
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

  Widget _buildParcelInfo(AsyncSnapshot<GoodsFindResponse> transferData) {
  final data = transferData.data!.body?.data?[0];

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tracking Section
          _labelRow('Tracking Code:', '${data?.code}'),
          _labelRow('Tracking China No.:', 'N/A'),
          
          const SizedBox(height: 16),
          const Text('Item Details:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // 2. Fees Grid
          Row(
            children: [
              Expanded(child: _labelRow('Transfer Fee CH:', '\$10.50')),
              Expanded(child: _labelRow('Packing Fee:', '\$0.50')),
            ],
          ),
          Row(
            children: [
              Expanded(child: _labelRow('Transfer Fee KH:', '\$0.00')),
              Expanded(child: _labelRow('Delivery Fee:', '\$0.00')),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Item Size:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // 3. Size Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Width: 120CM', style: const TextStyle(fontSize: 13)),
              Text('Length: 120CM', style: const TextStyle(fontSize: 13)),
              Text('Height: 120CM', style: const TextStyle(fontSize: 13)),
            ],
          ),

          const SizedBox(height: 16),
          const Text('Item Weight:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Weight: 1.20KG'),

          const SizedBox(height: 20),

          // 4. Stylized Info Boxes
          _buildInfoBox('QTY:', '${data?.qty} Package'),
          const SizedBox(height: 10),
          _buildInfoBox('From:', '${data?.destinationFromEn}'),
          const SizedBox(height: 10),
          _buildReceiverBox(
            label: 'Receiver:',
            phoneNumber: '${data?.receiverTelephone}',
            toLabel: 'To:',
            destination: '${data?.destinationToEn}',
          ),
        ],
      ),
    ),
  );
}

// Helper for simple label: value rows
Widget _labelRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$title  ', style: const TextStyle(color: Colors.black87)),
        // Spacer(),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
          ),
        ),
      ],
    ),
  );
}

// Helper for the rounded white boxes at the bottom
Widget _buildInfoBox(String label, String value) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

// Helper for the Receiver box which has two lines of value
Widget _buildReceiverBox({
  required String label,
  required String phoneNumber,
  required String toLabel,
  required String destination,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      children: [
        // Top Row: Receiver and Phone Number
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(phoneNumber),
            ),
          ],
        ),
        const SizedBox(height: 8), // Space between Receiver line and To line
        // Bottom Row: To and Destination
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(toLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Text(destination),
            ),
          ],
        ),
      ],
    ),
  );
}

  // Widget _buildParcelInfo(AsyncSnapshot<GoodsFindResponse> transferData) {
  //   return Container(
  //                       margin: const EdgeInsets.symmetric(vertical: 20),
  //                       decoration: BoxDecoration(
  //                         color: AppColors.whiteColor,
  //                         borderRadius: BorderRadius.circular(10),
  //                         border: Border.all(
  //                           color: AppColors.borderColor,
  //                           width: 0.5,
  //                         ),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(12.0),
  //                         child: Row(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             Expanded(
  //                               flex: 4,
  //                               child: Column(
  //                                 crossAxisAlignment:
  //                                     CrossAxisAlignment.start,
  //                                 children: [
  //                                   labelDisplay(
  //                                     title: 'tracking_code'.tr,
  //                                     value:
  //                                         (transferData
  //                                             .data!
  //                                             .body
  //                                             ?.data?[0]
  //                                             .code)!,
  //                                   ),
  //                                   labelDisplay(
  //                                     title: 'sender'.tr,
  //                                     value:
  //                                         (transferData
  //                                             .data!
  //                                             .body
  //                                             ?.data?[0]
  //                                             .senderTelephone)!,
  //                                   ),
  //                                   labelDisplay(
  //                                     title: 'from'.tr,
  //                                     value:
  //                                         (transferData
  //                                             .data!
  //                                             .body
  //                                             ?.data?[0]
  //                                             .destinationFromEn
  //                                             .toString())!,
  //                                   ),
  //                                   labelDisplay(
  //                                     title: 'receiver'.tr,
  //                                     value:
  //                                         (transferData
  //                                             .data!
  //                                             .body
  //                                             ?.data?[0]
  //                                             .receiverTelephone)!,
  //                                   ),
  //                                   labelDisplay(
  //                                     title: 'to'.tr,
  //                                     value:
  //                                         (transferData
  //                                             .data!
  //                                             .body
  //                                             ?.data?[0]
  //                                             .destinationToEn
  //                                             .toString())!,
  //                                   ),
  //                                   labelDisplay(
  //                                     title: 'qty'.tr,
  //                                     value:
  //                                         (transferData
  //                                             .data!
  //                                             .body
  //                                             ?.data?[0]
  //                                             .qty
  //                                             .toString())!,
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
                              
  //                           ],
  //                         ),
  //                       ),
  //                     );
  // }

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
