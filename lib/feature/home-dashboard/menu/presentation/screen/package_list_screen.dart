import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:express_vet/feature/home-dashboard/menu/presentation/screen/package_info_screen.dart';
import 'package:express_vet/api/travel_package.dart';
import 'package:express_vet/models/travel_package/travel_package_list_response.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import '../../../../../models/travel_package/travel_package_content.dart';
import '../../../../../utils/contains.dart';

class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  late Future<TravelPackageListResponse> travelPackageListFuture;
  late Future<TravelPackageContent> travelPackageContent;

  @override
  void initState() {
    super.initState();

    travelPackageListFuture = TravelPackage().getList(context);
    travelPackageContent = TravelPackage().getContent(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'booking_travel_package2'.tr),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<TravelPackageContent>(
                  future: travelPackageContent,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.header?.statusCode == 200 &&
                        snapshot.data?.header?.result == true) {
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.body!.length,
                        itemBuilder: (context, index) {
                          final models = snapshot.data!.body![0];

                          String getLocalizedText() {
                            if (Get.locale.toString() == 'km_KH') {
                              return models.descKh?.isNotEmpty == true
                                  ? models.descKh!
                                  : models.descEn ?? '';
                            } else if (Get.locale.toString() == 'zh_CN') {
                              return models.descCn?.isNotEmpty == true
                                  ? models.descCn!
                                  : models.descEn ?? '';
                            } else {
                              return models.descEn ?? '';
                            }
                          }

                          final localizedText = getLocalizedText();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: Text(
                                  Get.locale.toString() == 'km_KH'
                                      ? (models.titleKh?.isNotEmpty == true
                                          ? models.titleKh!
                                          : models.titleEn ?? '')
                                      : Get.locale.toString() == 'zh_CN'
                                      ? (models.titleCn?.isNotEmpty == true
                                          ? models.titleCn!
                                          : models.titleEn ?? '')
                                      : models.titleEn ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ReadMoreText(
                                localizedText,
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
                            ],
                          );
                        },
                      );
                    }
                    return const Text('');
                  },
                ),
                const SizedBox(height: 12),
                FutureBuilder<TravelPackageListResponse>(
                  future: travelPackageListFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.header?.statusCode == 200 &&
                        snapshot.data?.header?.result == true) {
                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.body!.length,
                        itemBuilder: (context, index) {
                          final models = snapshot.data!.body![index];

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade200),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 140,
                                        height: 130,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            imageUrl: models.photo!,
                                            placeholder:
                                                (context, url) => placeHolder(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    placeHolder(),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              Get.locale.toString() == 'km_KH'
                                                  ? (models
                                                              .nameKh
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? models.nameKh!
                                                      : models.name ?? '')
                                                  : Get.locale.toString() ==
                                                      'zh_CN'
                                                  ? (models
                                                              .nameCn
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? models.nameCn!
                                                      : models.name ?? '')
                                                  : models.name ?? '',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Text(
                                              Get.locale.toString() == 'km_KH'
                                                  ? (models
                                                              .descriptionKh
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? models.descriptionKh!
                                                      : models.description ??
                                                          '')
                                                  : Get.locale.toString() ==
                                                      'zh_CN'
                                                  ? (models
                                                              .descriptionCn
                                                              ?.isNotEmpty ==
                                                          true
                                                      ? models.descriptionCn!
                                                      : models.description ??
                                                          '')
                                                  : models.description ?? '',
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 36,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            50,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primaryColor,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '\$${models.price}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.primaryColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (models
                                                .originalPrice!
                                                .isNotEmpty)
                                              const SizedBox(width: 5),
                                            if (models
                                                .originalPrice!
                                                .isNotEmpty)
                                              Text(
                                                '\$${models.originalPrice}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  decoration:
                                                      TextDecoration
                                                          .lineThrough,
                                                  color: AppColors.textColor,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Get.to(
                                            () => PackageInfoScreen(
                                              travelPackageId: models.id!,
                                            ),
                                            transition: Transition.rightToLeft,
                                            duration: const Duration(
                                              milliseconds: Constrains.duration,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          height: 36,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              50,
                                            ),
                                            color: const Color(0xFFE38F5A),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'buy_now'.tr,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: AppColors.whiteColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 10);
                        },
                      );
                    }

                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      width: double.infinity,
                      child: const Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox placeHolder() {
    return const SizedBox(
      height: 130.0,
      width: 140.0,
      child: Image(
        image: AssetImage('assets/images/place_holder.png'),
        fit: BoxFit.cover,
      ),
    );
  }
}
