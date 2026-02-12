import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:express_vet/feature/auth/presentation/screen/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../feature/dash_board/presentation/screen/dashboard_screen.dart';
import '../controller/user_controller.dart';
import '../feature/auth/data/model/response/check_token_response.dart';
import '../feature/auth/data/model/response/check_version_response.dart';
import '../feature/auth/data/model/response/login_response.dart';
import '../models/simple_response.dart';
import '../utils/alert_dialog.dart';
import '../utils/alert_dialog_internet.dart';
import '../utils/app_colors.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class Auth {
  static int falseLoad = 0;
  static bool showError = false;

  // For Check Token request
  checkToken(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}auth/checkToken'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response check token ==>>${response.body}');
        final checkTokenResponse = CheckTokenResponse.fromJson(
          jsonDecode(response.body),
        );
        falseLoad = 0;
        showError = false;
        if (checkTokenResponse.header.statusCode == 401) {
          showDialog(
            barrierColor: Colors.black26,
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return PopScope(
                canPop: false,
                child: Dialog(
                  elevation: 0,
                  backgroundColor: const Color(0xffffffff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        'session_expired'.tr,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Text(
                          'session_expired_info'.tr,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: 20,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                await AppPref.clearAllData().then((value) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const SignInScreen(),
                                    ),
                                    (route) => false,
                                  );
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10.0),
                                  ),
                                ),
                                width: MediaQuery.of(context).size.width / 1.5,
                                height: 50,
                                child: Center(
                                  child: Text(
                                    'yes'.tr,
                                    style: const TextStyle(
                                      color: AppColors.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      } else {
        if (falseLoad < 2) {
          falseLoad++;
        }

        if (!showError) {
          if (falseLoad == 2) {
            showError = true;
            showDialog(
              barrierColor: Colors.black26,
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialogNoInternet(
                  ani: 'assets/gif/fail_load_ani.gif',
                  title: 'server_disruption'.tr,
                  description: 'server_disruption_info'.tr,
                );
              },
            );
          }
        }

        Future.delayed(const Duration(seconds: Constrains.timeout30), () {
          checkToken(context);
        });

        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }

  // For login request
  void login(context, String password, String username) async {
    Loading().loadingShow(context);

    String? deviceId = AppPref.getDeviceId() ?? "VET_Express_DeviceID";
    String? deviceName = AppPref.getDeviceName() ?? "VET_Express_DeviceName";

    log("Device ID: $deviceId, Device Name: $deviceName");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}auth/login'),
    );
    request.fields['deviceId'] = deviceId;
    request.fields['deviceName'] = deviceName;
    request.fields['password'] = password;
    request.fields['username'] = username;

    try {
      final result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout180),
      );
      final response = await http.Response.fromStream(result);
      Loading().loadingClose(context);

      if (response.statusCode == 200) {
        log('response body login ${response.body}');
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        if (loginResponse.header?.result == false &&
            loginResponse.header?.statusCode == 401) {
          alertDialogOneButton(
            title: 'invalid'.tr,
            description: 'check_password'.tr,
            buttonText: 'yes'.tr,
          );
        } else {
          String? tokenType = loginResponse.body?.tokenType;
          String? token = loginResponse.body?.accessToken;

          // Use static methods from AppPref
          await AppPref.setToken('${tokenType!} ${token!}');

          final UserController userController = Get.put(UserController());
          userController.fetchUserMe();

          await AppPref.setLogin().then((value) {
            Get.offAll(
              () => const DashboardScreen(from: 0),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: Constrains.duration),
            );
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
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
      log("error", error: e);
    }
  }

  // For logout request
  void logout(context) async {
    Loading().loadingShow(context);

    String? deviceId = AppPref.getDeviceId();

    Map<String, String> headers = {"Authorization": AppPref.getToken() ?? ''};

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}auth/logout'),
    );
    request.headers.addAll(headers);
    request.fields['deviceId'] = deviceId ?? '';

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      final response = await http.Response.fromStream(result);

      Loading().loadingClose(context);

      if (response.statusCode == 200) {
        log('response log out ${response.body}');

        // Clear ALL data using AppPref
        await AppPref.clearAllData().then((value) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const SignInScreen()),
            (route) => false,
          );
        });
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
      log("error", error: e);
    }
  }

  // For delete account
  deleteAccount(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}auth/deleteAccount'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response delete account ==>>${response.body}');
        final simpleResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );

        if (simpleResponse.header?.result == false) {
          alertDialogOneButton(
            title: 'not_successful'.tr,
            description: 'fail_delete'.tr,
            buttonText: 'yes'.tr,
          );
        } else if (simpleResponse.header?.result == true &&
            simpleResponse.header?.statusCode == 200) {
          alertDialogTravelPackage(
            title: 'successful'.tr,
            description: 'successful_delete'.tr,
            buttonText: 'yes'.tr,
            onButtonPressed: () async {
              // Clear ALL data using AppPref
              await AppPref.clearAllData().then((value) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                  (route) => false,
                );
              });
            },
          );
        }
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
    } catch (e) {
      Loading().loadingClose(context);
      log("error", error: e);
    }
  }

  // For Version Token request
  checkVersionUpdate(context) async {
    try {
      final response = await http
          .post(Uri.parse('${BaseUrl.BASE_URL}auth/checkVersion'))
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response check version ==>>${response.body}');
        final checkVersionResponse = CheckVersionResponse.fromJson(
          jsonDecode(response.body),
        );
        if (Platform.isAndroid) {
          if (double.parse((checkVersionResponse.body?.android).toString()) >
              double.parse(BaseUrl.APP_VERSION)) {
            showDialog(
              barrierColor: Colors.black26,
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return androidUpdate(context);
              },
            );
          }
        } else {
          if (double.parse((checkVersionResponse.body?.ios).toString()) >
              double.parse(BaseUrl.APP_VERSION)) {
            showDialog(
              barrierColor: Colors.black26,
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return iosUpdate(context);
              },
            );
          }
        }
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      throw Exception('Failed to load to server!!');
    }
  }

  Dialog androidUpdate(context) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Text(
              'update'.tr,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text('update_info'.tr, textAlign: TextAlign.start),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Visibility(
                      visible: false,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        width: MediaQuery.of(context).size.width / 4,
                        height: 50,
                        child: Center(
                          child: Text(
                            'No thanks',
                            style: TextStyle(color: Colors.green[700]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      openDeepLink(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.green[700],
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width / 4,
                      height: 50,
                      child: Center(
                        child: Text(
                          'update_now'.tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Image.asset('assets/images/play_store.png', height: 40),
          ],
        ),
      ),
    );
  }

  Dialog iosUpdate(context) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            Text(
              'update'.tr,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text('update_info'.tr, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            const Divider(),
            InkWell(
              onTap: () {
                openDeepLink(context);
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    'update_now'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openDeepLink(context) async {
    Navigator.pop(context);
    if (Platform.isAndroid) {
      final Uri playStoreUrl = Uri.parse(
        'https://play.google.com/store/apps/details?id=vireak_bunthan.udaya.com.vet_logistic',
      );
      await launchUrl(playStoreUrl, mode: LaunchMode.externalApplication);
    } else if (Platform.isIOS) {
      final Uri appStoreUrl = Uri.parse(
        'https://apps.apple.com/al/app/aba-mobile-bank/id1326432564',
      );
      await launchUrl(appStoreUrl, mode: LaunchMode.externalApplication);
    }
  }
}
