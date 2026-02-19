import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:express_vet/activities/ticket/rate_schedule_screen.dart';
import 'package:express_vet/activities/ticket/ticket_detail_screen.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:toastification/toastification.dart';

import '../../feature/home-dashboard/passenger/presentation/controller/booking.dart';
import '../../models/booking/booking_list_model.dart';
import '../../utils/contains.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> {
  late Future<BookingListModel> futureListBooking;

  @override
  void initState() {
    super.initState();
    futureListBooking = Booking().getBookingList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'ticket_history_new_1'.tr),
      body: FutureBuilder<BookingListModel>(
        future: futureListBooking,
        builder: (context, bookingData) {
          if (bookingData.hasData) {
            if ((bookingData.data?.body?.data)!.isNotEmpty) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (bookingData.data?.body?.data)!.length,
                      itemBuilder: (BuildContext context, int index) {
                        //* get the travel date value Example: (2024-10-3)
                        final String? travelDate =
                            bookingData.data?.body?.data?[index].travelDate;
                        //* get the departure of the starting hour Example: (01:00:00)
                        final String departure =
                            bookingData.data?.body?.data?[index].departure ??
                            "01:00:00";

                        String dateTimeString = "$travelDate $departure";
                        final DateFormat dateTimeFormat = DateFormat(
                          'yyyy-MM-dd HH:mm:ss',
                        );
                        DateTime travelDateTime = dateTimeFormat.parse(
                          dateTimeString,
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
                                  id:
                                      (bookingData.data?.body?.data?[index].id)!
                                          .toInt(),
                                ),
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
                                  //* logo and destination
                                  Row(
                                    children: [
                                      Image.asset(
                                        bookingData
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .journeyType ==
                                                1
                                            ? 'assets/images/vet_logo.png'
                                            : bookingData
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .journeyType ==
                                                2
                                            ? 'assets/images/ic_buva_sea.png'
                                            : bookingData
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .journeyType ==
                                                3
                                            ? 'assets/images/vet_air_bus.png'
                                            : 'assets/images/ic_buva_sea.png',
                                        height: 30,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "${bookingData.data?.body?.data?[index].destinationFrom} - ${bookingData.data?.body?.data?[index].destinationTo}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.titleColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  //* code and date time
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Ionicons.bookmarks_outline,
                                              size: 18,
                                              color: AppColors.textColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                "${bookingData.data?.body?.data?[index].code}",
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
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Ionicons.calendar_outline,
                                              size: 18,
                                              color: AppColors.textColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "${bookingData.data?.body?.data?[index].travelDate} (${DateFormat('HH:mm').format(DateFormat('HH:mm').parse((bookingData.data?.body?.data?[index].departure).toString()))})",
                                              style: const TextStyle(
                                                color: AppColors.textColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  //* transportationType and total seats
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Icon(
                                              bookingData
                                                              .data
                                                              ?.body
                                                              ?.data?[index]
                                                              .journeyType ==
                                                          2 ||
                                                      bookingData
                                                              .data
                                                              ?.body
                                                              ?.data?[index]
                                                              .journeyType ==
                                                          4
                                                  ? Ionicons.boat_outline
                                                  : Ionicons.bus_outline,
                                              size: 18,
                                              color: AppColors.textColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                "${bookingData.data?.body?.data?[index].transportationType}",
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
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Ionicons.person_outline,
                                              size: 18,
                                              color: AppColors.textColor,
                                            ),
                                            const SizedBox(width: 6),
                                            RichText(
                                              text: TextSpan(
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text:
                                                        '${bookingData.data?.body?.data?[index].totalSeat} ',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        bookingData
                                                                    .data
                                                                    ?.body
                                                                    ?.data?[index]
                                                                    .totalSeat!
                                                                    .toInt() ==
                                                                1
                                                            ? 'seat'.tr
                                                            : 'seats'.tr,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.textColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  //* lucky ticket
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isLuckyDraw ==
                                      1)
                                    const SizedBox(height: 12),
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isLuckyDraw ==
                                      1)
                                    const Row(
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
                                    ),

                                  //* travel package
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isTravelPackage ==
                                      1)
                                    const SizedBox(height: 12),
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isTravelPackage ==
                                      1)
                                    Row(
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
                                    ),

                                  //* rate and view detail
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      //* show the rating button after the car left
                                      if (travelDateTime.isBefore(
                                        DateTime.now(),
                                      ))
                                        bookingData
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .isRate ==
                                                0
                                            ? Expanded(
                                              flex: 1,
                                              child: InkWell(
                                                onTap: () async {
                                                  final result = await Get.to(
                                                    () => RateScheduleScreen(
                                                      scheduleId:
                                                          bookingData
                                                              .data
                                                              ?.body
                                                              ?.data?[index]
                                                              .scheduleId,
                                                      id:
                                                          bookingData
                                                              .data
                                                              ?.body
                                                              ?.data?[index]
                                                              .id
                                                              .toString(),
                                                    ),
                                                    transition:
                                                        Transition.rightToLeft,
                                                    duration: const Duration(
                                                      milliseconds:
                                                          Constrains.duration,
                                                    ),
                                                  );

                                                  // Check if the result is true, indicating a successful rating
                                                  if (result == true) {
                                                    // Refresh the booking list
                                                    setState(() {
                                                      futureListBooking =
                                                          Booking()
                                                              .getBookingList(
                                                                context,
                                                              );
                                                    });
                                                  }
                                                },
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Ionicons
                                                          .chatbubble_ellipses_outline,
                                                      size: 18,
                                                      color:
                                                          AppColors
                                                              .primaryColor,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      'Rate a schedule',
                                                      style: TextStyle(
                                                        color:
                                                            AppColors
                                                                .primaryColor,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                            : const Expanded(
                                              flex: 1,
                                              child: SizedBox(),
                                            ),

                                      //* show the countdown time before car left
                                      if (travelDateTime.isAfter(
                                        DateTime.now(),
                                      ))
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
                                                _calculateCountdown(
                                                  travelDateTime,
                                                ), // Countdown value
                                                style: const TextStyle(
                                                  color: AppColors.primaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Ionicons
                                                  .information_circle_outline,
                                              size: 18,
                                              color: AppColors.textColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'view_details'.tr,
                                              style: const TextStyle(
                                                color: AppColors.textColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                    ),
                  ],
                ),
              );
            }
            if ((bookingData.data?.body?.data)!.isEmpty) {
              return SizedBox(
                height: double.infinity,
                width: double.infinity,
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
          } else if (bookingData.hasError) {}

          return const Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
            ),
          );
        },
      ),
    );
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
