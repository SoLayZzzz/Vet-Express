import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/base/endpoint.dart';
import 'package:express_vet/components/skeleton.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/value_statics.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../controller/ev_charger_controller.dart';
import '../controller/ev_station_controller.dart';
import '../controller/ev_wallet_controller.dart';
import '../../data/model/response/ev_station_list_response.dart';
import '../../../../../utils/app_colors.dart';

import 'ev_detailStation_sheet.dart';
import 'ev_new_feed_screen.dart';

class EvChargerScreen extends GetView<EvChargerController> {
  EvChargerScreen({super.key});

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  final ValueNotifier<double> _currentCarouselPage =
      ValueNotifier<double>(0.0);

  late final Future<Uint8List?> _carChargingBytes = _loadEmbeddedPngBytes(
    "assets/icons/car_charging.svg",
  );

  Future<void> _openMap(String lat, String lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error'.tr, 'Could not launch maps'.tr);
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        // Ensure Obx is always listening to isCharging so it rebuilds in real time
        final _ = controller.isCharging.value;
        final s = controller.state;

        final isInitialLoading =
            (s.isLoadingSlides && controller.slideshowList.isEmpty) ||
            (s.isLoadingNews && controller.newsList.isEmpty) ||
            s.isLoadingWalletBalance;

        if (isInitialLoading) {
          return const EVSkeleton();
        }

        return _buildBody();
      }),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.evQrScanner);
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset("assets/icons/icon_ev_scan.png"),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return ClipRRect(
      child: SizedBox(
        height: 60,
        child: BottomAppBar(
          color: AppColors.primaryColor,
          elevation: 0.2,
          shape: const CircularNotchedRectangle(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0.2,
      backgroundColor: AppColors.primaryColor,
      title: Text(
        "ev_charger".tr.replaceAll('\n', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim(),
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Ionicons.chevron_back_outline,
          color: AppColors.whiteColor,
        ),
        onPressed: () {
          Get.back();
        },
      ),
      actions: [
        // Faq
        _buildAppBarButton(
          () => Get.toNamed(AppRoutes.evFaq),
          "assets/icons/faq.svg",
        ),
        // Support
        _buildAppBarButton(
          () => showContactBottomSheet(),
          "assets/icons/headphone.svg",
        ),
        // Policy
        _buildAppBarButton(
          () => Get.toNamed(AppRoutes.evPolicy),
          "assets/icons/Shield.svg",
        ),
      ],
    );
  }

  Widget _buildAppBarButton(VoidCallback? onTap, String iconPath) {
    return GestureDetector(
      onTap: () {
        onTap?.call();
      },
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 20,
        child: SvgPicture.asset(iconPath),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // New Ui
            // Obx(() {
            //   if (controller.isCharging.value != 1) {
            //     return const SizedBox.shrink();
            //   }
            //   if (controller.isChargingLoading.value) {
            //     return Column(
            //       children: [
            //         _buildCardChargingLoading(),
            //         const SizedBox(height: 15),
            //       ],
            //     );
            //   }
            //   return Column(
            //     children: [_buildCardCharging(), const SizedBox(height: 15)],
            //   );
            // }),

            // Fake
            _buildCardCharging(),
            const SizedBox(height: 15),

            _buildBalanceCard(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: _buildQuickActions(),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Nearby Station".tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.toNamed(AppRoutes.evNearbyStations);
                  },
                  child: Row(
                    children: [
                      Text(
                        "view_all".tr,
                        style: const TextStyle(color: AppColors.primaryColor),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            _buildStationList(),

            // _buildImageCarousel(),

            _buildNewsFeedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionIcon(int hour) {
    if (hour >= 0 && hour < 12) {
      return const Icon(
        Icons.wb_sunny,
        size: 30,
        color: Colors.orange,
      );
    } else if (hour >= 12 && hour < 17) {
      return const Icon(
        Icons.wb_cloudy,
        size: 30,
        color: Colors.amber,
      );
    } else {
      return const Icon(
        Icons.nights_stay,
        size: 30,
        color: Colors.indigo,
      );
    }
  }

  String _getGreetingWithUserName() {
    if (controller.isCharging.value == 1) {
      return 'You are charging now';
    }
    final hour = DateTime.now().hour;
    final String greeting;
    if (hour >= 0 && hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }
    final userName = ValueStatic.username;
    if (userName.isEmpty) return greeting;
    return '$greeting $userName';
  }

  Widget _buildCardCharging() {
    return Container(
      // height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF7F0EC), Color(0xFFE3C7B6)],
          // 0xFFF7F0EC
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        StreamBuilder<DateTime>(
                              stream: controller.timeStream,
                              initialData: DateTime.now(),
                              builder: (context, snapshot) {
                                final hour = snapshot.data?.hour ?? DateTime.now().hour;
                                return _buildSectionIcon(hour);
                              },
                            ),
                            SizedBox(width: 10,),
                        //
                        Text(
                          _getGreetingWithUserName(),
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildCarChargingImage(),
                      ),
                    ),
                    // View detail button
                    _buildDetailButton(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailButton() {
    if (controller.isCharging.value != 1) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () async {
        await controller.fetchChargingStatus();
        if (controller.isCharging.value != 1) return;
        if (controller.chargingTransactionId.value.isEmpty ||
            controller.chargingChargerUsername.value.isEmpty) {
          return;
        }
        _connectWebSocketAndNavigate(
          controller.chargingTransactionId.value,
          controller.chargingChargerUsername.value,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      // icon: const Icon(Icons.arrow_forward, color: AppColors.whiteColor),
      label: Text(
        "View Detail".tr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.whiteColor,
        ),
      ),
    );
  }

  Widget _buildCarChargingImage() {
    return FutureBuilder<Uint8List?>(
      future: _carChargingBytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(bytes, fit: BoxFit.contain);
        }
        return SvgPicture.asset(
          "assets/icons/car_charging.svg",
          fit: BoxFit.contain,
        );
      },
    );
  }

  Future<void> _connectWebSocketAndNavigate(
    String transactionId,
    String chargerUsername,
  ) async {
    final username = chargerUsername.isNotEmpty ? chargerUsername : 'ev01';
    final wsUrl = BaseUrl.BASE_URL_WEB_SOCKET;

    debugPrint('Connecting to EV charging WebSocket: $wsUrl');

    try {
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      final stompSend =
          'SEND\ndestination:/topic/ocpi/commands/$username\ncontent-type:application/json\n\n\u0000';

      debugPrint('destination:/topic/ocpi/commands/$username');
      debugPrint('content-type:application/json');
      channel.sink.add(stompSend);

      await Future.delayed(const Duration(milliseconds: 500));
      await channel.sink.close();
    } catch (e) {
      debugPrint('Error connecting to EV charging WebSocket: $e');
    }

    Get.toNamed(AppRoutes.evDetailCharging, arguments: {'transactionId': transactionId, 'chargerUsername': chargerUsername});
  }

  Future<Uint8List?> _loadEmbeddedPngBytes(String svgAssetPath) async {
    final svg = await rootBundle.loadString(svgAssetPath);
    final match = RegExp(r'data:image/png;base64,([^"\s]+)').firstMatch(svg);
    final data = match?.group(1);
    if (data == null || data.isEmpty) return null;

    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }

  String? _resolveStationImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http')) return imageUrl;
    final clean = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    return '${BaseUrl.BASE_URL_SLIDE_IMAGE_EV}${Uri.encodeFull(clean)}';
  }

  String _gunIconPath(String? name) {
    final n = (name ?? '').toUpperCase();
    if (n.contains('GB')) return AssetImages.ic_ev_gb;
    if (n.contains('EU') || n.contains('CCS') || n.contains('DC') || n.contains('CH')) {
      return AssetImages.ic_ev_dc;
    }
    return AssetImages.ic_ev_gb;
  }

  String _gunLabel(String? name) {
    final raw = name ?? '-';
    return raw.trim().isEmpty ? '-' : raw.trim();
  }

  String _calculateDistance(String? lat, String? lng) {
    if (lat == null || lng == null) return 'N/A km';

    final stationLat = double.tryParse(lat.trim());
    final stationLng = double.tryParse(lng.trim());
    if (stationLat == null || stationLng == null) return 'N/A km';

    final stationController = Get.find<EvStationController>();
    final current = stationController.currentPosition.value;
    if (current == null) return 'N/A km';

    final distance = _calculateSimpleDistance(
      current.latitude,
      current.longitude,
      stationLat,
      stationLng,
    );
    return '${distance.toStringAsFixed(1)} km';
  }

  double _calculateSimpleDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final latDiff = (lat1 - lat2).abs();
    final lngDiff = (lng1 - lng2).abs();
    return (latDiff + lngDiff) * 111.0;
  }

  Widget _buildStationList() {
    final stationController = Get.find<EvStationController>();

    return Obx(() {
      // Watch location so distances update once it is fetched
      stationController.currentPosition.value;
      stationController.isLocationLoading.value;

      final stations = stationController.allStations;

      if (stationController.isLoading.value && stations.isEmpty) {
        return const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (stations.isEmpty) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        height: Get.height / 6.5,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: stations.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return _buildStationCard(context, stations[index]);
          },
        ),
      );
    });
  }

  void _openEVDetailsModal(BuildContext context, EvStationListDatum station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EVStationDetailSheet(station: station),
    );
  }

Widget _buildStationCard(BuildContext context, EvStationListDatum station) {
  final bool isOpen = station.isOpen ?? ((station.totalChargerAvailable ?? 0) > 0);
  final stationImageUrl = _resolveStationImageUrl(station.imageUrl);
  final guns = station.gunInform ?? [];
  final stationController = Get.find<EvStationController>();
  final isLocationLoading = stationController.isLocationLoading.value;

  final backendDistanceKm = double.tryParse((station.value ?? '').trim());
  final backendDistanceText =
      backendDistanceKm == null ? null : '${backendDistanceKm.toStringAsFixed(1)} km';
  final computedDistanceText = _calculateDistance(station.lats, station.longs);
  final distanceText = backendDistanceText ?? computedDistanceText;

  return GestureDetector(
    onTap: () => _openEVDetailsModal(context, station),
    child: Container(
      width: 330,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 100,
            child: stationImageUrl == null
                ? Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.ev_station,
                      size: 32,
                      color: Colors.grey,
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: stationImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: Colors.grey.shade200),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.ev_station,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          station.name ?? '-',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF25252A),
                          ),
                        ),
                      ),
                      // if (station.isFavorite == true) ...[
                      //   const SizedBox(width: 6),
                      //   const Icon(
                      //     Icons.favorite,
                      //     size: 16,
                      //     color: Colors.red,
                      //   ),
                      // ],
                      // const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOpen ? const Color(0xFF009B55) : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOpen ? 'Open' : 'Closed',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4D5060),
                        ),
                      ),
                    ],
                  ),
                  // const SizedBox(height: 6),
                  // Row(
                  //   children: [
                  //     const Icon(
                  //       Icons.location_on_outlined,
                  //       size: 14,
                  //       color: AppColors.placeholderColor,
                  //     ),
                  //     const SizedBox(width: 4),
                  //     Expanded(
                  //       child: Text(
                  //         station.address ?? '-',
                  //         maxLines: 1,
                  //         overflow: TextOverflow.ellipsis,
                  //         style: const TextStyle(
                  //           fontSize: 12,
                  //           color: AppColors.placeholderColor,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: 15,
                        color: Color(0xFF4D5060),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Start from ',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.placeholderColor,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          station.pricePerKwh == null
                              ? '-'
                              : '${station.pricePerKwh!.toStringAsFixed(0)} KHR/kWh',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      SvgPicture.asset(
                        AssetImages.ic_station,
                        width: 15,
                        height: 15,
                        colorFilter: const ColorFilter.mode(
                          AppColors.placeholderColor,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text.rich(
                        TextSpan(
                          text: 'DC ',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.placeholderColor,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${station.totalChargerAvailable ?? '-'}/${station.totalCharger ?? '-'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Plug Types (match EVNearbyStationsScreen style)
                  Row(
                    children: [
                      if (guns.isEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AssetImages.ic_ev_dc,
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        )
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0; i < guns.length; i++) ...[
                                  if (i > 0) const SizedBox(width: 16),
                                  Image.asset(
                                    _gunIconPath(guns[i].name),
                                    width: 16,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_gunLabel(guns[i].name)} '
                                    '${guns[i].qtyAvailable ?? '-'}'
                                    '/${guns[i].qty ?? '-'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      _openMap(station.lats ?? '', station.longs ?? '');
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: Color(0xFF3445E5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'direction'.tr,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3445E5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (backendDistanceText == null && isLocationLoading)
                          Container(
                            width: 44,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          )
                        else
                          Text(
                            distanceText,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF707589),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildImageCarousel() {
    return Obx(() {
      if (controller.state.isLoadingSlides &&
          controller.slideshowList.isEmpty) {
        return _buildLoadingCarousel();
      }

      if (controller.state.hasErrorSlides) {
        return _buildErrorCarousel();
      }

      if (controller.slideshowImageUrls.isNotEmpty) {
        return _buildDynamicCarousel(controller.slideshowImageUrls);
      }

      // Fallback to default images if no slides from API
      final List<String> defaultImages = [
        'https://oknmedia.ap-south-1.linodeobjects.com/2026/04/DJI_20260319110048_0588_D-1024x576.jpg',
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&q=80&w=1000',
      ];

      return _buildDynamicCarousel(defaultImages);
    });
  }

  Widget _buildLoadingCarousel() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[300],
          ),
          child: const SizedBox.shrink(),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildErrorCarousel() {
    return Column(
      children: [
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'failed_to_load_slides'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: controller.refreshSlides,
                child: Text('retry'.tr),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

Widget _buildDynamicCarousel(List<String> imageUrls) {
  return Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final metrics = notification.metrics;
              if (metrics.viewportDimension > 0) {
                _currentCarouselPage.value =
                    metrics.pixels / metrics.viewportDimension;
              }
            }
            return false;
          },
          child: CarouselSlider(
            items: imageUrls.map((url) => _buildCarouselImage(url)).toList(),
            carouselController: _carouselController,
            options: CarouselOptions(
              aspectRatio: 16 / 7, 
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                controller.updateCurrentSlideIndex(index);
                _currentCarouselPage.value = index.toDouble();
              },
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      ValueListenableBuilder<double>(
        valueListenable: _currentCarouselPage,
        builder: (context, currentPage, child) {
          return _buildCarouselIndicators(imageUrls.length, currentPage);
        },
      ),
      const SizedBox(height: 20),
    ],
  );
}

  Widget _buildCarouselImage(String url) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      color: Colors.black, // Dark background to frame the full image nicely
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const SizedBox.shrink(),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image, size: 50, color: Colors.grey),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildCarouselIndicators(int count, double currentPage) {
    final int activeIndex = currentPage.round() % count;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                activeIndex == index
                    ? AppColors.primaryColor
                    : Colors.grey.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 1, child: _buildTotalBalance()),
          const SizedBox(width: 12),
          Expanded(flex: 1, child: _buildTotalPoint()),
        ],
      ),
    );
  }

  Widget _buildTotalBalance() {
    final wallet = Get.find<EvWalletController>();
    debugPrint(
      '====>> ****** [EvChargingScreen._buildTotalBalance] endpoint: ${Endpoint.evSaleOrderWalletAmount}, '
      'totalBalance: ${wallet.totalBalance.value}, '
      'formatted: ${wallet.formatAmount(wallet.totalBalance.value)} KHR',
    );
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.evWallet);
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F0EC), Color(0xFFE3C7B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 1,
              top: 2,
              child: Opacity(
                opacity: 0.99,
                child: SvgPicture.asset(
                  "assets/icons/money_background_small.svg",
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            //
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "total_balance".tr,
                    style: const TextStyle(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),
                  GetX<EvWalletController>(
                    builder: (wallet) {
                      return wallet.isLoadingBalance.value
                          ? const SizedBox(height: 40)
                          : SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${wallet.formatAmount(wallet.totalBalance.value)} KHR",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.titleColor,
                                ),
                              ),
                            ),
                          );
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.evTopUp);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // minimumSize: const Size(50, 35),
                      ),
                      icon: Image.asset(
                        "assets/icons/icon_ev_topUp.png",
                        width: 20,
                        height: 20,
                      ),
                      label: Text(
                        "top_up".tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.whiteColor,
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
  }

  Widget _buildTotalPoint() {
    return InkWell(
      onTap: () {
        final point = controller.state.membershipInfoResponse?.body?.data;
        Get.toNamed(AppRoutes.evMembership, arguments: {'section': 'menu', 'membershipInfo': point});

      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F0EC), Color(0xFFE3C7B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 1,
              top: 2,
              child: Opacity(
                opacity: 0.50,
                child: SvgPicture.asset(
                  "assets/icons/history_background_small.svg",
                  width: 60,
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            //
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'total_points'.tr,
                    style: const TextStyle(
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 5),
                  Obx(() {
                    final isLoading = controller.state.isLoadingMembershipInfo;
                    if (isLoading) return const SizedBox(height: 40);

                    final point =
                        controller.state.membershipInfoResponse?.body?.data;
                    final currentPoint = point?.currentPoint ?? 0;

                    return Text(
                      "$currentPoint ${'pts'.tr}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.titleColor,
                      ),
                    );
                  }),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Obx(() {
                      final isCharging = controller.isCharging.value == 1;
                      final point =
                          controller.state.membershipInfoResponse?.body?.data;

                      return ElevatedButton.icon(
                        onPressed: () {
                          if (isCharging) {
                            Get.toNamed(AppRoutes.evRedeemPoint, arguments: {'points': point});
                            return;
                          }

                          Get.toNamed(AppRoutes.evMembership, arguments: {'section': 'history', 'membershipInfo': point});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // minimumSize: const Size(50, 30),
                        ),
                        icon:
                            isCharging
                                ? const Icon(Icons.auto_awesome, size: 20)
                                : SvgPicture.asset(
                                  "assets/icons/history.svg",
                                  width: 20,
                                  height: 20,
                                ),
                        label: Text(
                          isCharging ? 'redeem'.tr : 'history'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildActionButton(
            // Icons.ev_station,
            SvgPicture.asset(AssetImages.ic_station, width: 15, height: 15),
            "ev_station".tr,
            // "Map Station",
            () {
              Get.toNamed(AppRoutes.evAllStations);
            },
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _buildActionButton(
            SvgPicture.asset(AssetImages.ic_favorite, width: 15, height: 15),
            "favorites".tr,
            () {
              Get.toNamed(AppRoutes.evFavorites);
            },
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: _buildActionButton(
            SvgPicture.asset(AssetImages.voucher, width: 15, height: 15),
            'voucher'.tr,
            () {
              Get.toNamed(AppRoutes.evVoucher);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(Widget icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.black38),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: icon,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsFeedSection() {
    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "news_feed".tr,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.evNewsFeed);
              },
              child: Row(
                children: [
                  Text(
                    "view_all".tr,
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // News List (Show only first 3 public news)
        Obx(() {
          final publicNews = controller.newsList.take(3).toList();

          // Loading state (only show when first load and empty)
          if (controller.state.isLoadingNews && publicNews.isEmpty) {
            return const SizedBox(height: 100);
          }

          // Error state
          if (controller.state.hasErrorNews) {
            return _buildNewsErrorState();
          }

          // Empty state
          if (publicNews.isEmpty) {
            return _buildNewsEmptyState();
          }

          return Column(
            children:
                publicNews.map((item) {
                  final desc = controller.getLocalizedDescription(item);
                  final imageUrl = controller.getFeedImageUrl(item);
                  return _buildNewsItem(
                    title: desc.split('.').first.trim(),
                    desc: desc,
                    imageUrl: imageUrl,
                    onTap: () {
                      // Use the same bottom sheet as NewsFeedScreen
                      NewsDetailBottomSheet.show(
                        context: Get.context!,
                        item: item,
                        controller: controller,
                      );
                    },
                  );
                }).toList(),
          );
        }),
      ],
    );
  }

  // Update _buildNewsItem to accept onTap parameter
  Widget _buildNewsItem({
    required String title,
    required String desc,
    required String imageUrl,
    required VoidCallback onTap, // Add onTap parameter
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap, // Add onTap to the card
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder:
                      (context, url) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const SizedBox.shrink(),
                      ),
                  errorWidget:
                      (context, url, error) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Optional: Clean empty & error states
  Widget _buildNewsEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text(
        "No news available at the moment",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _buildNewsErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 32),
            const SizedBox(height: 8),
            Text(
              "Failed to load news",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void showContactBottomSheet() {
    Get.bottomSheet(
      Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Title
                  Center(
                    child: Text(
                      'contact_us'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact List
                  Obx(() {
                    if (controller.state.isLoadingContact) {
                      return Center(
                        child: Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.contact_support,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    if (controller.state.hasErrorContact) {
                      return Center(
                        child: Column(
                          children: [
                            Text('failed_to_load_contacts'.tr),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: controller.refreshContacts,
                              child: Text('retry'.tr),
                            ),
                          ],
                        ),
                      );
                    }

                    final contacts = controller.contactList;
                    if (contacts.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('no_contacts_available'.tr),
                        ),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Phone contacts
                        ...controller.getPhoneContacts().map(
                          (contact) => _buildContactItem(
                            iconUrl: controller.getIconUrl(
                              contact,
                            ), // Get full icon URL
                            title: controller.getLocalizedName(contact),
                            subtitle: contact.link ?? '',
                            onTap: () async {
                              final uri = Uri(
                                scheme: 'tel',
                                path: contact.link ?? '',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                              Get.back();
                            },
                          ),
                        ),

                        // Social media contacts
                        ...controller.getSocialContacts().map(
                          (contact) => _buildContactItem(
                            iconUrl: controller.getIconUrl(
                              contact,
                            ), // Get full icon URL
                            title: controller.getLocalizedName(contact),
                            subtitle: contact.link ?? '',
                            onTap: () async {
                              if (contact.link == null ||
                                  contact.link!.isEmpty) {
                                Get.snackbar(
                                  'error'.tr,
                                  'link_not_available'.tr,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                                return;
                              }

                              final uri = Uri.parse(contact.link!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                              Get.back();
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    );
                  }),
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
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required String iconUrl,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            width: 0.2,
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Dynamic icon from API with fallback
            SizedBox(
              width: 32,
              height: 32,
              child:
                  iconUrl.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: iconUrl,
                        fit: BoxFit.contain,
                        placeholder:
                            (context, url) => Container(
                              color: Colors.grey[200],
                              child: const SizedBox.shrink(),
                            ),
                        errorWidget:
                            (context, url, error) => Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.contact_support,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                      )
                      : const Icon(
                        Icons.contact_support,
                        size: 24,
                        color: Colors.grey,
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 22, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
