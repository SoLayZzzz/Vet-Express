import 'dart:async';
import 'dart:developer';

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
  bool _didRetryStart = false;
  bool _isStarting = false;
  bool _isPermissionDialogOpen = false;

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
  }

  void setScanFrom(int scanFrom) {
    uiState.value = state.copyWith(scanFrom: scanFrom);
  }

  void onScreenVisible() {
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addObserver(this);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return;
      ensureCameraPermission().then((allowed) {
        if (_isDisposed) return;
        if (allowed) startScanning();
      });
    });
  }

  Future<void> startScanning() async {
    if (_isDisposed) return;
    if (state.isScanning) return;
    if (_isStarting) return;
    _isStarting = true;
    try {
      final allowed = await ensureCameraPermission();
      if (!allowed) {
        uiState.value = state.copyWith(isScanning: false);
        return;
      }
      await scannerController.start();
      _didRetryStart = false;
      uiState.value = state.copyWith(isScanning: true);
    } on MobileScannerException catch (e) {
      final message = e.toString().toLowerCase();
      debugPrint('Error starting scanner: $e');

      if (message.contains('controllerinitializing')) {
        return;
      }

      if (message.contains('controllernotattached')) {
        if (_didRetryStart) return;
        _didRetryStart = true;

        Future.delayed(const Duration(milliseconds: 100), () {
          if (_isDisposed) return;
          startScanning();
        });
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

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;

    scannerController
        .stop()
        .then((_) => scannerController.dispose())
        .catchError((_) {});

    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (_isDisposed) return;

    switch (appState) {
      case AppLifecycleState.resumed:
        if (!state.isScanning) {
          ensureCameraPermission().then((allowed) {
            if (_isDisposed) return;
            if (allowed) startScanning();
          });
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        scannerController
            .stop()
            .then((_) {
              uiState.value = state.copyWith(isScanning: false);
            })
            .catchError((e) {
              debugPrint('Error stopping scanner: $e');
            });
        break;
    }
  }

  Future<void> toggleFlash() async {
    try {
      await scannerController.toggleTorch();
      uiState.value = state.copyWith(flash: !state.flash);
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

    uiState.value = state.copyWith(isScanning: false);
    await scannerController.stop();

    final code = barcodes.first.rawValue;
    if (code != null) {
      await goodsSearch(Get.context!, code);
    }
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

  Future<void> _displayPermissionDialog(String title, String description) async {
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
        await openAppSettings();
        Get.back();
        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
    _isPermissionDialogOpen = false;
  }

  Future<bool> ensureCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) return true;

      if (status.isDenied || status.isLimited) {
        final req = await Permission.camera.request();
        if (req.isGranted) return true;
      }

      await _displayPermissionDialog('information'.tr, 'camera_permission_error'.tr);
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
      }
    } catch (e) {
      await _displayDialog('information'.tr, 'error_occurred'.tr);
      debugPrint('Image cropping error: $e');
    }
  }
}
