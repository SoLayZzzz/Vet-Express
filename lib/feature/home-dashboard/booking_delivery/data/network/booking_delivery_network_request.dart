import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../../base/base_url.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_pref.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';
import '../model/request/booking_delivery_add_request_body.dart';
import '../model/response/booking_delivery_add_response.dart';

class BookingDeliveryNetworkRequest {
  Future<BookingDeliveryAddResponse> addBookingDelivery({
    required BuildContext context,
    required BookingDeliveryAddRequestBody body,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.BASE_URL}request-transfer/add'),
      );

      final token = AppPref.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = token;
      }

      final filePath = body.filePath;
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      }

      request.fields.addAll(body.toFormFields());

      final response = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );

      final httpResponse = await http.Response.fromStream(response);

      if (httpResponse.statusCode == 200) {
        final decoded = jsonDecode(httpResponse.body);
        if (decoded is Map<String, dynamic>) {
          return BookingDeliveryAddResponse.fromJson(decoded);
        }
        return BookingDeliveryAddResponse.fromJson(<String, dynamic>{});
      }

      throw Exception('Failed to load to server!');
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
