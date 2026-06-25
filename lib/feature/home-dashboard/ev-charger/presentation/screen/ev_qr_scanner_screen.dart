import 'package:express_vet/asset_image.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/ev_scanner_controller.dart';

class EvQrScannerScreen extends GetView<EvScannerController> {
  const EvQrScannerScreen({super.key});

  Future<void> _showScanFailedDialog() {
    controller.isScanning.value = false;

    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
             Container(
                  height: 56,
                  width: 56,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetImages.stop),
                ),
              const SizedBox(height: 14),
              Text(
                'Scan Failed',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'QR Code Scan failed, please try again',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        controller.resetScanner();
                        Get.back();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE0E0E0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: const Color(0xFF374151),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        controller.retryScan();
                        try {
                          await controller.cameraController.stop();
                        } catch (_) {}

                        try {
                          await controller.cameraController.start();
                        } catch (_) {}
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text(
                        'Scan again',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Future<void> _showScanSuccessDialogAndNavigate() async {
    controller.isScanning.value = false;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 56,
                width: 56,
                alignment: Alignment.center,
                child: SvgPicture.asset(AssetImages.success),
              ),
              const SizedBox(height: 14),
              const Text(
                'Scanned Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your QR Code scanned Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(seconds: 3));
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    int selectedPlugIndex = 0;
    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Your Plug',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Station: #SF-092-MB',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildPlugOptionCard(
                    title: 'Plug A',
                    selected: selectedPlugIndex == 0,
                    onTap: () => setModalState(() => selectedPlugIndex = 0),
                  ),
                  const SizedBox(height: 14),
                  _buildPlugOptionCard(
                    title: 'Plug B',
                    selected: selectedPlugIndex == 1,
                    onTap: () => setModalState(() => selectedPlugIndex = 1),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.resetScanner();
                        Get.offNamed(AppRoutes.evChargingInformation);
                        
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPlugOptionCard({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color borderColor = selected ? const Color(0xFF0B3BDB) : const Color(0xFFC9CAD9);
    final Color backgroundColor = selected ? const Color(0xFFF4F7FF) : const Color(0xFFF3F4F6);
    final Color iconBg = selected ? const Color(0xFF2D5BFF) : const Color(0xFFEDEEF2);
    final Color iconColor = selected ? Colors.white : const Color(0xFF6B7280);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: selected ? 2 : 2),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(AssetImages.battery, width: 20, height: 20, colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Text(
                      title,
                      style:   TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: selected ?  Color(0xFF33358A) : Colors.black
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.circle, size: 12, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Available',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
             
             selected ?
              SvgPicture.asset(
                AssetImages.select,
                width: 20,
                height: 20,
              ) : const SizedBox.shrink(),
             
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full screen camera preview
          MobileScanner(
            controller: controller.cameraController,
            onDetect: controller.onQRDetect,
            fit: BoxFit.cover,
          ),

          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Ionicons.chevron_back_outline,
                          color: Colors.black,
                        ),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Scanner frame with transparent center
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          controller.isLoading.value
                              ? Colors.orange
                              : Colors.white,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Loading indicator
                      if (controller.isLoading.value)
                        Center(
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const CircularProgressIndicator(
                              color: Colors.orange,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE65100).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.qr_code_scanner, color: Colors.white),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Please scan the EV Charger QR code to confirm your payment",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                

                const Spacer(),
                //
                Row(
                  children: [
                     TextButton(
                      onPressed: _showScanFailedDialog, 
                      child: Text("failed",style: TextStyle(color: Colors.white),),
                    ),
                   
                    //
                     TextButton(
                      onPressed: () {
                        _showScanSuccessDialogAndNavigate();
                      }, 
                      child: Text("Success",style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                // Flashlight button  
                Obx(
                  () => Column(
                    children: [
                      GestureDetector(
                        onTap: controller.toggleFlashlight,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child:
                                controller.isFlashOn.value
                                    ? const Icon(
                                      Icons.flash_on,
                                      color: Colors.orange,
                                      size: 28,
                                    )
                                    : Image.asset(
                                      "assets/icons/icon_ev_lightUp.png",
                                      width: 24,
                                      height: 24,
                                      color: Colors.black,
                                    ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Flashlight",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
