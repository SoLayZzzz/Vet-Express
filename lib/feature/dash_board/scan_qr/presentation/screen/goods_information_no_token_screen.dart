import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';

import '../../data/model/response/goods_find_response.dart';
import '../../../../../utils/app_colors.dart';

class GoodsInformationNoTokenScreen extends StatefulWidget {
  final Future<GoodsFindResponse> futureData;

  const GoodsInformationNoTokenScreen({super.key, required this.futureData});

  @override
  State<GoodsInformationNoTokenScreen> createState() =>
      _GoodsInformationNoTokenScreenState();
}

class _GoodsInformationNoTokenScreenState
    extends State<GoodsInformationNoTokenScreen> {
  RxBool _showAllLogisticsDetails = false.obs;
  final GlobalKey _activeStatusKey = GlobalKey();
  final GlobalKey _lastStatusKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'tracking_parcel'.tr),
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
      bottomNavigationBar: null,
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
          return 0;
        case 2:
          return 1;
        case 5:
          return 2;
        case 6:
          return 3;
        case 3:
          return 4;
        case 7:
          return 5;
        case 4:
          return 6;
        default:
          return 999;
      }
    }

    final List<GoodsTransferMoveList> sortedMoves =
        List<GoodsTransferMoveList>.from(moveList)
          ..removeWhere(
            (e) => e.status == null || !allowedStatuses.contains(e.status),
          )
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

    final int activeIndex =
        effectiveHighlightIndex >= 0 ? effectiveHighlightIndex : 0;

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

          final bool isReached = showAll
              ? (effectiveHighlightIndex >= 0 &&
                  moveIndexInSorted <= effectiveHighlightIndex)
              : true;

          final Color statusColor =
              isReached ? AppColors.primaryColor : AppColors.textColor;

          Widget statusWidget;
          switch (move.status) {
            case 1:
              statusWidget = _displayV2(
                'posting',
                'at',
                move.msg ?? '',
                move.created ?? '',
                colorText: statusColor,
                view: false,
              );
              break;
            case 2:
              statusWidget = _displayV2(
                'shipping',
                'from_info',
                move.msg ?? '',
                move.created ?? '',
                colorText: statusColor,
              );
              break;
            case 5:
              statusWidget = _displayV2(
                'transit',
                'at',
                move.msg ?? '',
                move.created ?? '',
                colorText: statusColor,
              );
              break;
            case 3:
              statusWidget = _displayV2(
                'arrival',
                'at',
                move.msg ?? '',
                move.created ?? '',
                colorText: statusColor,
              );
              break;
            case 6:
              statusWidget = _displayV2(
                'shipping',
                'from_info',
                move.msg ?? '',
                move.created ?? '',
                colorText: statusColor,
              );
              break;
            case 7:
              statusWidget = _displayV2(
                'call',
                '',
                move.msg ?? '',
                move.created ?? '',
                colorText: statusColor,
                view: false,
              );
              break;
            case 4:
              statusWidget = _displayV2(
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
                Expanded(child: statusWidget),
              ],
            ),
          );
        },
      );
    });
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
            _labelRow('${'track_code'.tr}:', '${data?.code}'),
            const SizedBox(height: 16),
            _buildInfoBox('${'qty'.tr}:', '${data?.qty}'),
            const SizedBox(height: 10),
            _buildReceiverBox(
              label: '${'sender'.tr}:',
              phoneNumber: '${data?.senderTelephone}',
              toLabel: '${'from'.tr}:',
              destination: '${data?.destinationFromEn}',
            ),
            const SizedBox(height: 10),
            _buildReceiverBox(
              label: '${'receiver'.tr}:',
              phoneNumber: '${data?.receiverTelephone}',
              toLabel: '${'to'.tr}:',
              destination: '${data?.destinationToEn}',
            ),
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
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(child: Text(phoneNumber)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  toLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Expanded(child: Text(destination)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _displayV2(
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
