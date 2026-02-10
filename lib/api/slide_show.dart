import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/slide_show/slide_show_response.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../base/base_url.dart';

class SlideShow {
  Future<SlideShowResponse> slideShowMenu(
    context,
    int type,
    int page,
    int rowPerPage,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}slide-shows/list'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({
              'page': page,
              'rowsPerPage': rowPerPage,
              'searchText': '',
              'type': type,
              'orderBy': '',
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log(
          'This is response slide show ==>>${BaseUrl.BASE_URL} ${response.body}',
        );
        return SlideShowResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }

  Future<SlideShowResponse> slideShowAds(
    context,
    int page,
    int rowPerPage,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}user/advHome'),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({'page': page, 'rowsPerPage': rowPerPage}),
          )
          .timeout(const Duration(seconds: Constrains.timeout15));

      if (response.statusCode == 200) {
        log(
          'This is response slide show Ads ==>>${BaseUrl.BASE_URL} ${response.body}',
        );
        return SlideShowResponse.fromJson(jsonDecode(response.body));
      } else {
        log("Status ${response.statusCode}");
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }

  Future<SlideShowResponse> slideBus(
    context,
    int type,
    int page,
    int rowPerPage,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}slide-shows/busList'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({
              'page': page,
              'rowsPerPage': rowPerPage,
              'searchText': '',
              'type': type,
              'orderBy': '',
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log(
          'This is response slide show bus ==>>${BaseUrl.BASE_URL} ${response.body}',
        );
        return SlideShowResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }

  Future<SlideShowResponse> slideBuvaSea(
    context,
    int type,
    int page,
    int rowPerPage,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}slide-shows/buvaSeaList'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: json.encode({
              'page': page,
              'rowsPerPage': rowPerPage,
              'searchText': '',
              'type': type,
              'orderBy': '',
            }),
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log(
          'This is response slide show Buva Sea ==>>${BaseUrl.BASE_URL} ${response.body}',
        );
        return SlideShowResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }
}
