import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../api/request_transfer.dart';
import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';
import '../../utils/check_input.dart';

class ReviewScreen extends StatefulWidget {
  final String goodsTransferID;
  final String type;

  const ReviewScreen({super.key, required this.goodsTransferID, required this.type});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final comment = TextEditingController();

  late int rate = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          appBar: AppBarVET().appBar(context, 'title_survey'.tr),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'survey_ques'.tr,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: 0,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        rate = rating.toInt();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 30),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryColor, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: comment,
                          autofocus: false,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          style: const TextStyle(fontSize: 14),
                          validator: (String? value) {
                            return CheckInput().checkLength(value!, 1, 'survey_required'.tr, '');
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                            hintText: 'survey_comment'.tr,
                            hintMaxLines: 6,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    if (rate != 0)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: CupertinoButton(
                              color: AppColors.primaryColor,
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'survey_submit'.tr,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              onPressed: () {
                                RequestTransfer().review(
                                  widget.goodsTransferID,
                                  comment.text,
                                  rate.toString(),
                                  widget.type,
                                  context,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
