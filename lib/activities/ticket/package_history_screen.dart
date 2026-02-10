import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/api/travel_package.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:widget_zoom/widget_zoom.dart';

import '../../models/travel_package/buy_travel_package_list_response.dart';
import '../../utils/app_colors.dart';

class PackageHistoryScreen extends StatefulWidget {
  const PackageHistoryScreen({super.key});

  @override
  State<PackageHistoryScreen> createState() => _PackageHistoryScreenState();
}

class _PackageHistoryScreenState extends State<PackageHistoryScreen> {
  late Future<BuyTravelPackageListResponse> buyTravelPackageListFuture;

  @override
  void initState() {
    super.initState();
    buyTravelPackageListFuture = TravelPackage().getBuyList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'travel_package_history'.tr),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: FutureBuilder(
          future: buyTravelPackageListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.data!.header?.statusCode == 200 &&
                snapshot.data?.header?.result == true) {
              if (snapshot.data!.body!.isNotEmpty) {
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  primary: false,
                  shrinkWrap: true,
                  itemCount: snapshot.data!.body!.length,
                  itemBuilder: (context, index) {
                    final models = snapshot.data!.body![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'package_pf'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Container(
                                width: 130,
                                height: 130,
                                clipBehavior: Clip.antiAlias,
                                decoration: const BoxDecoration(shape: BoxShape.circle),
                                child: WidgetZoom(
                                  heroAnimationTag:
                                      'profile-image-${models.id}', // Use unique tag for each image
                                  zoomWidget: Image.network(
                                    models.photo!,
                                    width: 130,
                                    height: 130,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Divider(),
                          ),
                          Text(
                            "passenger_detail".tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          _itemDetail(
                            Ionicons.person_outline,
                            '${models.name}',
                            Ionicons.male_female_outline,
                            models.sex == 1 ? 'male'.tr : 'female'.tr,
                          ),
                          _itemDetail(
                            Ionicons.call_outline,
                            '${models.telephone}',
                            Ionicons.flag_outline,
                            '${models.nationalityName}',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              children: [
                                if (models.dob != null && models.dob!.isNotEmpty)
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Ionicons.calendar_outline,
                                          color: Colors.black45,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 10),
                                        Text('${models.dob}'),
                                      ],
                                    ),
                                  ),
                                if (models.email != null && models.email!.isNotEmpty)
                                  Expanded(
                                    flex: 1,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Ionicons.mail_unread_outline,
                                          size: 24,
                                          color: Colors.black45,
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(child: Text('${models.email}')),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Text(
                              Get.locale.toString() == 'km_KH'
                                  ? (models.packageNameKh?.isNotEmpty == true
                                      ? models.packageNameKh!
                                      : models.packageName ?? '')
                                  : Get.locale.toString() == 'zh_CN'
                                  ? (models.packageNameCn?.isNotEmpty == true
                                      ? models.packageNameCn!
                                      : models.packageName ?? '')
                                  : models.packageName ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                          ),
                          _item(label: 'show_package'.tr, value: '${models.packageCode}'),
                          _item(label: 'price'.tr, value: '\$${models.packagePrice}'),
                          _item(label: 'issue_date'.tr, value: '${models.packageDate}'),
                          _item(label: 'expire_date'.tr, value: '${models.packageExpired}'),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Divider(),
                          ),
                          if (models.termCondition!.isNotEmpty)
                            Text(
                              'condition'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.textColor,
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (models.termCondition!.isNotEmpty)
                            Text(
                              Get.locale.toString() == 'km_KH'
                                  ? (models.termConditionKh != null &&
                                          models.termConditionKh!.isNotEmpty
                                      ? models.termConditionKh!
                                      : models.termCondition ?? '')
                                  : Get.locale.toString() == 'zh_CN'
                                  ? (models.termConditionCn != null &&
                                          models.termConditionCn!.isNotEmpty
                                      ? models.termConditionCn!
                                      : models.termCondition ?? '')
                                  : models.termCondition ?? '',
                            ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder:
                      (_, __) => const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Divider(thickness: 1),
                      ),
                );
              } else if (snapshot.data!.body!.isEmpty) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/ic_travel_package.png"),
                      const SizedBox(height: 10),
                      Text(
                        "data_not_found".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }
            }
            return const Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
              ),
            );
          },
        ),
      ),
    );
  }

  _itemDetail(IconData icon1, String name1, IconData icon2, String name2) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(icon1, size: 24, color: Colors.black45),
                const SizedBox(width: 10),
                Text(name1),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                Icon(icon2, size: 24, color: Colors.black45),
                const SizedBox(width: 10),
                Text(name2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _item({required String label, required String value}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(flex: 2, child: Text(label)),
            const Text(":", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(width: 20),
            Expanded(flex: 4, child: Text(value)),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  SizedBox placeHolder() {
    return const SizedBox(
      height: 130.0,
      width: 130.0,
      child: ClipOval(
        child: Image(image: AssetImage('assets/images/place_holder.png'), fit: BoxFit.cover),
      ),
    );
  }
}
