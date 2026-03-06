import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../value_statics.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/button.dart';
import '../../data/model/response/car_rental_car_type_response.dart';

class RentalCarDetailScreen extends StatefulWidget {
  final String carType;
  final String seat;
  final String image;
  final List<CarRentalSlidePhoto>? listSlide;
  final List<CarRentalAmenities>? listIcon;

  const RentalCarDetailScreen({
    super.key,
    required this.carType,
    required this.seat,
    required this.image,
    required this.listSlide,
    required this.listIcon,
  });

  @override
  State<RentalCarDetailScreen> createState() => _RentalCarDetailScreenState();
}

class _RentalCarDetailScreenState extends State<RentalCarDetailScreen> {
  final RxInt _current = 0.obs;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, widget.carType),
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      (widget.image.isEmpty)
                          ? Image.asset(
                            AssetImages.place_holder,
                            height: MediaQuery.of(context).size.height * 0.12,
                          )
                          : CachedNetworkImage(
                            imageUrl: widget.image,
                            height: MediaQuery.of(context).size.height * 0.12,
                            fit: BoxFit.contain,
                            placeholder:
                                (context, url) => Image.asset(
                                  AssetImages.place_holder,
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                ),
                            errorWidget:
                                (context, url, error) => Image.asset(
                                  AssetImages.place_holder,
                                  height:
                                      MediaQuery.of(context).size.height * 0.12,
                                ),
                          ),
                      Text(
                        widget.carType,
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${widget.seat} ${'seats'.tr}',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  GridView(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1 / .7,
                        ),
                    children: <Widget>[
                      for (int i = 0; i < (widget.listIcon)!.length; i++)
                        list(
                          (widget.listIcon?[i].icon).toString(),
                          (widget.listIcon?[i].name).toString(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.30,
                    child: CarouselSlider(
                      carouselController: _controller,
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: const Duration(seconds: 4),
                        disableCenter: true,
                        viewportFraction: 1.0,
                        enlargeCenterPage: false,
                        height: MediaQuery.of(context).size.height * 0.25,
                        aspectRatio: 16 / 9,
                        initialPage: 0,
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enableInfiniteScroll: true,
                        onPageChanged: (index, reason) {
                          _current.value = index;
                        },
                      ),
                      items:
                          widget.listSlide
                              ?.map(
                                (item) => Container(
                                  margin: const EdgeInsets.all(5.0),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.40,
                                      imageUrl: item.photo.toString(),
                                      placeholder:
                                          (context, url) => placeHolder(),
                                      errorWidget:
                                          (context, url, error) =>
                                              placeHolder(),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedSmoothIndicator(
                    activeIndex: _current.value,
                    count: (widget.listSlide)!.length,
                    effect: const WormEffect(
                      activeDotColor: AppColors.primaryColor,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: nextButton(context),
    );
  }

  Widget nextButton(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        color: AppColors.whiteColor,
        width: double.infinity,
        child: globalButton(
          context: context,
          buttonText: 'next'.tr,
          onPressed: () {
            ValueStatic().clearCarRental();

            Get.toNamed(AppRoutes.carRentalInfo);
          },
        ),
      ),
    );
  }

  Padding placeHolder() {
    return const Padding(
      padding: EdgeInsets.only(top: 10),
      child: Center(
        child: SizedBox(
          height: 30.0,
          width: 30.0,
          child: CircularProgressIndicator(value: null, strokeWidth: 2.0),
        ),
      ),
    );
  }

  Container list(String path, String title) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: path,
              height: 30,
              width: 30,
              fit: BoxFit.contain,
              placeholder:
                  (context, url) => const SizedBox(height: 30, width: 30),
              errorWidget:
                  (context, url, error) => Image.asset(
                    AssetImages.place_holder,
                    height: 30,
                    width: 30,
                    fit: BoxFit.contain,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width / 37,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
