import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/destination/destination_from.dart';
import '../models/destination/destination_province.dart';
import '../models/destination/destination_to.dart';
import '../models/destination/response_des.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class Destination {
  // For get destination from
  Future<DestinationResponse> desFrom(
    context,
    String lang,
    String type,
    String search,
  ) async {
    var map = <String, dynamic>{};
    map['lang'] = lang;
    map['searchText'] = search;
    map['type'] = type;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}destinations/from'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response Des From ==>>${response.body}');
        return DestinationResponse.fromJson(jsonDecode(response.body));
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

  // For get destination to
  Future<DestinationResponse> desTo(
    context,
    String desFrom,
    String lang,
    String type,
    String search,
  ) async {
    var map = <String, dynamic>{};
    map['fromId'] = desFrom;
    map['lang'] = lang;
    map['searchText'] = search;
    map['type'] = type;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}destinations/to'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response Des To ==>>${response.body}');
        return DestinationResponse.fromJson(jsonDecode(response.body));
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

  // for get destination from
  Future<DesFromResponse> getDesFrom(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}destinations/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({'page': 1, 'rowsPerPage': 100}),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response des from  ==>>${response.body}');
        return DesFromResponse.fromJson(jsonDecode(response.body));
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

  // for get destination to
  Future<DesToResponse> getDesTo(context, int desFromId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}destinations/list-to'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({
              'page': 1,
              'rowsPerPage': 100,
              'destinationsFromId': desFromId,
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response des to ==>>${response.body}');
        return DesToResponse.fromJson(jsonDecode(response.body));
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

  // For get province
  Future<ProvinceResponse> province(context, String search) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}destinations/province'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({
              "page": "1",
              "rowsPerPage": "100",
              "searchText": search,
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response province ==>>${response.body}');
        return ProvinceResponse.fromJson(jsonDecode(response.body));
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

  // For get destination by province
  Future<ProvinceResponse> desByProvince(
    context,
    String provinceId,
    String search,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}destinations/destinationByProvince'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({
              "page": "1",
              "rowsPerPage": "100",
              "provinceId": provinceId,
              "searchText": search,
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response province ==>>${response.body}');
        return ProvinceResponse.fromJson(jsonDecode(response.body));
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
}
