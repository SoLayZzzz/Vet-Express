import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:express_vet/activities/ev/ev_policy_screen.dart';
import 'package:express_vet/activities/ev/ev_qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controller/ev/ev_contact_controller.dart';
import '../../controller/ev/ev_news_feed_controller.dart';
import '../../controller/ev/ev_slide_show_controller.dart';
import '../../controller/ev/ev_wallet_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/contains.dart';
import 'ev_charger_wallet_screen.dart';
import 'ev_new_feed_screen.dart';
import 'ev_station_screen.dart';
import 'ev_top_up_screen.dart';
import 'ev_faq_screen.dart';
import 'ev_fav_screen.dart';

class EvChargerScreen extends StatelessWidget {
  EvChargerScreen({super.key});

  final EvContactController evController = Get.find();
  final EvSlideshowController slideshowController = Get.find();
  final EvNewsFeedController newsFeedController = Get.find();
  final EvWalletController walletController = Get.find();
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => EvQrScannerScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: Constrains.duration),
        );
      },
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
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
        style: TextStyle(color: AppColors.whiteColor, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Ionicons.chevron_back_outline, color: AppColors.whiteColor),
        onPressed: () {
          Get.back();
        },
      ),
      actions: [
        IconButton(
          onPressed: () {
            Get.to(
              () => EvFaqScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: Constrains.duration),
            );
          },
          icon: Image.asset("assets/icons/icon_ev_faq.png"),
        ),
        IconButton(
          onPressed: () {
            showContactBottomSheet();
          },
          icon: Image.asset("assets/icons/icon_ev_contact.png"),
        ),
        IconButton(
          onPressed: () {
            Get.to(
              () => EvPolicyScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: Constrains.duration),
            );
          },
          icon: Image.asset("assets/icons/icon_ev_policy.png"),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Image Carousel with Indicators
            _buildImageCarousel(),

            // 2. Balance Card
            _buildBalanceCard(),
            const SizedBox(height: 20),

            // 3. Quick Actions
            _buildQuickActions(),
            const SizedBox(height: 10),

            // 4. News Feed Section
            _buildNewsFeedSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Obx(() {
      if (slideshowController.isLoading.value && slideshowController.slideshowList.isEmpty) {
        return _buildLoadingCarousel();
      }

      if (slideshowController.hasError.value) {
        return _buildErrorCarousel();
      }

      final imageUrls = slideshowController.slideshowImageUrls;

      // Fallback to default images if no slides from API
      if (imageUrls.isEmpty) {
        return _buildDefaultCarousel();
      }

      return _buildDynamicCarousel(imageUrls);
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
          child: const Center(child: CircularProgressIndicator()),
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
              Text('failed_to_load_slides'.tr, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: slideshowController.refreshData, child: Text('retry'.tr)),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDefaultCarousel() {
    final List<String> defaultImages = [
      'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&q=80&w=1000',
      'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&q=80&w=1000',
    ];

    return _buildDynamicCarousel(defaultImages);
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
                slideshowController.updateCurrentSlideIndex(index);
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
              child: const Center(child: CircularProgressIndicator()),
            ),
        errorWidget:
            (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
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
                slideshowController.currentSlideIndex.value == index
                    ? AppColors.primaryColor
                    : Colors.grey.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildBalanceCard() {
    return InkWell(
      onTap: () {
        Get.to(
          () => const EvWalletScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: Constrains.duration),
        );
      },
      child: Obx(() {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF7F0EC), Color(0xFFE3C7B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "total_balance".tr,
                    style: const TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 20, color: AppColors.primaryColor),
                ],
              ),
              const SizedBox(height: 8),
              walletController.isLoadingBalance.value
                  ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()))
                  : Text(
                    "${walletController.totalBalance.value.toStringAsFixed(2)} KHR",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleColor,
                    ),
                  ),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.to(
                      () => EvTopUpScreen(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: Constrains.duration),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: Image.asset("assets/icons/icon_ev_topUp.png", width: 20, height: 20),
                  label: Text(
                    "top_up".tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.whiteColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(Icons.ev_station, "ev_station".tr, () {
            Get.to(
              () => EvAllStationScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: Constrains.duration),
            );
          }),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(Icons.favorite, "favorites".tr, () {
            Get.to(
              () => EvFavoriteScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: Constrains.duration),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.whiteColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsFeedSection() {
    final EvNewsFeedController controller = Get.find<EvNewsFeedController>();

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("news_feed".tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Get.to(
                  () => const NewsFeedScreen(),
                  transition: Transition.rightToLeft,
                  duration: const Duration(milliseconds: Constrains.duration),
                );
              },
              child: Text(
                "view_all".tr,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // News List (Show only first 3 public news)
        Obx(() {
          final publicNews = controller.displayNewsList.take(3).toList();

          // Loading state (only show when first load and empty)
          if (controller.isLoading.value && publicNews.isEmpty) {
            return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
          }

          // Error state
          if (controller.hasError.value) {
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
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
            Text("Failed to load news", style: TextStyle(color: Colors.grey[600])),
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
                    if (evController.isLoading.value) {
                      return Center(
                        child: Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.contact_support, size: 20, color: Colors.grey),
                        ),
                      );
                    }

                    if (evController.hasError.value) {
                      return Center(
                        child: Column(
                          children: [
                            Text('failed_to_load_contacts'.tr),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: evController.refreshData,
                              child: Text('retry'.tr),
                            ),
                          ],
                        ),
                      );
                    }

                    final contacts = evController.contactList;
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
                        ...evController.getPhoneContacts().map(
                          (contact) => _buildContactItem(
                            iconUrl: evController.getIconUrl(contact), // Get full icon URL
                            title: evController.getLocalizedName(contact),
                            subtitle: contact.link ?? '',
                            onTap: () async {
                              final uri = Uri(scheme: 'tel', path: contact.link ?? '');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                              Get.back();
                            },
                          ),
                        ),

                        // Social media contacts
                        ...evController.getSocialContacts().map(
                          (contact) => _buildContactItem(
                            iconUrl: evController.getIconUrl(contact), // Get full icon URL
                            title: evController.getLocalizedName(contact),
                            subtitle: contact.link ?? '',
                            onTap: () async {
                              if (contact.link == null || contact.link!.isEmpty) {
                                return;
                              }

                              final uri = Uri.parse(contact.link!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
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
          border: Border.all(width: 0.2, color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
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
                      : const Icon(Icons.contact_support, size: 24, color: Colors.grey),
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
