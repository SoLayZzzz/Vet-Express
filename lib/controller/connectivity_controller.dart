import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;

  SnackbarController? _offlineSnackbarController;
  bool _wasOffline = false;

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
      _updateConnectionStatus(results);
    } catch (e) {
      log('Error checking connectivity: $e');
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    bool hasConnection =
        results.isNotEmpty &&
        results.any(
          (result) =>
              result != ConnectivityResult.none &&
              result != ConnectivityResult.bluetooth,
        );

    isConnected.value = hasConnection;

    if (hasConnection) {
      _handleConnected();
    } else {
      _handleDisconnected();
    }
  }

  void _handleConnected() {
    if (_wasOffline) {
      _wasOffline = false;
      _offlineSnackbarController?.close();
      _offlineSnackbarController = null;

      Get.rawSnackbar(
        titleText: Text(
          'back_online'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: Text(
          'internet_connection_restored'.tr,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        icon: const Icon(Icons.wifi_rounded, color: Colors.white, size: 24),
        backgroundColor: const Color(0xFF388E3C), // Emerald/green
        duration: const Duration(seconds: 3),
        isDismissible: true,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(12),
        borderRadius: 8,
      );
    }
  }

  void _handleDisconnected() {
    if (!_wasOffline) {
      () async {
        await Future.delayed(const Duration(milliseconds: 400));
        final stillOffline = !(await _hasActualConnection());
        if (!stillOffline) {
          _handleConnected();
          return;
        }

        if (!_wasOffline) {
          _wasOffline = true;
          _offlineSnackbarController?.close();
          _offlineSnackbarController = Get.rawSnackbar(
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
            backgroundColor: const Color(0xFFD32F2F), // Crimson red
            duration: const Duration(days: 365), // Persistent
            isDismissible: false,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 8,
            shouldIconPulse: true,
          );
        }
      }();
    }
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
      if (logicalConnected) return true;

      final lookup = await InternetAddress.lookup(
        'example.com',
      ).timeout(const Duration(seconds: 2));
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
    _offlineSnackbarController?.close();
    super.onClose();
  }
}
