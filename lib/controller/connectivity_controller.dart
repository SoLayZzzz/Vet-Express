import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/alert_dialog_internet.dart';

class ConnectivityController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;
  final RxBool isDialogShowing = false.obs;

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
    if (isDialogShowing.value && Get.isDialogOpen == true) {
      Get.back();
      isDialogShowing.value = false;
    }
  }

  void _handleDisconnected() {
    if (!isDialogShowing.value) {
      () async {
        await Future.delayed(const Duration(milliseconds: 400));
        final stillOffline = !(await _hasActualConnection());
        if (!stillOffline) {
          _handleConnected();
          return;
        }
        isDialogShowing.value = true;

        Get.dialog(
          PopScope(
            canPop: false,
            child: AlertDialogNoInternet(
              ani: 'assets/gif/no_internet_connection_ani.gif',
              title: 'connection'.tr,
              description: "no_internet_connection".tr,
            ),
          ),
          barrierColor: Colors.black26,
          barrierDismissible: false,
        ).then((_) {
          isDialogShowing.value = false;
        });
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
    super.onClose();
  }
}
