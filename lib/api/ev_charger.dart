import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/destination/destination_ev.dart';
import '../feature/home-dashboard/ev-charger/data/model/response/ev_charger_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class EvChargerList {
  Future<EvChargerResponse> getEvChargerList(
    context, {
    String? name,
    String? provinceId,
  }) async {
    try {
      log('Fetching EV stations with provinceId: $provinceId, name: $name');

      final Map<String, dynamic> requestBody = {};
      if (provinceId != null && provinceId.isNotEmpty) {
        requestBody['provinceId'] = provinceId;
      }
      if (name != null && name.isNotEmpty) {
        requestBody['name'] = name;
      }

      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}evStation/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      log('EV Charger API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        log("EV Charger API Response: ${jsonEncode(jsonResponse)}");

        return EvChargerResponse.fromJson(jsonResponse);
      } else {
        log('EV Charger API Error: ${response.statusCode} - ${response.body}');
        throw Exception("Failed to load: ${response.statusCode}");
      }
    } on TimeoutException catch (e) {
      log('EV Charger API Timeout: $e');
      rethrow;
    } catch (e) {
      log('EV Charger API Exception: $e');
      rethrow;
    }
  }

  /* Future<EvChargerResponse> getEvChargerList(context, {String? name, String? provinceId}) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}evStation/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({'provinceId': provinceId, 'name': name}),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log("This is response ev charger: ${response.body}");
        return EvChargerResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load: ${response.statusCode}");
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
*/
  Future<DestinationEvResponse> getProvinceEV(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}province/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log("This is response ev province: ${response.body}");
        return DestinationEvResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load: ${response.statusCode}");
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
