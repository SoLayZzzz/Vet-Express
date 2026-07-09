import 'dart:async';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

import '../screen/goods_information_no_token_screen.dart';
import '../../../../history-dashboard/other-history/presentation/screen/goods_information_screen.dart';
import '../../data/model/response/goods_find_response.dart';
import '../../data/model/response/good_search_response.dart';
import '../../../../../utils/app_colors.dart';
import '../uistate/scan_qr_ui_state.dart';
import '../../domain/uscase/scan_qr_usecase.dart';

class ScanQrController extends StateController<ScanQrUiState> {
  final ScanQrUseCase scanQrUseCase;

  ScanQrController(this.scanQrUseCase);

  late final MobileScannerController scannerController;

  Timer? _zoomAnimationTimer;

  bool _isDisposed = false;
  bool _initialized = false;
  bool _isStarting = false;
  bool _isStopping = false;
  bool _isRestarting = false;
  bool _isScreenVisible = false;
  bool _isPermissionDialogOpen = false;
  bool _openingAppSettings = false;
  Timer? _cameraStartRetryTimer;
  int _cameraStartRetryCount = 0;

  static const int _maxCameraStartRetries = 10;
  static const Duration _cameraStartRetryDelay = Duration(milliseconds: 250);

  @override
  ScanQrUiState onInitUiState() => const ScanQrUiState();

  @override
  void onInit() {
    super.onInit();

    scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.unrestricted,
      detectionTimeoutMs: 150,
      formats: [BarcodeFormat.qrCode],
      cameraResolution: const Size(1280, 720),
      returnImage: true,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    scannerController.addListener(_onScannerStateChanged);
  }

  void _cancelZoomAnimation() {
    _zoomAnimationTimer?.cancel();
    _zoomAnimationTimer = null;
  }

  Rect _buildDetectedQrRect(Barcode barcode, Size captureSize) {
    final corners = barcode.corners;
    if (corners.isNotEmpty) {
      final left = corners.map((point) => point.dx).reduce(math.min);
      final top = corners.map((point) => point.dy).reduce(math.min);
      final right = corners.map((point) => point.dx).reduce(math.max);
      final bottom = corners.map((point) => point.dy).reduce(math.max);
      final rect = Rect.fromLTRB(left, top, right, bottom);
      if (rect.width > 0 && rect.height > 0) return rect;
    }

    final barcodeSize = barcode.size;
    final width =
        barcodeSize.width <= 1
            ? barcodeSize.width * captureSize.width
            : barcodeSize.width;
    final height =
        barcodeSize.height <= 1
            ? barcodeSize.height * captureSize.height
            : barcodeSize.height;
    final left = (captureSize.width - width) / 2;
    final top = (captureSize.height - height) / 2;

    return Rect.fromLTWH(left, top, width, height);
  }

  Future<Uint8List?> _cropQrImage(
    Uint8List? bytes,
    Rect qrRect,
    Size captureSize,
  ) async {
    if (bytes == null || bytes.isEmpty || qrRect.isEmpty || captureSize.isEmpty) {
      return bytes;
    }

    try {
      final rect = [qrRect.left, qrRect.top, qrRect.right, qrRect.bottom];
      final captureWidth = captureSize.width;
      final captureHeight = captureSize.height;

      return await Isolate.run<Uint8List?>(() {
        final original = img.decodeImage(bytes);
        if (original == null) return bytes;

        // Barcode coordinates may be normalized (0..1) or already in camera pixels.
        final isNormalized = rect[2] <= 1.0 && rect[3] <= 1.0;
        final left = isNormalized ? rect[0] * captureWidth : rect[0];
        final top = isNormalized ? rect[1] * captureHeight : rect[1];
        final right = isNormalized ? rect[2] * captureWidth : rect[2];
        final bottom = isNormalized ? rect[3] * captureHeight : rect[3];

        final width = right - left;
        final height = bottom - top;
        final scaleX = original.width / captureWidth;
        final scaleY = original.height / captureHeight;

        const padding = 20.0;
        final x = ((left * scaleX) - padding).floor().clamp(0, original.width - 1);
        final y = ((top * scaleY) - padding).floor().clamp(0, original.height - 1);
        final maxW = original.width - x;
        final maxH = original.height - y;
        final w = ((width * scaleX) + (padding * 2)).ceil().clamp(1, maxW);
        final h = ((height * scaleY) + (padding * 2)).ceil().clamp(1, maxH);

        final cropped = img.copyCrop(
          original,
          x: x,
          y: y,
          width: w,
          height: h,
        );

        return img.encodeJpg(cropped, quality: 90);
      });
    } catch (e) {
      debugPrint('Crop QR image error: $e');
      return bytes;
    }
  }

  void setScanFrom(int scanFrom) {
    uiState.value = state.copyWith(scanFrom: scanFrom);
  }

  void onScreenVisible() {
    debugPrint(
      'ScanQrController: Screen visible. Initializing and scheduling scanner...',
    );
    _isScreenVisible = true;
    if (!_initialized) {
      _initialized = true;
      // Don't add lifecycle observer - we'll manage scanner manually
      // WidgetsBinding.instance.addObserver(this);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !_isScreenVisible) return;
      // Always try to start scanner - will return early if already running
      startScanning();
    });
  }

  Future<void> onScreenHidden() async {
    debugPrint('ScanQrController: Screen hidden. Stopping scanner...');
    _isScreenVisible = false;
    _cameraStartRetryTimer?.cancel();
    _cameraStartRetryTimer = null;
    _cameraStartRetryCount = 0;
    await stopScanning();
  }

  Future<void> restartScanning() async {
    if (_isDisposed || _isRestarting) return;
    
    _isRestarting = true;
    
    // Ensure screen is marked as visible when restarting
    _isScreenVisible = true;
    
    // Explicitly reset UI layout parameters back to an active scanning environment
    uiState.value = state.copyWith(
      isScanning: true,      // Set true to allow new image frame logic triggers
      isProcessing: false,
      isCaptureZooming: false,
      isQrDetected: false,   // Clear old frame state
      isLaserActive: false,  // Stop old line animation loops
      capturedImage: null,   // Clear structural raw image reference bytes
      detectedCode: '',
      clearDetectedQrRect: true,
    );
    
    await startScanning();
    
    _isRestarting = false;
  }

  Future<void> startScanning() async {
    if (_isDisposed || !_isScreenVisible) return;
    debugPrint(
      'ScanQrController: startScanning() requested. isRunning: ${scannerController.value.isRunning}, isStarting: $_isStarting, isStopping: $_isStopping',
    );
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      debugPrint(
        'ScanQrController: Aborting startScanning() because app is not resumed.',
      );
      return;
    }
    if (scannerController.value.isRunning) {
      // Scanner is already running, just reset state and return
      _cameraStartRetryTimer?.cancel();
      _cameraStartRetryTimer = null;
      _cameraStartRetryCount = 0;
      try {
        await scannerController.resetZoomScale();
              } catch (_) {}
      uiState.value = state.copyWith(
        isScanning: true,
        isProcessing: false,
        isCaptureZooming: false,
        isQrDetected: false,
        isLaserActive: false,
        capturedImage: null,
        detectedCode: '',
        clearDetectedQrRect: true,
      );
      return;
    }
    if (_isStarting || _isStopping) {
      debugPrint('ScanQrController: Already starting or stopping, skipping startScanning');
      return;
    }
    _isStarting = true;
    try {
      final allowed = await ensureCameraPermission();
      if (!allowed) {
        uiState.value = state.copyWith(isScanning: false);
        return;
      }
      if (_isDisposed ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      debugPrint('ScanQrController: Starting camera scanner...');
      await scannerController.start();
      debugPrint('ScanQrController: Camera scanner successfully started.');

      try {
        await scannerController.resetZoomScale();
              } catch (_) {}

      _cameraStartRetryTimer?.cancel();
      _cameraStartRetryTimer = null;
      _cameraStartRetryCount = 0;
      uiState.value = state.copyWith(
        isScanning: true,
        isProcessing: false,
        isCaptureZooming: false,
        isQrDetected: false,
        isLaserActive: false,
        capturedImage: null,
        detectedCode: '',
        clearDetectedQrRect: true,
      );
    } on MobileScannerException catch (e) {
      final message = e.toString().toLowerCase();
      debugPrint('Error starting scanner: $e');

      if (message.contains('controllerinitializing') ||
          message.contains('controllernotattached')) {
        uiState.value = state.copyWith(isScanning: false);
        _scheduleCameraStartRetry();
        return;
      }

      if (message.contains('permission')) {
        uiState.value = state.copyWith(isScanning: false);
        await _displayPermissionDialog(
          'information'.tr,
          'camera_permission_error'.tr,
        );
      }
    } catch (e) {
      debugPrint('Error starting scanner: $e');
    } finally {
      _isStarting = false;
    }
  }

  void _scheduleCameraStartRetry({bool resetCount = false}) {
    if (_isDisposed) return;
    if (resetCount) _cameraStartRetryCount = 0;
    if (_cameraStartRetryTimer?.isActive ?? false) return;
    if (_cameraStartRetryCount >= _maxCameraStartRetries) return;

    _cameraStartRetryCount++;
    _cameraStartRetryTimer = Timer(_cameraStartRetryDelay, () {
      _cameraStartRetryTimer = null;
      if (_isDisposed) return;
      startScanning();
    });
  }

  Future<void> stopScanning({bool resetState = true}) async {
    if (_isDisposed || _isStopping) return;
    _cameraStartRetryTimer?.cancel();
    _cameraStartRetryTimer = null;
    _cancelZoomAnimation();
    _isStopping = true;
    try {
      if (scannerController.value.isRunning) {
        await scannerController.stop();
      }
      try {
        await scannerController.resetZoomScale();
              } catch (_) {}
      if (!_isDisposed && resetState) {
        uiState.value = state.copyWith(
          isScanning: false,
          isProcessing: false,
          isCaptureZooming: false,
          isQrDetected: false,  
          isLaserActive: false, 
          capturedImage: null,
          detectedCode: '',
          clearDetectedQrRect: true,
        );
      }
    } catch (e) {
      debugPrint('Error stopping scanner: $e');
    } finally {
      _isStopping = false;
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    _isScreenVisible = false;
    _cameraStartRetryTimer?.cancel();
    _cameraStartRetryTimer = null;
    _cancelZoomAnimation();

    scannerController.removeListener(_onScannerStateChanged);

    scannerController
        .stop()
        .then((_) => scannerController.dispose())
        .catchError((_) {});

    super.onClose();
  }

  void _onScannerStateChanged() {
    if (_isDisposed) return;
    final isTorchOn = scannerController.value.torchState == TorchState.on;
    if (uiState.value.flash != isTorchOn) {
      uiState.value = uiState.value.copyWith(flash: isTorchOn);
    }
  }

  Future<void> toggleFlash() async {
    try {
      await scannerController.toggleTorch();
    } catch (e) {
      debugPrint('Error toggling torch: $e');
      _displayDialog('information'.tr, 'flash_error'.tr);
    }
  }

  Future<void> handleBarcodeDetection(BarcodeCapture capture) async {
    if (!state.isScanning || state.isProcessing || _isDisposed || state.isQrDetected) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;
    if (code == null || code.isEmpty) return;

    final imageSize = capture.size;
    final detectedRect = _buildDetectedQrRect(barcode, imageSize);
    final rawImageBytes = capture.image;

    // Show the processing UI while cropping the captured QR code in the background.
    uiState.value = state.copyWith(
      isProcessing: true,
      isCaptureZooming: true,
      detectedCode: code,
      detectedQrRect: detectedRect,
      detectedCaptureSize: imageSize,
    );

    final croppedImage = await _cropQrImage(rawImageBytes, detectedRect, imageSize);

    if (_isDisposed) return;

    // The captured QR code is now displayed in the dialog, and the laser scans it.
    uiState.value = state.copyWith(
      isScanning: true,
      isProcessing: true,
      isCaptureZooming: true,
      isQrDetected: true,
      capturedImage: croppedImage,
    );

    if (_isDisposed) return;

    uiState.value = state.copyWith(isLaserActive: true);

    // 1. Run the laser scan animation.
    await Future.delayed(const Duration(milliseconds: 1200));
    if (_isDisposed) return;

    uiState.value = state.copyWith(isLaserActive: false);

    // 2. Briefly show the scanned code before continuing.
    await Future.delayed(const Duration(milliseconds: 600));
    if (_isDisposed) return;

    try {
      await goodsSearch(Get.context!, code);
    } catch (_) {
      // If error occurs, flush states instantly to allow fallback scanning loop parameters
      if (!_isDisposed) {
        await restartScanning();
      }
    }
  }

  Future<void> goodsSearch(BuildContext context, String code) async {
    try {
      final json = await scanQrUseCase.searchCode(context: context, code: code);

      if (_isDisposed) return;

      final searchResponse = GoodsSearchResponse.fromJson(json);

      if (searchResponse.header?.result == true &&
          searchResponse.header?.statusCode == 200 &&
          searchResponse.body?.status == true) {
        if (searchResponse.body?.data == null ||
            searchResponse.body!.data!.isEmpty) {
          await _displayDialog('information'.tr, 'no_data_found'.tr);
          return;
        }

        final nextScreen =
            state.scanFrom == 0
                ? _buildWithTokenScreen(searchResponse)
                : _buildNoTokenScreen(json);

        // Keep camera running for continuous scanning
        // Don't stop scanner before navigation
        
        await Get.to(
          () => nextScreen,
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

        // Reset state when returning to allow new scans
        if (!_isDisposed) {
          uiState.value = state.copyWith(
            isQrDetected: false,
            isLaserActive: false,
            capturedImage: null,
            isProcessing: false,
          );
        }
      } else {
        await _displayDialog('information'.tr, 'code_invalid'.tr);
      }
    } catch (e) {
      await _displayDialog('information'.tr, 'error_occurred'.tr);
      debugPrint('Goods search error: $e');
    }
  }

  Widget _buildWithTokenScreen(GoodsSearchResponse searchResponse) {
    final id = searchResponse.body!.data![0].id!.toInt();
    return GoodsInformationScreen(id: id);
  }

  Widget _buildNoTokenScreen(Map<String, dynamic> json) {
    return GoodsInformationNoTokenScreen(
      futureData: Future.value(GoodsFindResponse.fromJson(json)),
    );
  }

  Future<void> _displayDialog(String title, String description) async {
    final completer = Completer<void>();

    alertDialogTravelPackage(
      title: title,
      description: description,
      buttonText: 'ok'.tr,
      onButtonPressed: () {
        Get.back();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
    await restartScanning();
  }

  Future<void> _displayPermissionDialog(
    String title,
    String description,
  ) async {
    if (_isPermissionDialogOpen) return;
    _isPermissionDialogOpen = true;

    final completer = Completer<void>();

    alertDialogTwoButton(
      title: title,
      description: description,
      buttonText1: 'cancel'.tr,
      buttonText2: 'setting'.tr,
      onButtonPressed1: () {
        Get.back();
        if (!completer.isCompleted) completer.complete();
      },
      onButtonPressed2: () async {
        Get.back();
        _isPermissionDialogOpen = false;
        _openingAppSettings = true;
        if (!completer.isCompleted) completer.complete();
        debugPrint('ScanQrController: Routing to App Settings...');
        await openAppSettings();
      },
    );

    await completer.future;
    if (!_openingAppSettings) {
      _isPermissionDialogOpen = false;
    }
  }

  Future<bool> ensureCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      debugPrint('ScanQrController: Camera permission status: $status');
      if (status.isGranted) return true;

      if (_openingAppSettings || _isPermissionDialogOpen) {
        debugPrint(
          'ScanQrController: Already routing to settings or permission dialog open.',
        );
        return false;
      }

      if (status.isDenied || status.isLimited) {
        debugPrint('ScanQrController: Requesting camera permission...');
        final req = await Permission.camera.request();
        debugPrint('ScanQrController: Camera permission request result: $req');
        if (req.isGranted) return true;
      }

      debugPrint(
        'ScanQrController: Permission denied. Showing custom permission alert dialog.',
      );
      await _displayPermissionDialog(
        'information'.tr,
        'camera_permission_error'.tr,
      );
      return false;
    } catch (e) {
      debugPrint('ensureCameraPermission error: $e');
      return false;
    }
  }

  Future<void> cropImage(BuildContext context) async {
    try {
      // Don't stop scanner - keep camera running for continuous scanning

      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (photo == null) {
        debugPrint(
          'ScanQrController: Image picking canceled.',
        );
        return;
      }

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
            aspectRatioPresets: const [
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

      if (croppedFile != null) {
        try {
          final capture = await scannerController.analyzeImage(
            croppedFile.path,
          );
          if (capture != null && capture.barcodes.isNotEmpty) {
            final code = capture.barcodes.first.rawValue;
            if (code != null) {
              await goodsSearch(Get.context!, code);
            }
          } else {
            await _displayDialog('information'.tr, 'code_invalid'.tr);
          }
        } catch (e) {
          debugPrint('QR analysis error: $e');
          await _displayDialog('information'.tr, 'qr_analysis_error'.tr);
        }
      } else {
        debugPrint(
          'ScanQrController: Image cropping canceled. Resuming scanner...',
        );
        await restartScanning();
      }
    } catch (e) {
      await _displayDialog('information'.tr, 'error_occurred'.tr);
      debugPrint('Image cropping error: $e');
    }
  }
}