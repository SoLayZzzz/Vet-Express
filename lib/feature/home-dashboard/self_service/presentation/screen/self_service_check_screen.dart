import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';

import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';

import '../controller/self_service_controller.dart';

class SelfServiceCheckScreen extends GetView<SelfServiceController> {
  final String? senderPhone;
  final String? receiverPhone;
  final String? itemPrice;
  final String? amount;

  const SelfServiceCheckScreen({
    super.key,
    this.receiverPhone,
    this.itemPrice,
    this.amount,
    this.senderPhone,
  });

  String _argString(String key, String? fallback) {
    final args = Get.arguments;
    if (args is Map && args[key] != null) {
      return args[key].toString();
    }
    return fallback ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final senderPhoneText = _argString('senderPhone', senderPhone);
    final receiverPhoneText = _argString('receiverPhone', receiverPhone);
    final itemPriceText = _argString('itemPrice', itemPrice);
    final amountText = _argString('amount', amount);

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
                            controller.saveSelfService(
                              context,
                              ValueStatic.locationId,
                              amountText,
                              itemPriceText,
                              receiverPhoneText,
                              senderPhoneText,
                              ValueStatic.uomId,
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'save'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'edit'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
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
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'plz_check'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),
                      textView(context, 'sender_telephone'.tr, senderPhoneText),
                      const SizedBox(height: 15),
                      textView(
                        context,
                        'receiver_telephone'.tr,
                        receiverPhoneText,
                      ),
                      const SizedBox(height: 15),
                      textView(
                        context,
                        'pro_city'.tr,
                        ValueStatic.provinceName,
                      ),
                      const SizedBox(height: 15),
                      textView(
                        context,
                        'location'.tr,
                        ValueStatic.locationName,
                      ),
                      const SizedBox(height: 15),
                      textView(context, 'item_price'.tr, '$itemPriceText\$'),
                      const SizedBox(height: 15),
                      textView(context, 'amount'.tr, amountText),
                      const SizedBox(height: 15),
                      textView(context, 'unit'.tr, ValueStatic.uomName),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row textView(BuildContext context, String title, String description) {
    return Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Text(title, maxLines: 2),
        ),
        Expanded(child: Text(': $description', maxLines: 2)),
      ],
    );
  }
}
