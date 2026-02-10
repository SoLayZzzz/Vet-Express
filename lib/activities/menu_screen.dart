import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:express_vet/activities/china/registration_screen.dart';
import 'package:express_vet/activities/ev/ev_charging_screen.dart';
import 'package:express_vet/activities/screen/vet_airway.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_pref.dart';
import '../base/base_url.dart';
import '../api/notifications.dart';
import '../api/user.dart';
import '../controller/china/china_controller.dart';
import '../controller/connectivity_controller.dart';
import '../feature/auth/presentation/controller/auth_controller.dart';
import '../models/notification/notification_response.dart';
import '../utils/contains.dart';
import 'china/warehouse_address_screen.dart';
import 'components/profile_widget.dart';
import 'screen/resort_screen.dart';
import 'components/slide_widget.dart';
import 'screen/contact_us_screen.dart';
import 'logistic/booking_delivery_screen.dart';
import 'logistic/self_service_screen.dart';
import 'notification_screen.dart';
import 'ticket/package_list_screen.dart';
import 'ticket/rental_car_list_screen.dart';
import 'ticket/value_statics.dart';
import '../routes/app_routes.dart';

class MenuScreen extends StatefulWidget {
  static int badge = 0;

  const MenuScreen({super.key});

  @override
  MenuScreenState createState() => MenuScreenState();
}

class MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  String language = '';
  static bool _initialized = false;
  bool _isMounted = false;

  /// GetX Controller
  final ConnectivityController _connectivityController = Get.put(
    ConnectivityController(),
  );

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    /// Add lifecycle observer to detect app resume
    WidgetsBinding.instance.addObserver(this);

    if (!_initialized) {
      getNotificationCount(context);
      register();
      final authController = Get.find<AuthController>();
      () async {
        try {
          await authController.authUseCase.checkToken();
        } catch (_) {}
      }();
      User().getUserMeStatic(context);
      () async {
        try {
          await authController.authUseCase.checkVersion();
        } catch (_) {}
      }();
      _initialized = true;
    }

    loadLanguage();

    OneSignal.Notifications.addForegroundWillDisplayListener((e) {
      log("Notification Foreground");
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /// When app resumes from background, recheck connection
    if (state == AppLifecycleState.resumed) {
      _connectivityController.recheckConnection();
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Safe setState method that checks if widget is still mounted
  void _safeSetState(VoidCallback fn) {
    if (_isMounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildBody());
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0.2,
      centerTitle: false,
      backgroundColor: AppColors.primaryColor,
      actions: _buildAppBarActions(),
      leading: _buildAppBarLeading(),
      leadingWidth: MediaQuery.of(context).size.width * 0.5,
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      _buildLanguageButton(),
      _buildContactButton(),
      _buildNotificationButton(),
      const SizedBox(width: 4),
    ];
  }

  Widget _buildAppBarLeading() {
    return Builder(
      builder: (BuildContext context) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 15),
            Image.asset("assets/images/vet_logo.png", height: 36, width: 36),
            const SizedBox(width: 10),
            const Text(
              'VET Express',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontSize: 20,
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  // ==================== BODY ====================
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileWidget(),
            _buildMainServicesGrid(),
            _buildOtherServicesSection(),
            _buildAccommodationSection(),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  // ==================== MAIN SERVICES GRID ====================
  Widget _buildMainServicesGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              children: [
                _buildMenuView(
                  'assets/images/ic_booking_bus_new.png',
                  'booking_bus'.tr,
                  () {
                    _navigateToBusBooking();
                  },
                ),
                _buildMenuView(
                  'assets/images/ic_booking_air_bus_new.png',
                  'booking_air_bus'.tr,
                  () => _navigateToAirBusBooking(),
                ),
                _buildMenuView(
                  'assets/images/ic_booking_boat_new.png',
                  'booking_boat'.tr,
                  () {
                    _navigateToBoatBooking();
                  },
                ),
                _buildMenuView('assets/icons/icon_ev.png', 'ev_charger'.tr, () {
                  _navigateToEvCharger();
                }),
                _buildMenuView(
                  'assets/images/ic_rental_car.png',
                  'car_rental'.tr,
                  () async {
                    await _navigateToCarRental();
                  },
                ),
                _buildMenuView(
                  'assets/images/ic_v_tenh.png',
                  'v_tinh'.tr,
                  () => _launch('https://www.vtenh.com/km/'),
                ),
                // _buildMenuView(
                //   'assets/images/ic_travel_package.png',
                //   'booking_travel_package'.tr,
                //   () => _navigateToTravelPackage(),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== OTHER SERVICES SECTION ====================
  Widget _buildOtherServicesSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Text(
              'other_service'.tr,
              style: const TextStyle(
                color: AppColors.titleColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildOtherServicesList(),
        ],
      ),
    );
  }

  Widget _buildOtherServicesList() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Row(
          children: [
            _buildServiceView(
              'assets/images/ic_add_goods.png',
              'self_service'.tr,
              () {
                _navigateToSelfService();
              },
            ),
            _buildServiceView(
              'assets/images/ic_booking_moto.png',
              'booking_delivery'.tr,
              () => _navigateToBookingDelivery(),
            ),
            _buildServiceView(
              'assets/icons/icon_address_china.jpg',
              'access_address_china'.tr,
              () => _navigateToAccessChina(),
            ),
            _buildServiceView(
              'assets/images/ic_travel_package.png',
              'booking_travel_package'.tr,
              () => _navigateToTravelPackage(),
            ),
            _buildServiceView(
              'assets/icons/icon_vet_airway.png',
              'vet_airway'.tr,
              () {
                _navigateToVetAirway();
              },
            ),
            // _buildServiceView('assets/images/ic_v_tenh.png', 'v_tinh'.tr, () async {
            //   await _launch('https://www.vtenh.com/km/');
            // }),
            _buildServiceView(
              'assets/images/ic_vpsar.png',
              'v_phsar'.tr,
              () async {
                await _launch('https://www.facebook.com/VPhsarCambodia');
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ACCOMMODATION SECTION ====================
  Widget _buildAccommodationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            'accommodation'.tr,
            style: const TextStyle(
              color: AppColors.titleColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ResortScreen(),
      ],
    );
  }

  // ==================== NEWS SECTION ====================
  Widget _buildNewsSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
            child: Text(
              'news'.tr,
              style: const TextStyle(
                color: AppColors.titleColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          SlideWidget(),
        ],
      ),
    );
  }

  // ==================== UI COMPONENTS ====================
  Widget _buildLanguageButton() {
    return IconButton(
      onPressed: _showLanguageBottomSheet,
      icon: Image.asset(
        language == "km"
            ? "assets/images/ic_cambodia.png"
            : language == "en"
            ? "assets/images/ic_english.png"
            : "assets/images/ic_chinese.png",
        height: 24,
      ),
    );
  }

  Widget _buildContactButton() {
    return IconButton(
      onPressed: () {
        Get.to(
          () => const ContactUsScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: Constrains.duration),
        );
      },
      icon: Image.asset(
        "assets/icons/icon_contact.png",
        color: AppColors.whiteColor,
        height: 24,
      ),
    );
  }

  Widget _buildNotificationButton() {
    return MenuScreen.badge != 0
        ? IconButton(
          icon: Badge.count(
            count: MenuScreen.badge.toInt(),
            textColor: AppColors.whiteColor,
            backgroundColor: AppColors.redColor,
            textStyle: const TextStyle(fontSize: 14),
            child: Image.asset(
              "assets/images/ic_notification.png",
              color: AppColors.whiteColor,
              width: 24,
              height: 24,
            ),
          ),
          onPressed: _navigateToNotifications,
        )
        : IconButton(
          icon: Image.asset(
            "assets/images/ic_notification.png",
            color: AppColors.whiteColor,
            width: 24,
            height: 24,
          ),
          onPressed: _navigateToNotifications,
        );
  }

  Widget _buildMenuView(String path, String title, VoidCallback onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(path),
              height: MediaQuery.of(context).size.width / 6.5,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 33,
                color: AppColors.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceView(String img, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(width: 0.2, color: AppColors.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(img, height: 36),
                const SizedBox(width: 5),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width / 32,
                    color: AppColors.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== NAVIGATION METHODS ====================
  void _navigateToBusBooking() {
    ValueStatic().clearDataTicket();
    ValueStatic.ticketType = "1";
    Get.toNamed(
      AppRoutes.ticketMenu,
      arguments: {'type': 1, 'appBarTitle': 'booking_bus_new'.tr},
    );
  }

  void _navigateToAirBusBooking() async {
    ValueStatic().clearDataTicket();
    ValueStatic.ticketType = "3";

    var result = await Get.toNamed(
      AppRoutes.ticketMenu,
      arguments: {'type': 3, 'appBarTitle': 'booking_air_bus1'.tr},
    );
    if (result == null) {
      ValueStatic.ticketType = "0";
    }
  }

  void _navigateToBoatBooking() {
    ValueStatic().clearDataTicket();
    ValueStatic.ticketType = "2";

    Get.toNamed(
      AppRoutes.ticketMenu,
      arguments: {'type': 2, 'appBarTitle': 'booking_boat_new'.tr},
    );
  }

  void _navigateToEvCharger() {
    Get.to(
      //() => const EvCharger(),
      () => EvChargerScreen(), //!new version
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }

  Future<void> _navigateToCarRental() async {
    await Get.to(
      () => RentalCarListScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }

  void _navigateToTravelPackage() async {
    Get.to(
      () => const PackageListScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }

  void _navigateToSelfService() {
    ValueStatic().clearSelfService();
    Get.to(
      () => const SelfServiceScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }

  void _navigateToBookingDelivery() {
    Get.to(
      () => const BookingDeliveryScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }

  void _navigateToAccessChina() async {
    // Check if user has existing customer data
    final ChinaController controller = Get.put(ChinaController());

    // Ensure customer list is loaded
    await controller.fetchCustomerList();

    if (controller.hasCustomers) {
      // User has existing customers, go directly to warehouse
      Get.to(
        () => WarehouseAddressScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: Constrains.duration),
      );
    } else {
      // No customers, go to registration
      Get.to(
        () => ChinaRegistrationScreen(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: Constrains.duration),
      );
    }
  }

  void _navigateToVetAirway() {
    Get.to(
      () => const VetAirway(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }

  /* void _navigateToWebView() {
    Get.to(
      () => const WebViewScreen(type: 2, ticketId: ''),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
  }*/

  void _navigateToNotifications() async {
    var result = await Get.to(
      () => const NotificationScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: Constrains.duration),
    );
    if (result == 'set') {
      _safeSetState(() {});
    }
  }

  // ==================== LANGUAGE METHODS ====================
  void _showLanguageBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildLanguageSelectionSheet();
      },
    );
  }

  Widget _buildLanguageSelectionSheet() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                _buildLanguageSheetHeader(),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLanguageOption(
                          'km',
                          'assets/images/ic_cambodia.png',
                          'ភាសាខ្មែរ',
                        ),
                        const Divider(height: 1),
                        _buildLanguageOption(
                          'en',
                          'assets/images/ic_english.png',
                          'English',
                        ),
                        const Divider(height: 1),
                        _buildLanguageOption(
                          'zh',
                          'assets/images/ic_chinese.png',
                          '中文',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 1,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close, color: Colors.grey, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSheetHeader() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 5,
            width: MediaQuery.sizeOf(context).width * 0.25,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'change_lang'.tr,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String langCode,
    String flagAsset,
    String languageName,
  ) {
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        await _updateLanguage(langCode);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Image.asset(flagAsset, width: 30, height: 30),
            const SizedBox(width: 20),
            Text(
              languageName,
              style: const TextStyle(fontSize: 16, color: AppColors.textColor),
            ),
            const Spacer(),
            if (language == langCode)
              Image.asset(
                "assets/images/ic_check_mark.png",
                width: 30,
                height: 30,
              ),
          ],
        ),
      ),
    );
  }

  // ==================== UTILITY METHODS ====================
  Future<void> _updateLanguage(String langCode) async {
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
    _safeSetState(() {
      language = langCode;
    });
  }

  void loadLanguage() {
    final languagePref = AppPref.getLanguage();

    if (languagePref == Constrains.ENGLISH) {
      _safeSetState(() {
        language = 'en';
      });
    } else if (languagePref == Constrains.CHINESE) {
      _safeSetState(() {
        language = 'zh';
      });
    } else {
      _safeSetState(() {
        language = 'km';
      });
    }
  }

  Future<void> _launch(url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text('can_not_open'.tr)));
    }
  }

  Future<void> register() async {
    String? deviceId = AppPref.getDeviceId();
    String deviceType = Platform.isAndroid ? 'Android' : 'IOS';

    log(
      'OneSignal.User.pushSubscription.id ${OneSignal.User.pushSubscription.id}',
    );

    if ((OneSignal.User.pushSubscription.id).toString().isNotEmpty) {
      log('Is Not Empty');
      Notifications().notificationRegister(
        context,
        deviceType,
        deviceId,
        OneSignal.User.pushSubscription.id,
      );
    } else {
      Future.delayed(const Duration(seconds: Constrains.timeout15), () {
        log('Is Empty');
        register();
      });
    }
  }

  Future<void> getNotificationCount(BuildContext context) async {
    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}notification/count-unread'),
            headers: <String, String>{
              "Content-type": "application/json",
              'Authorization': AppPref.getToken() ?? '',
            },
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        log('This is response getNotificationCount ==>>${response.body}');
        var data = NotificationResponse.fromJson(jsonDecode(response.body));

        if (data.header?.statusCode == 200 && data.header?.result == true) {
          _safeSetState(() {
            MenuScreen.badge = int.parse((data.body?.message).toString());
          });
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
}
