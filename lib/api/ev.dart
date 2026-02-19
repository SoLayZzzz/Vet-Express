// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_top_up_response.dart';
// import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_wallet_amount_response.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_contact_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_faq_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_news_feed_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_policy_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_province_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_scan_qr_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_slide_show_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_station_list_response.dart';
// import '../feature/home-dashboard/ev-charger/data/model/response/ev_wallet_list_response.dart';
// import '../models/simple_response.dart';
// import '../utils/alert_dialog.dart';
// import '../utils/app_pref.dart';
// import '../utils/contains.dart';
// import '../utils/loading.dart';
// import '../base/base_url.dart';

// class EV {
//   /// Get EV Contact Us
//   Future<EvContactResponse> getEvContactUs(
//     context,
//     int page,
//     int rowPerPage,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}dropdown/contact-us/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": page,
//               "rowsPerPage": rowPerPage,
//               "searchText": "",
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV contact us ==>>${response.body}');
//         return EvContactResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV FAQ
//   Future<EvFaqResponse> getEvFaQ(context, int page, int rowPerPage) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}dropdown/faqs/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": page,
//               "rowsPerPage": rowPerPage,
//               "searchText": "",
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV FAQ ==>>${response.body}');
//         return EvFaqResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV Policy
//   Future<EvPolicyResponse> getEvPolicy(
//     context,
//     int page,
//     int rowPerPage,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}dropdown/privacy-policy/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": page,
//               "rowsPerPage": rowPerPage,
//               "searchText": "",
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV Policy ==>>${response.body}');
//         return EvPolicyResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV Slide Show
//   Future<EvSlideShowResponse> getEvSlideShow(
//     context,
//     int page,
//     int rowPerPage,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}dropdown/slide-shows/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": page,
//               "rowsPerPage": rowPerPage,
//               "searchText": "",
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV slide show ==>>${response.body}');
//         return EvSlideShowResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV News Feed
//   Future<EvNewsFeedResponse> getEvNewsFeed(
//     context,
//     int page,
//     int rowPerPage,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}dropdown/new-feed/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": page,
//               "rowsPerPage": rowPerPage,
//               "searchText": "",
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV News Feed ==>>${response.body}');
//         return EvNewsFeedResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV Province
//   Future<EvProvinceResponse> getEvProvince(
//     context,
//     int page,
//     int rowPerPage,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}dropdown/province/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": page,
//               "rowsPerPage": rowPerPage,
//               "searchText": '',
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV Province ==>>${response.body}');
//         return EvProvinceResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV Station + Fav
//   Future<EvStationListResponse> getEvNewStation(
//     context, {
//     String? searchText,
//     int? provinceId,
//   }) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}station/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": 1,
//               "rowsPerPage": 100,
//               "searchText": searchText,
//               "provinceId": provinceId,
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV Station ==>>${response.body}');
//         return EvStationListResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// EV Tick Fav
//   Future<SimpleResponse> eVFav(context, int id) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}station/add-favorites/$id'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV Station ==>>${response.body}');
//         return SimpleResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV Wallet List
//   Future<EvWalletListResponse> getEvWalletList(
//     context,
//     int page,
//     int rowPerPage,
//   ) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}sale-order/wallet/list'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({
//               "page": page,
//               "rowsPerPage": rowPerPage,
//               "searchText": '',
//             }),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV Wallet ==>>${response.body}');
//         return EvWalletListResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// Get EV Wallet Amount
//   Future<EvWalletAmountResponse> getEvWalletAmount(context) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}sale-order/wallet/amount'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV Wallet Amount ==>>${response.body}');
//         return EvWalletAmountResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// EV Top UP
//   Future<EvTopUpResponse> evWalletTopUp(context, double amount) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}sale-order/wallet/top-up'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//             body: json.encode({"amount": amount}),
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV Top Up ==>>${response.body}');
//         return EvTopUpResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// EV payment
//   Future<EvTopUpResponse> evPaymentStatus(context, String transactionId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse(
//               '${BaseUrl.BASE_URL_EV}sale-order/wallet/top-up/status/$transactionId',
//             ),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//           )
//           .timeout(const Duration(seconds: Constrains.timeout30));

//       if (response.statusCode == 200) {
//         log('This is response EV payment status ==>>${response.body}');
//         return EvTopUpResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load to server!!');
//       }
//     } on TimeoutException {
//       Loading().loadingClose(context);
//       alertDialogOneButton(
//         title: 'timeout'.tr,
//         description: 'request_timed_out'.tr,
//         buttonText: 'ok'.tr,
//       );
//       rethrow;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   /// EV Scan find QR (sale-order/find/{transactionId})
//   Future<EvScanQrResponse> eVScanQR(context, String transactionId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse('${BaseUrl.BASE_URL_EV}sale-order/find/$transactionId'),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         log('EV Scan QR Response: ${response.body}');
//         return EvScanQrResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception(
//           'Failed to load data from server! Status: ${response.statusCode}',
//         );
//       }
//     } on TimeoutException {
//       _handleTimeout(context);
//       rethrow;
//     } catch (e) {
//       log('EV Scan QR Error: $e');
//       rethrow;
//     }
//   }

//   /// EV Scanner confirm payment (payment/confirm-payment/{transactionId})
//   Future<SimpleResponse> eVConfirmPayment(context, String transactionId) async {
//     try {
//       final response = await http
//           .post(
//             Uri.parse(
//               '${BaseUrl.BASE_URL_EV}payment/confirm-payment/$transactionId',
//             ),
//             headers: <String, String>{
//               "Content-type": "application/json",
//               'Authorization': AppPref.getToken() ?? '',
//             },
//           )
//           .timeout(const Duration(seconds: 30));

//       if (response.statusCode == 200) {
//         log('EV Confirm Payment Response: ${response.body}');
//         return SimpleResponse.fromJson(jsonDecode(response.body));
//       } else {
//         throw Exception(
//           'Failed to confirm payment! Status: ${response.statusCode}',
//         );
//       }
//     } on TimeoutException {
//       _handleTimeout(context);
//       rethrow;
//     } catch (e) {
//       log('EV Confirm Payment Error: $e');
//       rethrow;
//     }
//   }

//   void _handleTimeout(context) {
//     if (Get.isDialogOpen ?? false) {
//       Get.back();
//     }

//     Get.dialog(
//       AlertDialog(
//         title: Text('timeout'.tr),
//         content: Text('request_timed_out'.tr),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
//         ],
//       ),
//     );
//   }
// }
