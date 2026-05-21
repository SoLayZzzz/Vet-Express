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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'ticket_history_new_1'.tr),
      body: Obx(() {
        final future = controller.state.futureListBooking;
        if (future == null) {
          return const Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
            ),
          );
        }

        return FutureBuilder<BookingListModel>(
          future: future,
          builder: (context, bookingData) {
            if (bookingData.hasData) {
              if ((bookingData.data?.body?.data)!.isNotEmpty) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildListOfTicketHistory(bookingData),
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
            } else if (bookingData.hasError) {}

            return const Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildListOfTicketHistory(AsyncSnapshot<BookingListModel> bookingData) {
    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (bookingData.data?.body?.data)!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final String? travelDate =
                            bookingData.data?.body?.data?[index].travelDate;
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
                                      (bookingData
                                              .data
                                              ?.body
                                              ?.data?[index]
                                              .id)!
                                          .toInt(),
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
                                  _buildDestination(bookingData, index),
                                  const SizedBox(height: 10),
                                  _buildCodeAndDate(bookingData, index),
                                  const SizedBox(height: 10),
                                  _buldBusAndTime(bookingData, index),
                                  //
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isLuckyDraw ==
                                      1)
                                    const SizedBox(height: 10),
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isLuckyDraw ==
                                      1)
                                  //
                                    _buildIsLuckyDraw(),
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isTravelPackage ==
                                      1)
                                    const SizedBox(height: 10),
                                  if (bookingData
                                          .data
                                          ?.body
                                          ?.data?[index]
                                          .isTravelPackage ==
                                      1)
                                    _buildIsTravelPackage(),
                                  const SizedBox(height: 10),
                                  _buildRateAndTimecount(travelDateTime, bookingData, index, context),
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

   Widget _buildDestination(AsyncSnapshot<BookingListModel> bookingData, int index) {
    return Row(
                                  children: [
                                   Expanded(
                                     child: Row(
                                      children: [
                                         Image.asset(
                                        bookingData
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .journeyType ==
                                                1
                                            ? AssetImages.vet_logo
                                            : bookingData
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .journeyType ==
                                                2
                                            ? AssetImages.buva_sea
                                            : bookingData
                                                    .data
                                                    ?.body
                                                    ?.data?[index]
                                                    .journeyType ==
                                                3
                                            ? AssetImages.vet_air_bus_schedule
                                            : AssetImages.buva_sea,
                                        height: 30,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "${bookingData.data?.body?.data?[index].destinationFrom} - ${bookingData.data?.body?.data?[index].destinationTo}",
                                          maxLines: 1,
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
                                     //
                                     
                                   ),
                                    //
                                     Row(
                                       children: [
                                         Image.asset(
                                           AssetImages.user,
                                           height: 20,
                                         ),
                                         const SizedBox(width: 6),
                                         Text(
                                           '${bookingData.data?.body?.data?[index].totalSeat}',
                                           style: TextStyle(
                                             fontSize: 14,
                                             color: AppColors.primaryColor,
                                             fontWeight: FontWeight.bold,
                                           ),
                                         ),
                                       
                                       ],
                                     ),
                                    
                                  ],
                                );
  }

   Widget _buildCodeAndDate(AsyncSnapshot<BookingListModel> bookingData, int index) {
    return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          
                                          Image.asset(
                                            AssetImages.ic_ticket_history,
                                            width: 18,
                                            height: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              bookingData.data?.body?.data?[index].code ?? '-',
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

                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                         
                                           Image.asset(
                                            AssetImages.ic_date_history,
                                            width: 18,
                                            height: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "${bookingData.data?.body?.data?[index].travelDate}",
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
                                );
  }


Widget _buldBusAndTime(
    AsyncSnapshot<BookingListModel> bookingData, 
    int index) {
    return Row(
        mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                          
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                           Image.asset(
                                            // AssetImages.ic_boat_history ,
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
                                                ? AssetImages.ic_boat_history : AssetImages.ic_bus_history,
                                            width: 18,
                                            height: 18,
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

                                    Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [

                                           Image.asset(
                                            AssetImages.ic_time_history,
                                            width: 18,
                                            height: 18,
                                          ),
                                          Text(" ${DateFormat('HH:mm').format(DateFormat('HH:mm').parse((bookingData.data?.body?.data?[index].departure).toString()))}", style: TextStyle(
                                             color: AppColors.textColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                          ),),
                                        ],
                                      ),
                                    )
                                  ],
                                );
  }
  Widget _buildRateAndTimecount(
    DateTime travelDateTime, 
    AsyncSnapshot<BookingListModel> bookingData, 
    int index, 
    BuildContext context) {
    return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (travelDateTime.isBefore(
                                      DateTime.now(),
                                    ))
                                      bookingData
                                                  .data
                                                  ?.body
                                                  ?.data?[index]
                                                  .isRate ==
                                              0
                                          ? InkWell(
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
                                                    Transition
                                                        .rightToLeft,
                                                duration: const Duration(
                                                  milliseconds:
                                                      Constrains.duration,
                                                ),
                                              );
                                          
                                              if (result == true) {
                                                controller
                                                    .loadBookingList(
                                                      context: context,
                                                    );
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
                                          )
                                          : const Expanded(
                                            flex: 1,
                                            child: SizedBox(),
                                          ),
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
                                              ),
                                              style: const TextStyle(
                                                color:
                                                    AppColors.primaryColor,
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
