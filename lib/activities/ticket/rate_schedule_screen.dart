import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/feature/home-dashboard/schedule/data/network/schedule_network_request.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/style.dart';
import '../../base/base_url.dart';
import '../../models/schedule/total_by_journey_response.dart';
import '../../utils/alert_dialog.dart';
import '../../utils/app_bar.dart';
import '../../utils/app_pref.dart';
import '../../utils/button.dart';
import '../../utils/contains.dart';
import '../../utils/loading.dart';

class RateScheduleScreen extends StatefulWidget {
  final int? scheduleId; //use to display star
  final String? id; //use to rate

  const RateScheduleScreen({
    super.key,
    required this.scheduleId,
    required this.id,
  });

  @override
  RateScheduleScreenState createState() => RateScheduleScreenState();
}

class RateScheduleScreenState extends State<RateScheduleScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  late Future<TotalByJourneyResponse> reviewRate;

  final ScheduleNetworkRequest _scheduleNetworkRequest =
      Get.find<ScheduleNetworkRequest>();

  @override
  void initState() {
    super.initState();
    reviewRate = _scheduleNetworkRequest.fetchTotalByJourney(
      context: context,
      scheduleId: widget.scheduleId?.toInt() ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //* When you tap anywhere outside the keyboard, it closes the keyboard.
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBarVET().appBar(context, 'Rate a schedule'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      log('error ${dataReview.error}');
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

                const SizedBox(height: 30),
                const Text(
                  'Rate a schedule',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tell others what you think',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      icon: Icon(
                        index < _selectedRating
                            ? Icons.star
                            : Icons.star_border_outlined,
                        color:
                            index < _selectedRating
                                ? AppColors.primaryColor
                                : Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          if (_selectedRating == index + 1) {
                            _selectedRating--; // Deselect only the last selected star
                          } else {
                            _selectedRating = index + 1; // Set new rating
                          }
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _reviewController,
                  autofocus: false,
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  decoration: Style.inputText('Write a review'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar:
            _selectedRating > 0
                ? Container(
                  color: AppColors.whiteColor,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: globalButton(
                      context: context,
                      buttonText: 'Post',
                      onPressed: () {
                        saveRateSchedule(
                          context,
                          score: _selectedRating.toString(),
                          ticketId: widget.id.toString(),
                          note: _reviewController.text.toString(),
                        );

                        setState(() {
                          _selectedRating = 0;
                          _reviewController.clear();
                        });
                      },
                    ),
                  ),
                )
                : null,
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

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  saveRateSchedule(
    context, {
    required String score,
    required String ticketId,
    String? note,
  }) async {
    Loading().loadingShow(context);

    var map = <String, dynamic>{};
    map['score'] = score;
    map['ticketId'] = ticketId;
    // Only add 'note' if it's not null and not empty
    if (note != null && note.isNotEmpty) {
      map['note'] = note;
    }

    try {
      final response = await http
          .post(
            Uri.parse('${BaseUrl.BASE_URL}schedule-rate/save'),
            headers: <String, String>{
              "Content-type": "application/x-www-form-urlencoded",
              'Authorization': AppPref.getToken() ?? '',
            },
            body: map,
          )
          .timeout(const Duration(seconds: Constrains.timeout30));

      if (response.statusCode == 200) {
        Loading().loadingClose(context);
        log('This is response rate schedule ==>>${response.body}');
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['body']['status'] == true) {
          String message =
              jsonResponse['body']['message'] ??
              'Successfully posted, Thank you for your rating.';
          alertDialogTravelPackage(
            title: 'info'.tr,
            description: message,
            buttonText: 'close'.tr,
            onButtonPressed: () {
              Get.back();
              Get.back(result: true);
            },
          );
        } else {
          String message =
              jsonResponse['body']['message'] ??
              'Server responded with success status, but operation failed.';
          alertDialogTravelPackage(
            title: 'info'.tr,
            description: message,
            buttonText: 'close'.tr,
            onButtonPressed: () {
              Get.back();
              Get.back(result: false);
            },
          );
        }
      } else {
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
    } catch (e) {
      log('An error occurred: $e');
      rethrow;
    }
  }
}
