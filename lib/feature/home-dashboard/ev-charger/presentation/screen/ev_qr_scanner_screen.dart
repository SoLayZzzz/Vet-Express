import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controller/ev_scanner_controller.dart';

class EvQrScannerScreen extends GetView<EvScannerController> {
  const EvQrScannerScreen({super.key});

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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
