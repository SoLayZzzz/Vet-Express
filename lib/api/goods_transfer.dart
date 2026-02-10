import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../activities/logistic/goods_information_no_token_screen.dart';
import '../activities/logistic/goods_information_screen.dart';
import '../models/destination/goods_find_response.dart';
import '../models/goods_transfer/good_search_response.dart';
import '../models/goods_transfer/transfer_list_response.dart';
import '../models/request_transfer/self_service_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class GoodsTransfer {
  // for code search in fragment home
  void goodsSearch(context, String code, int type) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}goods-transfer/search-code'),
    );
    request.fields['code'] = code;

    try {
      var responseStream = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(responseStream);

      Loading().loadingClose(context);

      if (response.statusCode == 200) {
        log('response body search response ==> ${response.body}');
        final Response = GoodsSearchResponse.fromJson(
          jsonDecode(response.body),
        );
        if (Response.header?.result == true &&
            Response.header?.statusCode == 200) {
          if (Response.body?.status == true) {
            if (type == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GoodsInformationScreen(
                        id: (Response.body?.data![0].id)!.toInt(),
                      ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GoodsInformationNoTokenScreen(
                        futureData: get(
                          GoodsFindResponse.fromJson(jsonDecode(response.body)),
                        ),
                      ),
                ),
              );
            }
          } else {
            alertDialogOneButton(
              title: 'invalid_code'.tr,
              description: 'incorrect_code'.tr,
              buttonText: 'yes'.tr,
            );
          }
        } else {
          alertDialogOneButton(
            title: 'invalid_code'.tr,
            description: 'incorrect_code'.tr,
            buttonText: 'yes'.tr,
          );
        }
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

  Future<GoodsFindResponse> get(response) async {
    return await response;
  }

  // For get list goods transfer
  Future<TransferListResponse> getTransferList(
    context,
    int page,
    int rowPerPage,
    int desFrom,
    int desTo,
    int type,
    int status,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}goods-transfer/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: jsonEncode({
              "destinationFromId": desFrom,
              "destinationToId": desTo,
              "page": page,
              "rowsPerPage": rowPerPage,
              "type": type,
              "status": status,
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response transfer list ==>>${response.body}');
        return TransferListResponse.fromJson(jsonDecode(response.body));
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

  // For get find item goods transfer
  Future<GoodsFindResponse> findGoodsTransfer(context, int id) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}goods-transfer/find/$id'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response goods find ==>>${response.body}');
        return GoodsFindResponse.fromJson(jsonDecode(response.body));
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

  Future<RequestGoodsTransferResponse> selfService(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}request-transfer/goodsList'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response self Service ==>>${response.body}');
        return RequestGoodsTransferResponse.fromJson(jsonDecode(response.body));
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
