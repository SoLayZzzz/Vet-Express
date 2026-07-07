import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../base/base_url.dart';


class ConnectivityController extends GetxController with WidgetsBindingObserver {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = false.obs;
  final RxInt status = 1.obs;

  int _verifySequence = 0;

  bool _wasOffline = false;
  bool _offlineSnackbarShown = false;

  Timer? _onlineVerifyTimer;
  bool _onlineVerifyInProgress = false;

  Timer? _offlineRecheckTimer;
  bool _offlineRecheckInProgress = false;

  SnackbarController? _offlineSnackbarController;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isInForeground = true;
  bool _isResuming = false;

  void _console(String message) {
    debugPrint(message);
    log(message);
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (_connectivitySubscription != null) return;
    _initializeConnectivity();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isInForeground = true;
      _isResuming = true;
      ++_verifySequence;
      Future.delayed(const Duration(milliseconds: 800), () {
        _isResuming = false;
        _checkConnectivity();
      });
      return;
    }

    _isInForeground = false;
    ++_verifySequence;
    _onlineVerifyTimer?.cancel();
    _onlineVerifyTimer = null;
    _offlineRecheckTimer?.cancel();
    _offlineRecheckTimer = null;
  }

  void _initializeConnectivity() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (!_isInForeground || _isResuming) return;
      _updateConnectionStatus(results);
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final List<ConnectivityResult> results =
          await _connectivity.checkConnectivity();
      _updateConnectionStatus(results, fromInit: true);
    } catch (e) {
      _console('Error checking connectivity: $e');
    }
  }

  void _updateConnectionStatus(
    List<ConnectivityResult> results, {
    bool fromInit = false,
  }) {
    if (!_isInForeground) return;
    _console(
      '[Connectivity] update: results=$results fromInit=$fromInit isConnected=${isConnected.value} offlineShown=$_offlineSnackbarShown wasOffline=$_wasOffline',
    );
    final logicalConnected =
        results.isNotEmpty &&
        results.any(
          (result) =>
              result != ConnectivityResult.none &&
              result != ConnectivityResult.bluetooth,
        );

    if (!logicalConnected) {
      _console('[Connectivity] logicalConnected=false -> disconnected');
      _handleDisconnected();
      return;
    }

    if ((_offlineSnackbarController != null || _wasOffline) && !isConnected.value) {
      _handleConnected(showSnackbar: !fromInit);
      return;
    }

    final seq = ++_verifySequence;
    () async {
      final ok = await _hasActualConnection();
      _console('[Connectivity] verify seq=$seq ok=$ok currentSeq=$_verifySequence');
      if (seq != _verifySequence) return;

      if (ok) {
        _handleConnected(showSnackbar: !fromInit && !isConnected.value);
      } else {
        _handleDisconnected();
      }
    }();
  }

  void _handleConnected({required bool showSnackbar}) {
    ++_verifySequence;
    _console(
      '[Connectivity] CONNECTED showSnackbar=$showSnackbar seq=$_verifySequence offlineController=${_offlineSnackbarController != null} offlineShown=$_offlineSnackbarShown',
    );
    final transitioningFromOffline =
        !isConnected.value || _offlineSnackbarController != null;
    final shouldShowSnackbar =
        showSnackbar && transitioningFromOffline && _offlineSnackbarShown;
    isConnected.value = true;
    status.value = 1;

    _onlineVerifyTimer?.cancel();
    _onlineVerifyTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _verifyOnlineIfConnected();
    });

    _offlineRecheckTimer?.cancel();
    _offlineRecheckTimer = null;

    try {
      SnackbarController.cancelAllSnackbars();
    } catch (_) {}
    try {
      Get.closeAllSnackbars();
    } catch (_) {}
    try {
      _offlineSnackbarController?.close();
    } catch (_) {}
    _console('[Connectivity] closed offline snackbars (queue + overlay + controller)');
    _offlineSnackbarController = null;
    _wasOffline = false;
    _offlineSnackbarShown = false;

    if (shouldShowSnackbar) {
      _console('[Connectivity] show success snackbar: Connected');
      Future.delayed(const Duration(milliseconds: 250), () {
        if (!isConnected.value) return;
        Get.rawSnackbar(
          titleText: Text(
            'Connected',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          messageText: Text(
            'Internet Connected',
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          icon: const Icon(
            Icons.wifi_rounded,
            color: Color(0xFF2E7D32),
            size: 24,
          ),
          backgroundColor: const Color(0xFFC8E6C9),
          duration: const Duration(seconds: 2),
          isDismissible: true,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 8,
        );
      });
    }
  }

  void _handleDisconnected() {
    if (!_isInForeground || _isResuming) return;
    _console(
      '[Connectivity] DISCONNECTED seq=$_verifySequence isConnected=${isConnected.value} offlineController=${_offlineSnackbarController != null} offlineShown=$_offlineSnackbarShown',
    );
    if (status.value == 0 && _offlineSnackbarController != null) {
      return;
    }
    isConnected.value = false;
    status.value = 0;
    final seq = ++_verifySequence;
    _console('[Connectivity] disconnected start seq=$seq');

    _onlineVerifyTimer?.cancel();
    _onlineVerifyTimer = null;

    if (_offlineRecheckTimer == null) {
      _console('[Connectivity] start offline recheck timer (1s)');
      _offlineRecheckTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (isConnected.value) {
          _offlineRecheckTimer?.cancel();
          _offlineRecheckTimer = null;
          return;
        }

        if (_offlineRecheckInProgress) return;
        _offlineRecheckInProgress = true;

        () async {
          try {
            final ok = await _hasNetworkConnection();
            _console('[Connectivity] offline recheck ok=$ok');
            if (ok) {
              _handleConnected(showSnackbar: true);
            }
          } finally {
            _offlineRecheckInProgress = false;
          }
        }();
      });
    }

    () async {
      await Future.delayed(const Duration(milliseconds: 400));
      final stillOffline = !(await _hasNetworkConnection());
      _console(
        '[Connectivity] delayed offline confirm seq=$seq stillOffline=$stillOffline currentSeq=$_verifySequence',
      );
      if (seq != _verifySequence) return;

      if (!stillOffline) {
        _handleConnected(showSnackbar: true);
        return;
      }

      _wasOffline = true;

      if (_offlineSnackbarController != null) return;

      try {
        SnackbarController.cancelAllSnackbars();
      } catch (_) {}

      final controller = Get.rawSnackbar(
        titleText: const Text(
          'No Internet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        messageText: const Text(
          'No Internet Connection',
          style: TextStyle(color: Colors.white, fontSize: 14),
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

      _offlineSnackbarController = controller;
      _offlineSnackbarShown = true;
      _console('[Connectivity] show offline snackbar: No Internet');
      controller.future.then((_) {
        if (_offlineSnackbarController == controller) {
          _offlineSnackbarController = null;
        }
      });
    }();
  }

  Future<bool> _hasActualInternetAccess() async {
    try {
      final host = Uri.parse(BaseUrl.BASE_URL).host;
      if (host.isNotEmpty) {
        if (InternetAddress.tryParse(host) == null) {
          final result = await InternetAddress.lookup(host)
              .timeout(const Duration(milliseconds: 1500));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            return true;
          }
        } else {
          final port = Uri.parse(BaseUrl.BASE_URL).port;
          final socket = await Socket.connect(host, port > 0 ? port : 80,
                  timeout: const Duration(milliseconds: 1500));
          await socket.close();
          return true;
        }
      }
    } catch (_) {}

    try {
      final result = await InternetAddress.lookup('apple.com')
          .timeout(const Duration(milliseconds: 1500));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(milliseconds: 1500));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {}

    return false;
  }

  Future<bool> _hasNetworkConnection() async {
    try {
      final ok = await _hasActualInternetAccess();
      if (ok) return true;

      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty &&
          results.any(
            (r) =>
                r != ConnectivityResult.none &&
                r != ConnectivityResult.bluetooth,
          );
    } catch (e) {
      _console('Error checking network connection: $e');
      return false;
    }
  }

  Future<bool> _hasActualConnection() => _hasActualInternetAccess();


  Future<void> recheckConnection() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _checkConnectivity();
  }

  void _verifyOnlineIfConnected() {
    if (!_isInForeground || _isResuming) return;
    if (!isConnected.value) return;
    if (_onlineVerifyInProgress) return;
    _onlineVerifyInProgress = true;

    final seq = ++_verifySequence;
    () async {
      try {
        final ok = await _hasActualConnection();
        if (seq != _verifySequence) return;
        if (!ok) {
          _handleDisconnected();
        }
      } finally {
        _onlineVerifyInProgress = false;
      }
    }();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _offlineSnackbarController?.close();
    _offlineRecheckTimer?.cancel();
    _onlineVerifyTimer?.cancel();
    super.onClose();
  }
}


// import 'dart:async';
// import 'dart:developer';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import '../base/base_url.dart';

// // 1. Add WidgetsBindingObserver to detect app resume lifecycle
// class ConnectivityController extends GetxController with WidgetsBindingObserver {
//   final Connectivity _connectivity = Connectivity();
//   final RxBool isConnected = false.obs;
//   final RxInt status = 1.obs;

//   int _verifySequence = 0;

//   bool _wasOffline = false;
//   bool _offlineSnackbarShown = false;
  
//   // Flag to avoid firing false alarms immediately when waking up
//   bool _isResuming = false; 

//   Timer? _onlineVerifyTimer;
//   bool _onlineVerifyInProgress = false;

//   Timer? _offlineRecheckTimer;
//   bool _offlineRecheckInProgress = false;

//   SnackbarController? _offlineSnackbarController;

//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

//   void _console(String message) {
//     debugPrint(message);
//     log(message);
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     // Register lifecycle observer
//     WidgetsBinding.instance.addObserver(this);
//     if (_connectivitySubscription != null) return;
//     _initializeConnectivity();
//   }

//   // 2. Intercept Lifecycle changes to handle the resume race condition
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _console('[Connectivity] App Resumed. Cooling down checks to allow OS network wake up.');
//       _isResuming = true;
      
//       // Delay verification for a short window so the network chip can settle
//       Future.delayed(const Duration(milliseconds: 800), () {
//         _isResuming = false;
//         _checkConnectivity();
//       });
//     }
//   }

//   void _initializeConnectivity() {
//     _checkConnectivity();

//     _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
//       List<ConnectivityResult> results,
//     ) {
//       // Ignore broadcast events fired by OS during the immediate resume phase
//       if (_isResuming) {
//         _console('[Connectivity] Stream emitted while resuming; ignored.');
//         return;
//       }
//       _updateConnectionStatus(results);
//     });
//   }

//   Future<void> _checkConnectivity() async {
//     try {
//       final List<ConnectivityResult> results =
//           await _connectivity.checkConnectivity();
//       _updateConnectionStatus(results, fromInit: true);
//     } catch (e) {
//       _console('Error checking connectivity: $e');
//     }
//   }

//   void _updateConnectionStatus(
//     List<ConnectivityResult> results, {
//     bool fromInit = false,
//   }) {
//     _console(
//       '[Connectivity] update: results=$results fromInit=$fromInit isConnected=${isConnected.value} offlineShown=$_offlineSnackbarShown wasOffline=$_wasOffline',
//     );
//     final logicalConnected =
//         results.isNotEmpty &&
//         results.any(
//           (result) =>
//               result != ConnectivityResult.none &&
//               result != ConnectivityResult.bluetooth,
//         );

//     if (!logicalConnected) {
//       _console('[Connectivity] logicalConnected=false -> disconnected');
//       _handleDisconnected();
//       return;
//     }

//     if ((_offlineSnackbarController != null || _wasOffline) && !isConnected.value) {
//       _handleConnected(showSnackbar: !fromInit);
//       return;
//     }

//     final seq = ++_verifySequence;
//     () async {
//       final ok = await _hasActualConnection();
//       _console('[Connectivity] verify seq=$seq ok=$ok currentSeq=$_verifySequence');
//       if (seq != _verifySequence) return;

//       if (ok) {
//         _handleConnected(showSnackbar: !fromInit && !isConnected.value);
//       } else {
//         // If it fails right around initialization/resume, give it one safety net retry 
//         if (fromInit || _isResuming) {
//           _console('[Connectivity] Initial/Resume lookup failed. Retrying in 1 second...');
//           await Future.delayed(const Duration(seconds: 1));
//           final retryOk = await _hasActualConnection();
//           if (seq != _verifySequence) return;
//           if (retryOk) {
//             _handleConnected(showSnackbar: false);
//             return;
//           }
//         }
//         _handleDisconnected();
//       }
//     }();
//   }

//   void _handleConnected({required bool showSnackbar}) {
//     ++_verifySequence;
//     _console(
//       '[Connectivity] CONNECTED showSnackbar=$showSnackbar seq=$_verifySequence',
//     );
//     final transitioningFromOffline =
//         !isConnected.value || _offlineSnackbarController != null;
//     final shouldShowSnackbar =
//         showSnackbar && transitioningFromOffline && _offlineSnackbarShown;
//     isConnected.value = true;
//     status.value = 1;

//     _onlineVerifyTimer?.cancel();
//     _onlineVerifyTimer = Timer.periodic(const Duration(seconds: 5), (_) { // Bumped up slightly to reduce background clutter
//       _verifyOnlineIfConnected();
//     });

//     _offlineRecheckTimer?.cancel();
//     _offlineRecheckTimer = null;

//     try {
//       SnackbarController.cancelAllSnackbars();
//     } catch (_) {}
//     try {
//       Get.closeAllSnackbars();
//     } catch (_) {}
//     try {
//       _offlineSnackbarController?.close();
//     } catch (_) {}
    
//     _offlineSnackbarController = null;
//     _wasOffline = false;
//     _offlineSnackbarShown = false;

//     if (shouldShowSnackbar) {
//       _console('[Connectivity] show success snackbar: Connected');
//       Future.delayed(const Duration(milliseconds: 250), () {
//         if (!isConnected.value) return;
//         Get.rawSnackbar(
//           titleText: const Text(
//             'Connected',
//             style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           messageText: const Text(
//             'Internet Connected',
//             style: TextStyle(color: Colors.black87, fontSize: 14),
//           ),
//           icon: const Icon(Icons.wifi_rounded, color: Color(0xFF2E7D32), size: 24),
//           backgroundColor: const Color(0xFFC8E6C9),
//           duration: const Duration(seconds: 2),
//           isDismissible: true,
//           snackPosition: SnackPosition.TOP,
//           margin: const EdgeInsets.all(12),
//           borderRadius: 8,
//         );
//       });
//     }
//   }

//   Future<void> recheckConnection() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     await _checkConnectivity();
//   }

//   void _handleDisconnected() {
//     // If the app is currently resuming, ignore immediate requests to show an offline UI until cool down finishes
//     if (_isResuming) return; 

//     _console(
//       '[Connectivity] DISCONNECTED seq=$_verifySequence isConnected=${isConnected.value}',
//     );
//     if (status.value == 0 && _offlineSnackbarController != null) {
//       return;
//     }
//     isConnected.value = false;
//     status.value = 0;
//     final seq = ++_verifySequence;

//     _onlineVerifyTimer?.cancel();
//     _onlineVerifyTimer = null;

//     _offlineRecheckTimer ??= Timer.periodic(const Duration(seconds: 2), (_) {
//         if (isConnected.value) {
//           _offlineRecheckTimer?.cancel();
//           _offlineRecheckTimer = null;
//           return;
//         }

//         if (_offlineRecheckInProgress) return;
//         _offlineRecheckInProgress = true;

//         () async {
//           try {
//             final ok = await _hasNetworkConnection();
//             if (ok) {
//               _handleConnected(showSnackbar: true);
//             }
//           } catch (_) {
//             _offlineRecheckInProgress = false;
//           }
//         }();
//       });

//     () async {
//       await Future.delayed(const Duration(milliseconds: 600)); 
//       final stillOffline = !(await _hasNetworkConnection());
//       if (seq != _verifySequence) return;

//       if (!stillOffline) {
//         _handleConnected(showSnackbar: true);
//         return;
//       }

//       _wasOffline = true;
//       if (_offlineSnackbarController != null) return;

//       try {
//         SnackbarController.cancelAllSnackbars();
//       } catch (_) {}

//       final controller = Get.rawSnackbar(
//         titleText: const Text('No Internet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//         messageText: const Text('No Internet Connection', style: TextStyle(color: Colors.white, fontSize: 14)),
//         icon: const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 24),
//         backgroundColor: const Color(0xFFD32F2F),
//         duration: const Duration(days: 365),
//         isDismissible: false,
//         snackPosition: SnackPosition.TOP,
//         margin: const EdgeInsets.all(12),
//         borderRadius: 8,
//         shouldIconPulse: true,
//       );

//       _offlineSnackbarController = controller;
//       _offlineSnackbarShown = true;
//       controller.future.then((_) {
//         if (_offlineSnackbarController == controller) {
//           _offlineSnackbarController = null;
//         }
//       });
//     }();
//   }

//   Future<bool> _hasActualInternetAccess() async {
//     try {
//       final host = Uri.parse(BaseUrl.BASE_URL).host;
//       if (host.isNotEmpty) {
//         if (InternetAddress.tryParse(host) == null) {
//           final result = await InternetAddress.lookup(host)
//               .timeout(const Duration(milliseconds: 1500));
//           if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//             return true;
//           }
//         } else {
//           final port = Uri.parse(BaseUrl.BASE_URL).port;
//           final socket = await Socket.connect(host, port > 0 ? port : 80,
//                   timeout: const Duration(milliseconds: 1500));
//           await socket.close();
//           return true;
//         }
//       }
//     } catch (_) {}

//     try {
//       final result = await InternetAddress.lookup('apple.com')
//           .timeout(const Duration(milliseconds: 1500));
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         return true;
//       }
//     } catch (_) {}

//     return false;
//   }

//   Future<bool> _hasNetworkConnection() async {
//     try {
//       final ok = await _hasActualInternetAccess();
//       if (ok) return true;

//       final results = await _connectivity.checkConnectivity();
//       return results.isNotEmpty &&
//           results.any(
//             (r) =>
//                 r != ConnectivityResult.none &&
//                 r != ConnectivityResult.bluetooth,
//           );
//     } catch (e) {
//       return false;
//     }
//   }

//   Future<bool> _hasActualConnection() => _hasActualInternetAccess();

//   void _verifyOnlineIfConnected() {
//     if (!isConnected.value || _onlineVerifyInProgress || _isResuming) return;
//     _onlineVerifyInProgress = true;

//     final seq = ++_verifySequence;
//     () async {
//       try {
//         final ok = await _hasActualConnection();
//         if (seq != _verifySequence) return;
//         if (!ok) {
//           _handleDisconnected();
//         }
//       } finally {
//         _onlineVerifyInProgress = false;
//       }
//     }();
//   }

//   @override
//   void onClose() {
//     WidgetsBinding.instance.removeObserver(this); // Clean up observer
//     _connectivitySubscription?.cancel();
//     _offlineSnackbarController?.close();
//     _offlineRecheckTimer?.cancel();
//     _onlineVerifyTimer?.cancel();
//     super.onClose();
//   }
// }