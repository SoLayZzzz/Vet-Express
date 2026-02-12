import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../feature/dash_board/presentation/screen/dashboard_screen.dart';
import '../activities/ticket/payment_screen.dart';
import '../activities/ticket/value_statics.dart';
import '../models/booking/cancel_booking_response.dart';
import '../models/booking/confirm_booking_response.dart';
import '../models/booking/booking_detail_model.dart';
import '../models/booking/booking_list_model.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_colors.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class Booking {
  // For get confirm booking
  void confirmBooking(
    context,
    List<int> boardingPointId,
    List<int> dropOffId,
    String email,
    List<String> journeyDate,
    List<String> journeyId,
    int journeyType,
    String name,
    List<String> seatGender,
    List<String> seatJourney,
    List<String> seatName, // is user booking
    List<String> seatNum, // is seat label
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
    var data = <dynamic, dynamic>{};

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
    for (int i = 0; i < seatDob!.length; i++) {
      data['seatDob[$i]'] = seatDob[i].toString();
    }
    for (int i = 0; i < seatPassport!.length; i++) {
      data['seatPassport[$i]'] = seatPassport[i].toString();
    }
    data['nationally'] = national;
    data['isUseLuckyDraw'] = luckyDraw ? '1' : '0';
    data['packageTravelCode'] = packageTravelCode;
    data['couponCode'] = couponCode;

    Loading().loadingShow(context);

    log("Value confirm booking ${data.toString()}");

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}booking/confirm'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
            body: data,
          )
          .timeout(const Duration(seconds: Constrains.timeout180));

      if (response.statusCode == 200) {
        log('This is response confirm booking ==>>${response.body}');
        Loading().loadingClose(context);
        var data = ConfirmBookingResponse.fromJson(jsonDecode(response.body));
        if (data.header?.statusCode == 200 && data.header?.result == true) {
          if (data.body?.status == 2) {
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
            if (data.body?.msg == 'Data have been saved.') {
              ValueStatic.luckyDraw = luckyDraw;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PaymentScreen(
                        id: (data.body?.transactionId).toString(),
                        datas: data,
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
      } else {
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Dialog dialog(context, String title, String description) {
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
  void cancelBooking(context, String transactionID) async {
    Loading().loadingShow(context);

    var map = <String, dynamic>{};
    map['transactionId'] = transactionID;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}booking/cancel'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response cancel booking ==>>${response.body}');
        var data = CancelBookingResponse.fromJson(jsonDecode(response.body));
        if (data.header!.statusCode == 200 && data.header?.result == true) {
          if (data.body?.status == 1) {
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
      } else {
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingListModel> getBookingList(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}booking/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({'page': 1, 'rowsPerPage': 100}),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response booking list ==>>${response.body}');
        return BookingListModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingDetailModel> getTicketDetail(context, int id) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}booking/find/$id'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response by id  ==>>${response.body}');
        return BookingDetailModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
