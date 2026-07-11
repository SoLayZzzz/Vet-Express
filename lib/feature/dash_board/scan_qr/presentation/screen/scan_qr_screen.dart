import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'goods_search_input_screen.dart';
import '../../../../../utils/app_colors.dart';
import '../binding/scan_qr_binding.dart';
import '../controller/scan_qr_controller.dart';

class ScanQrScreen extends StatefulWidget {
  final int? scanFrom;

  const ScanQrScreen({super.key, this.scanFrom});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> with WidgetsBindingObserver {
  late ScanQrController controller;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    
    if (!Get.isRegistered<ScanQrController>()) {
      ScanQrBinding().dependencies();
    }
    controller = Get.find<ScanQrController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onScreenVisible();

      final args = Get.arguments;
      if (widget.scanFrom is int) {
        controller.setScanFrom(widget.scanFrom!);
      } else if (args is Map) {
        final scanFromArg = args['scanFrom'];
        if (scanFromArg is int) controller.setScanFrom(scanFromArg);
      } else if (args is int) {
        controller.setScanFrom(args);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Restart scanner when app is resumed (e.g., returning from system settings after granting permission)
    if (state == AppLifecycleState.resumed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.onAppResumed();
        controller.onScreenVisible();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Restart scanner when returning from navigation (e.g., bottom nav)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onAppResumed();
      controller.onScreenVisible();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop scanner when screen is disposed
    controller.onScreenHidden();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          _buildQrDetectedDialog(context),
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
                          minimumSize: const Size(double.infinity, 50)
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
                const SizedBox(height: 30,)
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
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
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildQrDetectedDialog(BuildContext context) {
    return Obx(() {
      if (!controller.state.isQrDetected || controller.state.capturedImage == null) {
        return const SizedBox.shrink();
      }

      final size = MediaQuery.of(context).size;
      final dialogSize = math.min(size.width - 80, size.height / 2);

      return Positioned.fill(
        child: AbsorbPointer(
          child: Container(
            color: Colors.black.withValues(alpha: 0.85),
            child: Center(
              child: Dialog(
                backgroundColor: Colors.white,
                insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: dialogSize,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            controller.state.capturedImage!,
                            fit: BoxFit.cover,
                          ),
                          QRScannerOverlay(
                            overlayColor: Colors.black87,
                            borderColor: Colors.transparent,
                            laserColor: AppColors.primaryColor,
                            borderRadius: 10,
                            borderLength: 30,
                            borderWidth: 0,
                            cutOutSize: dialogSize,
                            showLaser: controller.state.isLaserActive,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQrView(BuildContext context) {
    final scanner = controller.scannerController;
    final double defaultCutOut = MediaQuery.of(context).size.width * 0.8;

    return Stack(
      children: [
        // MobileScanner outside Obx to prevent recreation and camera stop/start
        MobileScanner(
          controller: scanner,
          onDetect: (capture) => controller.handleBarcodeDetection(capture),
        ),
        Obx(() {
          final bool isDetected = controller.state.isQrDetected; 
          final bool showLaserAnimation = controller.state.isLaserActive;

          // When detected, we cleanly scale the viewport box full 
          final double dynamicCutOutSize = isDetected ? (defaultCutOut * 1.15) : defaultCutOut;
          final double bottomPosition =
              (MediaQuery.of(context).size.height + dynamicCutOutSize) / 2 + 10;

          return Stack(
            children: [
              // OVERLAY CONTAINER SHIELDS WRAPPING TARGETS
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                top: 0, left: 0, right: 0, bottom: 0,
                child: QRScannerOverlay(
                  overlayColor: Colors.black87,
                  borderColor: AppColors.primaryColor,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 7,
                  cutOutSize: dynamicCutOutSize,
                  showLaser: showLaserAnimation, 
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottomPosition,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      isDetected ? 'processing_qr'.tr : 'scan_qr'.tr,
                      style: const TextStyle(
                        color: AppColors.whiteColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

class QRScannerOverlay extends StatefulWidget {
  final Color overlayColor;
  final Color borderColor;
  final Color laserColor;
  final double borderLength;
  final double borderWidth;
  final double borderRadius;
  final double cutOutSize;
  final bool showLaser;

  const QRScannerOverlay({
    super.key,
    this.overlayColor = Colors.black54,
    this.borderColor = Colors.red,
    this.laserColor = Colors.red,
    this.borderLength = 30,
    this.borderWidth = 10,
    this.borderRadius = 10,
    this.cutOutSize = 250,
    this.showLaser = false,
  });

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

class _QRScannerOverlayState extends State<QRScannerOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    if (widget.showLaser) {
      _laserController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant QRScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showLaser && !_laserController.isAnimating) {
      _laserController.repeat(reverse: true);
    } else if (!widget.showLaser) {
      _laserController.stop();
    }
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _laserController,
      builder: (context, child) {
        return CustomPaint(
          painter: QRScannerOverlayPainter(
            overlayColor: widget.overlayColor,
            borderColor: widget.borderColor,
            laserColor: widget.laserColor,
            borderLength: widget.borderLength,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
            cutOutSize: widget.cutOutSize,
            laserPosition: _laserController.value,
            showLaser: widget.showLaser,
          ),
        );
      },
    );
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color borderColor;
  final Color laserColor;
  final double borderLength;
  final double borderWidth;
  final double borderRadius;
  final double cutOutSize;
  final double laserPosition;
  final bool showLaser;

  QRScannerOverlayPainter({
    required this.overlayColor,
    required this.borderColor,
    required this.laserColor,
    required this.borderLength,
    required this.borderWidth,
    required this.borderRadius,
    required this.cutOutSize,
    required this.laserPosition,
    required this.showLaser,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final double cutOutWidth = cutOutSize;
    final double cutOutHeight = cutOutSize;

    final double left = (size.width - cutOutWidth) / 2;
    final double top = (size.height - cutOutHeight) / 2;
    final double right = left + cutOutWidth;
    final double bottom = top + cutOutHeight;

    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          Radius.circular(borderRadius),
        ),
      )
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    // Corner Boarders
    canvas.drawPath(Path()..moveTo(left, top + borderLength)..lineTo(left, top)..lineTo(left + borderLength, top), borderPaint);
    canvas.drawPath(Path()..moveTo(right - borderLength, top)..lineTo(right, top)..lineTo(right, top + borderLength), borderPaint);
    canvas.drawPath(Path()..moveTo(right, bottom - borderLength)..lineTo(right, bottom)..lineTo(right - borderLength, bottom), borderPaint);
    canvas.drawPath(Path()..moveTo(left + borderLength, bottom)..lineTo(left, bottom)..lineTo(left, bottom - borderLength), borderPaint);

    // Stage 3 Animation: Drawing the horizontal verticalLine traveling up and down
    if (showLaser) {
      final double currentLaserY = top + (cutOutHeight * laserPosition);
      final Paint laserPaint = Paint()
        ..color = laserColor
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;

      // Glow setup for realistic scanning effect
      final Paint laserGlowPaint = Paint()
        ..color = laserColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      // Draw standard laser line inside cutout box margins
      canvas.drawLine(Offset(left + 6, currentLaserY), Offset(right - 6, currentLaserY), laserPaint);
      
      // Draw a minor surrounding backdrop blur gradient block
      canvas.drawRect(
        Rect.fromLTRB(left + 6, currentLaserY - 4, right - 6, currentLaserY + 4),
        laserGlowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(QRScannerOverlayPainter oldDelegate) {
    return oldDelegate.cutOutSize != cutOutSize ||
        oldDelegate.laserPosition != laserPosition ||
        oldDelegate.showLaser != showLaser ||
        oldDelegate.laserColor != laserColor;
  }
}