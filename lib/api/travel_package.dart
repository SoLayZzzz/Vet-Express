import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../models/travel_package/buy_travel_package_list_response.dart';
import '../models/travel_package/confirm_travel_package_response.dart';
import '../models/travel_package/find_travel_package_response.dart';
import '../models/travel_package/travel_package_content.dart';
import '../models/travel_package/travel_package_list_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class TravelPackage {
  Future<TravelPackageListResponse> getList(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}travelPackage/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response travel package list ==>>${response.body}');
        return TravelPackageListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose();
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

  Future<TravelPackageContent> getContent(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}travelPackage/content'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response travel package content ==>>${response.body}');
        return TravelPackageContent.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose();
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

  Future<FindTravelPackageResponse> find(context, int id) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}travelPackage/find/$id'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response travel package find id ==>>${response.body}');
        return FindTravelPackageResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose();
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

  void confirm({
    context,
    String? address,
    String? dob,
    String? email,
    required String name,
    required int nationality,
    required String photo,
    required int sex,
    required String telephone,
    required int travelPackageId,
    required void Function(ConfirmTravelPackageResponse) doOnSuccess,
    required void Function() doOnFailed,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL_TICKET}travelPackage/confirm'),
    );
    request.headers['Authorization'] = AppPref.getToken() ?? '';
    if (address != null && address.isNotEmpty)
      request.fields['address'] = address;
    if (dob != null && dob.isNotEmpty) request.fields['dob'] = dob;
    if (email != null && email.isNotEmpty) request.fields['email'] = email;
    request.fields['name'] = name;
    request.fields['nationality'] = nationality.toString();
    request.fields['photo'] = photo;
    request.fields['sex'] = sex.toString();
    request.fields['telephone'] = telephone;
    request.fields['travelPackageId'] = travelPackageId.toString();

    try {
      final result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      final response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        log('This is response travel package confirm ==>>${response.body}');
        doOnSuccess.call(
          ConfirmTravelPackageResponse.fromJson(jsonDecode(response.body)),
        );
      } else {
        doOnFailed.call();
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
    } catch (e) {
      log('An error occurred: $e');
      rethrow;
    }
  }

  Future<BuyTravelPackageListResponse> getBuyList(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}travelPackage/getPackage'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response buy travel package list ==>>${response.body}');
        return BuyTravelPackageListResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } on TimeoutException {
      Loading().loadingClose();
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
