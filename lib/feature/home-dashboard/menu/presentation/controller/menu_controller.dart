import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/feature/auth/data/model/response/check_version_response.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:express_vet/feature/auth/presentation/binding/auth_binding.dart';
import 'package:express_vet/feature/auth/domain/uscase/auth_usecase.dart';
import 'package:express_vet/value_statics.dart';
import '../../../../../base/state_controller.dart';
import '../../../../../controller/connectivity_controller.dart';
import '../../../../auth/presentation/controller/auth_controller.dart';
import '../../../../../utils/app_pref.dart';
import '../../../../../utils/contains.dart';
import 'package:express_vet/feature/home-dashboard/notifications/presentation/binding/notifications_binding.dart';
import 'package:express_vet/feature/home-dashboard/notifications/domain/uscase/notifications_usecase.dart';
import '../../domain/uscase/menu_usecase.dart';
import '../uiState/menu_ui_state.dart';

class MenuController extends StateController<MenuUiState>
    with WidgetsBindingObserver {
  static bool _initialized = false;

  final MenuUseCase menuUseCase;

  MenuController(this.menuUseCase);

  late final ConnectivityController connectivityController =
      Get.find<ConnectivityController>();

  @override
  MenuUiState onInitUiState() => const MenuUiState();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadLanguageFromPref();
    OneSignal.Notifications.addForegroundWillDisplayListener((e) {
      debugPrint('Notification Foreground');
    });
    ever(connectivityController.isConnected, (bool connected) {
      if (connected) {
        getNotificationCount();
        _refreshUserStatics();
      }
    });
  }

  Future<void> _refreshUserStatics() async {
    try {
      if (!Get.isRegistered<AuthUseCase>()) {
        AuthBinding().dependencies();
      }
      final data = await Get.find<AuthUseCase>().getUserMe();
      if (data.header?.statusCode == 200 && data.header?.result == true) {
        ValueStatic.username = data.body?.name?.toString() ?? '';
        ValueStatic.phone = data.body?.telephone?.toString() ?? '';
        ValueStatic.email = data.body?.email?.toString() ?? '';
        ValueStatic.gender = data.body?.gender?.toInt() ?? 0;
        ValueStatic.dob = data.body?.dob?.toString() ?? '';
        ValueStatic.nationalityName =
            data.body?.nationalityName?.toString() ?? '';
        ValueStatic.nationalityId = data.body?.nationalityId ?? 0;
      }
    } catch (_) {}
  }

  @override
  void onReady() async {
    super.onReady();

    if (!_initialized) {
      getNotificationCount();
      register();

      try {
        final authController = Get.find<AuthController>();
        () async {
          try {
            await authController.authUseCase.checkToken();
          } catch (_) {}
        }();

        () async {
          try {
            await authController.authUseCase.checkVersion();
          } catch (_) {}
        }();
      } catch (_) {}

      await _refreshUserStatics();

      if (Get.context != null) {
        try {
          await checkVersionUpdate(Get.context!);
        } catch (e) {
          debugPrint('checkVersionUpdate error: $e');
        }
      }

      _initialized = true;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      connectivityController.recheckConnection();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  void _loadLanguageFromPref() {
    final languagePref = AppPref.getLanguage();

    if (languagePref == Constrains.ENGLISH) {
      uiState.value = state.copyWith(language: 'en');
    } else if (languagePref == Constrains.CHINESE) {
      uiState.value = state.copyWith(language: 'zh');
    } else {
      uiState.value = state.copyWith(language: 'km');
    }
  }

  Future<void> updateLanguage(String langCode) async {
    switch (langCode) {
      case 'km':
        Get.updateLocale(const Locale('km', 'KH'));
        await AppPref.setLanguage('km');
        break;
      case 'en':
        Get.updateLocale(const Locale('en', 'US'));
        await AppPref.setLanguage('en');
        break;
      case 'zh':
        Get.updateLocale(const Locale('zh', 'CN'));
        await AppPref.setLanguage('zh');
        break;
    }

    uiState.value = state.copyWith(language: langCode);
  }

  void clearBadge() {
    uiState.value = state.copyWith(badge: 0);
  }

  Future<void> getNotificationCount() async {
    try {
      final data = await menuUseCase.fetchNotificationCount();

      if (data.header?.statusCode == 200 && data.header?.result == true) {
        uiState.value = state.copyWith(
          badge: int.tryParse((data.body?.message).toString()) ?? 0,
        );
      }
    } on TimeoutException catch (e) {
      debugPrint('Timeout loading notification count: $e');
    } on SocketException catch (e) {
      debugPrint('Network error loading notification count: $e');
    } on Exception catch (e) {
      debugPrint('Error loading notification count: $e');
    }
  }

  Future<void> register() async {
    final context = Get.context;
    if (context == null) return;

    final String? deviceId = AppPref.getDeviceId();
    final String deviceType = Platform.isAndroid ? 'Android' : 'IOS';

    debugPrint(
      'OneSignal.User.pushSubscription.id ${OneSignal.User.pushSubscription.id}',
    );

    if ((OneSignal.User.pushSubscription.id).toString().isNotEmpty) {
      if (!Get.isRegistered<NotificationsUseCase>()) {
        NotificationsBinding().dependencies();
      }
      try {
        await Get.find<NotificationsUseCase>().notificationRegister(
          context: context,
          appType: deviceType,
          deviceId: deviceId,
          deviceToken: OneSignal.User.pushSubscription.id,
        );
      } on TimeoutException catch (e) {
        debugPrint('Timeout registering notification device: $e');
      } on SocketException catch (e) {
        debugPrint('Network error registering notification device: $e');
      } on Exception catch (e) {
        debugPrint('Error registering notification device: $e');
      }
    } else {
      Future.delayed(const Duration(seconds: Constrains.timeout15), () {
        register();
      });
    }
  }

  Future<void> openVtenhApp() async {
    const webUrl = 'https://www.vtenh.com/km/';
    const androidPackageName = 'com.vtenh.app.store';
    const iosUrlScheme = 'vtenh://';
    final appUri = Uri.parse(iosUrlScheme);
    final webUri = Uri.parse(webUrl);

    if (Platform.isAndroid) {
      try {
        final installed = await LaunchApp.isAppInstalled(
          androidPackageName: androidPackageName,
        );

        if (installed == true) {
          await LaunchApp.openApp(
            androidPackageName: androidPackageName,
            openStore: false,
          );
          return;
        }
      } catch (e) {
        debugPrint('VTENH app not installed or failed to open by package: $e');
      }
    }

    try {
      final opened = await launchUrl(
        appUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (opened) {
        return;
      }
    } catch (e) {
      debugPrint('VTinh app not installed or failed to open: $e');
    }

    try {
      final openedUniversalLink = await launchUrl(
        webUri,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      if (openedUniversalLink) {
        return;
      }
    } catch (e) {
      debugPrint('VTinh app failed to open by universal link: $e');
    }

    final ok = await canLaunchUrl(webUri);
    if (ok) {
      await launchUrl(webUri, mode: LaunchMode.inAppBrowserView);
      return;
    }

    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(
      Get.context!,
    ).showSnackBar(SnackBar(content: Text('can_not_open'.tr)));
  }

  // ===========

checkVersionUpdate(context) async {
  try {
    final response = await http
        .post(Uri.parse('${BaseUrl.BASE_URL}auth/checkVersion'))
        .timeout(const Duration(seconds: Constrains.timeout30));

    if (response.statusCode == 200) {
      debugPrint('==========> This is response check version ==>>${response.body}');
      final checkVersionResponse = CheckVersionResponse.fromJson(jsonDecode(response.body));
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
          Text('update'.tr, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600)),
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
                        child: Text('No thanks', style: TextStyle(color: Colors.green[700])),
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
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                    ),
                    width: MediaQuery.of(context).size.width / 4,
                    height: 50,
                    child: Center(
                      child: Text('update_now'.tr, style: const TextStyle(color: Colors.white)),
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
          Text('update'.tr, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600)),
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
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
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
