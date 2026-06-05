import 'dart:async';
import 'dart:math';

import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../screen/goods_information_no_token_screen.dart';
import '../../../../home-dashboard/notifications/presentation/screen/goods_information_screen.dart';
import '../../data/model/response/goods_find_response.dart';
import '../../data/model/response/good_search_response.dart';
import '../../../../../utils/app_colors.dart';
import '../uistate/scan_qr_ui_state.dart';
import '../../domain/uscase/scan_qr_usecase.dart';

class ScanQrController extends StateController<ScanQrUiState>
    with WidgetsBindingObserver {
  final ScanQrUseCase scanQrUseCase;

  ScanQrController(this.scanQrUseCase);

  late final MobileScannerController scannerController;

  bool _isDisposed = false;
  bool _initialized = false;
  bool _isStarting = false;
  bool _isStopping = false;
  bool _isPermissionDialogOpen = false;
  bool _openingAppSettings = false;

  Timer? _zoomAnimationTimer;
  Timer? _cameraStartRetryTimer;
  DateTime? _lastZoomRequestAt;
  bool _isZoomAnimating = false;
  int _cameraStartRetryCount = 0;

  static const double _minRelativeBarcodeAreaToAccept = 0.04;
  static const double _zoomStep = 0.6;
  static const double _maxZoomScale = 3.0;
  static const Duration _zoomRequestCooldown = Duration(milliseconds: 800);
  static const int _maxCameraStartRetries = 10;
  static const Duration _cameraStartRetryDelay = Duration(milliseconds: 250);

  @override
  ScanQrUiState onInitUiState() => const ScanQrUiState();

  @override
  void onInit() {
    super.onInit();

    scannerController = MobileScannerController(
      autoStart: false,
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 500,
      formats: [BarcodeFormat.qrCode],
      cameraResolution: const Size(1280, 720),
      returnImage: false,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    scannerController.addListener(_onScannerStateChanged);
  }

  void setScanFrom(int scanFrom) {
    uiState.value = state.copyWith(scanFrom: scanFrom);
  }

  void onScreenVisible() {
    debugPrint(
      'ScanQrController: Screen visible. Initializing and scheduling scanner...',
    );
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addObserver(this);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      _scheduleCameraStartRetry(resetCount: true);
    });
  }

  Future<void> startScanning() async {
    if (_isDisposed) return;
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
      _cameraStartRetryTimer?.cancel();
      _cameraStartRetryTimer = null;
      _cameraStartRetryCount = 0;
      if (!state.isScanning) {
        uiState.value = state.copyWith(isScanning: true);
      }
      return;
    }
    if (_isStarting || _isStopping) return;
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
      uiState.value = state.copyWith(isScanning: true);
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

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;

    _zoomAnimationTimer?.cancel();
    _zoomAnimationTimer = null;
    _cameraStartRetryTimer?.cancel();
    _cameraStartRetryTimer = null;

    scannerController.removeListener(_onScannerStateChanged);

    scannerController
        .stop()
        .then((_) => scannerController.dispose())
        .catchError((_) {});

    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    debugPrint('ScanQrController: App lifecycle changed to: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (_isDisposed) return;
          if (WidgetsBinding.instance.lifecycleState !=
              AppLifecycleState.resumed) {
            return;
          }

          final status = await Permission.camera.status;
          _openingAppSettings = false;

          if (status.isGranted) {
            _scheduleCameraStartRetry(resetCount: true);
          } else if (!_isPermissionDialogOpen) {
            await _displayPermissionDialog(
              'information'.tr,
              'camera_permission_error'.tr,
            );
          }
        });
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _cameraStartRetryTimer?.cancel();
        _cameraStartRetryTimer = null;

        if (scannerController.value.isRunning && !_isStopping) {
          _isStopping = true;
          debugPrint(
            'ScanQrController: Scanner is running. Stopping scanner...',
          );
          scannerController
              .stop()
              .then((_) {
                debugPrint('ScanQrController: Scanner stopped successfully.');
                _isStopping = false;
                if (!_isDisposed) {
                  uiState.value = uiState.value.copyWith(isScanning: false);
                }
              })
              .catchError((e) {
                _isStopping = false;
                debugPrint('Error stopping scanner: $e');
              });
        }
        break;
    }
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
    if (!state.isScanning || _isDisposed) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;
    if (code == null || code.isEmpty) return;

    final imageSize = capture.size;
    final isSmall = _isBarcodeTooSmall(barcode, imageSize);
    if (isSmall) {
      _requestAnimatedZoomToBarcode(barcode, imageSize);
      return;
    }

    uiState.value = state.copyWith(isScanning: false);
    await scannerController.stop();

    await goodsSearch(Get.context!, code);
  }

  bool _isBarcodeTooSmall(Barcode barcode, Size imageSize) {
    final barcodeSize = barcode.size;

    final imageArea = imageSize.width * imageSize.height;
    if (imageArea <= 0) return false;

    final barcodeArea = barcodeSize.width * barcodeSize.height;
    final relativeArea = barcodeArea / imageArea;
    return relativeArea < _minRelativeBarcodeAreaToAccept;
  }

  void _requestAnimatedZoomToBarcode(Barcode barcode, Size imageSize) {
    if (_isDisposed) return;
    if (!scannerController.value.isRunning) return;

    final now = DateTime.now();
    final last = _lastZoomRequestAt;
    if (last != null && now.difference(last) < _zoomRequestCooldown) {
      return;
    }
    _lastZoomRequestAt = now;

    if (!_isZoomAnimating) {
      _setFocusPointForBarcode(barcode, imageSize);
    }

    final currentZoom = scannerController.value.zoomScale;
    final targetZoom = min(currentZoom + _zoomStep, _maxZoomScale);
    if (targetZoom <= currentZoom) return;

    _animateZoom(currentZoom: currentZoom, targetZoom: targetZoom);
  }

  void _setFocusPointForBarcode(Barcode barcode, Size imageSize) {
    final corners = barcode.corners;
    if (corners.isEmpty) {
      scannerController
          .setFocusPoint(const Offset(0.5, 0.5))
          .catchError((_) {});
      return;
    }

    double minX = corners.first.dx;
    double maxX = corners.first.dx;
    double minY = corners.first.dy;
    double maxY = corners.first.dy;

    for (final c in corners) {
      minX = min(minX, c.dx);
      maxX = max(maxX, c.dx);
      minY = min(minY, c.dy);
      maxY = max(maxY, c.dy);
    }

    final centerX = (minX + maxX) / 2;
    final centerY = (minY + maxY) / 2;

    final normX = (centerX / imageSize.width).clamp(0.0, 1.0);
    final normY = (centerY / imageSize.height).clamp(0.0, 1.0);

    scannerController.setFocusPoint(Offset(normX, normY)).catchError((_) {});
  }

  void _animateZoom({required double currentZoom, required double targetZoom}) {
    _zoomAnimationTimer?.cancel();
    _zoomAnimationTimer = null;

    _isZoomAnimating = true;

    const totalSteps = 10;
    var step = 0;
    _zoomAnimationTimer = Timer.periodic(const Duration(milliseconds: 40), (t) {
      if (_isDisposed) {
        t.cancel();
        _isZoomAnimating = false;
        return;
      }
      if (!scannerController.value.isRunning) {
        t.cancel();
        _isZoomAnimating = false;
        return;
      }

      step++;
      final p = (step / totalSteps).clamp(0.0, 1.0);
      final zoom = currentZoom + (targetZoom - currentZoom) * p;
      scannerController.setZoomScale(zoom).catchError((_) {});

      if (step >= totalSteps) {
        t.cancel();
        _isZoomAnimating = false;
      }
    });
  }

  Future<void> goodsSearch(BuildContext context, String code) async {
    Loading().loadingShow();

    try {
      final json = await scanQrUseCase.searchCode(context: context, code: code);

      if (Get.context!.mounted) {
        Loading().loadingClose();
      }

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

        final result = await Get.to(
          () => nextScreen,
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 350),
        );

        if (result == null) {
          await startScanning();
        }
      } else {
        await _displayDialog('information'.tr, 'code_invalid'.tr);
      }
    } catch (e) {
      Loading().loadingClose();
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
    await startScanning();
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
      await scannerController.stop();

      final XFile? photo = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (photo == null) {
        debugPrint(
          'ScanQrController: Image picking canceled. Resuming scanner...',
        );
        await startScanning();
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
        await startScanning();
      }
    } catch (e) {
      await _displayDialog('information'.tr, 'error_occurred'.tr);
      debugPrint('Image cropping error: $e');
    }
  }
}
