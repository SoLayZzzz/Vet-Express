import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import '../activities/home_screen.dart';
import '../activities/logistic/self_service_qr_screen.dart';
import '../models/goods_transfer/review_response.dart';
import '../models/request_transfer/add_goods.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class RequestTransfer {
  void saveGoodsSelfService(
    context,
    String destinationToId,
    String itemQty,
    String itemValue,
    String receiverTelephone,
    String senderTelephone,
    String uomId,
  ) async {
    var map = <String, dynamic>{};
    map['destinationToId'] = destinationToId;
    map['itemQty'] = itemQty;
    map['itemValue'] = itemValue;
    map['receiverTelephone'] = receiverTelephone;
    map['senderTelephone'] = senderTelephone;
    map['uomId'] = uomId;

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}request-transfer/addGoods'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response save self service==>>${response.body}');
        AddGoodsResponse data = AddGoodsResponse.fromJson(
          jsonDecode(response.body),
        );
        if (data.header?.statusCode == 200 && data.header?.result == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => SelfServiceQRScreen(
                    qrCode: (data.body?.message).toString(),
                  ),
            ),
          );
        } else {
          Loading().loadingClose(context);
          alertDialogOneButton(
            title: 'Save not Success',
            description: 'Please try agian!',
            buttonText: 'ok'.tr,
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
      rethrow;
    }
  }

  void bookingTransferItem(
    BuildContext context,
    String? filepath,
    String itemName,
    String lats,
    String longs,
    String qtyType,
    String senderAddr,
    String serviceType,
    String telephone,
  ) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}request-transfer/add'),
    );
    request.headers['Authorization'] = AppPref.getToken() ?? '';

    if (filepath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', filepath));
    }

    request.fields['itemName'] = itemName;
    request.fields['lats'] = lats;
    request.fields['longs'] = longs;
    request.fields['qtyType'] = qtyType;
    request.fields['senderAddr'] = senderAddr;
    request.fields['serviceType'] = serviceType;
    request.fields['telephone'] = telephone;

    try {
      final response = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );

      final httpResponse = await http.Response.fromStream(response);

      if (httpResponse.statusCode == 200) {
        Loading().loadingClose(context);
        log('Response: ${httpResponse.body}');
        AddGoodsResponse data = AddGoodsResponse.fromJson(
          jsonDecode(httpResponse.body),
        );

        if (data.header?.statusCode == 200 && data.header?.result == true) {
          alertDialogOneButton(
            title: 'success'.tr,
            description: 'success_info'.tr,
            buttonText: 'close'.tr,
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen(from: 0)),
            (Route<dynamic> route) => false,
          );
        } else {
          Loading().loadingClose(context);
          alertDialogOneButton(
            title: 'timeout'.tr,
            description: 'request_timed_out'.tr,
            buttonText: 'ok'.tr,
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

  void review(
    String transferId,
    String comment,
    String score,
    String type,
    BuildContext context,
  ) async {
    Loading().loadingShow(context);

    Map<String, String> headers = {
      "Authorization": AppPref.getToken() ?? '',
      "Content-Type": 'multipart/form-data',
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}request-transfer/saveSurvey'),
    );
    request.headers.addAll(headers);
    request.fields['comment'] = comment;
    request.fields['goodsTransferId'] = transferId;
    request.fields['score'] = score;
    request.fields['type'] = type;

    try {
      final response = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );

      final httpResponse = await http.Response.fromStream(response);
      log('Response of review: ${httpResponse.body}');

      if (httpResponse.statusCode == 200) {
        Loading().loadingClose(context);
        final data = ReviewResponse.fromJson(jsonDecode(httpResponse.body));

        if (data.header?.statusCode == 200 && data.header?.result == true) {
          if (data.body?.status == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("survey_submitted".tr)));
            Navigator.pop(context, '1');
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("try_again".tr)));
          }
        }
      } else {
        Loading().loadingClose(context);
        log("Request failed with status: ${httpResponse.statusCode}");
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
    } catch (e) {
      Loading().loadingClose(context);
      rethrow;
    }
  }
}
