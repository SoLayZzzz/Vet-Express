import 'dart:convert';
import 'dart:developer';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:express_vet/activities/logistic/goods_search_input_screen.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/utils/button.dart';
import 'package:express_vet/utils/loading.dart';
import '../../models/destination/goods_find_response.dart';
import '../../models/goods_transfer/good_search_response.dart';
import '../../utils/app_colors.dart';
import 'goods_information_no_token_screen.dart';
import 'goods_information_screen.dart';

class ScanQR extends StatefulWidget {
  final int scanFrom; // 0 is from menu screen, 1 is from no token

  const ScanQR({super.key, required this.scanFrom});

  @override
  State<ScanQR> createState() => _ScanQRState();
}

class _ScanQRState extends State<ScanQR> with WidgetsBindingObserver {
  String? result;
  late MobileScannerController controller;
  bool _flash = false;
  bool _isDisposed = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500,
      formats: [BarcodeFormat.qrCode],
      cameraResolution: Size(1280, 720),
      returnImage: false,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    WidgetsBinding.instance.addObserver(this);

    // Start scanning when widget initializes
    _startScanning();
  }

  void _startScanning() async {
    try {
      await controller.stop();
      await controller.start();
      if (mounted) {
        setState(() {
          _isScanning = true;
        });
      }
    } catch (e) {
      log('Error starting scanner: $e');
      _displayDialog(context, 'information'.tr, 'camera_permission_error'.tr);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    controller.stop().then(
      (_) => controller.dispose(),
    ); // Stop and then dispose
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isScanning) {
          controller
              .start()
              .then((_) {
                if (mounted) {
                  setState(() {
                    _isScanning = true;
                  });
                }
              })
              .catchError((e) {
                log('Error resuming scanner: $e');
              });
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        controller
            .stop()
            .then((_) {
              if (mounted) {
                setState(() {
                  _isScanning = false;
                });
              }
            })
            .catchError((e) {
              log('Error stopping scanner: $e');
            });
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: IconButton(
                      icon: Icon(_flash ? Icons.flash_on : Icons.flash_off),
                      color: Colors.white,
                      onPressed: _toggleFlash,
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
                    if (widget.scanFrom == 0)
                      _buildOptionButton(
                        context: context,
                        icon: Icons.edit,
                        text: 'enter_tracking'.tr,
                        onTap:
                            () => Get.to(
                              () => const GoodsSearchInputScreen(),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 350),
                            ),
                      ),
                    _buildOptionButton(
                      context: context,
                      icon: Icons.image,
                      text: 'upload_image'.tr,
                      onTap: _cropImage,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (widget.scanFrom == 1)
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: globalButton(
                      context: context,
                      buttonText: 'cancel'.tr,
                      onPressed: () => Get.back(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFlash() async {
    try {
      await controller.toggleTorch();
      if (mounted) {
        setState(() => _flash = !_flash);
      }
    } catch (e) {
      log('Error toggling torch: $e');
      _displayDialog(context, 'information'.tr, 'flash_error'.tr);
    }
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
              decoration: BoxDecoration(
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
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) => _handleBarcodeDetection(context, capture),
        ),
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

  Future<void> _handleBarcodeDetection(
    BuildContext context,
    BarcodeCapture capture,
  ) async {
    if (!_isScanning || _isDisposed) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      setState(() {
        _isScanning = false;
      });
      await controller.stop();
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        await goodsSearch(context, code);
      }
    }
  }

  Future<void> goodsSearch(BuildContext context, String code) async {
    if (!mounted) return;

    Loading().loadingShow(context);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseUrl.BASE_URL}goods-transfer/search-code'),
      )..fields['code'] = code;

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (!mounted) return;
      Loading().loadingClose(context);

      if (responseData.statusCode == 200) {
        log('Search response: ${responseData.body}');
        final Map<String, dynamic> jsonData = jsonDecode(responseData.body);
        final searchResponse = GoodsSearchResponse.fromJson(jsonData);

        if (searchResponse.header?.result == true &&
            searchResponse.header?.statusCode == 200 &&
            searchResponse.body?.status == true) {
          if (searchResponse.body?.data == null ||
              searchResponse.body!.data!.isEmpty) {
            _displayDialog(context, 'information'.tr, 'no_data_found'.tr);
            return;
          }

          final nextScreen =
              widget.scanFrom == 0
                  ? GoodsInformationScreen(
                    id: searchResponse.body!.data![0].id!.toInt(),
                  )
                  : GoodsInformationNoTokenScreen(
                    futureData: Future.value(
                      GoodsFindResponse.fromJson(jsonData),
                    ),
                  );

          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => nextScreen),
          );

          if (mounted && result == null) {
            _startScanning();
          }
        } else {
          _displayDialog(context, 'information'.tr, 'code_invalid'.tr);
        }
      } else {
        _displayDialog(
          context,
          'information'.tr,
          'error_code'.tr + responseData.statusCode.toString(),
        );
      }
    } catch (e) {
      if (mounted) {
        Loading().loadingClose(context);
        _displayDialog(context, 'information'.tr, 'error_occurred'.tr);
        log('Goods search error: $e');
      }
    }
  }

  Future<void> _displayDialog(
    BuildContext context,
    String title,
    String description,
  ) async {
    if (!mounted) return;

    await alertDialogTravelPackage(
      title: title,
      description: description,
      buttonText: 'ok'.tr,
      onButtonPressed: () {
        Navigator.pop(context);
        if (mounted) {
          _startScanning();
        }
      },
    );
  }

  Future<void> _cropImage() async {
    try {
      await controller.stop(); // Stop live scanning before image analysis
      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (photo == null) return;

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: photo.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'crop_qr_code'.tr,
            toolbarColor: AppColors.primaryColor,
            toolbarWidgetColor: AppColors.whiteColor,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
          IOSUiSettings(
            title: 'crop_qr_code'.tr,
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (croppedFile != null && mounted) {
        try {
          final BarcodeCapture? capture = await controller.analyzeImage(
            croppedFile.path,
          );
          if (capture != null && capture.barcodes.isNotEmpty) {
            final String? code = capture.barcodes.first.rawValue;
            if (code != null) {
              await goodsSearch(context, code);
            }
          } else {
            _displayDialog(context, 'information'.tr, 'code_invalid'.tr);
          }
        } catch (e) {
          log('QR analysis error: $e');
          _displayDialog(context, 'information'.tr, 'qr_analysis_error'.tr);
        }
      }
    } catch (e) {
      if (mounted) {
        _displayDialog(context, 'information'.tr, 'error_occurred'.tr);
        log('Image cropping error: $e');
      }
    } finally {
      _startScanning(); // Restart scanning after image analysis
    }
  }
}

// Custom QR Scanner Overlay to help users position the QR code
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

    // Draw the overlay with a cutout in the middle
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

    // Draw the corner borders
    final Paint borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    // Top left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + borderLength)
        ..lineTo(left, top)
        ..lineTo(left + borderLength, top),
      borderPaint,
    );

    // Top right corner
    canvas.drawPath(
      Path()
        ..moveTo(right - borderLength, top)
        ..lineTo(right, top)
        ..lineTo(right, top + borderLength),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawPath(
      Path()
        ..moveTo(right, bottom - borderLength)
        ..lineTo(right, bottom)
        ..lineTo(right - borderLength, bottom),
      borderPaint,
    );

    // Bottom left corner
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
