import 'package:express_vet/asset_image.dart';
import 'package:express_vet/models/schedule/total_by_journey_response.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/button.dart';
import 'package:express_vet/utils/platform_insets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/style.dart';

import '../binding/rate_schedule_binding.dart';
import '../controller/rate_schedule_controller.dart';

class RateScheduleScreen extends GetView<RateScheduleController> {
  final int? scheduleId; //use to display star
  final String? id; //use to rate

  const RateScheduleScreen({
    super.key,
    required this.scheduleId,
    required this.id,
  });

  @override
  RateScheduleController get controller {
    if (!Get.isRegistered<RateScheduleController>()) {
      RateScheduleBinding().dependencies();
    }
    return Get.find<RateScheduleController>();
  }

  @override
  Widget build(BuildContext context) {
    controller.ensureInitialized(
      scheduleId: scheduleId?.toInt() ?? 0,
      ticketId: id.toString(),
    );

    return GestureDetector(
      onTap: () {
        //* When you tap anywhere outside the keyboard, it closes the keyboard.
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBarVET().appBar(context, 'reate_a_schedule'.tr),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //* star and rating
                Obx(() {
                  final future = controller.state.futureTotalByJourney;
                  if (future == null) {
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
                  }

                  return FutureBuilder<TotalByJourneyResponse>(
                    future: future,
                    builder: (context, dataReview) {
                      if (dataReview.hasData) {
                        if (dataReview.data!.header?.statusCode == 200 &&
                            dataReview.data!.header?.result == true) {
                          if (dataReview.data!.body!.isNotEmpty) {
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        '${dataReview.data?.body?[0].totalRate ?? 0}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RatingBarIndicator(
                                        rating:
                                            dataReview
                                                .data
                                                ?.body?[0]
                                                .totalRate ??
                                            0.0,
                                        itemBuilder:
                                            (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.orange,
                                            ),
                                        itemCount: 5,
                                        itemSize: 24,
                                        unratedColor: Colors.grey[300],
                                        direction: Axis.horizontal,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${'based_on'.tr} ${dataReview.data?.body?[0].totalView ?? 0} ${'review'.tr}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildRatingBar(
                                  'excellent'.tr,
                                  (dataReview.data?.body?[0].rateFive ?? 0.0)
                                      .toDouble(),
                                  Colors.green,
                                ),
                                _buildRatingBar(
                                  'good'.tr,
                                  (dataReview.data?.body?[0].rateFour ?? 0.0)
                                      .toDouble(),
                                  Colors.lightGreen,
                                ),
                                _buildRatingBar(
                                  'average'.tr,
                                  (dataReview.data?.body?[0].rateThree ?? 0.0)
                                      .toDouble(),
                                  Colors.yellow,
                                ),
                                _buildRatingBar(
                                  'below_average'.tr,
                                  (dataReview.data?.body?[0].rateTwo ?? 0.0)
                                      .toDouble(),
                                  Colors.orange,
                                ),
                                _buildRatingBar(
                                  'poor'.tr,
                                  (dataReview.data?.body?[0].rateOne ?? 0.0)
                                      .toDouble(),
                                  Colors.red,
                                ),
                              ],
                            );
                          } else {
                            return SizedBox(
                              height: double.infinity,
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(AssetImages.ic_empty, height: 84),
                                  Text('receiving_list_is_empty'.tr),
                                ],
                              ),
                            );
                          }
                        }
                      } else if (dataReview.hasError) {
                        debugPrint('error ${dataReview.error}');
                      }

                      return Center(
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
                  );
                }),

                const SizedBox(height: 30),
                 Text(
                  'reate_a_schedule'.tr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 5),
                 Text(
                  'tell_other'.tr,
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < controller.state.selectedRating
                              ? Icons.star
                              : Icons.star_border_outlined,
                          color:
                              index < controller.state.selectedRating
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                        ),
                        onPressed: () {
                          controller.toggleRating(index);
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.reviewController,
                  autofocus: false,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: Style.inputText('wite_a_review'.tr),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Obx(() {
          if (controller.state.selectedRating <= 0) {
            return const SizedBox.shrink();
          }
          final useSafeArea = PlatformInsets.useSafeArea;
    final iosBottomInset = PlatformInsets.iosBottomInset();

          return SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: useSafeArea,
            child: Container(
              color: AppColors.whiteColor,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 15, iosBottomInset),
                child: globalButton(
                  context: context,
                  buttonText: 'post'.tr,
                  onPressed: () {
                    controller.post(context: context);
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  //* widget for rating bar
  Widget _buildRatingBar(String label, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: percentage / 100,
              color: color,
              backgroundColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
