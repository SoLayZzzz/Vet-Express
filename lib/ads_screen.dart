import 'dart:developer';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/controller/user_controller.dart';
import 'package:express_vet/feature/auth/data/model/request/refreshToken_login_request.dart';
import 'package:express_vet/feature/auth/domain/uscase/auth_usecase.dart';
import 'package:express_vet/feature/auth/presentation/binding/auth_binding.dart';
import 'utils/app_colors.dart';
import 'utils/app_pref.dart';
import 'utils/cached_disk_image.dart';
import 'utils/contains.dart';
import 'utils/image_cache_service.dart';

class AdsScreen extends StatefulWidget {
  final List<String> images;

  const AdsScreen({super.key, required this.images});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int activeIndex = 0;
  bool _shouldAutoNavigate = true;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    log("🎯 AdsScreen initialized with ${widget.images.length} images");

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();

    // Combine both operations in one post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        loadLanguage(); // Move here to avoid build conflict
        await ImageCacheService.precacheToMemory(
          widget.images.take(3).toList(),
          context,
        );
      }
    });

    if (widget.images.isEmpty) {
      log("🖼️ No ads images available, skipping immediately");
      Future.delayed(Duration.zero, () {
        if (mounted) {
          _navigateBasedOnLoginStatus();
        }
      });
      return;
    }

    _shouldAutoNavigate = true;
    Future.delayed(const Duration(milliseconds: 6000), () {
      if (mounted && _shouldAutoNavigate) {
        log("⏰ Auto-navigation triggered after 6 seconds");
        _navigateBasedOnLoginStatus();
      }
    });
  }

  /// Navigate based on login status (called after ads finish)
  Future<void> _navigateBasedOnLoginStatus() async {
    if (_hasNavigated) return;
    _hasNavigated = true;
    _shouldAutoNavigate = false;

    // Use AppPref instead of direct SharedPreferences
    final isLoggedIn = AppPref.isLoggedIn();

    log("🔐 Navigation check - isLoggedIn: $isLoggedIn");

    if (!mounted) return;

    if (isLoggedIn) {
      final ok = await _ensureValidSession();
      if (!mounted) return;
      if (ok) {
        log("➡️ Navigating to HomeScreen");
        Get.offAllNamed(AppRoutes.home);
      } else {
        log("➡️ Navigating to SignInScreen");
        Get.offAllNamed(AppRoutes.signIn);
      }
      return;
    }

    log("➡️ Navigating to SignInScreen");
    Get.offAllNamed(AppRoutes.signIn);
  }

  Future<bool> _ensureValidSession() async {
    final refreshToken = AppPref.getRefreshToken();
    final deviceId = AppPref.getDeviceId() ?? 'VET_Express_DeviceID';

    if (refreshToken == null || refreshToken.isEmpty) {
      await AppPref.clearAllData();
      try {
        Get.find<UserController>().clearUserData();
      } catch (_) {}
      return false;
    }

    try {
      if (!Get.isRegistered<AuthUseCase>()) {
        AuthBinding().dependencies();
      }
      final auth = Get.find<AuthUseCase>();
      final check = await auth.checkToken();
      if (check.header.result == true && check.header.statusCode == 200) {
        final me = await auth.getUserMe();
        if (me.header?.result == true && me.header?.statusCode == 200) {
          return true;
        }
      }
    } catch (_) {}

    try {
      if (!Get.isRegistered<AuthUseCase>()) {
        AuthBinding().dependencies();
      }
      final auth = Get.find<AuthUseCase>();
      final resp = await auth.loginWithRefreshToken(
        RefreshtokenLoginRequest(deviceId: deviceId, refreshToken: refreshToken),
      );

      final tokenType = resp.body?.tokenType;
      final newAccess = resp.body?.accessToken;
      final newRefresh = resp.body?.refreshToken;

      if (tokenType != null && newAccess != null) {
        await AppPref.setToken('$tokenType $newAccess');
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await AppPref.setRefreshToken(newRefresh);
        }

        final me = await auth.getUserMe();
        if (me.header?.result == true && me.header?.statusCode == 200) {
          return true;
        }
      }
    } catch (_) {}

    await AppPref.clearAllData();
    try {
      Get.find<UserController>().clearUserData();
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Show ads carousel (for ALL users)
    return _buildAdsCarousel(size);
  }

  /// Ads carousel
  Widget _buildAdsCarousel(Size size) {
    final reversedImages = widget.images.reversed.toList();

    return Scaffold(
      body: Container(
        color: AppColors.backgroundColor,
        child: Stack(
          children: [
            // Carousel for multiple images
            if (widget.images.length == 1)
              SizedBox(
                width: size.width,
                height: size.height,
                child: CachedDiskImage(
                  imageUrl: widget.images.first,
                  fit: BoxFit.fill,
                ),
              )
            else
              CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  pauseAutoPlayOnTouch: true,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  height: size.height,
                  onPageChanged: (index, reason) {
                    setState(() {
                      activeIndex = index;
                    });
                  },
                ),
                items:
                    reversedImages
                        .map(
                          (item) => SizedBox(
                            width: size.width,
                            height: size.height,
                            child: CachedDiskImage(
                              imageUrl: item,
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                        .toList(),
              ),

            // Controls overlay wrapped in SafeArea
            SafeArea(
              child: Stack(
                children: [
                  // Page indicator (only show if we have multiple images)
                  if (widget.images.length > 1)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: AnimatedSmoothIndicator(
                              activeIndex: activeIndex,
                              count: reversedImages.length,
                              effect: const ExpandingDotsEffect(
                                activeDotColor: AppColors.primaryColor,
                                dotHeight: 9,
                                dotWidth: 9,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Countdown + Skip
                  Positioned(
                    right: 10,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Countdown Timer
                        Container(
                          width: 45,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: TweenAnimationBuilder<Duration>(
                              duration: const Duration(milliseconds: 6000),
                              tween: Tween(
                                begin: const Duration(seconds: 6),
                                end: const Duration(seconds: 0),
                              ),
                              onEnd: () {
                                if (mounted && _shouldAutoNavigate) {
                                  _navigateBasedOnLoginStatus();
                                }
                              },
                              builder: (_, Duration value, __) {
                                final seconds = value.inSeconds;
                                return Text(
                                  '$seconds',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Skip Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            side: const BorderSide(color: AppColors.whiteColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          onPressed: () {
                            log("👆 Skip button pressed");
                            _shouldAutoNavigate = false;
                            _navigateBasedOnLoginStatus();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 24,
                            ),
                            child: Text(
                              "skip".tr,
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.whiteColor,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  void loadLanguage() {
    final language = AppPref.getLanguage();
    if (language == Constrains.ENGLISH) {
      Get.updateLocale(const Locale('en', 'US'));
    } else if (language == Constrains.CHINESE) {
      Get.updateLocale(const Locale('zh', 'CN'));
    } else {
      Get.updateLocale(const Locale('km', 'KH'));
    }
  }

  @override
  void dispose() {
    _shouldAutoNavigate = false;
    _controller.dispose();
    super.dispose();
  }
}
