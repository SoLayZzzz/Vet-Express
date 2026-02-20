import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'goods_search_input_screen.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/button.dart';
import '../binding/scan_qr_binding.dart';
import '../controller/scan_qr_controller.dart';

class ScanQrScreen extends GetView<ScanQrController> {
  final int? scanFrom;

  const ScanQrScreen({super.key, this.scanFrom});

  @override
  ScanQrController get controller {
    if (!Get.isRegistered<ScanQrController>()) {
      ScanQrBinding().dependencies();
    }
    return Get.find<ScanQrController>();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onScreenVisible();

      final args = Get.arguments;
      if (scanFrom is int) {
        controller.setScanFrom(scanFrom!);
      } else if (args is Map) {
        final scanFromArg = args['scanFrom'];
        if (scanFromArg is int) controller.setScanFrom(scanFromArg);
      } else if (args is int) {
        controller.setScanFrom(args);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          _buildQrView(context),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Obx(
                      () => IconButton(
                        icon: Icon(
                          controller.state.flash
                              ? Icons.flash_on
                              : Icons.flash_off,
                        ),
                        color: Colors.white,
                        onPressed: controller.toggleFlash,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'scan_qr'.tr,
                    style: const TextStyle(
                      color: AppColors.whiteColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(() {
                      if (controller.state.scanFrom != 0) {
                        return const SizedBox.shrink();
                      }

                      return _buildOptionButton(
                        context: context,
                        icon: Icons.edit,
                        text: 'enter_tracking'.tr,
                        onTap:
                            () => Get.to(
                              () => const GoodsSearchInputScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 350),
                            ),
                      );
                    }),
                    _buildOptionButton(
                      context: context,
                      icon: Icons.image,
                      text: 'upload_image'.tr,
                      onTap: () => controller.cropImage(context),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Obx(() {
                  if (controller.state.scanFrom != 1) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.all(15),
                    child: globalButton(
                      context: context,
                      buttonText: 'cancel'.tr,
                      onPressed: () => Get.back(),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              width: 50,
              height: 50,
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final scanner = controller.scannerController;

    return Stack(
      children: [
        if (scanner != null)
          MobileScanner(
            controller: scanner,
            onDetect:
                (capture) =>
                    controller.handleBarcodeDetection(context, capture),
          )
        else
          const SizedBox.shrink(),
        QRScannerOverlay(
          overlayColor: Colors.black87,
          borderColor: AppColors.primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 7,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ],
    );
  }
}

class QRScannerOverlay extends StatelessWidget {
  final Color overlayColor;
  final Color borderColor;
  final double borderLength;
  final double borderWidth;
  final double borderRadius;
  final double cutOutSize;

  const QRScannerOverlay({
    super.key,
    this.overlayColor = Colors.black54,
    this.borderColor = Colors.red,
    this.borderLength = 30,
    this.borderWidth = 10,
    this.borderRadius = 10,
    this.cutOutSize = 250,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: QRScannerOverlayPainter(
              overlayColor: overlayColor,
              borderColor: borderColor,
              borderLength: borderLength,
              borderWidth: borderWidth,
              borderRadius: borderRadius,
              cutOutSize: cutOutSize,
            ),
          ),
        ),
        Center(
          child: SizedBox(
            width: cutOutSize + 20,
            height: cutOutSize + 20,
            child: const Center(
              child: Text(
                '',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color borderColor;
  final double borderLength;
  final double borderWidth;
  final double borderRadius;
  final double cutOutSize;

  QRScannerOverlayPainter({
    required this.overlayColor,
    required this.borderColor,
    required this.borderLength,
    required this.borderWidth,
    required this.borderRadius,
    required this.cutOutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill;

    final double cutOutWidth = cutOutSize;
    final double cutOutHeight = cutOutSize;

    final double left = (size.width - cutOutWidth) / 2;
    final double top = (size.height - cutOutHeight) / 2;
    final double right = left + cutOutWidth;
    final double bottom = top + cutOutHeight;

    final Path path =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTRB(left, top, right, bottom),
              Radius.circular(borderRadius),
            ),
          )
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final Paint borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    canvas.drawPath(
      Path()
        ..moveTo(left, top + borderLength)
        ..lineTo(left, top)
        ..lineTo(left + borderLength, top),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(right - borderLength, top)
        ..lineTo(right, top)
        ..lineTo(right, top + borderLength),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - borderLength)
        ..lineTo(right, bottom)
        ..lineTo(right - borderLength, bottom),
      borderPaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(left + borderLength, bottom)
        ..lineTo(left, bottom)
        ..lineTo(left, bottom - borderLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
