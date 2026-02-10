import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../activities/ticket/rental_car_info_screen.dart';
import '../models/destination/destination_province.dart';
import '../models/simple_response.dart';
import '../models/vehicle_rental/car_type_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class VehicleRental {
  // for get car type
  Future<CarTypeResponse> getCarTypeList(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}vehicle-rental/busType'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response car type ==>>${response.body}');
        return CarTypeResponse.fromJson(jsonDecode(response.body));
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

  // for get car type
  Future<ProvinceResponse> getProvince(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}vehicle-rental/province'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response province ==>>${response.body}');
        return ProvinceResponse.fromJson(jsonDecode(response.body));
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

  void rentalSave(
    context,
    String busTypeId,
    String dateFrom,
    String dateTo,
    String name,
    String numberBus,
    String provinceFrom,
    String provinceTo,
    String telephone,
    String travelType,
    String note,
  ) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}vehicle-rental/add'),
    );
    request.headers['Authorization'] = AppPref.getToken() ?? '';
    request.fields['busTypeId'] = busTypeId;
    request.fields['dateFrom'] = dateFrom;
    request.fields['dateTo'] = dateTo;
    request.fields['name'] = name;
    request.fields['numberBus'] = numberBus;
    request.fields['provinceFrom'] = provinceFrom;
    request.fields['provinceTo'] = provinceTo;
    request.fields['telephone'] = telephone;
    request.fields['travelType'] = travelType;
    request.fields['note'] = note;

    try {
      final result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      final response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        log(response.body);
        Loading().loadingClose(context);
        SimpleResponse data = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (data.header?.statusCode == 200 && data.header?.result == true) {
          alertDialogRental(
            context: context,
            details: [
              {'name'.tr: name},
              {'phone'.tr: telephone},
              {'from'.tr: provinceFrom},
              {'to'.tr: provinceTo},
              {'departure_date'.tr: dateFrom},
              {'return_date'.tr: dateTo},
              {'car_type'.tr: RentalCarInfoScreen.carType},
              {'amount_of_car'.tr: numberBus},
            ],
          );
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
      Loading().loadingClose(context);
      rethrow;
    }
  }
}
