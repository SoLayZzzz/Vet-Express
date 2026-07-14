import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/ev_top_up_controller.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/style.dart';

class EvTopUpScreen extends GetView<EvTopUpController> {
  const EvTopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'top_up'.tr),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAmountTitle(),
              const SizedBox(height: 16),
              _buildAmountGrid(),
              const SizedBox(height: 20),
              _buildCustomAmountLabel(),
              const SizedBox(height: 8),
              _buildCustomAmountField(),
              const SizedBox(height: 20),
              _buildPaymentTitle(),
              const SizedBox(height: 6),
              _buildKHQRPaymentOption(),
              const SizedBox(height: 40),
              _buildTopUpButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountTitle() {
    return Text(
      'choose_amount'.tr,
      style: const TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  Widget _buildAmountGrid() {
    return GetBuilder<EvTopUpController>(
      builder: (controller) {
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: controller.predefinedAmounts.length,
          itemBuilder: (context, index) {
            final amount = controller.predefinedAmounts[index];
            final isSelected = controller.selectedAmount.value == amount;
            return GestureDetector(
              onTap: () => controller.selectAmount(amount),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.primaryColor
                          : Color(0xFF1E3A8A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primaryColor
                            : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 2,
                      ),
                  ],
                ),
                child: Text(
                  "${amount.toStringAsFixed(0)} KHR",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color:
                        isSelected
                            ? AppColors.whiteColor
                            : AppColors.secondaryColor,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomAmountLabel() {
    return Text(
      'enter_amount'.tr,
      style: const TextStyle(color: Colors.grey, fontSize: 16),
    );
  }

  Widget _buildCustomAmountField() {
    return GetBuilder<EvTopUpController>(
      builder: (controller) {
        return TextField(
          controller: controller.amountController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: controller.updateCustomAmount,
          style: const TextStyle(fontSize: 14, color: AppColors.textColor),
          decoration: Style.inputText('enter_amount'.tr).copyWith(
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'KHR',
                style: TextStyle(fontSize: 16, color: AppColors.textColor),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentTitle() {
    return Text(
      'choose_payment'.tr,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.titleColor,
      ),
    );
  }

  Widget _buildKHQRPaymentOption() {
    return GetBuilder<EvTopUpController>(
      builder: (controller) {
        final isSelectedABA = controller.paymentMethodId.value == 1;
        final isSelectedACLEDA = controller.paymentMethodId.value == 2;

        final showABA = controller.isPaymentMethodEnabled('ABA');
        final showAC = controller.isPaymentMethodEnabled('AC');

        if (controller.isLoadingPaymentMethods.value) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        }

        if (!showABA && !showAC) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'no_payment_methods_available'.tr,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ),
          );
        }

        return Column(
          children: [
            if (showABA) _buildABACard(controller, isSelectedABA),
            if (showAC) _buildAcledaCard(controller, isSelectedACLEDA),
          ],
        );
      },
    );
  }

  Widget _buildAcledaCard(EvTopUpController controller, bool isSelectedACLEDA) {
    return GestureDetector(
            onTap: () => controller.selectPaymentMethod('ACLEDA', 2),
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color:
                      isSelectedACLEDA
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                  width: isSelectedACLEDA ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Image.asset(AssetImages.ic_acleda, height: 44),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACLEDA PAY / KHQR',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.titleColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Bank Account / Wallet Account',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelectedACLEDA
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          isSelectedACLEDA
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildABACard(EvTopUpController controller, bool isSelectedABA) {
    return GestureDetector(
            onTap: () => controller.selectPaymentMethod('ABA Pay', 1),
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color:
                      isSelectedABA
                          ? AppColors.primaryColor
                          : AppColors.borderColor,
                  width: isSelectedABA ? 1.5 : 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Image.asset(AssetImages.ic_aba, height: 44),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ABA KHQR',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.titleColor,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'tap_to_pay_with_KHQR'.tr,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelectedABA
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color:
                          isSelectedABA
                              ? AppColors.primaryColor
                              : AppColors.borderColor,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget _buildTopUpButton() {
    return GetBuilder<EvTopUpController>(
      builder: (controller) {
        final showABA = controller.isPaymentMethodEnabled('ABA');
        final showAC = controller.isPaymentMethodEnabled('AC');

        // Hide button if no payment methods are available
        if (!showABA && !showAC) return const SizedBox.shrink();

        final isNoPaymentSelected = controller.paymentMethodId.value == 0;

        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed:
                controller.isLoading.value
                    ? null
                    : () {
                      debugPrint(
                        'EvTopUpScreen.TopUpButton.tap amount=${controller.finalAmount}, '
                        'paymentMethodId=${controller.paymentMethodId.value}, '
                        'paymentMethodName=${controller.selectedPaymentMethod.value}',
                      );
                      controller.performTopUp();
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: isNoPaymentSelected ? Colors.grey : AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child:
                controller.isLoading.value
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      "top_up".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        );
      },
    );
  }
}
