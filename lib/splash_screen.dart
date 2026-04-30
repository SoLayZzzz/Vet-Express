import 'dart:convert';
import 'dart:developer';
import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'base/base_url.dart';
import 'api/slide_show.dart';
import 'feature/auth/data/model/response/check_version_response.dart';
import 'models/slide_show/slide_show_response.dart';
import 'utils/app_pref.dart';
import 'utils/alert_dialog.dart';
import 'utils/contains.dart';
import 'utils/image_cache_service.dart';
import 'ads_screen.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  bool _apiCallCompleted = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _initializeDeviceInfo();
    await checkVersionUpdate(Get.context!);

    if (!mounted || _apiCallCompleted) return;

    await _loadData();
  }

  void _navigateToMenuWithTimeoutDialog() {
    if (!mounted || _apiCallCompleted) return;

    _apiCallCompleted = true;
    setState(() => _isLoading = false);

    Get.offAllNamed(AppRoutes.home);
    Future.delayed(Duration.zero, () {
      if (Get.isDialogOpen == true) return;
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
    });
  }

  /// Device info
  Future<void> _initializeDeviceInfo() async {
    String? cachedDeviceId = AppPref.getDeviceId();
    String? cachedDeviceName = AppPref.getDeviceName();

    if (cachedDeviceId != null && cachedDeviceName != null) return;

    Map<String, String> deviceInfo = await _getDeviceInfo();
    await AppPref.setDeviceInfo(
      deviceInfo['deviceId']!,
      deviceInfo['deviceName']!,
    );
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    String? deviceId = '';
    String? deviceName = '';

    try {
      if (Platform.isAndroid) {
        deviceId = Uuid().v4();
        deviceName = 'VET_isAndroid';
      } else if (Platform.isIOS) {
        deviceId = Uuid().v4();
        deviceName = 'VET_isIOS';
      }
    } catch (e) {
      deviceId = 'unknown';
      deviceName = 'unknown';
    }

    log("deviceId $deviceId");
    log("deviceName $deviceName");

    return {'deviceId': deviceId, 'deviceName': deviceName};
  }

  /// Version check + cache invalidation
  Future<void> checkVersionUpdate(BuildContext context) async {
    final box = Hive.box('cacheBox');
    try {
      final response = await http
          .post(Uri.parse('${BaseUrl.BASE_URL}auth/checkVersion'))
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        final checkVersionResponse = CheckVersionResponse.fromJson(
          jsonDecode(response.body),
        );
        if (checkVersionResponse.body?.cache != null) {
          for (int i = 0; i < checkVersionResponse.body!.cache!.length; i++) {
            final serverModified =
                checkVersionResponse.body!.cache![i].modified!.toInt();
            final localKey =
                [
                  'modifiedResort',
                  'modifiedSlideShow',
                  'modifiedSlideBus',
                  'modifiedSlideBoat',
                  'modifiedAds',
                ][i];
            int localModified = box.get(localKey, defaultValue: 0);
            if (localModified < serverModified) {
              final cacheKeys =
                  [
                    'resortList',
                    'slideShow',
                    'slideBus',
                    'slideBoat',
                    'slideAds',
                  ][i];
              await box.delete(cacheKeys);
              await ImageCacheService.clearImageCache(
                cacheKeys,
              ); 
            }
          }
        }
      }
    } on TimeoutException {
      _navigateToMenuWithTimeoutDialog();
      return;
    } catch (e) {
      log("Version check error: ${e.toString()}");
    }
  }

  /// Smart caching with Telegram-style logic
  Future<void> _loadData() async {
    final box = Hive.box('cacheBox');

    // STEP 1: Check if we have cached ads
    List<String>? cachedAds = box.get('slideAds')?.cast<String>();

    if (cachedAds != null && cachedAds.isNotEmpty) {
      // WE HAVE CACHE: Precache to disk and memory first, then show
      log("✅ Using cached ads data (${cachedAds.length} images)");
      await ImageCacheService.preCacheAllImages(cachedAds);
      await ImageCacheService.precacheToMemory(cachedAds, context);
      _navigateToAdsScreen(cachedAds);
    } else {
      // NO CACHE: Fetch from server with timeout protection
      log("🔄 No cache found, fetching from server");
      await _fetchAdsFromServerWithTimeout();
    }
  }

  /// Fetch ads with timeout protection
  Future<void> _fetchAdsFromServerWithTimeout() async {
    try {
      await _fetchAdsFromServer().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log("⏰ API timeout - proceeding with empty ads");
          _navigateToMenuWithTimeoutDialog();
        },
      );
    } on TimeoutException {
      log("⏰ API timeout - proceeding to menu");
      _navigateToMenuWithTimeoutDialog();
    } catch (e) {
      log("❌ API error: $e - proceeding with empty ads");
      _navigateToAdsScreen([]);
    }
  }

  /// Fetch ads from server and cache
  Future<void> _fetchAdsFromServer() async {
    final box = Hive.box('cacheBox');

    log("🌐 Fetching ads from server...");

    SlideShowResponse data = await SlideShow().slideShowAds(context, 1, 100);
    if (data.header?.statusCode == 200 &&
        data.header?.result == true &&
        (data.body?.data?.isNotEmpty ?? false)) {
      List<String> ads =
          data.body!.data!
              .map((item) => BaseUrl.BASE_URL_SLIDE_IMAGE + (item.image ?? ''))
              .toList();

      await box.put('slideAds', ads);
      await box.put(
        'modifiedAds',
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
      );
      await ImageCacheService.preCacheAllImages(ads);
      await ImageCacheService.precacheToMemory(ads, context);

      log("✅ Server data fetched and cached successfully");
      _navigateToAdsScreen(ads);
    } else {
      log("⚠️ Server responded but no ads data");
      _navigateToAdsScreen([]);
    }
  }

  /// Navigate to AdsScreen
  void _navigateToAdsScreen(List<String> images) {
    if (!mounted || _apiCallCompleted) return;

    _apiCallCompleted = true;
    setState(() => _isLoading = false);

    log("🎯 Navigating to AdsScreen with ${images.length} images");

    Get.off(
      () => AdsScreen(images: images),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFD7A23), Color(0xFFDE5D0A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    AssetImages.vet_logo,
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "VET Express",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
