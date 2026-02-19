import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screen/ev_payment_screen.dart';
import '../screen/payment_success_screen.dart';
import 'ev_wallet_controller.dart';
import 'ev_payment_controller.dart';
import '../../domain/uscase/ev_charger_usecase.dart';

class EvTopUpController extends GetxController {
  final EvChargerUseCase useCase;
  late final EvWalletController walletController;

  EvTopUpController(this.useCase);

  // Amount selection
  final RxDouble selectedAmount = 5000.0.obs;
  final RxString customAmount = ''.obs;
  final List<double> predefinedAmounts = [
    5000,
    10000,
    20000,
    50000,
    100000,
    200000,
  ];

  // Payment method
  final RxString selectedPaymentMethod = 'ABA Pay'.obs;
  final RxInt paymentMethodId = 0.obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Store transaction data
  final RxString currentTransactionId = ''.obs;
  final RxDouble currentTopUpAmount = 0.0.obs;
  final RxBool isCheckingPayment = false.obs;

  // Text controller
  final TextEditingController amountController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    walletController = Get.find<EvWalletController>();
    amountController.text = selectedAmount.value.toStringAsFixed(0);
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }

  void selectAmount(double amount) {
    selectedAmount.value = amount;
    amountController.text = amount.toStringAsFixed(0);
    customAmount.value = '';
    update();
  }

  void updateCustomAmount(String value) {
    customAmount.value = value;
    if (value.isNotEmpty) {
      try {
        selectedAmount.value = double.tryParse(value) ?? 0.0;
      } catch (e) {
        selectedAmount.value = 0.0;
      }
    }
  }

  double get finalAmount {
    if (customAmount.value.isNotEmpty) {
      return double.tryParse(customAmount.value) ?? selectedAmount.value;
    }
    return selectedAmount.value;
  }

  Future<void> performTopUp() async {
    if (finalAmount < 1000) {
      Get.snackbar(
        'Error',
        'Please enter a valid amount',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (paymentMethodId.value == 0) {
      Get.snackbar(
        'Error',
        'Please select a payment method',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';

    try {
      // Send amount in cents (API expects cents)
      final amountInCents = (finalAmount);
      final response = await useCase.walletTopUp(
        context: Get.context!,
        amount: amountInCents.toDouble(),
      );

      if (response.header?.statusCode == 200 && response.body?.status == true) {
        final data = response.body!.data;

        // Store transaction info for status checking
        currentTransactionId.value = data?.transactionId ?? '';
        currentTopUpAmount.value = finalAmount;

        // Check if we have a checkout URL for payment
        if (data?.deeplink != null &&
            data!.deeplink!.isNotEmpty &&
            data.checkoutQrUrl != null &&
            data.checkoutQrUrl!.isNotEmpty) {
          // Navigate to payment screen with checkout URL and transaction ID
          Get.to(
            () => const EvPaymentScreen(),
            binding: BindingsBuilder(() {
              if (Get.isRegistered<EvPaymentController>()) {
                Get.delete<EvPaymentController>();
              }
              Get.put(EvPaymentController());
            }),
            arguments: {
              'deepLink': data.deeplink!,
              'checkoutQrUrl': data.checkoutQrUrl!,
            },
          );

          // Start checking payment status when payment screen closes
          _startPaymentStatusCheck();
        } else {
          Get.back();
          Get.snackbar(
            'Warning',
            'Checkout Qr Url is Empty',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(milliseconds: 2000),
          );
        }
      } else {
        throw Exception(response.body?.message ?? 'Top-up failed');
      }
    } on TimeoutException {
      hasError.value = true;
      errorMessage.value = 'Request timed out';
      Get.snackbar(
        'Error',
        'Request timed out',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Top-up failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startPaymentStatusCheck() {
    // Start checking payment status after a delay
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (currentTransactionId.value.isNotEmpty) {
        _checkPaymentStatus();
      }
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (currentTransactionId.value.isEmpty || isCheckingPayment.value) {
      return;
    }

    isCheckingPayment.value = true;

    try {
      final response = await useCase.walletTopUpStatus(
        context: Get.context!,
        transactionId: currentTransactionId.value,
      );

      if (response.header?.statusCode == 200 && response.body?.status == true) {
        final data = response.body!.data;

        // Check if payment is approved
        if (data?.paymentStatus?.toUpperCase() == 'APPROVED') {
          // Payment successful - fetch latest balance from backend
          await _handleSuccessfulPayment();
          return;
        } else if (data?.paymentStatus?.toUpperCase() == 'PENDING') {
          // Payment still pending, check again after delay
          Future.delayed(const Duration(milliseconds: 5000), () {
            _checkPaymentStatus();
          });
        } else {
          // Payment failed or other status
          _showPaymentFailedPopup(data?.paymentStatus ?? 'Failed');

          // Close screens but show failure
          _closeAllPaymentScreens();
        }
      } else {
        // API error, try again
        Future.delayed(const Duration(milliseconds: 5000), () {
          _checkPaymentStatus();
        });
      }
    } catch (e) {
      // Error checking status, try again
      log('Error checking payment status: $e');
      Future.delayed(const Duration(milliseconds: 5000), () {
        _checkPaymentStatus();
      });
    } finally {
      isCheckingPayment.value = false;
    }
  }

  Future<void> _handleSuccessfulPayment() async {
    try {
      // Fetch the latest balance from backend
      await walletController.fetchBalance();

      // Also refresh transactions to show the new transaction
      await walletController.fetchWalletTransactions();
    } catch (e) {
      log('Error fetching updated balance: $e');
      // Continue anyway - user will still see success
    }

    // Clear transaction data
    currentTransactionId.value = '';
    isCheckingPayment.value = false;

    // Close all payment screens FIRST
    _closeAllPaymentScreens();

    // Then show success screen (with a tiny delay to ensure screens are closed)
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.to(
        () => PaymentSuccessScreen(amount: currentTopUpAmount.value),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 300),
      );
    });
  }

  void completePaymentAndCloseScreens() {
    // Clear transaction data
    currentTransactionId.value = '';
    currentTopUpAmount.value = 0.0;
    isCheckingPayment.value = false;

    // Close all payment-related screens and go back to wallet
    _closeAllPaymentScreens();
  }

  void _closeAllPaymentScreens() {
    // Close any open dialogs
    while (Get.isDialogOpen == true) {
      Get.back();
    }

    // Close payment screen and top-up screen
    // Use a loop to ensure we close all payment-related screens
    int maxAttempts = 5;
    int attempts = 0;

    while (attempts < maxAttempts) {
      final currentRoute = Get.currentRoute;

      if (currentRoute.contains('EvPaymentScreen') ||
          currentRoute.contains('EvTopUpScreen')) {
        Get.back();
        attempts++;
      } else {
        break;
      }
    }
  }

  void _showPaymentFailedPopup(String status) {
    Get.dialog(
      AlertDialog(
        title: const Icon(Icons.error, color: Colors.red, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment $status',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'The payment was not completed successfully. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog and payment screens
              Get.back();
              _closeAllPaymentScreens();
            },
            child: const Text('OK', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Manual trigger to check payment status (can be called from payment screen)
  Future<void> checkPaymentStatusManually() async {
    if (currentTransactionId.value.isNotEmpty) {
      await _checkPaymentStatus();
    }
  }

  // Payment method
  void selectPaymentMethod(String method, int id) {
    selectedPaymentMethod.value = method;
    paymentMethodId.value = id;
    update();
  }
}
