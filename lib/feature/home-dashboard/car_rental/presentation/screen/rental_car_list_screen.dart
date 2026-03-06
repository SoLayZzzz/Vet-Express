import 'package:cached_network_image/cached_network_image.dart';
import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../routes/app_routes.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../controller/car_rental_controller.dart';
import '../../data/model/response/car_rental_car_type_response.dart';
import 'rental_car_info_screen.dart';

class RentalCarListScreen extends StatefulWidget {
  const RentalCarListScreen({super.key});

  @override
  State<RentalCarListScreen> createState() => _RentalCarListScreenState();
}

class _RentalCarListScreenState extends State<RentalCarListScreen> {
  late final CarRentalController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CarRentalController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadCarTypes(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'car_rental1'.tr),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'vehicle_bar'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleColor,
                ),
              ),
              const SizedBox(height: 10),
              ReadMoreText(
                'vehicle readme'.tr,
                trimMode: TrimMode.Line,
                trimLines: 3,
                moreStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.seeMoreColor,
                ),
                trimCollapsedText: 'see_more'.tr,
                lessStyle: const TextStyle(
                  fontSize: 14,
                  color: AppColors.titleColor,
                ),
                trimExpandedText: 'see_less'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'ask_info'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.greyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () async {
                      final url = Uri.parse('https://t.me/vetairbusexpress');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.borderColor,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(AssetImages.ic_telegram, height: 28),
                          const SizedBox(width: 15),
                          const Text(
                            'Telegram',
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(
                () => FutureBuilder<CarRentalCarTypeResponse>(
                  future: controller.state.futureCarTypes,
                  builder: (context, carTypeData) {
                    if (carTypeData.hasData) {
                      if (carTypeData.data!.header?.statusCode == 200 &&
                          carTypeData.data!.header?.result == true) {
                        if (carTypeData.data!.body?.data?.isNotEmpty == true) {
                          return ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: carTypeData.data!.body?.data?.length,
                            itemBuilder: (BuildContext context, int index) {
                              final data = carTypeData.data?.body?.data?[index];
                              return item(
                                (data?.id).toString(),
                                (data?.name).toString(),
                                (data?.totalSeat).toString(),
                                (data?.photo).toString(),
                                data?.slidePhoto,
                                data?.amenities,
                              );
                            },
                          );
                        } else {
                          return SizedBox(
                            height: double.infinity,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(AssetImages.ic_empty, height: 84),
                                Text('no_data'.tr),
                              ],
                            ),
                          );
                        }
                      }
                    } else if (carTypeData.hasError) {
                      return const Center(child: Text('Error'));
                    }
                    return const Center(
                      child: SizedBox(
                        height: 50.0,
                        width: 50.0,
                        child: CircularProgressIndicator(
                          value: null,
                          strokeWidth: 5.0,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column item(
    String id,
    String carType,
    String seat,
    String image,
    List<CarRentalSlidePhoto>? slide,
    List<CarRentalAmenities>? icon,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            RentalCarInfoScreen.busId = id;
            RentalCarInfoScreen.carType = carType;
            Get.toNamed(
              AppRoutes.carRentalDetail,
              arguments: {
                'carType': carType,
                'seat': seat,
                'image': image,
                'listSlide': slide,
                'listIcon': icon,
              },
            );
          },
          child: Row(
            children: [
              CachedNetworkImage(
                height: 80,
                width: 140,
                fit: BoxFit.cover,
                imageUrl: image,
                placeholder: (context, url) => placeHolder(),
                errorWidget: (context, url, error) => placeHolder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('$seat ${'seats'.tr}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
      ],
    );
  }

  SizedBox placeHolder() {
    return const SizedBox(
      height: 80.0,
      width: 140.0,
      child: Image(
        image: AssetImage(AssetImages.place_holder),
        fit: BoxFit.cover,
      ),
    );
  }
}
