import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/resort_controller.dart';
import '../../models/resort/resort_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/contains.dart';
import 'resort_webview_screen.dart';
import '../components/cache_image_widget.dart';

class ResortScreen extends StatelessWidget {
  ResortScreen({super.key});

  final ResortController controller = Get.put(ResortController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.resortList.isNotEmpty) {
        return _buildResortListWithData();
      }

      if (controller.isLoading.value) {
        return _buildSkeletonLoading();
      }

      return _buildSkeletonLoading();
    });
  }

  /// Build resort list when we have data (cached or fresh)
  Widget _buildResortListWithData() {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: controller.resortList.length,
        itemBuilder: (context, index) {
          final accommodation = controller.resortList[index];
          return _buildResortItem(accommodation);
        },
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
    );
  }

  /// Build individual resort item
  Widget _buildResortItem(ResortBody accommodation) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      width: 240,
      height: 180,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Stack(
                children: [
                  accommodation.photo != null && accommodation.photo!.isNotEmpty
                      ? CachedImage(
                        imageUrl: accommodation.photo!,
                        fit: BoxFit.cover,
                        height: 120,
                        width: double.infinity,
                      )
                      : _buildPlaceholder(),
                  _buildResortTitle(accommodation.name ?? 'Unknown Resort'),
                ],
              ),
            ),
            SizedBox(height: 60, child: _buildResortFooter(accommodation)),
          ],
        ),
      ),
    );
  }

  /// Build resort title overlay
  Widget _buildResortTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
        gradient: LinearGradient(
          colors: [Color(0xFFE5E6E4), Color(0x4DFBFBF2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.titleColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Build resort footer with price and book button
  Widget _buildResortFooter(ResortBody accommodation) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              accommodation.price ?? 'Price N/A',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _buildBookButton(accommodation),
        ],
      ),
    );
  }

  /// Build book button
  Widget _buildBookButton(ResortBody accommodation) {
    return InkWell(
      onTap: () {
        if (accommodation.link != null && accommodation.link!.isNotEmpty) {
          Get.to(
            () => ResortWebViewScreen(url: accommodation.link ?? ""),
            duration: const Duration(milliseconds: Constrains.duration),
            transition: Transition.rightToLeft,
          );
        } else {
          Get.snackbar(
            'error'.tr,
            'no_website_available'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: AppColors.primaryColor.withOpacity(0.1),
          border: Border.all(color: AppColors.primaryColor, width: 1),
        ),
        child: Text(
          "book_resort".tr,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Build skeleton loading state
  Widget _buildSkeletonLoading() {
    return SizedBox(
      width: double.infinity,
      height: 180,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) => _buildSkeletonItem(),
        padding: const EdgeInsets.symmetric(horizontal: 15),
      ),
    );
  }

  /// Build skeleton item
  Widget _buildSkeletonItem() {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Container(
        width: 240,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlaceholder(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 70,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build placeholder image
  Widget _buildPlaceholder() {
    return Container(
      height: 120,
      color: Colors.grey[200],
      child: const Center(
        child: Image(
          image: AssetImage('assets/images/place_holder.png'),
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
