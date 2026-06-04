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
  bool _didLogStatusTracking = false;
  RxBool _showAllLogisticsDetails = false.obs;
  final GlobalKey _activeStatusKey = GlobalKey();
  final GlobalKey _lastStatusKey = GlobalKey();

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
                        _buildStatusTracking(transferData),
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
      // bottomNavigationBar: _buildTotalBottomNavigationBar(),
    );
  }

  Widget _buildStatusTracking(AsyncSnapshot<GoodsFindResponse> transferData) {
    final List<GoodsTransferMoveList> moveList =
        transferData.data?.body?.data?[0].goodsTransferMoveList ??
            <GoodsTransferMoveList>[];

    final int? currentStatus = moveList.isNotEmpty ? moveList.first.status : null;

    const Set<int> allowedStatuses = <int>{1, 2, 3, 4, 5, 6, 7};

    int orderOf(int? status) {
      switch (status) {
        case 1:
          return 0; // Posting
        case 2:
          return 1; // Shipping
        case 5:
          return 2; // Transit
        case 6:
          return 3; // Shipping
        case 3:
          return 4; // Arrived
        case 7:
          return 5; // Call to Customer
        case 4:
          return 6; // Received
        default:
          return 999;
      }
    }

    final List<GoodsTransferMoveList> sortedMoves =
        List<GoodsTransferMoveList>.from(moveList)
          ..removeWhere((e) => e.status == null || !allowedStatuses.contains(e.status))
          ..sort((a, b) => orderOf(a.status).compareTo(orderOf(b.status)));

    final int? highlightStatus = (currentStatus != null &&
            allowedStatuses.contains(currentStatus))
        ? currentStatus
        : (sortedMoves.isNotEmpty ? sortedMoves.last.status : null);

    final int highlightIndex = (highlightStatus == null)
        ? -1
        : sortedMoves.indexWhere((e) => e.status == highlightStatus);

    final int effectiveHighlightIndex = (highlightIndex >= 0)
        ? highlightIndex
        : (sortedMoves.isNotEmpty ? sortedMoves.length - 1 : -1);

    final int activeIndex = effectiveHighlightIndex >= 0 ? effectiveHighlightIndex : 0;

    return Obx(() {
      final bool showAll = _showAllLogisticsDetails.value;
      final List<GoodsTransferMoveList> displayMoves = showAll
          ? sortedMoves
          : (sortedMoves.isNotEmpty
              ? <GoodsTransferMoveList>[sortedMoves[activeIndex]]
              : <GoodsTransferMoveList>[]);

      return ListView.builder(
        padding: const EdgeInsets.only(top: 12),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: displayMoves.length + 1,
        itemBuilder: (context, index) {
          final int length = displayMoves.length + 1;

          if (index == displayMoves.length) {
            final text = showAll
                ? 'View less logistics details'
                : 'View more logistics details';
            final int moveIndexInSorted = activeIndex;

            return InkWell(
              onTap: () {
                final bool nextValue = !_showAllLogisticsDetails.value;
                _showAllLogisticsDetails.value = nextValue;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final targetContext = nextValue
                      ? _lastStatusKey.currentContext
                      : _activeStatusKey.currentContext;
                  if (targetContext == null) return;
                  Scrollable.ensureVisible(
                    targetContext,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: 2,
                            ),
                          ),
                        ),
                        Container(
                          height: 70,
                          width: 2,
                          color: (index >= length - 1)
                              ? AppColors.backgroundColor
                              : (moveIndexInSorted < effectiveHighlightIndex
                                  ? AppColors.primaryColor
                                  : AppColors.borderColor),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            text,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: AppColors.textColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final move = displayMoves[index];
          final int moveIndexInSorted = showAll ? index : activeIndex;

          final bool isCurrent =
              highlightStatus != null && move.status == highlightStatus;
          final bool isReached = showAll
              ? (effectiveHighlightIndex >= 0 &&
                  moveIndexInSorted <= effectiveHighlightIndex)
              : true;

        final Color statusColor =
            isReached ? AppColors.primaryColor : AppColors.textColor;

        Widget statusWidget;
        switch (move.status) {
          case 1:
            statusWidget = display(
              'posting',
              'at',
              move.msg ?? '',
              move.created ?? '',
              colorText: statusColor,
              view: false,
            );
            break;
          case 2:
            statusWidget = display(
              'shipping',
              'from_info',
              move.msg ?? '',
              move.created ?? '',
              colorText: statusColor,
            );
            break;
          case 5:
            statusWidget = display(
              'transit',
              'at',
              move.msg ?? '',
              move.created ?? '',
              colorText: statusColor,
            );
            break;
          case 3:
            statusWidget = display(
              'arrival',
              'at',
              move.msg ?? '',
              move.created ?? '',
              colorText: statusColor,
            );
            break;
          case 6:
            statusWidget = display(
              'shipping',
              'from_info',
              move.msg ?? '',
              move.created ?? '',
              colorText: statusColor,
            );
            break;
          case 7:
            statusWidget = display(
              'call',
              '',
              move.msg ?? '',
              move.created ?? '',
              colorText: statusColor,
              view: false,
            );
            break;
          case 4:
            statusWidget = display(
              'received',
              '',
              move.msg ?? '',
              move.created ?? '',
              colorText: statusColor,
            );
            break;
          default:
            statusWidget = const SizedBox.shrink();
        }

          final Key? rowKey = (!showAll && index == 0)
              ? _activeStatusKey
              : (showAll && index == displayMoves.length - 1)
                  ? _lastStatusKey
                  : null;

          return KeyedSubtree(
            key: rowKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* icon tick
                Column(
                  children: [
                    Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isReached
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isReached
                                ? AppColors.primaryColor
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 70,
                      width: 2,
                      color: (index >= length - 1)
                          ? AppColors.backgroundColor
                          : (moveIndexInSorted < effectiveHighlightIndex
                              ? AppColors.primaryColor
                              : AppColors.borderColor),
                    ),
                  ],
                ),
                const SizedBox(width: 10),

                //* status
                Expanded(child: statusWidget),
              ],
            ),
          );
        },
      );
    });
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
          // _labelRow('${'track_china_no'.tr}:', '-'),
          
          // const SizedBox(height: 16),
          //  Text('${'item_detail'.tr}:', style: TextStyle(fontWeight: FontWeight.bold)),
          // const SizedBox(height: 8),

          // // 2. Fees Grid
          // Column(
          //   children: [
          //     _buildItemDetailsRow('${'tranfer_fee_ch'.tr}:', '\$10.50', '${'packing_fee'.tr}:', '\$0.50'),
          //     _buildItemDetailsRow('${'tranfer_fee_kh'.tr}:', '\$0.00', '${'delivery_fee'.tr}:', '\$0.00'),
          //   ],
          // ),

          // const SizedBox(height: 16),
          //  Text('${'item_size'.tr}:', style: TextStyle(fontWeight: FontWeight.bold)),
          // const SizedBox(height: 8),

          // 3. Size Row
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('${'width'.tr}: 120CM', style: const TextStyle(fontSize: 13)),
          //     Text('${'length'.tr}: 120CM', style: const TextStyle(fontSize: 13)),
          //     Text('${'height'.tr}: 120CM', style: const TextStyle(fontSize: 13)),
          //   ],
          // ),

          const SizedBox(height: 16),
          //  Text('${'item_weight'.tr}:', style: TextStyle(fontWeight: FontWeight.bold)),
          // const SizedBox(height: 8),
          // Text('${'weight'.tr}: 1.20KG'),

          // const SizedBox(height: 20),

          // 4. Stylized Info Boxes
          _buildInfoBox('${'qty'.tr}:', '${data?.qty} ${data?.typeId}'),
          const SizedBox(height: 10),
          _buildReceiverBox(
            label: '${'from'.tr}:',
            phoneNumber: '${data?.senderTelephone}',
            toLabel: '${'to'.tr}:',
            destination: '${data?.destinationFromEn}',
          ),
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

Widget _labelRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
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

  Widget display(

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
