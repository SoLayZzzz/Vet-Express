import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/feature/home-dashboard/schedule/data/network/schedule_network_request.dart';
import '../../../../../models/schedule/list_by_journey_response.dart';
import '../../../../../models/schedule/total_by_journey_response.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/button.dart';

class ReviewRateScreen extends StatefulWidget {
  final int? scheduleId; //use for rate
  final int? status;
  final int? type;
  final String? id; //use for booking

  const ReviewRateScreen({
    super.key,
    required this.scheduleId,
    required this.status,
    required this.type,
    this.id,
  });

  @override
  State<ReviewRateScreen> createState() => _ReviewRateScreenState();
}

class _ReviewRateScreenState extends State<ReviewRateScreen> {
  late Future<TotalByJourneyResponse> reviewRate;
  late Future<ListByJourneyResponse> reviewRateUser;

  final ScheduleNetworkRequest _scheduleNetworkRequest =
      Get.find<ScheduleNetworkRequest>();

  @override
  void initState() {
    super.initState();

    reviewRateUser = _scheduleNetworkRequest.fetchListByJourney(
      context: context,
      scheduleId: widget.scheduleId?.toInt() ?? 0,
    );
    reviewRate = _scheduleNetworkRequest.fetchTotalByJourney(
      context: context,
      scheduleId: widget.scheduleId?.toInt() ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, "Review"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),

            //* star and rating
            FutureBuilder<TotalByJourneyResponse>(
              future: reviewRate,
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
                                // Star rating
                                RatingBarIndicator(
                                  rating:
                                      dataReview.data?.body?[0].totalRate ??
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
                                  'Based on ${dataReview.data?.body?[0].totalView ?? 0} reviews',
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
                            'Excellent',
                            (dataReview.data?.body?[0].rateFive ?? 0.0)
                                .toDouble(),
                            Colors.green,
                          ),
                          _buildRatingBar(
                            'Good',
                            (dataReview.data?.body?[0].rateFour ?? 0.0)
                                .toDouble(),
                            Colors.lightGreen,
                          ),
                          _buildRatingBar(
                            'Average',
                            (dataReview.data?.body?[0].rateThree ?? 0.0)
                                .toDouble(),
                            Colors.yellow,
                          ),
                          _buildRatingBar(
                            'Below Average',
                            (dataReview.data?.body?[0].rateTwo ?? 0.0)
                                .toDouble(),
                            Colors.orange,
                          ),
                          _buildRatingBar(
                            'Poor',
                            (dataReview.data?.body?[0].rateOne ?? 0.0)
                                .toDouble(),
                            Colors.red,
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    } else {
                      return SizedBox(
                        height: double.infinity,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/ic_empty.png',
                              height: 84,
                            ),
                            Text('receiving_list_is_empty'.tr),
                          ],
                        ),
                      );
                    }
                  }
                } else if (dataReview.hasError) {
                  debugPrint('error ${dataReview.error}');
                }
                return const SizedBox(
                  height: 200, // Define a reasonable height
                  child: Center(
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 5.0,
                    ),
                  ),
                );
              },
            ),

            //* user comment
            FutureBuilder<ListByJourneyResponse>(
              future: reviewRateUser,
              builder: (context, dataUser) {
                if (dataUser.hasData) {
                  if (dataUser.data!.header?.statusCode == 200 &&
                      dataUser.data?.header?.result == true) {
                    if (dataUser.data!.body!.isNotEmpty) {
                      return ListView.separated(
                        padding: const EdgeInsets.only(bottom: 15),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dataUser.data!.body!.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          return _buildReviewTile(
                            dataUser.data?.body?[index].photo ?? '',
                            dataUser.data?.body?[index].name ?? '',
                            dataUser.data?.body?[index].score ?? 0,
                            dataUser.data?.body?[index].comment ?? '',
                          );
                        },
                      );
                    }
                  }
                } else if (dataUser.hasError) {
                  debugPrint('error ${dataUser.error}');
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
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
                            'journeyId': widget.id.toString(),
                            'isBack': false,
                          },
                        );
                      } else {
                        Get.toNamed(
                          AppRoutes.selectSeat,
                          arguments: {
                            'journeyId': widget.id.toString(),
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
                            : (widget.status == 4
                                ? 'unavailable'.tr
                                : 'left'.tr),
                    buttonColor: Colors.grey,
                    onPressed: () {},
                  ),
        ),
      ),
    );
  }

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

  Widget _buildReviewTile(
    String img,
    String username,
    int rating,
    String review,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(img),
              onBackgroundImageError: (_, __) {},
              child: img.isEmpty ? placeHolder() : null,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: index < rating ? Colors.orange : Colors.grey,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rating.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(review, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget placeHolder() {
    return const CircleAvatar(
      backgroundColor: AppColors.borderColor,
      backgroundImage: AssetImage('assets/images/img_user_profile.png'),
    );
  }
}
