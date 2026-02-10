import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:express_vet/feature/auth/presentation/screen/sign_in_screen.dart';
import 'package:express_vet/feature/auth/presentation/screen/verify_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../activities/home_screen.dart';
import '../feature/auth/presentation/screen/new_password_screen.dart';

import '../activities/ticket/value_statics.dart';
import '../controller/user_controller.dart';
import '../feature/auth/data/model/response/nationality_response.dart';
import '../models/simple_response.dart';
import '../models/user/user_me.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_pref.dart';
import '../utils/contains.dart';
import '../utils/loading.dart';
import '../base/base_url.dart';

class User {
  // For register user take token to request code verification
  void register(
    context,
    String name,
    String password,
    String telephone, {
    String? email,
    String? dob,
    String? filename,
    int? gender,
    int? nationalityId,
  }) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/register'),
    );
    request.fields['name'] = name;
    request.fields['password'] = password;
    request.fields['telephone'] = telephone;

    if (email != null) {
      request.fields['email'] = email;
    }
    if (dob != null) {
      request.fields['dob'] = dob;
    }
    if (filename != null) {
      request.fields['filename'] = filename;
    }
    if (gender != null) {
      request.fields['gender'] = gender.toString();
    }
    if (nationalityId != null) {
      request.fields['nationalityId'] = nationalityId.toString();
    }

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout90),
      );
      var response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose(context);

        log('This is response Sign Up ==>> ${response.body}');
        final registerResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (registerResponse.header?.result == true &&
            registerResponse.header?.statusCode == 200) {
          if (registerResponse.body?.status == true) {
            String? token = registerResponse.body?.message.toString();

            Get.to(
              () => VerifyCodeScreen(
                identify: 1,
                token: token!,
                phone: telephone,
              ),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: Constrains.duration),
            );
          } else {
            alertDialogOneButton(
              title: 'information'.tr,
              description: 'this_phone_number_have_been_registered'.tr,
              buttonText: 'yes'.tr,
            );
          }
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

  // For verify code that send via SMS
  void verification(context, String code, String token) async {
    Loading().loadingShow(context);

    String? deviceId = AppPref.getDeviceId() ?? "VET_Express_DeviceID";
    String? deviceName = AppPref.getDeviceName() ?? "VET_Express_DeviceName";

    log("Device ID: $deviceId, Device Name: $deviceName");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/verification'),
    );
    request.fields['code'] = code;
    request.fields['deviceId'] = deviceId;
    request.fields['deviceName'] = deviceName;
    request.fields['token'] = token;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response Verification ==>>${response.body}');
        final verifyResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (verifyResponse.header?.result == true &&
            verifyResponse.header?.statusCode == 200) {
          if (verifyResponse.body?.status == true) {
            String? token = verifyResponse.body?.message.toString();

            // Use static methods from AppPref
            await AppPref.setToken('Bearer ${token!}');

            final UserController userController = Get.put(UserController());
            userController.fetchUserMe();

            await AppPref.setLogin().then((value) {
              Get.offAll(
                () => const HomeScreen(from: 0),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: Constrains.duration),
              );
            });
          } else {
            dialogInvalid(context, 'code_verify_invalid'.tr);
          }
        } else {
          dialogInvalid(context, 'code_verify_invalid'.tr);
        }
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
    }
  }

  // For resend verify code that send via SMS
  void reSendVerification(context, String phone) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/resend-code-verify'),
    );
    request.fields['phone'] = phone;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response Resend Code Sign Up ==>>${response.body}');
        final verifyResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (verifyResponse.header?.result == true &&
            verifyResponse.header?.statusCode == 200) {
          if (verifyResponse.body?.status == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('code_have_sent'.tr)));
            VerifyCodeScreen.newToken = (verifyResponse.body?.message)!;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('check_your_phone_number'.tr)),
            );
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        }
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
    }
  }

  // For user forgot password
  void forgotPassword(context, String phone) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/reset-password-send-sms'),
    );
    request.fields['phone'] = phone;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      Loading().loadingClose(context);
      if (response.statusCode == 200) {
        log('This is response Forgot Password ==>>${response.body}');
        final forgotPassResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (forgotPassResponse.header?.result == true &&
            forgotPassResponse.header?.statusCode == 200) {
          if (forgotPassResponse.body?.status == true) {
            String? token = forgotPassResponse.body?.message.toString();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => VerifyCodeScreen(
                      identify: 2,
                      token: token!,
                      phone: phone,
                    ),
              ),
            );
          } else {
            dialogInvalid(context, 'this_phone_number_not_registered'.tr);
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
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
    }
  }

  // For user forgot password
  Future<void> verifyForgotPassword(context, String code, String token) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/reset-password'),
    );
    request.fields['code'] = code;
    request.fields['token'] = token;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response ==>>${response.body}');
        final verifyForgotPassResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (verifyForgotPassResponse.header?.result == true &&
            verifyForgotPassResponse.header?.statusCode == 200) {
          if (verifyForgotPassResponse.body?.status == true) {
            String? token = verifyForgotPassResponse.body?.message.toString();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CreateNewPasswordScreen(token: token!),
              ),
            );
          } else {
            dialogInvalid(context, 'sms_code_invalid'.tr);
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        }
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
    }
  }

  // For resend verify code that send via SMS for reset password
  void reSendPasswordVerification(context, String token) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/resend-code'),
    );
    request.fields['token'] = token;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response ==>>${response.body}');
        final verifyPasswordResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (verifyPasswordResponse.header?.result == true &&
            verifyPasswordResponse.header?.statusCode == 200) {
          if (verifyPasswordResponse.body?.status == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('code_have_sent'.tr)));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        }
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
    }
  }

  // create new password
  void createNewPassword(context, String password, String token) async {
    Loading().loadingShow(context);

    //

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/new-password'),
    );
    request.fields['newPassword'] = password;
    request.fields['token'] = token;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response ==>>${response.body}');
        final createNewPasswordResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (createNewPasswordResponse.header?.result == true &&
            createNewPasswordResponse.header?.statusCode == 200) {
          if (createNewPasswordResponse.body?.status == true) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const SignInScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        }
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

  // for get user me
  Future<UserMeResponse> getUserMe(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}user/me'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response User me ==>>${response.body}');
        return UserMeResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      Loading().loadingClose(context);
      log("error", error: e);
      rethrow;
    }
  }

  // for get user me
  void getUserMeStatic(context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}user/me'),
            headers: <String, String>{
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response User me static ==>>${response.body}');
        late UserMeResponse data = UserMeResponse.fromJson(
          jsonDecode(response.body),
        );
        if (data.header!.statusCode == 200 && data.header!.result == true) {
          ValueStatic.username = data.body!.name.toString();
          ValueStatic.phone = data.body!.telephone.toString();
          ValueStatic.email = data.body!.email.toString();
          ValueStatic.gender = data.body!.gender!.toInt();
          ValueStatic.dob = data.body!.dob.toString();
          ValueStatic.nationalityName = data.body!.nationalityName.toString();
          ValueStatic.nationalityId = data.body!.nationalityId ?? 0;
        }
      } else {
        throw Exception('Failed to load to server!!');
      }
    } catch (e) {
      //Loading().loadingClose(context);
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('an_error_occurred'.tr)));
      throw Exception('Failed to load to server!!');
    }
  }

  // update user profile
  profileUpdate(
    context,
    String name, {
    String? telephone,
    String? email,
    String? filename,
    int? gender,
    int? nationalityId,
  }) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/update'),
    );
    request.headers['Authorization'] = AppPref.getToken() ?? '';
    request.fields['name'] = name;
    request.fields['telephone'] = telephone.toString();
    request.fields['gender'] = gender.toString();
    request.fields['nationalityId'] = nationalityId.toString();
    request.fields['email'] = email!;
    request.fields['filename'] = filename!;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response update user ==>>${response.body}');
        final createNewPasswordResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (createNewPasswordResponse.header?.result == true &&
            createNewPasswordResponse.header?.statusCode == 200) {
          if (createNewPasswordResponse.body?.status == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('updated'.tr)));

            final UserController userController = Get.put(UserController());
            userController.fetchUserMe();
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
        }
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
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('an_error_occurred'.tr)));
    }
  }

  // Dialog information
  void dialogInvalid(context, String message) {
    alertDialogOneButton(
      title: 'information'.tr,
      description: message,
      buttonText: 'yes'.tr,
    );
  }

  void forgotPasswordByTelegram(context, String phone) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/send-otp-forget-password'),
    );
    request.fields['phone'] = phone;
    request.fields['type'] = '2';

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      Loading().loadingClose(context);
      if (response.statusCode == 200) {
        log('This is response Forgot Password ==>>${response.body}');
        final forgotPassTelegramResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (forgotPassTelegramResponse.header?.result == true &&
            forgotPassTelegramResponse.header?.statusCode == 200) {
          if (forgotPassTelegramResponse.body?.status == true) {
            String? token = forgotPassTelegramResponse.body?.message.toString();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => VerifyCodeScreen(
                      identify: 3,
                      token: token!,
                      phone: phone,
                    ),
              ),
            );
          } else {
            dialogInvalid(context, 'this_phone_number_not_registered'.tr);
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
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
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('an_error_occurred'.tr)));
    }
  }

  void registerByTelegram(context, String type, String phone) async {
    Loading().loadingShow(context);

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseUrl.BASE_URL}user/send-otp-register'),
    );
    request.fields['phone'] = phone;
    request.fields['type'] = type;

    try {
      var result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      var response = await http.Response.fromStream(result);

      Loading().loadingClose(context);
      if (response.statusCode == 200) {
        log('This is response register by telegram ==>>${response.body}');
        final forgotPassTelegramResponse = SimpleResponse.fromJson(
          jsonDecode(response.body),
        );
        if (forgotPassTelegramResponse.header?.result == true &&
            forgotPassTelegramResponse.header?.statusCode == 200) {
          if (forgotPassTelegramResponse.body?.status == true) {
            String? token = forgotPassTelegramResponse.body?.message.toString();
            if (type == '1') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => VerifyCodeScreen(
                        identify: 1,
                        token: token!,
                        phone: phone,
                      ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => VerifyCodeScreen(
                        identify: 4,
                        token: token!,
                        phone: phone,
                      ),
                ),
              );
            }
          } else {
            dialogInvalid(context, 'this_phone_number_not_registered'.tr);
          }
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('try_again'.tr)));
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
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('an_error_occurred'.tr)));
    }
  }

  /// get nationality use in profile and sign up
  Future<NationalityResponse> getNationality(context) async {
    try {
      final response = await http
          .post(Uri.parse('${BaseUrl.BASE_URL}user/nationalityList'))
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response nationality ==>>${response.body}');
        return NationalityResponse.fromJson(jsonDecode(response.body));
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
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('an_error_occurred'.tr)));
      rethrow;
    }
  }

  ///use in travel package info and passenger detail screen
  Future<NationalityResponse> getNationalityTicket(context) async {
    try {
      final response = await http
          .post(Uri.parse('${BaseUrl.BASE_URL_TICKET}user/nationalityList'))
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response nationality ticket ==>>${response.body}');
        return NationalityResponse.fromJson(jsonDecode(response.body));
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
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('an_error_occurred'.tr)));
      rethrow;
    }
  }
}
