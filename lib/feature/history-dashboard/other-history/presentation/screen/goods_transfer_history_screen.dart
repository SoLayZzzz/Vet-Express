import 'dart:developer';

import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/history-dashboard/other-history/presentation/screen/review_screen.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../home-dashboard/notifications/presentation/screen/goods_information_screen.dart';
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
            _buildTabBarSelect(context),
            
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

  Widget _buildTabBarSelect(BuildContext context) {
  return Column(
    children: [
      Container(
        color: Colors.white,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 54, // Fixed height for a consistent "pill" look
          decoration: BoxDecoration(
            color: const Color(0XFFE6E8EA), // Light gray background
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // 1. Static Vertical Dividers
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    Expanded(child: SizedBox()),
                    VerticalDivider(color: Colors.black12, thickness: 1),
                    Expanded(child: SizedBox()),
                    VerticalDivider(color: Colors.black12, thickness: 1),
                    Expanded(child: SizedBox()),
                  ],
                ),
              ),
              
              // 2. The Actual TabBar
              Padding(
                padding: const EdgeInsets.all(4), // Space between gray bar and white pill
                child: TabBar(
                  controller: controller.tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  
                  // The White Floating Pill
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  
                  tabs: [
                    Tab(text: 'sending'.tr),
                    Tab(text: 'receiving'.tr),
                    Tab(text: 'vet_self_service'.tr),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // 3. Tab Content
      SizedBox(height: 10),
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
    final future = type == 1 ? controller.state.futureSending : controller.state.futureReceiving;

    if (future == null) {
      controller.loadTransferList(context: context, type: type);
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<TransferListResponse>(
      future: future,
      builder: (context, data) {
        if (data.hasData && (data.data?.body?.data?.isNotEmpty ?? false)) {
          return Stack(
            children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: data.data!.body!.data!.length,
                itemBuilder: (context, index) {
                  return TransferItemCard(
                    item: data.data!.body!.data![index],
                    type: type,
                  );
                },
              ),
              
              _filterButton(context: context),
            ],
          );
        }
        return Center(
          child: Text(
            'no_data'.tr,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
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
              context: Get.context!,
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

  // String _returnStatus(int status) {
  //   String txtStatus = '';
  //   if (status == 1) {
  //     txtStatus = "posting".tr;
  //   } else if (status == 2) {
  //     txtStatus = "shipping".tr;
  //   } else if (status == 3) {
  //     txtStatus = "arrival".tr;
  //   } else if (status == 4) {
  //     txtStatus = "received".tr;
  //   }
  //   return txtStatus;
  // }
}




class TransferItemCard extends StatefulWidget {
  final dynamic item; // Replace 'dynamic' with your specific model type
  final int type;

  const TransferItemCard({super.key, required this.item, required this.type});

  @override
  State<TransferItemCard> createState() => _TransferItemCardState();
}

class _TransferItemCardState extends State<TransferItemCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.code ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _returnStatus(widget.item.status),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
            ),
        
            // 2. Body Section (Gray Background)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.deepBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(AssetImages.ic_recieved), // Ensure this exists
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: 
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Local NO. ${widget.item.id}",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const SizedBox(height: 5),
                                Text("${widget.item.destinationFromEn}", style: TextStyle(fontSize: 12)),
                                Text("${widget.item.destinationToEn}", style: TextStyle(fontSize: 12)),
                                Text("${widget.item.senderTelephone}", style: TextStyle(fontSize: 12)),
                                              
                              ],
                            ),
                            //
                             Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                               children: [
                                Text('${'qty'.tr}: ${widget.item.qty}/1',style: const TextStyle(fontSize: 12))
                               ],
                             ),
                            
                          ],
                        ),
                    
                      
                  ),
        
                ],
              ),
            ),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
               child: Container(height: 1.5, color: Colors.grey[300]),
             ),
        
        
            // 3. Dropdown Fee Details (Animated)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Column(
                        children: [
                          
                          _buildFeeRow('tranfer_fee_ch'.tr, '\$10.50'),
                          _buildFeeRow('packing_fee'.tr, '\$0.50'),
                          _buildFeeRow('tranfer_fee_kh'.tr, '\$0.00'),
                          _buildFeeRow('delivery_fee'.tr, '\$0.00'),
                          
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Image.asset(AssetImages.line),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
        
            // 4. Total Bar (Clickable)
            InkWell(
              onTap: () => setState(() => isExpanded = !isExpanded),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                     Text("total_price".tr, style: TextStyle(fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        const Text(
                          "\$11.00",
                          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          // isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
                          Icons.keyboard_arrow_right,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        
            // 5. Action Buttons
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [

                  Expanded(child: _buildBtn(
                    "unpaid".tr, 
                    (){},
                    isOutline: true)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildBtn(
                      "track_order".tr,
                      _onTrackOrderPressed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: _buildBtn("pay_now".tr, (){
                    Get.toNamed(AppRoutes.parcelPayment);
                  })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildBtn(String title, VoidCallback? onTap, {bool isOutline = false}) {
    return InkWell(
      onTap: (){onTap?.call();},
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: isOutline ? const Color(0xFFEDF0F3) : const Color(0xFFF9E8DE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isOutline ? Colors.black87 : AppColors.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _onTrackOrderPressed() {
    final id = _parseId(widget.item.id);
    if (id == null) return;

    Get.to(
      () => GoodsInformationScreen(id: id),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
    debugPrint('Tracking order with ID: $id');
  }

  int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return int.tryParse(value.toString());
  }

  int _parseStatus(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String _returnStatus(dynamic statusValue) {
  final status = _parseStatus(statusValue);

  debugPrint(
    'Transfer status raw=$statusValue parsed=$status type=${statusValue.runtimeType}',
  );

  final statusMap = {
    1: "posting".tr,
    2: "shipping".tr,
    3: "arrival".tr,
    4: "received".tr,
    5: "transit".tr,
    6: "delivery".tr,
    7: "call".tr,
  };

  return statusMap[status] ?? 'Status: $status';
}

}




  // Widget _transferTab({required BuildContext context, required int type}) {
  //   return Obx(() {
  //     final future =
  //         type == 1
  //             ? controller.state.futureSending
  //             : controller.state.futureReceiving;

  //     if (future == null) {
  //       controller.loadTransferList(context: context, type: type);
  //       return const Center(
  //         child: SizedBox(
  //           height: 50.0,
  //           width: 50.0,
  //           child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
  //         ),
  //       );
  //     }

  //     return FutureBuilder<TransferListResponse>(
  //       future: future,
  //       builder: (context, data) {
  //         if (data.hasData) {
  //           if ((data.data?.header?.result) == true &&
  //               (data.data?.header?.statusCode) == 200) {
  //             if ((data.data?.body?.data)!.isNotEmpty) {
  //               return Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 15.0),
  //                 child: Stack(
  //                   children: [
  //                     ListView.builder(
  //                       physics: const BouncingScrollPhysics(),
  //                       itemCount: (data.data?.body?.data)!.length,
  //                       itemBuilder: (context, index) {
  //                         return Container(
  //                           margin: const EdgeInsets.only(top: 12.0),
  //                           padding: const EdgeInsets.all(12.0),
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(10),
  //                             color: AppColors.whiteColor,
  //                             border: Border.all(
  //                               width: 0.5,
  //                               color: AppColors.borderColor,
  //                             ),
  //                           ),
  //                           child: InkWell(
  //                             onTap: () {
  //                               Get.to(
  //                                 () => GoodsInformationScreen(
  //                                   id:
  //                                       (data.data?.body?.data?[index].id)!
  //                                           .toInt(),
  //                                 ),
  //                                 transition: Transition.rightToLeft,
  //                                 duration: const Duration(
  //                                   milliseconds: Constrains.duration,
  //                                 ),
  //                               );
  //                             },
  //                             child: Column(
  //                               children: [
  //                                 Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     Text(
  //                                       "${data.data?.body?.data?[index].code}",
  //                                       style: const TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 15,
  //                                         color: AppColors.titleColor,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       "${data.data?.body?.data?[index].date}",
  //                                       style: const TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 15,
  //                                         color: AppColors.titleColor,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Row(
  //                                   crossAxisAlignment:
  //                                       CrossAxisAlignment.center,
  //                                   children: [
  //                                     Column(
  //                                       children: [
  //                                         const SizedBox(height: 20),
  //                                         Image.asset(
  //                                           AssetImages.ic_posting,
  //                                           width: 40,
  //                                           height: 40,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                     Expanded(
  //                                       child: Column(
  //                                         children: [
  //                                           Text(
  //                                             _returnStatus(
  //                                               (data
  //                                                   .data
  //                                                   ?.body
  //                                                   ?.data?[index]
  //                                                   .status)!,
  //                                             ),
  //                                             style: const TextStyle(
  //                                               fontWeight: FontWeight.bold,
  //                                               fontSize: 16,
  //                                               color: AppColors.secondaryColor,
  //                                             ),
  //                                           ),
  //                                           Image.asset(
  //                                             AssetImages.ic_tracking_line,
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     ),
  //                                     Column(
  //                                       children: [
  //                                         const SizedBox(height: 20),
  //                                         Image.asset(
  //                                           AssetImages.ic_receive,
  //                                           width: 40,
  //                                           height: 40,
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Padding(
  //                                   padding: const EdgeInsets.symmetric(
  //                                     vertical: 10.0,
  //                                   ),
  //                                   child: Row(
  //                                     children: [
  //                                       Text(
  //                                         (data
  //                                                 .data
  //                                                 ?.body
  //                                                 ?.data?[index]
  //                                                 .destinationFromEn)
  //                                             .toString(),
  //                                         style: const TextStyle(
  //                                           fontWeight: FontWeight.bold,
  //                                           fontSize: 15,
  //                                           color: AppColors.primaryColor,
  //                                         ),
  //                                       ),
  //                                       const Spacer(),
  //                                       Text(
  //                                         (data
  //                                                 .data
  //                                                 ?.body
  //                                                 ?.data?[index]
  //                                                 .destinationToEn)
  //                                             .toString(),
  //                                         style: const TextStyle(
  //                                           fontWeight: FontWeight.bold,
  //                                           fontSize: 15,
  //                                           color: AppColors.primaryColor,
  //                                         ),
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                                 Row(
  //                                   mainAxisAlignment:
  //                                       MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     Text(
  //                                       (data
  //                                               .data
  //                                               ?.body
  //                                               ?.data?[index]
  //                                               .senderTelephone)
  //                                           .toString(),
  //                                       style: const TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 14,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       (data
  //                                               .data
  //                                               ?.body
  //                                               ?.data?[index]
  //                                               .receiverTelephone)
  //                                           .toString(),
  //                                       style: const TextStyle(
  //                                         fontWeight: FontWeight.bold,
  //                                         fontSize: 14,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 Padding(
  //                                   padding: const EdgeInsets.only(top: 12.0),
  //                                   child: Row(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.spaceBetween,
  //                                     children: [
  //                                       Row(
  //                                         children: [
  //                                           Image.asset(
  //                                             AssetImages.ic_qty,
  //                                             width: 24,
  //                                           ),
  //                                           const SizedBox(width: 6),
  //                                           Text(
  //                                             'Qty: ${(data.data?.body?.data?[index].qty).toString()}',
  //                                             style: const TextStyle(
  //                                               fontWeight: FontWeight.bold,
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //                                       if ((data
  //                                                       .data
  //                                                       ?.body
  //                                                       ?.data?[index]
  //                                                       .isSurveyReceiver)
  //                                                   .toString() ==
  //                                               '0' &&
  //                                           type == 2)
  //                                         _surveyButton(
  //                                           context: context,
  //                                           goodsTransferId:
  //                                               (data
  //                                                       .data
  //                                                       ?.body
  //                                                       ?.data?[index]
  //                                                       .id)
  //                                                   .toString(),
  //                                           type: type,
  //                                         ),
  //                                       if ((data
  //                                                       .data
  //                                                       ?.body
  //                                                       ?.data?[index]
  //                                                       .isSurveySender)
  //                                                   .toString() ==
  //                                               '0' &&
  //                                           type == 1)
  //                                         _surveyButton(
  //                                           context: context,
  //                                           goodsTransferId:
  //                                               (data
  //                                                       .data
  //                                                       ?.body
  //                                                       ?.data?[index]
  //                                                       .id)
  //                                                   .toString(),
  //                                           type: type,
  //                                         ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         );
  //                       },
  //                     ),
  //                     _filterButton(context: context),
  //                   ],
  //                 ),
  //               );
  //             }
  //             if ((data.data?.body?.data)!.isEmpty) {
  //               return Stack(
  //                 children: [
  //                   Center(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       children: [
  //                         Image.asset(
  //                           AssetImages.ic_empty,
  //                           width: 150,
  //                           height: 150,
  //                         ),
  //                         Text(
  //                           'no_data'.tr,
  //                           style: const TextStyle(
  //                             fontSize: 16,
  //                             color: AppColors.primaryColor,
  //                             fontWeight: FontWeight.w500,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   _filterButton(context: context),
  //                 ],
  //               );
  //             }
  //           }
  //         } else if (data.hasError) {
  //           log('error ${data.error}');
  //         }
  //         return const Center(
  //           child: SizedBox(
  //             height: 50.0,
  //             width: 50.0,
  //             child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
  //           ),
  //         );
  //       },
  //     );
  //   });
  // }