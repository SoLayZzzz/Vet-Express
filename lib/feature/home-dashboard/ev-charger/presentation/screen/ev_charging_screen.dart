import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/components/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/ev_charger_controller.dart';
import '../controller/ev_wallet_controller.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../routes/app_routes.dart';
import 'ev_new_feed_screen.dart';

class EvChargerScreen extends GetView<EvChargerController> {
  EvChargerScreen({super.key});

  final CarouselSliderController _carouselController =
      CarouselSliderController();

  late final Future<Uint8List?> _carChargingBytes = _loadEmbeddedPngBytes(
    AssetImages.ic_car_charging,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
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
        "ev_charger1".tr,
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
          AssetImages.ic_ev_faq,
        ),
        // Support
        _buildAppBarButton(
          () => showContactBottomSheet(),
          AssetImages.ic_ev_contact,
        ),
        // Policy
        _buildAppBarButton(
          () => Get.toNamed(AppRoutes.evPolicy),
          AssetImages.ic_ev_policy,
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
            Obx(() {
              if (controller.isCharging.value != 1) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [_buildCardCharging(), const SizedBox(height: 15)],
              );
            }),

            _buildBalanceCard(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: _buildQuickActions(),
            ),

            _buildImageCarousel(),

            _buildNewsFeedSection(),
          ],
        ),
      ),
    );
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
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            bottom: -30,
                            right: -30,
                            child: Image.asset(
                              AssetImages.gifCharging,
                              height: 100,
                              width: 100,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Your vehicle is charging',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
                //
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
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          AppRoutes.evDetailCharging,
                          arguments: {
                            'transactionId':
                                controller.chargingTransactionId.value,
                            'chargerUsername':
                                controller.chargingChargerUsername.value,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      label: Text(
                        "View Detail".tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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
          AssetImages.ic_car_charging,
          fit: BoxFit.contain,
        );
      },
    );
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
          child: CarouselSlider(
            items: imageUrls.map((url) => _buildCarouselImage(url)).toList(),
            carouselController: _carouselController,
            options: CarouselOptions(
              height: 180,
              viewportFraction: 1.0,
              enableInfiniteScroll: true,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged: (index, reason) {
                controller.updateCurrentSlideIndex(index);
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => _buildCarouselIndicators(imageUrls.length)),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCarouselImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Container(
              color: Colors.grey[200],
              child: const SizedBox.shrink(),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
      ),
    );
  }

  Widget _buildCarouselIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                controller.state.currentSlideIndex == index
                    ? AppColors.primaryColor
                    : Colors.grey.withValues(alpha: 0.5),
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard() {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildTotalBalance()),
        const SizedBox(width: 12),
        Expanded(flex: 1, child: _buildTotalPoint()),
      ],
    );
  }

  Widget _buildTotalBalance() {
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
                  AssetImages.ic_money_backgroound_small,
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
                          : Text(
                            "${wallet.totalBalance.value.toStringAsFixed(2)} KHR",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.titleColor,
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
                        minimumSize: const Size(50, 35),
                      ),
                      icon: Image.asset(
                        AssetImages.ic_topUp,
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
        final isCharging = controller.isCharging.value == 1;

        if (isCharging) {
          Get.toNamed(
            AppRoutes.evRedeemPoint,
            arguments: <String, dynamic>{'points': point},
          );
        } else {
          Get.toNamed(
            AppRoutes.evMembership,
            arguments: <String, dynamic>{
              'section': 'menu',
              'membershipInfo': point,
            },
          );
        }
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
                  AssetImages.ic_history_background_small,
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
                    "Total Points".tr,
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
                      "$currentPoint pts",
                      style: const TextStyle(
                        fontSize: 20,
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
                            Get.toNamed(
                              AppRoutes.evRedeemPoint,
                              arguments: <String, dynamic>{'points': point},
                            );
                            return;
                          }

                          Get.toNamed(
                            AppRoutes.evMembership,
                            arguments: <String, dynamic>{
                              'section': 'history',
                              'membershipInfo': point,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          minimumSize: const Size(50, 35),
                        ),
                        icon:
                            isCharging
                                ? const Icon(Icons.auto_awesome, size: 20)
                                : SvgPicture.asset(
                                  AssetImages.ic_history,
                                  width: 20,
                                  height: 20,
                                ),
                        label: Text(
                          isCharging ? 'Redeem' : "History".tr,
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
            SvgPicture.asset(AssetImages.ic_station, width: 18, height: 18),
            // "ev_charger".tr,
            "Map Station",
            () {
              Get.toNamed(AppRoutes.evAllStations);
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            SvgPicture.asset(AssetImages.ic_favorite, width: 18, height: 18),
            "favorites".tr,
            () {
              Get.toNamed(AppRoutes.evFavorites);
            },
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildActionButton(
            SvgPicture.asset(AssetImages.voucher, width: 18, height: 18),
            "Voucher".tr,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
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
            Column(
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
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
