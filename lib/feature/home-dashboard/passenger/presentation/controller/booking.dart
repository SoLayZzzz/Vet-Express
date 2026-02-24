import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../payment/presentaion/ui/payment_screen.dart';
import '../../../../../value_statics.dart';
import '../../../../../feature/dash_board/presentation/screen/dashboard_screen.dart';
import '../../data/model/response/booking_list_model.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/loading.dart';
import '../../data/network/passenger_network_request.dart';
import '../../data/model/response/booking_detail_model.dart';
import '../binding/passenger_binding.dart';

class Booking {
  PassengerNetworkRequest _ensureNetworkRequest() {
    if (!Get.isRegistered<PassengerNetworkRequest>()) {
      PassengerBinding().dependencies();
    }
    return Get.find<PassengerNetworkRequest>();
  }

  // For get confirm booking
  void confirmBooking(
    BuildContext context,
    List<int> boardingPointId,
    List<int> dropOffId,
    String email,
    List<String> journeyDate,
    List<String> journeyId,
    int journeyType,
    String name,
    List<String> seatGender,
    List<String> seatJourney,
    List<String> seatName,
    List<String> seatNum,
    List<double> seatPrice,
    String telephone,
    double totalAmount,
    double totalDiscount,
    String totalSeat,
    String app,
    List<int> seatNationallyId,
    String national,
    bool luckyDraw,
    String packageTravelCode,
    String couponCode, {
    List<String>? seatDob,
    List<String>? seatPassport,
  }) async {
    final data = <String, String>{};

    for (int i = 0; i < boardingPointId.length; i++) {
      data['boardingPointId[$i]'] = boardingPointId[i].toString();
    }

    for (int i = 0; i < dropOffId.length; i++) {
      data['dropOffId[$i]'] = dropOffId[i].toString();
    }

    data['email'] = email;

    for (int i = 0; i < journeyDate.length; i++) {
      data['journeyDate[$i]'] = journeyDate[i].toString();
    }

    for (int i = 0; i < journeyId.length; i++) {
      data['journeyId[$i]'] = journeyId[i].toString();
    }

    data['journeyType'] = journeyType.toString();
    data['name'] = name;

    for (int i = 0; i < seatGender.length; i++) {
      data['seatGender[$i]'] = seatGender[i].toString();
    }

    for (int i = 0; i < seatJourney.length; i++) {
      data['seatJourney[$i]'] = seatJourney[i].toString();
    }

    for (int i = 0; i < seatName.length; i++) {
      data['seatName[$i]'] = seatName[i].toString();
    }

    for (int i = 0; i < seatNum.length; i++) {
      data['seatNum[$i]'] = seatNum[i].toString();
    }

    for (int i = 0; i < seatPrice.length; i++) {
      data['seatPrice[$i]'] = seatPrice[i].toString();
    }

    data['telephone'] = telephone;
    data['totalAmount'] = totalAmount.toString();
    data['totalDiscount'] = totalDiscount.toString();
    data['totalSeat'] = totalSeat;
    data['app'] = app;

    for (int i = 0; i < seatNationallyId.length; i++) {
      data['seatNationallyId[$i]'] = seatNationallyId[i].toString();
    }

    final localDob = seatDob ?? <String>[];
    for (int i = 0; i < localDob.length; i++) {
      data['seatDob[$i]'] = localDob[i].toString();
    }

    final localPassport = seatPassport ?? <String>[];
    for (int i = 0; i < localPassport.length; i++) {
      data['seatPassport[$i]'] = localPassport[i].toString();
    }

    data['nationally'] = national;
    data['isUseLuckyDraw'] = luckyDraw ? '1' : '0';
    data['packageTravelCode'] = packageTravelCode;
    data['couponCode'] = couponCode;

    Loading().loadingShow();

    try {
      final response = await _ensureNetworkRequest().confirmBooking(
        context: context,
        fields: data,
      );
      Loading().loadingClose();

      if (response.header?.statusCode == 200 &&
          response.header?.result == true) {
        if (response.body?.status == 2) {
          alertDialogTwoButton(
            title: 'your_ticket_has_been_reserved'.tr,
            description: 'ticket_info1'.tr,
            buttonText1: 'home'.tr,
            buttonText2: 'show_ticket'.tr,
            onButtonPressed1: () {
              ValueStatic().clearDataTicket();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(from: 0),
                ),
                (Route<dynamic> route) => false,
              );
            },
            onButtonPressed2: () {
              ValueStatic().clearDataTicket();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(from: 2),
                ),
                (Route<dynamic> route) => false,
              );
            },
          );
        } else {
          if (response.body?.msg == 'Data have been saved.') {
            ValueStatic.luckyDraw = luckyDraw;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => PaymentScreen(
                      id: (response.body?.transactionId).toString(),
                      datas: response,
                    ),
              ),
            );
          } else {
            showDialog(
              barrierColor: Colors.black26,
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return dialog(
                  context,
                  'information'.tr,
                  'seat_not_free_now'.tr,
                );
              },
            );
          }
        }
      }
    } on TimeoutException {
      rethrow;
    } catch (_) {
      Loading().loadingClose();
      rethrow;
    }
  }

  Dialog dialog(BuildContext context, String title, String description) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Text(
            title,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(description, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    ValueStatic().clearDataTicket();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(from: 0),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 50,
                    child: Center(
                      child: Text(
                        'start_again'.tr,
                        style: const TextStyle(color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // For get delete booking
  void cancelBooking(BuildContext context, String transactionID) async {
    Loading().loadingShow();

    try {
      final response = await _ensureNetworkRequest().cancelBooking(
        context: context,
        transactionId: transactionID,
      );
      Loading().loadingClose();

      if (response.header?.statusCode == 200 &&
          response.header?.result == true) {
        if (response.body?.status == 1) {
          ValueStatic().clearDataTicket();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardScreen(from: 0),
            ),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on TimeoutException {
      rethrow;
    } catch (_) {
      Loading().loadingClose();
      rethrow;
    }
  }

  Future<BookingListModel> getBookingList(BuildContext context) {
    return _ensureNetworkRequest().getBookingList(context: context);
  }

  Future<BookingDetailModel> getTicketDetail(BuildContext context, int id) {
    return _ensureNetworkRequest().getTicketDetail(context: context, id: id);
  }
}
