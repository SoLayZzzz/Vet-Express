import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/saving_point/saving_list_response.dart';
import '../models/saving_point/saving_point_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class SavingPoint {
  // for get notification for logistic
  Future<SavingPointResponse> getSavingPoint(
    context,
    String month,
    String year,
  ) async {
    Map<String, String> headers = {"Authorization": AppPref.getToken() ?? ''};

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}saving-point/account'),
    );
    request.headers.addAll(headers);
    request.fields['month'] = month;
    request.fields['year'] = year;

    try {
      final response = await http.Response.fromStream(
        await request.send().timeout(
          const Duration(seconds: Constrains.timeout30),
        ),
      );

      log("Response saving point${response.body}");
      return SavingPointResponse.fromJson(jsonDecode(response.body));
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

  Future<SavingListResponse> getSavingPointDetail(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}saving-point/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({'page': 1, 'rowsPerPage': 100}),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response saving point list ==>>${response.body}');
        return SavingListResponse.fromJson(jsonDecode(response.body));
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
      Loading().loadingClose(context);
      rethrow;
    }
  }
}
