import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'rate_schedule_screen.dart';
import 'ticket_detail_screen.dart';
import '../../../../home-dashboard/passenger/data/model/response/booking_list_model.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/contains.dart';
import '../controller/ticket_history_controller.dart';
import '../binding/ticket_detail_binding.dart';

class TicketHistoryScreen extends GetView<TicketHistoryController> {
  const TicketHistoryScreen({super.key});

  String _formatHHmm(String? raw) {
    final original = (raw ?? '').trim();
    if (original.isEmpty || original == 'null') return '';

    final dt = DateTime.tryParse(original);
    if (dt != null) return DateFormat('HH:mm').format(dt);

    var s = original;
    if (s.contains('T')) s = s.split('T').last;
    if (s.contains(' ')) s = s.split(' ').last;
    if (s.contains('.')) s = s.split('.').first;

    if (RegExp(r'^\d{1,2}:\d{2}(:\d{2})?$').hasMatch(s)) {
      final parts = s.split(':');
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }

    return s;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'ticket_history_new_1'.tr),
      body: Column(
        children: [
          _buildTabBarSelect(context),
          Expanded(
            child: Obx(() {
              final future = controller.state.futureListBooking;

              if (future == null) {
                return TabBarView(
                  controller: controller.tabController,
                  children: const [
                    Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          value: null,
                          strokeWidth: 5.0,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          value: null,
                          strokeWidth: 5.0,
                        ),
                      ),
                    ),
                  ],
                );
              }

              return FutureBuilder<BookingListModel>(
                future: future,
                builder: (context, bookingData) {
                  if (bookingData.connectionState == ConnectionState.waiting) {
                    return TabBarView(
                      controller: controller.tabController,
                      children: const [
                        Center(
                          child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: CircularProgressIndicator(
                              value: null,
                              strokeWidth: 5.0,
                            ),
                          ),
                        ),
                        Center(
                          child: SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: CircularProgressIndicator(
                              value: null,
                              strokeWidth: 5.0,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  if (bookingData.hasError) {
                    return TabBarView(
                      controller: controller.tabController,
                      children: [
                        _buildEmptyState(),
                        _buildEmptyState(),
                      ],
                    );
                  }

                  final all = bookingData.data?.body?.data ?? <BookingListDataItem>[];
                  final now = DateTime.now();

                  final upcoming = all.where((e) {
                    final arriveDateTime = _parseTripEndDateTime(
                      travelDate: e.travelDate,
                      departure: e.departure,
                      arrival: e.arrival,
                    );
                    return arriveDateTime.isAfter(now);
                  }).toList();

                  final history = all.where((e) {
                    final arriveDateTime = _parseTripEndDateTime(
                      travelDate: e.travelDate,
                      departure: e.departure,
                      arrival: e.arrival,
                    );
                    return !arriveDateTime.isAfter(now);
                  }).toList();

                  return TabBarView(
                    controller: controller.tabController,
                    children: [
                      upcoming.isEmpty
                          ? _buildEmptyState()
                          : _buildTicketList(items: upcoming, context: context),
                      _buildHistoryTab(items: history, context: context),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSelect(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 54, 
        decoration: BoxDecoration(
          color: const Color(0XFFE6E8EA), 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // 1. Static Vertical Divider
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  Expanded(child: SizedBox()),
                  VerticalDivider(color: Colors.black12, thickness: 1),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),

            // 2. The Actual TabBar
            Padding(
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: controller.tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AssetImages.ic_empty,
            width: 150,
            height: 150,
          ),
          Text(
            "data_not_found".tr,
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

  Widget _buildHistoryTab({
    required List<BookingListDataItem> items,
    required BuildContext context,
  }) {
    return Column(
      children: [
        _buildHistoryInfoBanner(),
        Expanded(
          child: items.isEmpty
              ? _buildEmptyState()
              : _buildTicketList(items: items, context: context),
        ),
      ],
    );
  }

  Widget _buildHistoryInfoBanner() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.black12, width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child:   Image.asset(AssetImages.ic_i,
                width: 30,
                height: 30,
            ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( 
                    'information'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ticket_history_remove_after_12_months'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.greyColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketList({
    required List<BookingListDataItem> items,
    required BuildContext context,
  }) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: false,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];

        final DateTime travelDateTime = _parseTripEndDateTime(
          travelDate: item.travelDate,
          departure: item.departure,
          arrival: item.arrival,
        );

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: AppColors.whiteColor,
            border: Border.all(
              width: 0.2,
              color: AppColors.borderColor,
            ),
          ),
          child: InkWell(
            onTap: () {
              Get.to(
                () => TicketDetailScreen(
                  id: item.id ?? 0,
                  journeyType: item.journeyType,
                ),
                binding: TicketDetailBinding(),
                transition: Transition.rightToLeft,
                duration: const Duration(
                  milliseconds: Constrains.duration,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildDestination(item),
                  const SizedBox(height: 12),
                  _buildCodeAndDate(item),
                  const SizedBox(height: 12),
                  _buldBusAndTime(item),
                  //
                  if (item.isLuckyDraw == 1) const SizedBox(height: 12),
                  if (item.isLuckyDraw == 1) _buildIsLuckyDraw(),
                  if (item.isTravelPackage == 1) const SizedBox(height: 12),
                  if (item.isTravelPackage == 1) _buildIsTravelPackage(),
                  const SizedBox(height: 12),
                  _buildRateAndTimecount(travelDateTime, item, context),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 10);
      },
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 12,
      ),
    );
  }

  DateTime _parseTravelDateTime(String? travelDate, String departure) {
    final travelDateStr = (travelDate ?? '').trim();
    final departureStr = departure.trim();

    DateTime? parsed;

    if (departureStr.isNotEmpty && departureStr.contains('-')) {
      parsed = DateTime.tryParse(departureStr);
    }

    if (parsed == null && travelDateStr.isNotEmpty && travelDateStr.contains(':')) {
      parsed = DateTime.tryParse(travelDateStr);
    }

    if (parsed == null && travelDateStr.isNotEmpty && departureStr.isNotEmpty) {
      final datePart = travelDateStr.split(' ').first;
      final timePart = departureStr.contains(' ')
          ? departureStr.split(' ').last
          : departureStr;

      final combined = '$datePart $timePart';
      parsed = DateTime.tryParse(combined);

      if (parsed == null) {
        try {
          parsed = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(combined);
        } catch (_) {
          try {
            parsed = DateFormat('yyyy-MM-dd HH:mm').parseStrict(combined);
          } catch (_) {}
        }
      }
    }

    if (parsed == null && travelDateStr.isNotEmpty) {
      parsed = DateTime.tryParse(travelDateStr.split(' ').first);
    }

    return parsed ?? DateTime.now();
  }

  DateTime _parseTripEndDateTime({
    required String? travelDate,
    required String? departure,
    required String? arrival,
  }) {
    final travelDateStr = (travelDate ?? '').trim();
    final arrivalStr = (arrival ?? '').trim();

    if (arrivalStr.isEmpty || arrivalStr == 'null') {
      return _parseTravelDateTime(travelDate, (departure ?? '').trim());
    }

    DateTime? parsed;

    if (arrivalStr.contains('-') || arrivalStr.contains('T')) {
      parsed = DateTime.tryParse(arrivalStr);
    }

    if (parsed == null && travelDateStr.isNotEmpty) {
      var timePart = arrivalStr;
      if (timePart.contains('T')) timePart = timePart.split('T').last;
      if (timePart.contains(' ')) timePart = timePart.split(' ').last;
      if (timePart.contains('.')) timePart = timePart.split('.').first;

      final datePart = travelDateStr.split(' ').first;
      final combined = '$datePart $timePart';

      parsed = DateTime.tryParse(combined);

      if (parsed == null) {
        try {
          parsed = DateFormat('yyyy-MM-dd HH:mm:ss').parseStrict(combined);
        } catch (_) {
          try {
            parsed = DateFormat('yyyy-MM-dd HH:mm').parseStrict(combined);
          } catch (_) {}
        }
      }
    }

    return parsed ?? _parseTravelDateTime(travelDate, (departure ?? '').trim());
  }

  Widget _buildDestination(BookingListDataItem item) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Image.asset(
                item.journeyType == 1
                    ? AssetImages.vet_logo
                    : item.journeyType == 2
                        ? AssetImages.buva_sea
                        : item.journeyType == 3
                            ? AssetImages.vet_air_bus_schedule
                            : AssetImages.buva_sea,
                height: 30,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${_capitalizePlaceName(item.destinationFrom)} - ${_capitalizePlaceName(item.destinationTo)}",
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.titleColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Ionicons.person_outline,
              size: 22,
              color: AppColors.textColor,
            ),
            const SizedBox(width: 6),
            Text(
              '${item.totalSeat}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCodeAndDate(BookingListDataItem item) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Image.asset(
                AssetImages.ic_ticket_history,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.code ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Image.asset(
                AssetImages.ic_date_history,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${item.travelDate}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


Widget _buldBusAndTime(BookingListDataItem item) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Image.asset(
                // AssetImages.ic_boat_history ,
                item.journeyType == 2 || item.journeyType == 4
                    ? AssetImages.ic_boat_history
                    : AssetImages.ic_bus_history,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "${item.transportationType}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Image.asset(
                AssetImages.ic_time_history,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatHHmm(item.departure),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
  Widget _buildRateAndTimecount(
    DateTime travelDateTime,
    BookingListDataItem item,
    BuildContext context,
  ) {
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (travelDateTime.isBefore(now))
          item.isRate == 0
              ? InkWell(
                  onTap: () async {
                    final result = await Get.to(
                      () => RateScheduleScreen(
                        scheduleId: item.scheduleId,
                        id: item.id.toString(),
                      ),
                      transition: Transition.rightToLeft,
                      duration: const Duration(
                        milliseconds: Constrains.duration,
                      ),
                    );

                    if (result == true) {
                      controller.reloadBookingList();
                    }
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Ionicons.chatbubble_ellipses_outline,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Rate a schedule',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : const Expanded(
                  flex: 1,
                  child: SizedBox(),
                ),
        if (!travelDateTime.isBefore(now))
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(
                  Ionicons.time_outline,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  _calculateCountdown(travelDateTime),
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildIsTravelPackage() {
    return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "*",
                                        style: TextStyle(
                                          color: AppColors.redColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "booking_travel_package2".tr,
                                          style: const TextStyle(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
  }

  Widget _buildIsLuckyDraw() {
    return  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "*",
                                        style: TextStyle(
                                          color: AppColors.redColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Please show your e-ticket to our staff at the ticket counter to get your physical Lucky Ticket",
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
  }

  String _capitalizePlaceName(String? input) {
    final s = (input ?? '').trim();
    if (s.isEmpty) return '';

    final out = StringBuffer();
    var capitalizeNext = true;

    for (var i = 0; i < s.length; i++) {
      final ch = s[i];
      final isLetter = RegExp(r'[A-Za-z]').hasMatch(ch);

      if (capitalizeNext && isLetter) {
        out.write(ch.toUpperCase());
        capitalizeNext = false;
        continue;
      }

      if (isLetter) {
        out.write(ch.toLowerCase());
      } else {
        out.write(ch);
      }

      if (ch == ' ' || ch == '-' || ch == '/') {
        capitalizeNext = true;
      }
    }

    return out.toString();
  }
 

  String _calculateCountdown(DateTime travelDateTime) {
    DateTime now = DateTime.now();

    if (travelDateTime.isBefore(now)) {
      return "Time's up";
    }

    Duration difference = travelDateTime.difference(now);
    int months = (difference.inDays ~/ 30);
    int days = difference.inDays % 30;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    if (months > 0) {
      return months == 1 ? '1 month' : '$months months';
    } else if (days > 0) {
      return days == 1 ? '1 day' : '$days days';
    } else if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}h : ${minutes.toString().padLeft(2, '0')}min';
    } else if (minutes > 0) {
      return '$minutes min';
    }

    return "Less than a minute";
  }
}
