import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../../../api/notifications.dart';
import '../../../api/user.dart';
import '../../../base/base_url.dart';
import '../../../base/state_controller.dart';
import '../../../controller/connectivity_controller.dart';
import '../../../feature/auth/presentation/controller/auth_controller.dart';
import '../../../models/notification/notification_response.dart';
import '../../../utils/app_pref.dart';
import '../../../utils/contains.dart';
import '../presentation/uiState/menu_ui_state.dart';

class MenuController extends StateController<MenuUiState>
    with WidgetsBindingObserver {
  static bool _initialized = false;

  late final ConnectivityController connectivityController =
      Get.isRegistered<ConnectivityController>()
          ? Get.find<ConnectivityController>()
          : Get.put(ConnectivityController());

  @override
  MenuUiState onInitUiState() => const MenuUiState();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadLanguageFromPref();
    OneSignal.Notifications.addForegroundWillDisplayListener((e) {
      log('Notification Foreground');
    });
  }

  @override
  void onReady() {
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

      final context = Get.context;
      if (context != null) {
        User().getUserMeStatic(context);
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
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}notification/count-unread'),
            headers: <String, String>{
              'Content-type': 'application/json',
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response getNotificationCount ==>>${response.body}');
        final data = NotificationResponse.fromJson(jsonDecode(response.body));

        if (data.header?.statusCode == 200 && data.header?.result == true) {
          uiState.value = state.copyWith(
            badge: int.parse((data.body?.message).toString()),
          );
        }
      } else {
        log('Failed to load notification count: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      log('Timeout loading notification count: $e');
    } on SocketException catch (e) {
      log('Network error loading notification count: $e');
    } on Exception catch (e) {
      log('Error loading notification count: $e');
    }
  }

  Future<void> register() async {
    final context = Get.context;
    if (context == null) return;

    final String? deviceId = AppPref.getDeviceId();
    final String deviceType = Platform.isAndroid ? 'Android' : 'IOS';

    log(
      'OneSignal.User.pushSubscription.id ${OneSignal.User.pushSubscription.id}',
    );

    if ((OneSignal.User.pushSubscription.id).toString().isNotEmpty) {
      Notifications().notificationRegister(
        context,
        deviceType,
        deviceId,
        OneSignal.User.pushSubscription.id,
      );
    } else {
      Future.delayed(const Duration(seconds: Constrains.timeout15), () {
        register();
      });
    }
  }

  Future<void> openVtenhApp() async {
    try {
      if (Platform.isIOS) {
        const appStoreLink =
            'itms-apps://apps.apple.com/us/app/vtenh-shop-easy/id1548621235';

        // Try opening the VTENH app
        final isInstalled = await LaunchApp.isAppInstalled(
          iosUrlScheme: 'vtenh://',
        );
        final result = isInstalled ? 1 : 0;

        if (result == 1) {
          await LaunchApp.openApp(
            iosUrlScheme: 'vtenh://', // must match VTENH app scheme
            appStoreLink: appStoreLink,
            openStore: false, // don't open store yet
          );
          return; // app opened successfully
        }

        // App not installed → open App Store
        await LaunchApp.openApp(
          iosUrlScheme: 'vtenh://',
          appStoreLink: appStoreLink,
          openStore: true,
        );
      } else {
        const playStoreLink = 'market://details?id=com.vtenh.app.store';

        // Try opening Android app
        final isInstalled = await LaunchApp.isAppInstalled(
          androidPackageName: 'com.vtenh.app.store',
        );
        final result = isInstalled ? 1 : 0;

        if (result == 1) {
          await LaunchApp.openApp(
            androidPackageName: 'com.vtenh.app.store',
            appStoreLink: playStoreLink,
            openStore: false,
          );
          return; // app opened successfully
        }

        // App not installed → open Play Store
        await LaunchApp.openApp(
          androidPackageName: 'com.vtenh.app.store',
          appStoreLink: playStoreLink,
          openStore: true,
        );
      }
    } catch (e) {
      log('Error launching VTENH app: $e');

      // Fallback: open store if something fails
      if (Platform.isIOS) {
        await LaunchApp.openApp(
          iosUrlScheme: 'vtenh://',
          appStoreLink:
              'itms-apps://apps.apple.com/us/app/vtenh-shop-easy/id1548621235',
          openStore: true,
        );
      } else {
        await LaunchApp.openApp(
          androidPackageName: 'com.vtenh.app.store',
          appStoreLink: 'market://details?id=com.vtenh.app.store',
          openStore: true,
        );
      }
    }
  }
}
