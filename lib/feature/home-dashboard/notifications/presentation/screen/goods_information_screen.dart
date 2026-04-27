import 'package:express_vet/asset_image.dart';
import 'package:express_vet/routes/app_routes.dart';
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
      appBar: AppBarVET().appBar(context, 'tracking_parcel'.tr),
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
                                          ? AssetImages.ic_ticket_green
                                          : AssetImages.ic_ticket_orange,
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
                                          AssetImages.ic_posting,
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
                                          AssetImages.ic_shipping,
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
                                          AssetImages.ic_arrive,
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
                                          AssetImages.ic_recieved,
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
                                          AssetImages.ic_arrive,
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
                                          AssetImages.ic_delivery_to_customer,
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
                                          AssetImages.ic_call_to_customer,
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
              debugPrint('error ${transferData.error}');
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
      bottomNavigationBar: _buildTotalBottomNavigationBar(),
    );
  }

  Widget _buildTotalBottomNavigationBar() {
  return SafeArea(
    child: Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.5)), 
      ),
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${'total_price'.tr} \$11.00',
            style: const TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(
            width: 140,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(AppRoutes.parcelPayment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "unpaid".tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ),
          )
        
        ],
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
          color: Colors.black.withAlpha(30),
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
          _labelRow('${'track_code'.tr}:', '${data?.code}'),
          _labelRow('${'track_china_no'.tr}:', '-'),
          
          const SizedBox(height: 16),
           Text('${'item_detail'.tr}:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // 2. Fees Grid
          Column(
            children: [
              _buildItemDetailsRow('${'tranfer_fee_ch'.tr}:', '\$10.50', '${'packing_fee'.tr}:', '\$0.50'),
              _buildItemDetailsRow('${'tranfer_fee_kh'.tr}:', '\$0.00', '${'delivery_fee'.tr}:', '\$0.00'),
            ],
          ),

          const SizedBox(height: 16),
           Text('${'item_size'.tr}:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // 3. Size Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${'width'.tr}: 120CM', style: const TextStyle(fontSize: 13)),
              Text('${'length'.tr}: 120CM', style: const TextStyle(fontSize: 13)),
              Text('${'height'.tr}: 120CM', style: const TextStyle(fontSize: 13)),
            ],
          ),

          const SizedBox(height: 16),
           Text('${'item_weight'.tr}:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('${'weight'.tr}: 1.20KG'),

          const SizedBox(height: 20),

          // 4. Stylized Info Boxes
          _buildInfoBox('${'qty'.tr}:', '${data?.qty} Package'),
          const SizedBox(height: 10),
          _buildInfoBox('${'from'.tr}:', '${data?.destinationFromEn}'),
          const SizedBox(height: 10),
          _buildReceiverBox(
            label: '${'receiver'.tr}:',
            phoneNumber: '${data?.receiverTelephone}',
            toLabel: '${'to'.tr}:',
            destination: '${data?.destinationToEn}',
          ),
          //
          const SizedBox(height: 10),
           _buildInfoBox('${'delivery_to'.tr}:', '${data?.destinationToEn}'),
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

Widget _buildItemDetailsRow(String title1, String value1, String title2, String value2) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        // Left Section
        Expanded(
          child: Row(
            children: [
              Text('$title1 ', style: const TextStyle(color: Colors.black87, fontSize: 14)),
              const Spacer(), 
              Text(
                value1,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 14),
              ),
              const SizedBox(width: 20), 
            ],
          ),
        ),
        
        // Right Section
        Expanded(
          child: Row(
            children: [
              Text('$title2 ', style: const TextStyle(color: Colors.black87, fontSize: 14)),
              const Spacer(), 
              Text(
                value2,
                style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black, fontSize: 14),
              ),
            ],
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
        const SizedBox(height: 8),
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

  // labelDisplay({required title, required value}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Expanded(
  //           child: Text(
  //             '$title:',
  //             style: const TextStyle(
  //               fontWeight: FontWeight.w500,
  //               color: AppColors.titleColor,
  //             ),
  //           ),
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: const TextStyle(
  //               fontWeight: FontWeight.w500,
  //               color: AppColors.titleColor,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
