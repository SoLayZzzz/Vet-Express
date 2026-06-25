import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum _ConnectionBannerState { none, offline, reconnecting }

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = false.obs;

  SnackbarController? _statusSnackbarController;
  _ConnectionBannerState _bannerState = _ConnectionBannerState.none;
  int _verifySequence = 0;

  Timer? _periodicRecheckTimer;
  bool _periodicCheckInProgress = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      _updateConnectionStatus(results, fromInit: true);
    } catch (e) {
      log('Error checking connectivity: $e');
    }
  }

  void _updateConnectionStatus(
    List<ConnectivityResult> results, {
    bool fromInit = false,
  }) {
    final logicalConnected =
        results.isNotEmpty &&
        results.any(
          (result) =>
              result != ConnectivityResult.none &&
              result != ConnectivityResult.bluetooth,
        );

    if (!logicalConnected) {
      isConnected.value = false;
      _handleDisconnected();
      return;
    }

    if (isConnected.value) return;

    final showUi = !fromInit && _bannerState != _ConnectionBannerState.none;
    _handleReconnectingAndVerify(showUi: showUi);
  }

  void _handleConnected({required bool showSnackbar}) {
    isConnected.value = true;

    _periodicRecheckTimer?.cancel();
    _periodicRecheckTimer = null;

    if (_bannerState != _ConnectionBannerState.none) {
      _bannerState = _ConnectionBannerState.none;
      _statusSnackbarController?.close();
      _statusSnackbarController = null;
    }

    if (showSnackbar) {
      Get.rawSnackbar(
        titleText: Text(
          'connected'.tr,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          'internet_connected'.tr,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        icon: const Icon(
          Icons.wifi_rounded,
          color: Color(0xFF2E7D32),
          size: 24,
        ),
        backgroundColor: const Color(0xFFC8E6C9),
        duration: const Duration(seconds: 3),
        isDismissible: true,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }
  }

  void _handleReconnectingAndVerify({required bool showUi}) {
    if (isConnected.value) return;

    if (showUi && _bannerState != _ConnectionBannerState.reconnecting) {
      _bannerState = _ConnectionBannerState.reconnecting;
      _statusSnackbarController?.close();
      _statusSnackbarController = Get.rawSnackbar(
        titleText: Text(
          'reconnecting'.tr,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          'connecting_to_internet'.tr,
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
        icon: const Icon(
          Icons.wifi_rounded,
          color: Color(0xFFFF9800),
          size: 24,
        ),
        backgroundColor: const Color(0xFFFFE0B2),
        duration: const Duration(days: 365),
        isDismissible: false,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
        shouldIconPulse: true,
      );
    }

    final seq = ++_verifySequence;
    () async {
      final ok = await _hasActualConnection();
      if (seq != _verifySequence) return;

      if (ok) {
        _handleConnected(showSnackbar: showUi);
      } else {
        _handleDisconnected();
      }
    }();
  }

  void _handleDisconnected() {
    final seq = ++_verifySequence;

    _periodicRecheckTimer ??= Timer.periodic(const Duration(seconds: 3), (_) {
      if (isConnected.value) {
        _periodicRecheckTimer?.cancel();
        _periodicRecheckTimer = null;
        return;
      }

      if (_periodicCheckInProgress) return;
      _periodicCheckInProgress = true;

      final shouldShowConnectedSnackbar =
          _bannerState != _ConnectionBannerState.none;
      () async {
        try {
          final ok = await _hasActualConnection();
          if (ok) {
            _handleConnected(showSnackbar: shouldShowConnectedSnackbar);
          }
        } finally {
          _periodicCheckInProgress = false;
        }
      }();
    });

    () async {
      await Future.delayed(const Duration(milliseconds: 400));
      final stillOffline = !(await _hasActualConnection());
      if (seq != _verifySequence) return;

      if (!stillOffline) {
        _handleReconnectingAndVerify(
          showUi: _bannerState != _ConnectionBannerState.none,
        );
        return;
      }

      if (_bannerState != _ConnectionBannerState.offline) {
        _bannerState = _ConnectionBannerState.offline;
        _statusSnackbarController?.close();
        _statusSnackbarController = Get.rawSnackbar(
          titleText: Text(
            'connection'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          messageText: Text(
            'no_internet_connection'.tr,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          icon: const Icon(
            Icons.wifi_off_rounded,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: const Color(0xFFD32F2F),
          duration: const Duration(days: 365),
          isDismissible: false,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
          shouldIconPulse: true,
        );
      }
    }();
  }

  Future<bool> _hasActualConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final logicalConnected =
          results.isNotEmpty &&
          results.any(
            (r) =>
                r != ConnectivityResult.none &&
                r != ConnectivityResult.bluetooth,
          );
      if (!logicalConnected) return false;

      try {
        final socket = await Socket.connect(
          '1.1.1.1',
          443,
          timeout: const Duration(seconds: 4),
        );
        socket.destroy();
        return true;
      } catch (_) {}

      HttpClient? client;
      try {
        client = HttpClient()..connectionTimeout = const Duration(seconds: 4);

        final urls = <Uri>[
          Uri.parse('https://www.apple.com/library/test/success.html'),
          Uri.parse('https://clients3.google.com/generate_204'),
        ];

        for (final url in urls) {
          final request = await client
              .getUrl(url)
              .timeout(const Duration(seconds: 4));
          request.followRedirects = false;
          final response =
              await request.close().timeout(const Duration(seconds: 4));
          final ok = response.statusCode >= 200 && response.statusCode < 400;
          await response.drain();
          if (ok) return true;
        }
      } catch (_) {
      } finally {
        client?.close(force: true);
      }

      final lookup = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 4));
      return lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty;
    } catch (e) {
      log('Error verifying internet access: $e');
      return false;
    }
  }

  Future<void> recheckConnection() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkConnectivity();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _statusSnackbarController?.close();
    _periodicRecheckTimer?.cancel();
    super.onClose();
  }
}
