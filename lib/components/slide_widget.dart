import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controller/slide_controller.dart';
import '../utils/app_colors.dart';
import 'cache_image_widget.dart';

class SlideWidget extends StatelessWidget {
  SlideWidget({super.key});

  final SlideController controller = Get.put(SlideController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.imgList.isNotEmpty) {
        return _buildCarouselWithData();
      }

      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      return _buildLoadingState();
    });
  }

  /// Build carousel when we have data (cached or fresh)
  Widget _buildCarouselWithData() {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 6),
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            height: MediaQuery.of(Get.context!).size.height * 0.16,
            initialPage: 0,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            onPageChanged:
                (index, reason) => controller.currentIndex.value = index,
          ),
          items:
              controller.imgList
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: double.infinity,
                          child: CachedImage(
                            imageUrl: item,
                            fit: BoxFit.cover,
                            height:
                                MediaQuery.of(Get.context!).size.height * 0.16,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        _buildPageIndicator(),
      ],
    );
  }

  /// Build page indicator (only show if we have multiple images)
  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 0,
      left: 1,
      right: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(Get.context!).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Obx(
                    () => AnimatedSmoothIndicator(
                      activeIndex: controller.currentIndex.value,
                      count: controller.imgList.length,
                      effect: const ExpandingDotsEffect(
                        activeDotColor: AppColors.primaryColor,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build loading/placeholder state
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _buildPlaceholder(),
      ),
    );
  }

  /// Build placeholder image
  Widget _buildPlaceholder() {
    return SizedBox(
      height: MediaQuery.of(Get.context!).size.height * 0.16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image(
          image: const AssetImage('assets/images/place_holder.png'),
          height: MediaQuery.of(Get.context!).size.height * 0.16,
          width: double.infinity,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
