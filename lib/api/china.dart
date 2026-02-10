import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:express_vet/models/china/province_response.dart';
import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/models/china/list_by_province.dart';
import 'package:express_vet/models/simple_response.dart';
import 'package:express_vet/models/china/warehouse_response.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class ChinaService {
  /// get province list
  Future<ProvinceResponse> getProvinceList(context, String lang) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}province/list'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
              'Content-Type': 'application/json',
            },
            body: json.encode({'lang': lang}),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response province china ==>>${response.body}');
        return ProvinceResponse.fromJson(jsonDecode(response.body));
      } else {
        log('Province list failed: ${response.statusCode}');
        throw Exception(
          'Failed to load province list. Status: ${response.statusCode}',
        );
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
      log('Province list error: $e');
      rethrow;
    }
  }

  /// get branch by province
  Future<BranchByProvinceResponse> getBranchByProvince(
    context,
    String lang,
    String provinceId,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}branch/listByProvince'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
              'Content-Type': 'application/json',
            },
            body: json.encode({'lang': lang, 'provinceId': provinceId}),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response branch by province china ==>>${response.body}');
        return BranchByProvinceResponse.fromJson(jsonDecode(response.body));
      } else {
        log('Branch by province failed: ${response.statusCode}');
        throw Exception(
          'Failed to load branches. Status: ${response.statusCode}',
        );
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
      log('Branch by province error: $e');
      rethrow;
    }
  }

  /// create china customer - FIXED to use multipart/form-data
  Future<SimpleResponse> addChinaCustomer(
    context, {
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) async {
    try {
      Loading().loadingShow(context);

      ///for multipart/form-data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.BASE_URL}china-customer/add'),
      );

      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Authorization'] = AppPref.getToken() ?? '';
      request.fields['address'] = address;
      request.fields['branch_id'] = branchId;
      request.fields['name'] = name;
      request.fields['telephone'] = telephone;

      final responseStream = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );

      final response = await http.Response.fromStream(responseStream);

      Loading().loadingClose(context);

      if (response.statusCode == 200) {
        log('This is response add customer china ==>>${response.body}');
        return SimpleResponse.fromJson(jsonDecode(response.body));
      } else {
        log('Add customer failed: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to add customer. Status: ${response.statusCode}',
        );
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
      log('Add customer error: $e');
      rethrow;
    }
  }

  /// update china customer - FIXED to use multipart/form-data
  Future<SimpleResponse> updateChinaCustomer(
    context, {
    required String address,
    required String branchId,
    required String name,
    required String telephone,
  }) async {
    try {
      Loading().loadingShow(context);

      ///for multipart/form-data
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.BASE_URL}china-customer/update'),
      );

      request.headers['Content-Type'] = 'multipart/form-data';
      request.headers['Authorization'] = AppPref.getToken() ?? '';
      request.fields['address'] = address;
      request.fields['branch_id'] = branchId;
      request.fields['name'] = name;
      request.fields['telephone'] = telephone;

      final responseStream = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );

      final response = await http.Response.fromStream(responseStream);

      Loading().loadingClose(context);

      if (response.statusCode == 200) {
        log('This is response add customer china ==>>${response.body}');
        return SimpleResponse.fromJson(jsonDecode(response.body));
      } else {
        log('Add customer failed: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Failed to add customer. Status: ${response.statusCode}',
        );
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
      log('Add customer error: $e');
      rethrow;
    }
  }

  /// get china customer list
  Future<CustomerChinaListResponse> chinaCustomerList(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}china-customer/list'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response china customer list ==>>${response.body}');
        return CustomerChinaListResponse.fromJson(jsonDecode(response.body));
      } else {
        log('Customer list failed: ${response.statusCode}');
        throw Exception(
          'Failed to load customer list. Status: ${response.statusCode}',
        );
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
      log('Customer list error: $e');
      rethrow;
    }
  }

  /// Warehouse list
  Future<WarehouseResponse> chinaWarehouse(context, type) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}china-customer/warehouseList'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
              'Content-Type': 'application/json',
            },
            body: json.encode({'type': type}),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response china warehouse ==>>${response.body}');
        return WarehouseResponse.fromJson(jsonDecode(response.body));
      } else {
        log('Warehouse list failed: ${response.statusCode}');
        throw Exception(
          'Failed to load warehouse list. Status: ${response.statusCode}',
        );
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
      log('Warehouse list error: $e');
      rethrow;
    }
  }
}
