import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'goods_search_input_screen.dart';
import '../../../../../utils/app_colors.dart';
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
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildQrView(context),
          _buildVignetteOverlay(),
          _buildTopBar(context),
          _buildBottomBar(context),
          Obx(() {
            if (!controller.state.isProcessing) {
              return const SizedBox.shrink();
            }
            return Positioned.fill(
              child: AbsorbPointer(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: SizedBox(
                      height: 44,
                      width: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVignetteOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
              Colors.black.withValues(alpha: 0.75),
            ],
            stops: const [0.5, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // _buildCircularButton(
              //   icon: Icons.arrow_back_ios_new_rounded,
              //   onTap: () => Get.back(),
              // ),
              // Expanded(
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Text(
              //         'scan_qr'.tr,
              //         style: const TextStyle(
              //           color: Colors.white,
              //           fontSize: 20,
              //           fontWeight: FontWeight.bold,
              //           letterSpacing: 0.5,
              //           shadows: [
              //             Shadow(
              //               color: Colors.black54,
              //               offset: Offset(0, 2),
              //               blurRadius: 4,
              //             ),
              //           ],
              //         ),
              //       ),
              //       const SizedBox(height: 4),
              //       Text(
              //         'scan_qr_info'.tr,
              //         style: TextStyle(
              //           color: Colors.white.withValues(alpha: 0.7),
              //           fontSize: 12,
              //           fontWeight: FontWeight.w400,
              //         ),
              //         textAlign: TextAlign.center,
              //       ),
              //     ],
              //   ),
              // ),
              Obx(
                () => _buildCircularButton(
                  icon:
                      controller.state.flash
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                  onTap: controller.toggleFlash,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Center(child: Icon(icon, color: Colors.white, size: 20)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final List<Widget> buttons = [];
                  if (controller.state.scanFrom == 0) {
                    buttons.add(
                      _buildOptionButton(
                        context: context,
                        icon: Icons.edit,
                        text: 'enter_tracking'.tr,
                        onTap: () async {
                          debugPrint(
                            'ScanQrScreen: Stopping scanner to enter tracking ID.',
                          );
                          await controller.scannerController.stop();
                          await Get.to(
                            () => const GoodsSearchInputScreen(),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 350),
                          );
                          debugPrint(
                            'ScanQrScreen: Returned from GoodsSearchInputScreen. Starting scanner...',
                          );
                          await controller.startScanning();
                        },
                      ),
                    );
                  }
                  buttons.add(
                    _buildOptionButton(
                      context: context,
                      icon: Icons.image,
                      text: 'upload_image'.tr,
                      onTap: () => controller.cropImage(context),
                    ),
                  );
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: buttons,
                  );
                }),
                Obx(() {
                  if (controller.state.scanFrom != 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          minimumSize: Size(double.infinity, 50)
                          ),
                          onPressed: () => Get.back(),
                          child: Text(
                            'cancel'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                //
                SizedBox(height: 30,)
              ],
            ),
          ),
        ),
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
      // borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            width: 48,
            height: 48,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: "Inter",
              // fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final scanner = controller.scannerController;
    final double cutOutSize = MediaQuery.of(context).size.width * 0.8;
    final double bottomPosition =
        (MediaQuery.of(context).size.height + cutOutSize) / 2 + 10;

    return Stack(
      children: [
        MobileScanner(
          controller: scanner,
          onDetect:
              (capture) => controller.handleBarcodeDetection(context, capture),
        ),
        QRScannerOverlay(
          overlayColor: Colors.black87,
          borderColor: AppColors.primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 7,
          cutOutSize: cutOutSize,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomPosition,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
              ), // Added bottom padding for breathing room
              child: Text(
                'scan_qr'.tr,
                style: const TextStyle(
                  color: AppColors.whiteColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class QRScannerOverlay extends StatefulWidget {
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
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

class _QRScannerOverlayState extends State<QRScannerOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: QRScannerOverlayPainter(
              overlayColor: widget.overlayColor,
              borderColor: widget.borderColor,
              borderLength: widget.borderLength,
              borderWidth: widget.borderWidth,
              borderRadius: widget.borderRadius,
              cutOutSize: widget.cutOutSize,
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
