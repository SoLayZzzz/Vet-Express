import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:express_vet/activities/ticket/ticket_schedule_car_detail_map_screen.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/routes/app_routes.dart';

import '../../feature/schedule/data/model/response/schedule_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/button.dart';

class TicketScheduleCarDetailScreen extends StatefulWidget {
  final String journeyId;
  final String carType;
  final String seat;
  final String image;
  final String description;
  final int type;
  final int status;
  final List<SlidePhoto>? listSlide;
  final List<Amenities>? listIcon;
  final List<BoardingPointList>? boardingPoint;
  final List<DropOffPointList>? dropOffPoint;

  const TicketScheduleCarDetailScreen({
    super.key,
    required this.carType,
    required this.seat,
    required this.image,
    required this.listSlide,
    required this.listIcon,
    required this.journeyId,
    required this.type,
    required this.boardingPoint,
    required this.dropOffPoint,
    required this.description,
    required this.status,
  });

  @override
  State<TicketScheduleCarDetailScreen> createState() =>
      _TicketScheduleCarDetailScreenState();
}

class _TicketScheduleCarDetailScreenState
    extends State<TicketScheduleCarDetailScreen> {
  int _current = 0;
  final CarouselSliderController _controller = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(
        context,
        widget.type == 1
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
                if ((widget.listSlide)!.isNotEmpty)
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
                            height: MediaQuery.of(context).size.height * 0.25,
                            aspectRatio: 16 / 9,
                            initialPage: 0,
                            autoPlayCurve: Curves.fastOutSlowIn,
                            enableInfiniteScroll: true,
                            onPageChanged: (index, reason) {
                              setState(() {
                                _current = index;
                              });
                            },
                          ),
                          items:
                              widget.listSlide
                                  ?.map(
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
                                              imageUrl: item.photo.toString(),
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
                                    child: AnimatedSmoothIndicator(
                                      activeIndex: _current,
                                      count: (widget.listSlide)!.length,
                                      effect: const ExpandingDotsEffect(
                                        activeDotColor: AppColors.primaryColor,
                                        dotHeight: 8,
                                        dotWidth: 8,
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
                    if (widget.boardingPoint!.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: (widget.boardingPoint)!.length,
                          separatorBuilder:
                              (context, int index) => Container(
                                height: 1,
                                color: AppColors.borderColor,
                              ),
                          itemBuilder: (context, i) {
                            return getAddress(
                              (widget.boardingPoint?[i].name).toString(),
                              (widget.boardingPoint?[i].address).toString(),
                              i,
                              double.parse(
                                (widget.boardingPoint?[i].lats).toString(),
                              ),
                              double.parse(
                                (widget.boardingPoint?[i].longs).toString(),
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
                    if (widget.dropOffPoint!.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: (widget.dropOffPoint)!.length,
                          separatorBuilder:
                              (context, int index) => Container(
                                height: 1,
                                color: AppColors.borderColor,
                              ),
                          itemBuilder: (context, i) {
                            return getAddress(
                              (widget.dropOffPoint?[i].name).toString(),
                              (widget.dropOffPoint?[i].address).toString(),
                              i,
                              double.parse(
                                (widget.dropOffPoint?[i].lats).toString(),
                              ),
                              double.parse(
                                (widget.dropOffPoint?[i].longs).toString(),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
                if ((widget.listIcon)!.isNotEmpty)
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
                if ((widget.listIcon)!.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1 / 0.7,
                        ),
                    itemCount: (widget.listIcon)!.length,
                    itemBuilder: (BuildContext context, i) {
                      return listAmen(
                        (widget.listIcon?[i].icon).toString(),
                        (widget.listIcon?[i].name).toString(),
                      );
                    },
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    if (widget.description.isNotEmpty)
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
                          widget.description
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
      bottomNavigationBar: Container(
        width: double.infinity,
        color: AppColors.whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child:
            widget.status == 1
                ? globalButton(
                  context: context,
                  buttonText: 'booking_ticket'.tr,
                  buttonColor:
                      ValueStatic.ticketType == '3'
                          ? AppColors.airBusColor
                          : AppColors.primaryColor,
                  onPressed: () {
                    if (widget.type == 1) {
                      Get.toNamed(
                        AppRoutes.selectSeat,
                        arguments: {
                          'journeyId': widget.journeyId,
                          'isBack': false,
                        },
                      );
                    } else {
                      Get.toNamed(
                        AppRoutes.selectSeat,
                        arguments: {
                          'journeyId': widget.journeyId,
                          'isBack': true,
                        },
                      );
                    }
                  },
                )
                : globalButton(
                  context: context,
                  buttonText:
                      widget.status == 3
                          ? 'full'.tr
                          : (widget.status == 4 ? 'unavailable'.tr : 'left'.tr),
                  buttonColor: Colors.grey,
                  onPressed: () {},
                ),
      ),
    );
  }

  SizedBox placeHolder() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image(
          image: const AssetImage('assets/images/place_holder.png'),
          height: MediaQuery.of(context).size.height * 0.25,
          width: double.infinity,
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }

  Column listAmen(String path, String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          path,
          height: 30,
          errorBuilder: (context, error, stackTrace) {
            return Image(
              image: const AssetImage('assets/images/place_holder.png'),
              height: 30,
              fit: BoxFit.cover,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Image(
              image: const AssetImage('assets/images/place_holder.png'),
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

  InkWell getAddress(
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
