import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart' show Trans;

class ParcelPaymentScreen extends StatefulWidget {
  const ParcelPaymentScreen({super.key});

  @override
  State<ParcelPaymentScreen> createState() => _ParcelPaymentScreenState();
}

class _ParcelPaymentScreenState extends State<ParcelPaymentScreen> {
  int paymentMethodID = 0;

  int paymentMethodSelected = 0;

  bool get _isPayEnabled => paymentMethodSelected != 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text('parcel_payment'.tr),
      ),
      //
      bottomNavigationBar: _buildButtonPay(),
      //
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'choose_payment'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleColor,
                ),
              ),
              _buildPaymentWithKHQR(),
              _buildPaymentWithCeditCard(),
            ],
          ),
      ),
    );
  }

  Widget _buildPaymentWithCeditCard() {
    return GestureDetector(
            onTap: () {
              paymentMethodID = 6;
              paymentMethodSelected = 2;
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color:
                      paymentMethodSelected == 2
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Image.asset('assets/images/ic_big_visa.png', height: 44),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Credit/Debit Card',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.titleColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Image.asset(
                                'assets/images/ic_visa_small.png',
                                height: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      paymentMethodSelected == 2
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          paymentMethodSelected == 2
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildPaymentWithKHQR() {
    return GestureDetector(
            onTap: () {
              paymentMethodID = 5;
              paymentMethodSelected = 1;
              setState(() {});
            },
            child: Container(
              margin: const EdgeInsets.symmetric( vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color:
                      paymentMethodSelected == 1
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Image.asset('assets/images/ic_khqr.png', height: 44),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ABA KHQR',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.titleColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                'tap_to_pay_with_KHQR'.tr,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      paymentMethodSelected == 1
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          paymentMethodSelected == 1
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildButtonPay() {
  return SafeArea(
    child: Container(
                    color: AppColors.whiteColor,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
      child: IgnorePointer(
        ignoring: !_isPayEnabled,
        child: globalButton(
          context: context,
          buttonText: 'pay_now'.tr,
          buttonColor:
              _isPayEnabled ? AppColors.primaryColor : AppColors.greyColor,
          onPressed: () async {
            if (!_isPayEnabled) return;
            debugPrint('Pay now pressed');
          },
        ),
      ),
    ),
  );
}
  
}