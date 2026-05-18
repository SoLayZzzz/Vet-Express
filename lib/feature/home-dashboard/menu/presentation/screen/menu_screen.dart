import 'dart:async';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/home-dashboard/china-service/presentation/controller/china_controller.dart';
import 'package:express_vet/feature/home-dashboard/china-service/presentation/bindding/china_service_binding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:express_vet/feature/home-dashboard/menu/presentation/binding/menu_binding.dart';
import 'package:express_vet/feature/home-dashboard/menu/presentation/controller/menu_controller.dart'
    as menu;
import '../../../../../../utils/app_colors.dart';
import '../../../profile/presentaion/ui/profile_widget.dart';
import '../../../resort/resort_screen.dart';
import '../../../../../components/slide_widget.dart';
import '../../../../../value_statics.dart';
import '../../../../../routes/app_routes.dart';

class MenuScreen extends GetView<menu.MenuController> {
  const MenuScreen({super.key});

  void _ensureDependencies() {
    MenuBinding().dependencies();
  }

  @override
  Widget build(BuildContext context) {
    _ensureDependencies();
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  // ==================== APP BAR ====================
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0.2,
      centerTitle: false,
      backgroundColor: AppColors.primaryColor,
      actions: _buildAppBarActions(context),
      leading: _buildAppBarLeading(context),
      leadingWidth: MediaQuery.of(context).size.width * 0.5,
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      _buildLanguageButton(context),
      _buildContactButton(),
      _buildNotificationButton(),
      const SizedBox(width: 4),
    ];
  }

  Widget _buildAppBarLeading(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 15),
            Image.asset(AssetImages.vet_logo, height: 36, width: 36),
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
  Widget _buildBody(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileWidget(),
            _buildMainServicesGrid(context),
            _buildOtherServicesSection(),
            _buildAccommodationSection(),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  // ==================== MAIN SERVICES GRID ====================
  Widget _buildMainServicesGrid(BuildContext context) {
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
                _buildMenuView(AssetImages.booking_bus, 'booking_bus'.tr, () {
                  _navigateToBusBooking();
                }),
                _buildMenuView(
                  AssetImages.booking_air_bus,
                  'booking_air_bus'.tr,
                  () => _navigateToAirBusBooking(),
                ),
                _buildMenuView(AssetImages.booking_boat, 'booking_boat'.tr, () {
                  _navigateToBoatBooking();
                }),
                _buildMenuView(AssetImages.ev_charger, 'ev_charger'.tr, () {
                  Get.toNamed(AppRoutes.evCharger);
                }),
                _buildMenuView(
                  AssetImages.rental_car,
                  'car_rental'.tr,
                  () async {
                    await Get.toNamed(AppRoutes.carRentalList);
                  },
                ),
                _buildMenuView(
                  AssetImages.vtinh_logo,
                  'v_tinh'.tr,
                  () => controller.openVtenhApp(),
                ),
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
            _buildServiceView(AssetImages.self_service, 'self_service'.tr, () {
              _navigateToSelfService();
            }),
            _buildServiceView(
              AssetImages.booking_moto,
              'booking_delivery'.tr,

              () => Get.toNamed(AppRoutes.bookingDelivery),
            ),
            _buildServiceView(
              AssetImages.access_china,
              'access_address_china'.tr,
              () => _navigateToAccessChina(),
            ),
            _buildServiceView(
              AssetImages.travel_package,
              'booking_travel_package'.tr,
              () => Get.toNamed(AppRoutes.travelPackageList),
            ),
            _buildServiceView(AssetImages.vet_airway, 'vet_airway'.tr, () {
              Get.toNamed(AppRoutes.vetAirway);
            }),
            // _buildServiceView('assets/images/ic_v_tenh.png', 'v_tinh'.tr, () async {
            //   await _launch('https://www.vtenh.com/km/');
            // }),
            _buildServiceView(AssetImages.vpsar, 'v_phsar'.tr, () async {
              await _launch('https://www.facebook.com/VPhsarCambodia');
            }),
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
  Widget _buildLanguageButton(BuildContext context) {
    return Obx(() {
      final language = controller.state.language;
      return IconButton(
        onPressed: () => _showLanguageBottomSheet(context),
        icon: Image.asset(
          language == "km"
              ? AssetImages.cambodia
              : language == "en"
              ? AssetImages.english
              : AssetImages.china,
          height: 24,
        ),
      );
    });
  }

  Widget _buildContactButton() {
    return IconButton(
      onPressed: () {
        Get.toNamed(AppRoutes.contactUs);
      },
      icon: Image.asset(
        AssetImages.contact,
        color: AppColors.whiteColor,
        height: 24,
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Obx(() {
      final badge = controller.state.badge;
      return badge != 0
          ? IconButton(
            icon: Badge.count(
              count: badge.toInt(),
              textColor: AppColors.whiteColor,
              backgroundColor: AppColors.redColor,
              textStyle: const TextStyle(fontSize: 14),
              child: Image.asset(
                AssetImages.notification,
                color: AppColors.whiteColor,
                width: 24,
                height: 24,
              ),
            ),
            onPressed: _navigateToNotifications,
          )
          : IconButton(
            icon: Image.asset(
              AssetImages.notification,
              color: AppColors.whiteColor,
              width: 24,
              height: 24,
            ),
            onPressed: _navigateToNotifications,
          );
    });
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
              height: MediaQuery.of(Get.context!).size.width / 6.5,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(Get.context!).size.width / 33,
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
                    fontSize: MediaQuery.of(Get.context!).size.width / 32,
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

  void _navigateToSelfService() {
    ValueStatic().clearSelfService();
    Get.toNamed(AppRoutes.selfService);
  }

  void _navigateToAccessChina() async {
    ChinaServiceBinding().dependencies();
    final ChinaController controller = Get.find<ChinaController>();

    await controller.fetchCustomerList();

    if (controller.hasCustomers) {
      Get.toNamed(AppRoutes.warehouseAddress);
    } else {
      Get.toNamed(AppRoutes.chinaRegistration);
    }
  }

  void _navigateToNotifications() async {
    var result = await Get.toNamed(AppRoutes.notifications);
    if (result == 'set') {
      controller.getNotificationCount();
    }
  }

  // ==================== LANGUAGE METHODS ====================
  void _showLanguageBottomSheet(BuildContext context) {
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
                          AssetImages.cambodia,
                          'ភាសាខ្មែរ',
                        ),
                        const Divider(height: 1),
                        _buildLanguageOption(
                          'en',
                          AssetImages.english,
                          'English',
                        ),
                        const Divider(height: 1),
                        _buildLanguageOption('zh', AssetImages.china, '中文'),
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
                Get.back();
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
            width: MediaQuery.sizeOf(Get.context!).width * 0.25,
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
        Get.back();
        await controller.updateLanguage(langCode);
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
            Obx(() {
              final language = controller.state.language;
              if (language != langCode) return const SizedBox.shrink();
              return Image.asset(AssetImages.check_mark, width: 30, height: 30);
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(url) async {
    final uri = Uri.tryParse(url.toString());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text('can_not_open'.tr)));
      return;
    }

    await Get.to(
      () => InAppWebViewScreen(
        initialUrl: uri.toString(),
        title: uri.host,
      ),
    );
  }
}

class InAppWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String? title;

  const InAppWebViewScreen({
    super.key,
    required this.initialUrl,
    this.title,
  });

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;
            if (uri.scheme != 'http' && uri.scheme != 'https') {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _handleSystemBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleSystemBack();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Get.back();
          },
        ),
          title: Text('VPsar'),
        ),
        body: WebViewWidget(controller: _controller),
      ),
    );
  }
}
