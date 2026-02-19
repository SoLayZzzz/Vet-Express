import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:express_vet/activities/ticket/ticket_schedule_car_detail_map_screen.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/utils/app_bar.dart';

import '../controller/schedule_car_detail_controller.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/button.dart';

class TicketScheduleCarDetailScreen extends StatefulWidget {
  const TicketScheduleCarDetailScreen({super.key});

  @override
  State<TicketScheduleCarDetailScreen> createState() =>
      _TicketScheduleCarDetailScreenState();
}

class _TicketScheduleCarDetailScreenState
    extends State<TicketScheduleCarDetailScreen> {
  final CarouselSliderController _controller = CarouselSliderController();

  String? _lastJourneyId;

  ScheduleCarDetailController get _scheduleController =>
      Get.find<ScheduleCarDetailController>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = Get.arguments as Map<dynamic, dynamic>?;
    final journeyId = (args?['journeyId'] as String?) ?? '';
    if (_lastJourneyId == journeyId) return;
    _lastJourneyId = journeyId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleController.applyArgs(args);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScheduleCarDetailController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBarVET().appBar(
            context,
            controller.type == 1
                ? '${ValueStatic.desfrom} - ${ValueStatic.desTo}'
                : '${ValueStatic.desTo} - ${ValueStatic.desfrom}',
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.listSlide.isNotEmpty)
                      Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: CarouselSlider(
                              carouselController: _controller,
                              options: CarouselOptions(
                                autoPlay: true,
                                autoPlayInterval: const Duration(seconds: 4),
                                disableCenter: true,
                                viewportFraction: 1.0,
                                enlargeCenterPage: false,
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                aspectRatio: 16 / 9,
                                initialPage: 0,
                                autoPlayCurve: Curves.fastOutSlowIn,
                                enableInfiniteScroll: true,
                                onPageChanged: (index, reason) {
                                  controller.onCarouselPageChanged(index);
                                },
                              ),
                              items:
                                  controller.listSlide
                                      .map(
                                        (item) => ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                            Radius.circular(6.0),
                                          ),
                                          child: InkWell(
                                            onTap: () {},
                                            child: Stack(
                                              children: [
                                                CachedNetworkImage(
                                                  fit: BoxFit.cover,
                                                  width:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width,
                                                  height:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height *
                                                      0.25,
                                                  imageUrl:
                                                      item.photo.toString(),
                                                  placeholder:
                                                      (context, url) =>
                                                          placeHolder(),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          placeHolder(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 1,
                            right: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Obx(
                                          () => AnimatedSmoothIndicator(
                                            activeIndex:
                                                controller
                                                    .currentSlideIndex
                                                    .value,
                                            count: controller.listSlide.length,
                                            effect: const ExpandingDotsEffect(
                                              activeDotColor:
                                                  AppColors.primaryColor,
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
                          ),
                        ],
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //* boarding point
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                          child: Text(
                            'boarding_address'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.titleColor,
                            ),
                          ),
                        ),
                        if (controller.boardingPoint.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: controller.boardingPoint.length,
                              separatorBuilder:
                                  (context, int index) => Container(
                                    height: 1,
                                    color: AppColors.borderColor,
                                  ),
                              itemBuilder: (context, i) {
                                return getAddress(
                                  (controller.boardingPoint[i].name).toString(),
                                  (controller.boardingPoint[i].address)
                                      .toString(),
                                  i,
                                  double.parse(
                                    (controller.boardingPoint[i].lats)
                                        .toString(),
                                  ),
                                  double.parse(
                                    (controller.boardingPoint[i].longs)
                                        .toString(),
                                  ),
                                );
                              },
                            ),
                          ),

                        //* drop off point
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                          child: Text(
                            'drop_off_address'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.titleColor,
                            ),
                          ),
                        ),
                        if (controller.dropOffPoint.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: controller.dropOffPoint.length,
                              separatorBuilder:
                                  (context, int index) => Container(
                                    height: 1,
                                    color: AppColors.borderColor,
                                  ),
                              itemBuilder: (context, i) {
                                return getAddress(
                                  (controller.dropOffPoint[i].name).toString(),
                                  (controller.dropOffPoint[i].address)
                                      .toString(),
                                  i,
                                  double.parse(
                                    (controller.dropOffPoint[i].lats)
                                        .toString(),
                                  ),
                                  double.parse(
                                    (controller.dropOffPoint[i].longs)
                                        .toString(),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    if (controller.listIcon.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                        child: Text(
                          'amenities'.tr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.titleColor,
                          ),
                        ),
                      ),
                    if (controller.listIcon.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const ScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1 / 0.7,
                            ),
                        itemCount: controller.listIcon.length,
                        itemBuilder: (BuildContext context, i) {
                          return listAmen(
                            (controller.listIcon[i].icon).toString(),
                            (controller.listIcon[i].name).toString(),
                          );
                        },
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        if (controller.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              'description'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.titleColor,
                              ),
                            ),
                          ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              controller.description
                                  .split('\n')
                                  .map(
                                    (line) => Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: Text(
                                        line,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              width: double.infinity,
              color: AppColors.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child:
                  controller.status == 1
                      ? globalButton(
                        context: context,
                        buttonText: 'booking_ticket'.tr,
                        buttonColor:
                            ValueStatic.ticketType == '3'
                                ? AppColors.airBusColor
                                : AppColors.primaryColor,
                        onPressed: () {
                          controller.openSelectSeat();
                        },
                      )
                      : globalButton(
                        context: context,
                        buttonText:
                            controller.status == 3
                                ? 'full'.tr
                                : (controller.status == 4
                                    ? 'unavailable'.tr
                                    : 'left'.tr),
                        buttonColor: Colors.grey,
                        onPressed: () {},
                      ),
            ),
          ),
        );
      },
    );
  }

  Widget placeHolder() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image(
          image: const AssetImage(AssetImages.place_holder),
          height: MediaQuery.of(context).size.height * 0.25,
          width: double.infinity,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  Widget listAmen(String path, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          path,
          height: 30,
          errorBuilder: (context, error, stackTrace) {
            return Image(
              image: const AssetImage(AssetImages.place_holder),
              height: 30,
              fit: BoxFit.cover,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Image(
              image: const AssetImage(AssetImages.place_holder),
              height: 30,
              fit: BoxFit.cover,
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.width / 37,
            color:
                ValueStatic.ticketType != '3'
                    ? AppColors.primaryColor
                    : AppColors.airBusColor,
          ),
        ),
      ],
    );
  }

  Widget getAddress(
    String name,
    String address,
    int index,
    double lat,
    double long,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TicketScheduleCarDetailMapScreen(
                  name: name,
                  address: address,
                  latitude: lat,
                  longitude: long,
                ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
              ),
            ),
            const Icon(
              Ionicons.chevron_forward_outline,
              size: 18,
              color: AppColors.borderColor,
            ),
          ],
        ),
      ),
    );
  }
}
