import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/resort/resort_response.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../base/base_url.dart';

class Resort {
  Future<ResortResponse> getResortList(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL_TICKET}resorts/list'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is resort response ==>>${response.body}');
        return ResortResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }
}
