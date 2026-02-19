import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../api/notifications.dart';
import '../../../../api/user.dart';
import '../../../../base/state_controller.dart';
import '../../../../controller/connectivity_controller.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../../utils/app_pref.dart';
import '../../../../utils/contains.dart';
import '../../domain/uscase/menu_usecase.dart';
import '../uiState/menu_ui_state.dart';

class MenuController extends StateController<MenuUiState>
    with WidgetsBindingObserver {
  static bool _initialized = false;

  final MenuUseCase menuUseCase;

  MenuController(this.menuUseCase);

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
      final data = await menuUseCase.fetchNotificationCount();

      if (data.header?.statusCode == 200 && data.header?.result == true) {
        uiState.value = state.copyWith(
          badge: int.tryParse((data.body?.message).toString()) ?? 0,
        );
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
        log('VTENH app not installed or failed to open by package: $e');
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
      log('VTinh app not installed or failed to open: $e');
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
      log('VTinh app failed to open by universal link: $e');
    }

    final ok = await canLaunchUrl(webUri);
    if (ok) {
      await launchUrl(webUri, mode: LaunchMode.inAppBrowserView);
      return;
    }

    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('can_not_open'.tr)));
  }
}
