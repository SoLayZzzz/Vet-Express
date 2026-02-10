import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/api/request_transfer.dart';

import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';

class SelfServiceCheckScreen extends StatefulWidget {
  final String senderPhone;
  final String receiverPhone;
  final String itemPrice;
  final String amount;

  const SelfServiceCheckScreen(
      {super.key,
      required this.receiverPhone,
      required this.itemPrice,
      required this.amount,
      required this.senderPhone});

  @override
  State<SelfServiceCheckScreen> createState() => _SelfServiceCheckScreenState();
}

class _SelfServiceCheckScreenState extends State<SelfServiceCheckScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarVET().appBar(context, 'check_information'.tr),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Stack(
              children: [
                Positioned(
                  child: Column(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                RequestTransfer().saveGoodsSelfService(
                                    context,
                                    ValueStatic.locationId,
                                    widget.amount,
                                    widget.itemPrice,
                                    widget.receiverPhone,
                                    widget.senderPhone,
                                    ValueStatic.uomId);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.3,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'save'.tr,
                                        style: const TextStyle(fontSize: 13, color: Colors.white),
                                      )),
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width / 2.3,
                                decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'edit'.tr,
                                        style: const TextStyle(fontSize: 13, color: Colors.white),
                                      )),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            'plz_check'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 30),
                          textView('sender_telephone'.tr, widget.senderPhone),
                          const SizedBox(height: 15),
                          textView('receiver_telephone'.tr, widget.receiverPhone),
                          const SizedBox(height: 15),
                          textView('pro_city'.tr, ValueStatic.provinceName),
                          const SizedBox(height: 15),
                          textView('location'.tr, ValueStatic.locationName),
                          const SizedBox(height: 15),
                          textView('item_price'.tr, '${widget.itemPrice}\$'),
                          const SizedBox(height: 15),
                          textView('amount'.tr, widget.amount),
                          const SizedBox(height: 15),
                          textView('unit'.tr, ValueStatic.uomName),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )));
  }

  Row textView(String title, String description) {
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width / 2, child: Text(title, maxLines: 2)),
        Expanded(child: Text(': $description', maxLines: 2)),
      ],
    );
  }
}
