import 'dart:developer';
import 'package:express_vet/feature/home-dashboard/ev-charger/presentation/screen/ev_charger_wallet_screen.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_scan_qr_response.dart'
    as ev_scan;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../api/ev.dart';
import 'ev_wallet_controller.dart';

class EvScannerController extends GetxController {
  final EV _apiService = EV();
  late final EvWalletController walletController;

  @override
  void onInit() {
    super.onInit();
    walletController = Get.find<EvWalletController>();
  }

  // Observables
  var isLoading = false.obs;
  var isScanning = true.obs;
  var isFlashOn = false.obs;
  var scanResult = Rx<String?>(null);
  var transactionData = Rxn<ev_scan.Datum>();
  var errorMessage = Rx<String?>(null);

  // Mobile Scanner Controller
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  // Handle QR detection
  void onQRDetect(BarcodeCapture capture) {
    if (!isScanning.value) return;

    final barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String qrData = barcodes.first.rawValue ?? '';

      if (qrData.isNotEmpty) {
        isScanning.value = false;
        _processScannedQR(qrData.trim());
      }
    }
  }

  // Process scanned QR code
  Future<void> _processScannedQR(String transactionId) async {
    isLoading.value = true;

    try {
      final response = await _apiService.eVScanQR(Get.context!, transactionId);

      if (response.body?.status == true &&
          response.body?.data != null &&
          response.body!.data!.isNotEmpty) {
        scanResult.value = transactionId;
        transactionData.value = response.body!.data!.first;
        _showFullScreenVerificationDialog();
      } else {
        errorMessage.value = response.body?.message ?? 'Scan failed';
        _showScanFailedDialog(errorMessage.value!);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _showScanFailedDialog('Scan failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Confirm payment
  Future<void> confirmPayment() async {
    final transactionId = scanResult.value;
    if (transactionId == null) return;

    isLoading.value = true;

    try {
      final response = await _apiService.eVConfirmPayment(
        Get.context!,
        transactionId,
      );

      if (response.header?.result == true &&
          response.header?.statusCode == 200) {
        if (response.body?.status == true &&
            response.body?.message == 'success') {
          // Update wallet balance after charging
          if (transactionData.value != null &&
              transactionData.value!.totalPrice != null) {
            walletController.updateBalanceAfterCharging();
          }

          // Payment successful
          Get.back(); // Close verification dialog
          _showFullScreenPaymentSuccessDialog();
        } else {
          errorMessage.value = response.body?.message ?? 'Payment failed';
          _showPaymentErrorDialog();
        }
      } else {
        errorMessage.value = response.body?.message ?? 'Payment failed';
        _showPaymentErrorDialog();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      _showPaymentErrorDialog();
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle flashlight
  void toggleFlashlight() async {
    try {
      await cameraController.toggleTorch();
      isFlashOn.value = !isFlashOn.value;
    } catch (e) {
      log('Flashlight error: $e');
    }
  }

  // Full-screen Verification Dialog
  void _showFullScreenVerificationDialog() {
    final data = transactionData.value;

    Get.dialog(
      _FullScreenVerificationDialog(
        data: data,
        onConfirm: confirmPayment,
        onCancel: () {
          Get.back();
          retryScan();
        },
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      barrierDismissible: false,
    );
  }

  // Full-screen Payment Success Dialog
  void _showFullScreenPaymentSuccessDialog() {
    final data = transactionData.value;

    Get.dialog(
      _FullScreenPaymentSuccessDialog(
        data: data,
        onDone: _navigateToWalletScreen,
        onScanAgain: () {
          Get.back(); // Close success dialog
          retryScan(); // Restart scanning
        },
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      barrierDismissible: false,
    );
  }

  // Dialog: Scan Failed (Keep as small dialog)
  void _showScanFailedDialog(String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Scan Failed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        resetScanner();
                        Get.back(); // Close scanner screen
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        retryScan();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Scan Again",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Dialog: Payment Error
  void _showPaymentErrorDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Payment Failed",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage.value ??
                    "Payment confirmation failed. Please try again.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _showFullScreenVerificationDialog(); // Show verification dialog again
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        "Try Again",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Navigate to EvChargerScreen
  void _navigateToWalletScreen() {
    resetScanner();
    Get.back();
    // If EvChargerScreen is not the first screen, navigate to it
    Get.off(
      () => EvWalletScreen(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }

  // Helper methods
  void retryScan() {
    resetScanner();
    isScanning.value = true;
  }

  void resetScanner() {
    isLoading.value = false;
    isScanning.value = true;
    scanResult.value = null;
    transactionData.value = null;
    errorMessage.value = null;
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}

// ==================== FULL SCREEN VERIFICATION DIALOG ====================
class _FullScreenVerificationDialog extends StatelessWidget {
  final ev_scan.Datum? data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _FullScreenVerificationDialog({
    required this.data,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final EvScannerController controller = Get.find<EvScannerController>();
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: onCancel,
          ),
          title: const Text(
            "Verification",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                const SizedBox(height: 10),
                const Text(
                  "Please verify all information",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 25),

                // Transaction Details Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Transaction Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Transaction ID
                      _buildDetailRow(
                        "Transaction ID",
                        data?.transactionId ?? "N/A",
                      ),
                      const Divider(height: 30),

                      // Station Name
                      _buildDetailRow(
                        "Station Name",
                        data?.stationName ?? "N/A",
                      ),
                      const Divider(height: 30),

                      // Order Date
                      _buildDetailRow("Order Date", data?.orderDate ?? "N/A"),
                      const Divider(height: 30),

                      // Total kWh
                      _buildDetailRow(
                        "Total kWh",
                        "${data?.totalKwh ?? 0} kWh",
                      ),
                      const Divider(height: 30),

                      // Total Amount
                      _buildDetailRow(
                        "Total Amount",
                        "${data?.totalPrice?.toStringAsFixed(2) ?? "0.00"} KHR",
                        isAmount: true,
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Info Note
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Please make sure all details are correct before confirming payment.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Confirm Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE65100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        disabledBackgroundColor: Colors.grey[400],
                      ),
                      child:
                          controller.isLoading.value
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.verified,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Confirm Payment",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isAmount ? const Color(0xFFE65100) : Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ==================== FULL SCREEN PAYMENT SUCCESS DIALOG ====================
class _FullScreenPaymentSuccessDialog extends StatelessWidget {
  final ev_scan.Datum? data;
  final VoidCallback onDone;
  final VoidCallback onScanAgain;

  const _FullScreenPaymentSuccessDialog({
    required this.data,
    required this.onDone,
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Success Header Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Success Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Success Title
                    const Text(
                      "Payment Successful!",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Success Message
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Your payment has been confirmed successfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Transaction Details Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 25,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Transaction Details Title
                    const Text(
                      "Transaction Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          if (data != null) ...[
                            _buildSummaryRow(
                              "Transaction ID",
                              data?.transactionId ?? "N/A",
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              "Station Name",
                              data?.stationName ?? "N/A",
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              "Amount",
                              "${data?.totalPrice?.toStringAsFixed(2) ?? "0.00"} KHR",
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow(
                              "Energy",
                              "${data?.totalKwh ?? 0} kWh",
                            ),
                            const SizedBox(height: 12),
                            _buildSummaryRow("Date", data?.orderDate ?? "N/A"),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Done Button - Updated text to be more descriptive
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: onDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE65100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 22,
                            ), // Changed icon
                            SizedBox(width: 10),
                            Text(
                              "Go to Wallet", // Updated text
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Back to Scanner Button
                    TextButton(
                      onPressed: onScanAgain,
                      child: const Text(
                        "Scan Another QR",
                        style: TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: label == "Amount" ? const Color(0xFFE65100) : Colors.black87,
          ),
        ),
      ],
    );
  }
}
