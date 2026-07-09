// import 'dart:async';
// import 'dart:math' as math;

// import 'package:express_vet/base/state_controller.dart';
// import 'package:express_vet/utils/alert_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../screen/goods_information_no_token_screen.dart';
// import '../../../../history-dashboard/other-history/presentation/screen/goods_information_screen.dart';
// import '../../data/model/response/goods_find_response.dart';
// import '../../data/model/response/good_search_response.dart';
// import '../../../../../utils/app_colors.dart';
// import '../uistate/scan_qr_ui_state.dart';
// import '../../domain/uscase/scan_qr_usecase.dart';

// class ScanQrController extends StateController<ScanQrUiState>
//     with WidgetsBindingObserver {
//   final ScanQrUseCase scanQrUseCase;

//   ScanQrController(this.scanQrUseCase);

//   late final MobileScannerController scannerController;

//   Timer? _zoomAnimationTimer;
//   double _currentZoomScale = 0.0;

//   bool _isDisposed = false;
//   bool _initialized = false;
//   bool _isStarting = false;
//   bool _isStopping = false;
//   bool _isScreenVisible = false;
//   bool _isPermissionDialogOpen = false;
//   bool _openingAppSettings = false;
//   Timer? _cameraStartRetryTimer;
//   int _cameraStartRetryCount = 0;

//   static const int _maxCameraStartRetries = 10;
//   static const Duration _cameraStartRetryDelay = Duration(milliseconds: 250);

//   @override
//   ScanQrUiState onInitUiState() => const ScanQrUiState();

//   @override
//   void onInit() {
//     super.onInit();

//     scannerController = MobileScannerController(
//       autoStart: false,
//       detectionSpeed: DetectionSpeed.unrestricted,
//       detectionTimeoutMs: 150,
//       formats: [BarcodeFormat.qrCode],
//       cameraResolution: const Size(1280, 720),
//       returnImage: false,
//       facing: CameraFacing.back,
//       torchEnabled: false,
//     );
//     scannerController.addListener(_onScannerStateChanged);
//   }

//   void _cancelZoomAnimation() {
//     _zoomAnimationTimer?.cancel();
//     _zoomAnimationTimer = null;
//   }

//   Future<void> _setZoomScale(double zoomScale) async {
//     final clamped = zoomScale.clamp(0.0, 1.0);
//     _currentZoomScale = clamped;
//     try {
//       await scannerController.setZoomScale(clamped);
//     } catch (_) {}
//   }

//   void _animateZoomTo(
//     double targetZoomScale, {
//     Duration duration = const Duration(milliseconds: 550),
//     Curve curve = Curves.easeOutCubic,
//   }) {
//     if (_isDisposed) return;

//     _cancelZoomAnimation();
//     final from = _currentZoomScale;
//     final to = targetZoomScale.clamp(0.0, 1.0);
//     if ((from - to).abs() < 0.001) return;

//     final stopwatch = Stopwatch()..start();
//     _zoomAnimationTimer = Timer.periodic(const Duration(milliseconds: 16), (
//       timer,
//     ) {
//       if (_isDisposed) {
//         timer.cancel();
//         return;
//       }
//       if (!scannerController.value.isRunning) {
//         timer.cancel();
//         return;
//       }

//       final tRaw = stopwatch.elapsedMilliseconds / duration.inMilliseconds;
//       final t = tRaw.clamp(0.0, 1.0);
//       final eased = curve.transform(t);
//       final value = from + (to - from) * eased;
//       _setZoomScale(value);

//       if (t >= 1.0) {
//         timer.cancel();
//         _zoomAnimationTimer = null;
//       }
//     });
//   }

//   double _computeTargetZoomScale(Barcode barcode, Size captureSize) {
//     final barcodeSize = barcode.size;
//     final w = barcodeSize.width;
//     final h = barcodeSize.height;
//     final barcodeArea = w * h;

//     double relativeArea;
//     if (w <= 1.0 && h <= 1.0) {
//       relativeArea = barcodeArea;
//     } else {
//       final imageArea = captureSize.width * captureSize.height;
//       if (imageArea <= 0) {
//         relativeArea = 0.0;
//       } else {
//         relativeArea = barcodeArea / imageArea;
//       }
//     }

//     const desiredRelativeArea = 0.18;
//     const maxRatio = 14.0;
//     const maxZoom = 0.92;
//     const minZoom = 0.28;

//     if (relativeArea <= 0) return 0.75;

//     if (relativeArea >= desiredRelativeArea) return minZoom;

//     final ratio = (desiredRelativeArea / relativeArea).clamp(1.0, maxRatio);
//     final scale = math.sqrt(ratio);
//     final normalized = ((scale - 1) / (math.sqrt(maxRatio) - 1)).clamp(
//       0.0,
//       1.0,
//     );
//     final zoom = (normalized * maxZoom).clamp(0.0, maxZoom);
//     return math.max(minZoom, zoom).clamp(0.0, maxZoom);
//   }

//   Rect _buildDetectedQrRect(Barcode barcode, Size captureSize) {
//     final corners = barcode.corners;
//     if (corners.isNotEmpty) {
//       final left = corners.map((point) => point.dx).reduce(math.min);
//       final top = corners.map((point) => point.dy).reduce(math.min);
//       final right = corners.map((point) => point.dx).reduce(math.max);
//       final bottom = corners.map((point) => point.dy).reduce(math.max);
//       final rect = Rect.fromLTRB(left, top, right, bottom);
//       if (rect.width > 0 && rect.height > 0) return rect;
//     }

//     final barcodeSize = barcode.size;
//     final width =
//         barcodeSize.width <= 1
//             ? barcodeSize.width * captureSize.width
//             : barcodeSize.width;
//     final height =
//         barcodeSize.height <= 1
//             ? barcodeSize.height * captureSize.height
//             : barcodeSize.height;
//     final left = (captureSize.width - width) / 2;
//     final top = (captureSize.height - height) / 2;

//     return Rect.fromLTWH(left, top, width, height);
//   }

//   void setScanFrom(int scanFrom) {
//     uiState.value = state.copyWith(scanFrom: scanFrom);
//   }

//   void onScreenVisible() {
//     debugPrint(
//       'ScanQrController: Screen visible. Initializing and scheduling scanner...',
//     );
//     _isScreenVisible = true;
//     if (!_initialized) {
//       _initialized = true;
//       WidgetsBinding.instance.addObserver(this);
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_isDisposed || !_isScreenVisible) return;
//       restartScanning();
//     });
//   }

//   Future<void> onScreenHidden() async {
//     debugPrint('ScanQrController: Screen hidden. Stopping scanner...');
//     _isScreenVisible = false;
//     _cameraStartRetryTimer?.cancel();
//     _cameraStartRetryTimer = null;
//     _cameraStartRetryCount = 0;
//     await stopScanning();
//   }

//   Future<void> restartScanning() async {
//     if (_isDisposed || !_isScreenVisible) return;
//     uiState.value = state.copyWith(
//       isProcessing: false,
//       isCaptureZooming: false,
//       detectedCode: '',
//       clearDetectedQrRect: true,
//     );
//     await startScanning();
//   }

//   Future<void> startScanning() async {
//     if (_isDisposed || !_isScreenVisible) return;
//     debugPrint(
//       'ScanQrController: startScanning() requested. isRunning: ${scannerController.value.isRunning}, isStarting: $_isStarting, isStopping: $_isStopping',
//     );
//     if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
//       debugPrint(
//         'ScanQrController: Aborting startScanning() because app is not resumed.',
//       );
//       return;
//     }
//     if (scannerController.value.isRunning) {
//       _cameraStartRetryTimer?.cancel();
//       _cameraStartRetryTimer = null;
//       _cameraStartRetryCount = 0;
//       try {
//         await scannerController.resetZoomScale();
//         _currentZoomScale = 0.0;
//       } catch (_) {}
//       uiState.value = state.copyWith(
//         isScanning: true,
//         isProcessing: false,
//         isCaptureZooming: false,
//         detectedCode: '',
//         clearDetectedQrRect: true,
//       );
//       return;
//     }
//     if (_isStarting || _isStopping) return;
//     _isStarting = true;
//     try {
//       final allowed = await ensureCameraPermission();
//       if (!allowed) {
//         uiState.value = state.copyWith(isScanning: false);
//         return;
//       }
//       if (_isDisposed ||
//           WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
//         return;
//       }
//       debugPrint('ScanQrController: Starting camera scanner...');
//       await scannerController.start();
//       debugPrint('ScanQrController: Camera scanner successfully started.');

//       try {
//         await scannerController.resetZoomScale();
//         _currentZoomScale = 0.0;
//       } catch (_) {}

//       _cameraStartRetryTimer?.cancel();
//       _cameraStartRetryTimer = null;
//       _cameraStartRetryCount = 0;
//       uiState.value = state.copyWith(
//         isScanning: true,
//         isProcessing: false,
//         isCaptureZooming: false,
//         detectedCode: '',
//         clearDetectedQrRect: true,
//       );
//     } on MobileScannerException catch (e) {
//       final message = e.toString().toLowerCase();
//       debugPrint('Error starting scanner: $e');

//       if (message.contains('controllerinitializing') ||
//           message.contains('controllernotattached')) {
//         uiState.value = state.copyWith(isScanning: false);
//         _scheduleCameraStartRetry();
//         return;
//       }

//       if (message.contains('permission')) {
//         uiState.value = state.copyWith(isScanning: false);
//         await _displayPermissionDialog(
//           'information'.tr,
//           'camera_permission_error'.tr,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error starting scanner: $e');
//     } finally {
//       _isStarting = false;
//     }
//   }

//   void _scheduleCameraStartRetry({bool resetCount = false}) {
//     if (_isDisposed) return;
//     if (resetCount) _cameraStartRetryCount = 0;
//     if (_cameraStartRetryTimer?.isActive ?? false) return;
//     if (_cameraStartRetryCount >= _maxCameraStartRetries) return;

//     _cameraStartRetryCount++;
//     _cameraStartRetryTimer = Timer(_cameraStartRetryDelay, () {
//       _cameraStartRetryTimer = null;
//       if (_isDisposed) return;
//       startScanning();
//     });
//   }

//   Future<void> stopScanning({bool resetState = true}) async {
//     if (_isDisposed || _isStopping) return;
//     _cameraStartRetryTimer?.cancel();
//     _cameraStartRetryTimer = null;
//     _cancelZoomAnimation();
//     _isStopping = true;
//     try {
//       if (scannerController.value.isRunning) {
//         await scannerController.stop();
//       }
//       try {
//         await scannerController.resetZoomScale();
//         _currentZoomScale = 0.0;
//       } catch (_) {}
//       if (!_isDisposed && resetState) {
//         uiState.value = state.copyWith(
//           isScanning: false,
//           isProcessing: false,
//           isCaptureZooming: false,
//           detectedCode: '',
//           clearDetectedQrRect: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error stopping scanner: $e');
//     } finally {
//       _isStopping = false;
//     }
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _isDisposed = true;
//     _isScreenVisible = false;
//     _cameraStartRetryTimer?.cancel();
//     _cameraStartRetryTimer = null;
//     _cancelZoomAnimation();

//     scannerController.removeListener(_onScannerStateChanged);

//     scannerController
//         .stop()
//         .then((_) => scannerController.dispose())
//         .catchError((_) {});

//     super.onClose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_isDisposed) return;
//     debugPrint('ScanQrController: App lifecycle changed to: $state');

//     switch (state) {
//       case AppLifecycleState.resumed:
//         Future.delayed(const Duration(milliseconds: 500), () async {
//           if (_isDisposed) return;
//           if (WidgetsBinding.instance.lifecycleState !=
//               AppLifecycleState.resumed) {
//             return;
//           }

//           final status = await Permission.camera.status;
//           _openingAppSettings = false;

//           if (!_isScreenVisible) return;

//           if (status.isGranted) {
//             _scheduleCameraStartRetry(resetCount: true);
//           } else if (!_isPermissionDialogOpen) {
//             await _displayPermissionDialog(
//               'information'.tr,
//               'camera_permission_error'.tr,
//             );
//           }
//         });
//         break;
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//       case AppLifecycleState.hidden:
//         stopScanning();
//         break;
//     }
//   }

//   void _onScannerStateChanged() {
//     if (_isDisposed) return;
//     final isTorchOn = scannerController.value.torchState == TorchState.on;
//     if (uiState.value.flash != isTorchOn) {
//       uiState.value = uiState.value.copyWith(flash: isTorchOn);
//     }
//   }

//   Future<void> toggleFlash() async {
//     try {
//       await scannerController.toggleTorch();
//     } catch (e) {
//       debugPrint('Error toggling torch: $e');
//       _displayDialog('information'.tr, 'flash_error'.tr);
//     }
//   }

//   Future<void> handleBarcodeDetection(
//     BuildContext context,
//     BarcodeCapture capture,
//   ) async {
//     if (!state.isScanning || state.isProcessing || _isDisposed) return;

//     final barcodes = capture.barcodes;
//     if (barcodes.isEmpty) return;

//     final barcode = barcodes.first;
//     final code = barcode.rawValue;
//     if (code == null || code.isEmpty) return;

//     final imageSize = capture.size;
//     final targetZoom = _computeTargetZoomScale(barcode, imageSize);
//     final detectedRect = _buildDetectedQrRect(barcode, imageSize);

//     uiState.value = state.copyWith(
//       isScanning: false,
//       isProcessing: true,
//       isCaptureZooming: true,
//       detectedCode: code,
//       detectedQrRect: detectedRect,
//       detectedCaptureSize: imageSize,
//     );

//     _animateZoomTo(targetZoom, duration: const Duration(milliseconds: 360));
//     await Future.delayed(const Duration(milliseconds: 260));

//     try {
//       await goodsSearch(Get.context!, code);
//     } finally {
//       if (!_isDisposed) {
//         _animateZoomTo(0.0, duration: const Duration(milliseconds: 300));
//         uiState.value = uiState.value.copyWith(
//           isProcessing: false,
//           isCaptureZooming: false,
//           clearDetectedQrRect: true,
//         );
//       }
//     }
//   }

//   Future<void> goodsSearch(BuildContext context, String code) async {
//     try {
//       final json = await scanQrUseCase.searchCode(context: context, code: code);

//       if (_isDisposed) return;

//       final searchResponse = GoodsSearchResponse.fromJson(json);

//       if (searchResponse.header?.result == true &&
//           searchResponse.header?.statusCode == 200 &&
//           searchResponse.body?.status == true) {
//         if (searchResponse.body?.data == null ||
//             searchResponse.body!.data!.isEmpty) {
//           await _displayDialog('information'.tr, 'no_data_found'.tr);
//           return;
//         }

//         final nextScreen =
//             state.scanFrom == 0
//                 ? _buildWithTokenScreen(searchResponse)
//                 : _buildNoTokenScreen(json);

//         await stopScanning(resetState: false);
//         await Get.to(
//           () => nextScreen,
//           transition: Transition.rightToLeft,
//           duration: const Duration(milliseconds: 350),
//         );

//         if (!_isDisposed) {
//           await restartScanning();
//         }
//       } else {
//         await _displayDialog('information'.tr, 'code_invalid'.tr);
//       }
//     } catch (e) {
//       await _displayDialog('information'.tr, 'error_occurred'.tr);
//       debugPrint('Goods search error: $e');
//     }
//   }

//   Widget _buildWithTokenScreen(GoodsSearchResponse searchResponse) {
//     final id = searchResponse.body!.data![0].id!.toInt();
//     return GoodsInformationScreen(id: id);
//   }

//   Widget _buildNoTokenScreen(Map<String, dynamic> json) {
//     return GoodsInformationNoTokenScreen(
//       futureData: Future.value(GoodsFindResponse.fromJson(json)),
//     );
//   }

//   Future<void> _displayDialog(String title, String description) async {
//     final completer = Completer<void>();

//     alertDialogTravelPackage(
//       title: title,
//       description: description,
//       buttonText: 'ok'.tr,
//       onButtonPressed: () {
//         Get.back();
//         if (!completer.isCompleted) completer.complete();
//       },
//     );

//     await completer.future;
//     await restartScanning();
//   }

//   Future<void> _displayPermissionDialog(
//     String title,
//     String description,
//   ) async {
//     if (_isPermissionDialogOpen) return;
//     _isPermissionDialogOpen = true;

//     final completer = Completer<void>();

//     alertDialogTwoButton(
//       title: title,
//       description: description,
//       buttonText1: 'cancel'.tr,
//       buttonText2: 'setting'.tr,
//       onButtonPressed1: () {
//         Get.back();
//         if (!completer.isCompleted) completer.complete();
//       },
//       onButtonPressed2: () async {
//         Get.back();
//         _isPermissionDialogOpen = false;
//         _openingAppSettings = true;
//         if (!completer.isCompleted) completer.complete();
//         debugPrint('ScanQrController: Routing to App Settings...');
//         await openAppSettings();
//       },
//     );

//     await completer.future;
//     if (!_openingAppSettings) {
//       _isPermissionDialogOpen = false;
//     }
//   }

//   Future<bool> ensureCameraPermission() async {
//     try {
//       final status = await Permission.camera.status;
//       debugPrint('ScanQrController: Camera permission status: $status');
//       if (status.isGranted) return true;

//       if (_openingAppSettings || _isPermissionDialogOpen) {
//         debugPrint(
//           'ScanQrController: Already routing to settings or permission dialog open.',
//         );
//         return false;
//       }

//       if (status.isDenied || status.isLimited) {
//         debugPrint('ScanQrController: Requesting camera permission...');
//         final req = await Permission.camera.request();
//         debugPrint('ScanQrController: Camera permission request result: $req');
//         if (req.isGranted) return true;
//       }

//       debugPrint(
//         'ScanQrController: Permission denied. Showing custom permission alert dialog.',
//       );
//       await _displayPermissionDialog(
//         'information'.tr,
//         'camera_permission_error'.tr,
//       );
//       return false;
//     } catch (e) {
//       debugPrint('ensureCameraPermission error: $e');
//       return false;
//     }
//   }

//   Future<void> cropImage(BuildContext context) async {
//     try {
//       await stopScanning();

//       final XFile? photo = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//       );
//       if (photo == null) {
//         debugPrint(
//           'ScanQrController: Image picking canceled. Resuming scanner...',
//         );
//         await restartScanning();
//         return;
//       }

//       final CroppedFile? croppedFile = await ImageCropper().cropImage(
//         sourcePath: photo.path,
//         compressFormat: ImageCompressFormat.jpg,
//         compressQuality: 100,
//         uiSettings: [
//           AndroidUiSettings(
//             toolbarTitle: 'crop_qr_code'.tr,
//             toolbarColor: AppColors.primaryColor,
//             toolbarWidgetColor: AppColors.whiteColor,
//             initAspectRatio: CropAspectRatioPreset.square,
//             lockAspectRatio: false,
//             aspectRatioPresets: const [
//               CropAspectRatioPreset.original,
//               CropAspectRatioPreset.square,
//               CropAspectRatioPreset.ratio4x3,
//             ],
//           ),
//           IOSUiSettings(
//             title: 'crop_qr_code'.tr,
//             aspectRatioLockEnabled: true,
//             resetAspectRatioEnabled: false,
//           ),
//         ],
//       );

//       if (croppedFile != null) {
//         try {
//           final capture = await scannerController.analyzeImage(
//             croppedFile.path,
//           );
//           if (capture != null && capture.barcodes.isNotEmpty) {
//             final code = capture.barcodes.first.rawValue;
//             if (code != null) {
//               await goodsSearch(Get.context!, code);
//             }
//           } else {
//             await _displayDialog('information'.tr, 'code_invalid'.tr);
//           }
//         } catch (e) {
//           debugPrint('QR analysis error: $e');
//           await _displayDialog('information'.tr, 'qr_analysis_error'.tr);
//         }
//       } else {
//         debugPrint(
//           'ScanQrController: Image cropping canceled. Resuming scanner...',
//         );
//         await restartScanning();
//       }
//     } catch (e) {
//       await _displayDialog('information'.tr, 'error_occurred'.tr);
//       debugPrint('Image cropping error: $e');
//     }
//   }
// }


import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  double _currentZoomScale = 0.0;

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

  Future<void> _setZoomScale(double zoomScale) async {
    final clamped = zoomScale.clamp(0.0, 1.0);
    _currentZoomScale = clamped;
    try {
      await scannerController.setZoomScale(clamped);
    } catch (_) {}
  }

  void _animateZoomTo(
    double targetZoomScale, {
    Duration duration = const Duration(milliseconds: 550),
    Curve curve = Curves.easeOutCubic,
  }) {
    if (_isDisposed) return;

    _cancelZoomAnimation();
    final from = _currentZoomScale;
    final to = targetZoomScale.clamp(0.0, 1.0);
    if ((from - to).abs() < 0.001) return;

    final stopwatch = Stopwatch()..start();
    _zoomAnimationTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (!scannerController.value.isRunning) {
        timer.cancel();
        return;
      }

      final tRaw = stopwatch.elapsedMilliseconds / duration.inMilliseconds;
      final t = tRaw.clamp(0.0, 1.0);
      final eased = curve.transform(t);
      final value = from + (to - from) * eased;
      _setZoomScale(value);

      if (t >= 1.0) {
        timer.cancel();
        _zoomAnimationTimer = null;
      }
    });
  }

  double _computeTargetZoomScale(Barcode barcode, Size captureSize) {
    final barcodeSize = barcode.size;
    final w = barcodeSize.width;
    final h = barcodeSize.height;
    final barcodeArea = w * h;

    double relativeArea;
    if (w <= 1.0 && h <= 1.0) {
      relativeArea = barcodeArea;
    } else {
      final imageArea = captureSize.width * captureSize.height;
      if (imageArea <= 0) {
        relativeArea = 0.0;
      } else {
        relativeArea = barcodeArea / imageArea;
      }
    }

    const desiredRelativeArea = 0.18;
    const maxRatio = 14.0;
    const maxZoom = 0.92;
    const minZoom = 0.28;

    if (relativeArea <= 0) return 0.75;

    if (relativeArea >= desiredRelativeArea) return minZoom;

    final ratio = (desiredRelativeArea / relativeArea).clamp(1.0, maxRatio);
    final scale = math.sqrt(ratio);
    final normalized = ((scale - 1) / (math.sqrt(maxRatio) - 1)).clamp(
      0.0,
      1.0,
    );
    final zoom = (normalized * maxZoom).clamp(0.0, maxZoom);
    return math.max(minZoom, zoom).clamp(0.0, maxZoom);
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
        _currentZoomScale = 0.0;
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
        _currentZoomScale = 0.0;
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
        _currentZoomScale = 0.0;
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

  Future<void> handleBarcodeDetection(
    BuildContext context,
    BarcodeCapture capture,
  ) async {
    if (!state.isScanning || state.isProcessing || _isDisposed || state.isQrDetected) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;
    if (code == null || code.isEmpty) return;

    final imageSize = capture.size;
    final targetZoom = _computeTargetZoomScale(barcode, imageSize);
    final detectedRect = _buildDetectedQrRect(barcode, imageSize);
    final rawImageBytes = capture.image; 

    uiState.value = state.copyWith(
      isScanning: true,
      isProcessing: true,
      isCaptureZooming: true,
      isQrDetected: true, 
      detectedCode: code,
      detectedQrRect: detectedRect,
      detectedCaptureSize: imageSize,
      capturedImage: rawImageBytes, 
    );

    // Keep camera running for continuous scanning
    // Don't stop the scanner

    if (_isDisposed) return;

    uiState.value = state.copyWith(isLaserActive: true);

    // Run laser effect window
    await Future.delayed(const Duration(milliseconds: 1800));

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

// import 'dart:async';
// import 'dart:math' as math;

// import 'package:express_vet/base/state_controller.dart';
// import 'package:express_vet/utils/alert_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_cropper/image_cropper.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';

// import '../screen/goods_information_no_token_screen.dart';
// import '../../../../history-dashboard/other-history/presentation/screen/goods_information_screen.dart';
// import '../../data/model/response/goods_find_response.dart';
// import '../../data/model/response/good_search_response.dart';
// import '../../../../../utils/app_colors.dart';
// import '../uistate/scan_qr_ui_state.dart';
// import '../../domain/uscase/scan_qr_usecase.dart';

// class ScanQrController extends StateController<ScanQrUiState>
//     with WidgetsBindingObserver {
//   final ScanQrUseCase scanQrUseCase;

//   ScanQrController(this.scanQrUseCase);

//   late final MobileScannerController scannerController;

//   Timer? _zoomAnimationTimer;
//   double _currentZoomScale = 0.0;

//   bool _isDisposed = false;
//   bool _initialized = false;
//   bool _isStarting = false;
//   bool _isStopping = false;
//   bool _isScreenVisible = false;
//   bool _isPermissionDialogOpen = false;
//   bool _openingAppSettings = false;
//   Timer? _cameraStartRetryTimer;
//   int _cameraStartRetryCount = 0;

//   static const int _maxCameraStartRetries = 10;
//   static const Duration _cameraStartRetryDelay = Duration(milliseconds: 250);

//   @override
//   ScanQrUiState onInitUiState() => const ScanQrUiState();

//   // @override
//   // void onInit() {
//   //   super.onInit();

//   //   scannerController = MobileScannerController(
//   //     autoStart: false,
//   //     detectionSpeed: DetectionSpeed.unrestricted,
//   //     detectionTimeoutMs: 150,
//   //     formats: [BarcodeFormat.qrCode],
//   //     cameraResolution: const Size(1280, 720),
//   //     returnImage: false,
//   //     facing: CameraFacing.back,
//   //     torchEnabled: false,
//   //   );
//   //   scannerController.addListener(_onScannerStateChanged);
//   // }

//   @override
//   void onInit() {
//     super.onInit();

//     scannerController = MobileScannerController(
//       autoStart: false,
//       detectionSpeed: DetectionSpeed.unrestricted,
//       detectionTimeoutMs: 150,
//       formats: [BarcodeFormat.qrCode],
//       cameraResolution: const Size(1280, 720),
//       returnImage: true, // <-- CRITICAL: Change this to true to capture image bytes
//       facing: CameraFacing.back,
//       torchEnabled: false,
//     );
//     scannerController.addListener(_onScannerStateChanged);
//   }

//   @override
//   Future<void> restartScanning() async {
//     if (_isDisposed || !_isScreenVisible) return;
//     uiState.value = state.copyWith(
//       isProcessing: false,
//       isCaptureZooming: false,
//       isQrDetected: false,   
//       isLaserActive: false,  
//       detectedCode: '',
//       capturedImage: null, // <-- Clear image reference on reset
//       clearDetectedQrRect: true,
//     );
//     await startScanning();
//   }

//   @override
//   Future<void> handleBarcodeDetection(
//     BuildContext context,
//     BarcodeCapture capture,
//   ) async {
//     if (!state.isScanning || state.isProcessing || _isDisposed || state.isQrDetected) return;

//     final barcodes = capture.barcodes;
//     if (barcodes.isEmpty) return;

//     final barcode = barcodes.first;
//     final code = barcode.rawValue;
//     if (code == null || code.isEmpty) return;

//     // Get the dynamic dimensions and image frames
//     final imageSize = capture.size;
//     final detectedRect = _buildDetectedQrRect(barcode, imageSize);
//     final rawImageBytes = capture.image; // Raw extracted image bytes

//     // =======================================================
//     // STAGE 1 & 2: Freeze frame, display it, and close camera
//     // =======================================================
//     uiState.value = state.copyWith(
//       isScanning: false,
//       isProcessing: true,
//       isCaptureZooming: true,
//       isQrDetected: true, 
//       detectedCode: code,
//       detectedQrRect: detectedRect,
//       detectedCaptureSize: imageSize,
//       capturedImage: rawImageBytes, // Cache the image frame into state
//     );

//     // Immediately stop camera stream right after grabbing frame data
//     await stopScanning(resetState: false);

//     if (_isDisposed) return;

//     // =======================================================
//     // STAGE 3: Turn on laser scanning vertical line over the frame
//     // =======================================================
//     uiState.value = state.copyWith(isLaserActive: true);

//     // Dynamic sweep delay animation window
//     await Future.delayed(const Duration(milliseconds: 1800));

//     if (_isDisposed) return;

//     try {
//       await goodsSearch(Get.context!, code);
//     } finally {
//       if (!_isDisposed) {
//         uiState.value = uiState.value.copyWith(
//           isProcessing: false,
//           isCaptureZooming: false,
//           isQrDetected: false,
//           isLaserActive: false,
//           capturedImage: null,
//           clearDetectedQrRect: true,
//         );
//       }
//     }
//   }

//   void _cancelZoomAnimation() {
//     _zoomAnimationTimer?.cancel();
//     _zoomAnimationTimer = null;
//   }

//   Future<void> _setZoomScale(double zoomScale) async {
//     final clamped = zoomScale.clamp(0.0, 1.0);
//     _currentZoomScale = clamped;
//     try {
//       await scannerController.setZoomScale(clamped);
//     } catch (_) {}
//   }

//   void _animateZoomTo(
//     double targetZoomScale, {
//     Duration duration = const Duration(milliseconds: 550),
//     Curve curve = Curves.easeOutCubic,
//   }) {
//     if (_isDisposed) return;

//     _cancelZoomAnimation();
//     final from = _currentZoomScale;
//     final to = targetZoomScale.clamp(0.0, 1.0);
//     if ((from - to).abs() < 0.001) return;

//     final stopwatch = Stopwatch()..start();
//     _zoomAnimationTimer = Timer.periodic(const Duration(milliseconds: 16), (
//       timer,
//     ) {
//       if (_isDisposed) {
//         timer.cancel();
//         return;
//       }
//       if (!scannerController.value.isRunning) {
//         timer.cancel();
//         return;
//       }

//       final tRaw = stopwatch.elapsedMilliseconds / duration.inMilliseconds;
//       final t = tRaw.clamp(0.0, 1.0);
//       final eased = curve.transform(t);
//       final value = from + (to - from) * eased;
//       _setZoomScale(value);

//       if (t >= 1.0) {
//         timer.cancel();
//         _zoomAnimationTimer = null;
//       }
//     });
//   }

//   double _computeTargetZoomScale(Barcode barcode, Size captureSize) {
//     final barcodeSize = barcode.size;
//     final w = barcodeSize.width;
//     final h = barcodeSize.height;
//     final barcodeArea = w * h;

//     double relativeArea;
//     if (w <= 1.0 && h <= 1.0) {
//       relativeArea = barcodeArea;
//     } else {
//       final imageArea = captureSize.width * captureSize.height;
//       if (imageArea <= 0) {
//         relativeArea = 0.0;
//       } else {
//         relativeArea = barcodeArea / imageArea;
//       }
//     }

//     const desiredRelativeArea = 0.18;
//     const maxRatio = 14.0;
//     const maxZoom = 0.92;
//     const minZoom = 0.28;

//     if (relativeArea <= 0) return 0.75;

//     if (relativeArea >= desiredRelativeArea) return minZoom;

//     final ratio = (desiredRelativeArea / relativeArea).clamp(1.0, maxRatio);
//     final scale = math.sqrt(ratio);
//     final normalized = ((scale - 1) / (math.sqrt(maxRatio) - 1)).clamp(
//       0.0,
//       1.0,
//     );
//     final zoom = (normalized * maxZoom).clamp(0.0, maxZoom);
//     return math.max(minZoom, zoom).clamp(0.0, maxZoom);
//   }

//   Rect _buildDetectedQrRect(Barcode barcode, Size captureSize) {
//     final corners = barcode.corners;
//     if (corners.isNotEmpty) {
//       final left = corners.map((point) => point.dx).reduce(math.min);
//       final top = corners.map((point) => point.dy).reduce(math.min);
//       final right = corners.map((point) => point.dx).reduce(math.max);
//       final bottom = corners.map((point) => point.dy).reduce(math.max);
//       final rect = Rect.fromLTRB(left, top, right, bottom);
//       if (rect.width > 0 && rect.height > 0) return rect;
//     }

//     final barcodeSize = barcode.size;
//     final width =
//         barcodeSize.width <= 1
//             ? barcodeSize.width * captureSize.width
//             : barcodeSize.width;
//     final height =
//         barcodeSize.height <= 1
//             ? barcodeSize.height * captureSize.height
//             : barcodeSize.height;
//     final left = (captureSize.width - width) / 2;
//     final top = (captureSize.height - height) / 2;

//     return Rect.fromLTWH(left, top, width, height);
//   }

//   void setScanFrom(int scanFrom) {
//     uiState.value = state.copyWith(scanFrom: scanFrom);
//   }

//   void onScreenVisible() {
//     debugPrint(
//       'ScanQrController: Screen visible. Initializing and scheduling scanner...',
//     );
//     _isScreenVisible = true;
//     if (!_initialized) {
//       _initialized = true;
//       WidgetsBinding.instance.addObserver(this);
//     }

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_isDisposed || !_isScreenVisible) return;
//       restartScanning();
//     });
//   }

//   Future<void> onScreenHidden() async {
//     debugPrint('ScanQrController: Screen hidden. Stopping scanner...');
//     _isScreenVisible = false;
//     _cameraStartRetryTimer?.cancel();
//     _cameraStartRetryTimer = null;
//     _cameraStartRetryCount = 0;
//     await stopScanning();
//   }

//   // Future<void> restartScanning() async {
//   //   if (_isDisposed || !_isScreenVisible) return;
//   //   uiState.value = state.copyWith(
//   //     isProcessing: false,
//   //     isCaptureZooming: false,
//   //     isQrDetected: false,   // Reset Stage 2
//   //     isLaserActive: false,  // Reset Stage 3
//   //     detectedCode: '',
//   //     clearDetectedQrRect: true,
//   //   );
//   //   await startScanning();
//   // }

//   Future<void> startScanning() async {
//     if (_isDisposed || !_isScreenVisible) return;
//     debugPrint(
//       'ScanQrController: startScanning() requested. isRunning: ${scannerController.value.isRunning}, isStarting: $_isStarting, isStopping: $_isStopping',
//     );
//     if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
//       debugPrint(
//         'ScanQrController: Aborting startScanning() because app is not resumed.',
//       );
//       return;
//     }
//     if (scannerController.value.isRunning) {
//       _cameraStartRetryTimer?.cancel();
//       _cameraStartRetryTimer = null;
//       _cameraStartRetryCount = 0;
//       try {
//         await scannerController.resetZoomScale();
//         _currentZoomScale = 0.0;
//       } catch (_) {}
//       uiState.value = state.copyWith(
//         isScanning: true,
//         isProcessing: false,
//         isCaptureZooming: false,
//         isQrDetected: false,
//         isLaserActive: false,
//         detectedCode: '',
//         clearDetectedQrRect: true,
//       );
//       return;
//     }
//     if (_isStarting || _isStopping) return;
//     _isStarting = true;
//     try {
//       final allowed = await ensureCameraPermission();
//       if (!allowed) {
//         uiState.value = state.copyWith(isScanning: false);
//         return;
//       }
//       if (_isDisposed ||
//           WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
//         return;
//       }
//       debugPrint('ScanQrController: Starting camera scanner...');
//       await scannerController.start();
//       debugPrint('ScanQrController: Camera scanner successfully started.');

//       try {
//         await scannerController.resetZoomScale();
//         _currentZoomScale = 0.0;
//       } catch (_) {}

//       _cameraStartRetryTimer?.cancel();
//       _cameraStartRetryTimer = null;
//       _cameraStartRetryCount = 0;
//       uiState.value = state.copyWith(
//         isScanning: true,
//         isProcessing: false,
//         isCaptureZooming: false,
//         isQrDetected: false,
//         isLaserActive: false,
//         detectedCode: '',
//         clearDetectedQrRect: true,
//       );
//     } on MobileScannerException catch (e) {
//       final message = e.toString().toLowerCase();
//       debugPrint('Error starting scanner: $e');

//       if (message.contains('controllerinitializing') ||
//           message.contains('controllernotattached')) {
//         uiState.value = state.copyWith(isScanning: false);
//         _scheduleCameraStartRetry();
//         return;
//       }

//       if (message.contains('permission')) {
//         uiState.value = state.copyWith(isScanning: false);
//         await _displayPermissionDialog(
//           'information'.tr,
//           'camera_permission_error'.tr,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error starting scanner: $e');
//     } finally {
//       _isStarting = false;
//     }
//   }

//   void _scheduleCameraStartRetry({bool resetCount = false}) {
//     if (_isDisposed) return;
//     if (resetCount) _cameraStartRetryCount = 0;
//     if (_cameraStartRetryTimer?.isActive ?? false) return;
//     if (_cameraStartRetryCount >= _maxCameraStartRetries) return;

//     _cameraStartRetryCount++;
//     _cameraStartRetryTimer = Timer(_cameraStartRetryDelay, () {
//       _cameraStartRetryTimer = null;
//       if (_isDisposed) return;
//       startScanning();
//     });
//   }

//   Future<void> stopScanning({bool resetState = true}) async {
//     if (_isDisposed || _isStopping) return;
//     _cameraStartRetryTimer?.cancel();
//     _cameraStartRetryTimer = null;
//     _cancelZoomAnimation();
//     _isStopping = true;
//     try {
//       if (scannerController.value.isRunning) {
//         await scannerController.stop();
//       }
//       try {
//         await scannerController.resetZoomScale();
//         _currentZoomScale = 0.0;
//       } catch (_) {}
//       if (!_isDisposed && resetState) {
//         uiState.value = state.copyWith(
//           isScanning: false,
//           isProcessing: false,
//           isCaptureZooming: false,
//           isQrDetected: false,  // Reset Stage 2
//           isLaserActive: false, // Reset Stage 3
//           detectedCode: '',
//           clearDetectedQrRect: true,
//         );
//       }
//     } catch (e) {
//       debugPrint('Error stopping scanner: $e');
//     } finally {
//       _isStopping = false;
//     }
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _isDisposed = true;
//     _isScreenVisible = false;
//     _cameraStartRetryTimer?.cancel();
//     _cameraStartRetryTimer = null;
//     _cancelZoomAnimation();

//     scannerController.removeListener(_onScannerStateChanged);

//     scannerController
//         .stop()
//         .then((_) => scannerController.dispose())
//         .catchError((_) {});

//     super.onClose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (_isDisposed) return;
//     debugPrint('ScanQrController: App lifecycle changed to: $state');

//     switch (state) {
//       case AppLifecycleState.resumed:
//         Future.delayed(const Duration(milliseconds: 500), () async {
//           if (_isDisposed) return;
//           if (WidgetsBinding.instance.lifecycleState !=
//               AppLifecycleState.resumed) {
//             return;
//           }

//           final status = await Permission.camera.status;
//           _openingAppSettings = false;

//           if (!_isScreenVisible) return;

//           if (status.isGranted) {
//             _scheduleCameraStartRetry(resetCount: true);
//           } else if (!_isPermissionDialogOpen) {
//             await _displayPermissionDialog(
//               'information'.tr,
//               'camera_permission_error'.tr,
//             );
//           }
//         });
//         break;
//       case AppLifecycleState.inactive:
//       case AppLifecycleState.paused:
//       case AppLifecycleState.detached:
//       case AppLifecycleState.hidden:
//         stopScanning();
//         break;
//     }
//   }

//   void _onScannerStateChanged() {
//     if (_isDisposed) return;
//     final isTorchOn = scannerController.value.torchState == TorchState.on;
//     if (uiState.value.flash != isTorchOn) {
//       uiState.value = uiState.value.copyWith(flash: isTorchOn);
//     }
//   }

//   Future<void> toggleFlash() async {
//     try {
//       await scannerController.toggleTorch();
//     } catch (e) {
//       debugPrint('Error toggling torch: $e');
//       _displayDialog('information'.tr, 'flash_error'.tr);
//     }
//   }

//   // Future<void> handleBarcodeDetection(
//   //   BuildContext context,
//   //   BarcodeCapture capture,
//   // ) async {
//   //   // block incoming frames if processing or if we already flagged a detection lock
//   //   if (!state.isScanning || state.isProcessing || _isDisposed || state.isQrDetected) return;

//   //   final barcodes = capture.barcodes;
//   //   if (barcodes.isEmpty) return;

//   //   final barcode = barcodes.first;
//   //   final code = barcode.rawValue;
//   //   if (code == null || code.isEmpty) return;

//   //   final imageSize = capture.size;
//   //   final targetZoom = _computeTargetZoomScale(barcode, imageSize);
//   //   final detectedRect = _buildDetectedQrRect(barcode, imageSize);

//   //   // ==========================================
//   //   // STAGE 1 & 2: QR Code found, scale overlay frame out
//   //   // ==========================================
//   //   uiState.value = state.copyWith(
//   //     isScanning: false,
//   //     isProcessing: true,
//   //     isCaptureZooming: true,
//   //     isQrDetected: true, // Scales layout containers
//   //     detectedCode: code,
//   //     detectedQrRect: detectedRect,
//   //     detectedCaptureSize: imageSize,
//   //   );

//   //   // Animate camera preview zoom to crop closely on target bounds
//   //   _animateZoomTo(targetZoom, duration: const Duration(milliseconds: 360));
    
//   //   // Give time for layout container morphing animations to finish expanding
//   //   await Future.delayed(const Duration(milliseconds: 400));

//   //   if (_isDisposed) return;

//   //   // ==========================================
//   //   // STAGE 3: Turn on laser scanning verticalLine animation
//   //   // ==========================================
//   //   uiState.value = state.copyWith(isLaserActive: true);

//   //   // Hold visual scanning state for 1.6s to sweep the laser up and down cleanly
//   //   await Future.delayed(const Duration(milliseconds: 1600));

//   //   if (_isDisposed) return;

//   //   try {
//   //     // Execute standard database/API endpoint lookup logic matching payload
//   //     await goodsSearch(Get.context!, code);
//   //   } finally {
//   //     if (!_isDisposed) {
//   //       _animateZoomTo(0.0, duration: const Duration(milliseconds: 300));
//   //       uiState.value = uiState.value.copyWith(
//   //         isProcessing: false,
//   //         isCaptureZooming: false,
//   //         isQrDetected: false,
//   //         isLaserActive: false,
//   //         clearDetectedQrRect: true,
//   //       );
//   //     }
//   //   }
//   // }

//   Future<void> goodsSearch(BuildContext context, String code) async {
//     try {
//       final json = await scanQrUseCase.searchCode(context: context, code: code);

//       if (_isDisposed) return;

//       final searchResponse = GoodsSearchResponse.fromJson(json);

//       if (searchResponse.header?.result == true &&
//           searchResponse.header?.statusCode == 200 &&
//           searchResponse.body?.status == true) {
//         if (searchResponse.body?.data == null ||
//             searchResponse.body!.data!.isEmpty) {
//           await _displayDialog('information'.tr, 'no_data_found'.tr);
//           return;
//         }

//         final nextScreen =
//             state.scanFrom == 0
//                 ? _buildWithTokenScreen(searchResponse)
//                 : _buildNoTokenScreen(json);

//         await stopScanning(resetState: false);
//         await Get.to(
//           () => nextScreen,
//           transition: Transition.rightToLeft,
//           duration: const Duration(milliseconds: 350),
//         );

//         if (!_isDisposed) {
//           await restartScanning();
//         }
//       } else {
//         await _displayDialog('information'.tr, 'code_invalid'.tr);
//       }
//     } catch (e) {
//       await _displayDialog('information'.tr, 'error_occurred'.tr);
//       debugPrint('Goods search error: $e');
//     }
//   }

//   Widget _buildWithTokenScreen(GoodsSearchResponse searchResponse) {
//     final id = searchResponse.body!.data![0].id!.toInt();
//     return GoodsInformationScreen(id: id);
//   }

//   Widget _buildNoTokenScreen(Map<String, dynamic> json) {
//     return GoodsInformationNoTokenScreen(
//       futureData: Future.value(GoodsFindResponse.fromJson(json)),
//     );
//   }

//   Future<void> _displayDialog(String title, String description) async {
//     final completer = Completer<void>();

//     alertDialogTravelPackage(
//       title: title,
//       description: description,
//       buttonText: 'ok'.tr,
//       onButtonPressed: () {
//         Get.back();
//         if (!completer.isCompleted) completer.complete();
//       },
//     );

//     await completer.future;
//     await restartScanning();
//   }

//   Future<void> _displayPermissionDialog(
//     String title,
//     String description,
//   ) async {
//     if (_isPermissionDialogOpen) return;
//     _isPermissionDialogOpen = true;

//     final completer = Completer<void>();

//     alertDialogTwoButton(
//       title: title,
//       description: description,
//       buttonText1: 'cancel'.tr,
//       buttonText2: 'setting'.tr,
//       onButtonPressed1: () {
//         Get.back();
//         if (!completer.isCompleted) completer.complete();
//       },
//       onButtonPressed2: () async {
//         Get.back();
//         _isPermissionDialogOpen = false;
//         _openingAppSettings = true;
//         if (!completer.isCompleted) completer.complete();
//         debugPrint('ScanQrController: Routing to App Settings...');
//         await openAppSettings();
//       },
//     );

//     await completer.future;
//     if (!_openingAppSettings) {
//       _isPermissionDialogOpen = false;
//     }
//   }

//   Future<bool> ensureCameraPermission() async {
//     try {
//       final status = await Permission.camera.status;
//       debugPrint('ScanQrController: Camera permission status: $status');
//       if (status.isGranted) return true;

//       if (_openingAppSettings || _isPermissionDialogOpen) {
//         debugPrint(
//           'ScanQrController: Already routing to settings or permission dialog open.',
//         );
//         return false;
//       }

//       if (status.isDenied || status.isLimited) {
//         debugPrint('ScanQrController: Requesting camera permission...');
//         final req = await Permission.camera.request();
//         debugPrint('ScanQrController: Camera permission request result: $req');
//         if (req.isGranted) return true;
//       }

//       debugPrint(
//         'ScanQrController: Permission denied. Showing custom permission alert dialog.',
//       );
//       await _displayPermissionDialog(
//         'information'.tr,
//         'camera_permission_error'.tr,
//       );
//       return false;
//     } catch (e) {
//       debugPrint('ensureCameraPermission error: $e');
//       return false;
//     }
//   }

//   Future<void> cropImage(BuildContext context) async {
//     try {
//       await stopScanning();

//       final XFile? photo = await ImagePicker().pickImage(
//         source: ImageSource.gallery,
//       );
//       if (photo == null) {
//         debugPrint(
//           'ScanQrController: Image picking canceled. Resuming scanner...',
//         );
//         await restartScanning();
//         return;
//       }

//       final CroppedFile? croppedFile = await ImageCropper().cropImage(
//         sourcePath: photo.path,
//         compressFormat: ImageCompressFormat.jpg,
//         compressQuality: 100,
//         uiSettings: [
//           AndroidUiSettings(
//             toolbarTitle: 'crop_qr_code'.tr,
//             toolbarColor: AppColors.primaryColor,
//             toolbarWidgetColor: AppColors.whiteColor,
//             initAspectRatio: CropAspectRatioPreset.square,
//             lockAspectRatio: false,
//             aspectRatioPresets: const [
//               CropAspectRatioPreset.original,
//               CropAspectRatioPreset.square,
//               CropAspectRatioPreset.ratio4x3,
//             ],
//           ),
//           IOSUiSettings(
//             title: 'crop_qr_code'.tr,
//             aspectRatioLockEnabled: true,
//             resetAspectRatioEnabled: false,
//           ),
//         ],
//       );

//       if (croppedFile != null) {
//         try {
//           final capture = await scannerController.analyzeImage(
//             croppedFile.path,
//           );
//           if (capture != null && capture.barcodes.isNotEmpty) {
//             final code = capture.barcodes.first.rawValue;
//             if (code != null) {
//               await goodsSearch(Get.context!, code);
//             }
//           } else {
//             await _displayDialog('information'.tr, 'code_invalid'.tr);
//           }
//         } catch (e) {
//           debugPrint('QR analysis error: $e');
//           await _displayDialog('information'.tr, 'qr_analysis_error'.tr);
//         }
//       } else {
//         debugPrint(
//           'ScanQrController: Image cropping canceled. Resuming scanner...',
//         );
//         await restartScanning();
//       }
//     } catch (e) {
//       await _displayDialog('information'.tr, 'error_occurred'.tr);
//       debugPrint('Image cropping error: $e');
//     }
//   }
// }