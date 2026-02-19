/*
import 'dart:developer';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:express_vet/utils/app_bar.dart';
import '../../controller/ev/ev_top_up_controller.dart';

class EvPaymentScreen extends StatefulWidget {
  final String deepLink;
  final String checkoutQrUrl;

  const EvPaymentScreen({super.key, required this.deepLink, required this.checkoutQrUrl});

  @override
  State<EvPaymentScreen> createState() => _EvPaymentScreenState();
}

class _EvPaymentScreenState extends State<EvPaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;
  bool _showWebView = false;
  bool _deepLinkAttempted = false;
  final EvTopUpController _topUpController = Get.find<EvTopUpController>();
  bool loop = true;

  @override
  void initState() {
    super.initState();

    // Start payment process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPaymentProcess();
    });
  }

  Future<void> _startPaymentProcess() async {
    // First, try to open the banking app with deeplink
    await _tryOpenDeepLink();
  }

  Future<void> _tryOpenDeepLink() async {
    setState(() {
      _deepLinkAttempted = true;
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(widget.deepLink);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        // Try to launch the banking app
        log('Attempting to launch deeplink: ${widget.deepLink}');
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (launched) {
          // Successfully opened banking app
          log('Banking app launched successfully');
          Get.snackbar(
            'Payment App Opened',
            'Please complete the payment in your banking app',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(milliseconds: 3000),
          );

          // Start checking payment status after a delay
          Future.delayed(const Duration(milliseconds: 3000), () {
            _topUpController.checkPaymentStatusManually();
          });

          // Close screen after a short delay
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted && !_paymentCompleted) {
              Get.back();
            }
          });

          // Set a timeout to fallback to webview if user doesn't complete in banking app
          Future.delayed(const Duration(milliseconds: 10000), () {
            if (mounted && !_paymentCompleted && !_showWebView) {
              _fallbackToWebView();
            }
          });

          return;
        } else {
          log('Banking app launch failed');
          _fallbackToWebView();
        }
      } else {
        log('Cannot launch deeplink');
        _fallbackToWebView();
      }
    } catch (e) {
      log('Error launching deeplink: $e');
      _fallbackToWebView();
    }
  }

  void _fallbackToWebView() {
    log('Falling back to webview with URL: ${widget.checkoutQrUrl}');
    setState(() {
      _showWebView = true;
      _isLoading = false;
    });

    _initializeWebView();
  }

  void _initializeWebView() {
    if (widget.checkoutQrUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Payment URL is not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Get.back();
      });
      return;
    }

    // Create WebViewController
    _controller = WebViewController();

    // Set up navigation delegate
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar if needed
        },
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
          });
          // Check for payment completion immediately
          if (_checkForPaymentCompletion(url)) {
            // Stop loading if payment completed
            setState(() {
              _isLoading = false;
            });
          }
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
          _checkForPaymentCompletion(url);
        },
        onWebResourceError: (WebResourceError error) {
          log('WebView error: ${error.description}');
          setState(() {
            _isLoading = false;
          });
        },
        onNavigationRequest: (NavigationRequest request) {
          log('WebView navigation to: ${request.url}');

          // If payment already completed, prevent any further navigation
          if (_paymentCompleted) {
            return NavigationDecision.prevent;
          }

          // Check for payment completion in the target URL
          if (_checkForPaymentCompletion(request.url)) {
            return NavigationDecision.prevent;
          }

          // Handle deeplink navigation
          if (request.url.startsWith('abapay://') ||
              request.url.startsWith('aba://') ||
              request.url.startsWith('abamobilebank://') ||
              request.url.contains('abapay')) {
            // Launch banking app
            _launchDeepLinkFromWebView(request.url);

            // Close webview since user is going to banking app
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted && !_paymentCompleted) {
                Get.back();
              }
            });

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ),
    );

    // Set JavaScript mode
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    // Load the web URL
    _controller.loadRequest(Uri.parse(widget.checkoutQrUrl));
  }

  Future<void> _launchDeepLinkFromWebView(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('Error launching deeplink from WebView: $e');
    }
  }

  bool _checkForPaymentCompletion(String url) {
    if (_paymentCompleted) return false;

    // More specific success patterns for KHQR/ABA Pay
    final successPatterns = [
      'success',
      'payment-success',
      'completed',
      'thank-you',
      'successful',
      'approved',
      'transaction-complete',
      'payment-done',
      'order-success',
      'paymentsuccess', // Common pattern
      'payment/success', // Common pattern
      'status=success', // Query parameter pattern
      'result=success', // Query parameter pattern
    ];

    // Check if URL contains success patterns
    final lowerUrl = url.toLowerCase();
    for (var pattern in successPatterns) {
      if (lowerUrl.contains(pattern)) {
        _handleSuccessfulPayment();
        return true;
      }
    }

    // Check for specific ABA/KHQR success indicators
    if (lowerUrl.contains('aba') &&
        (lowerUrl.contains('complete') ||
            lowerUrl.contains('success') ||
            lowerUrl.contains('done'))) {
      _handleSuccessfulPayment();
      return true;
    }

    return false;
  }

  void _handleSuccessfulPayment() {
    if (_paymentCompleted) return;

    _paymentCompleted = true;
    log('Payment success detected in WebView');

    // Close webview immediately
    if (_showWebView) {
      _controller.clearCache();
      _controller.clearLocalStorage();
    }

    // Show success message
    Get.snackbar(
      'Payment Successful',
      'Your payment was completed successfully!',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 2000),
    );

    // Close this screen immediately
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Get.back();

        // Also try to pop any remaining dialogs
        if (Get.isDialogOpen == true) {
          Get.back();
        }

        // Trigger payment status check in controller
        // This will show the full-screen success modal
        _topUpController.checkPaymentStatusManually();
      }
    });
  }

  void _handlePaymentFailure() {
    if (_paymentCompleted) return;

    _paymentCompleted = true;
    log('Payment failure detected in WebView');

    // Close webview
    if (_showWebView) {
      _controller.clearCache();
      _controller.clearLocalStorage();
    }

    // Show failure message
    Get.snackbar(
      'Payment Failed',
      'Payment was not completed. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 3000),
    );

    // Close payment screen after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_paymentCompleted) {
          return true;
        }

        bool? shouldClose = await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Cancel Payment'),
                content: const Text('Are you sure you want to cancel this payment?'),
                actions: [
                  TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
                  TextButton(onPressed: () => Get.back(result: true), child: const Text('Yes')),
                ],
              ),
        );

        if (shouldClose == true) {
          // When user manually closes payment screen, check payment status
          _topUpController.checkPaymentStatusManually();

          // Close webview if open
          if (_showWebView) {
            _controller.clearCache();
            _controller.clearLocalStorage();
          }
        }

        return shouldClose ?? false;
      },
      child: Scaffold(appBar: AppBarVET().appBar(context, "Payment"), body: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_showWebView) {
      // Show WebView for web payment
      return Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } else if (_deepLinkAttempted) {
      // Show loading while trying to open banking app
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Opening Banking App...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Redirecting to ABA Pay...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Show webview fallback button after 3 seconds
              if (_deepLinkAttempted)
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 3000),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          const Text(
                            'Taking too long?',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _fallbackToWebView();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Use Web Payment Instead'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    } else {
      // Initial loading
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    // If payment wasn't completed and we're closing the screen,
    // check payment status one last time
    if (!_paymentCompleted && mounted) {
      log('Payment screen disposed, checking status');
      _topUpController.checkPaymentStatusManually();
    }

    // Clear webview resources
    if (_showWebView) {
      _controller.clearCache();
      _controller.clearLocalStorage();
    }

    super.dispose();
  }
}
*/

import 'dart:developer';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:express_vet/utils/app_bar.dart';
import '../controller/ev_top_up_controller.dart';

class EvPaymentScreen extends StatefulWidget {
  final String deepLink;
  final String checkoutQrUrl;

  const EvPaymentScreen({
    super.key,
    required this.deepLink,
    required this.checkoutQrUrl,
  });

  @override
  State<EvPaymentScreen> createState() => _EvPaymentScreenState();
}

class _EvPaymentScreenState extends State<EvPaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _paymentCompleted = false;
  bool _showWebView = false;
  bool _deepLinkAttempted = false;
  final EvTopUpController _topUpController = Get.find<EvTopUpController>();
  bool loop = true;

  @override
  void initState() {
    super.initState();

    // Start payment process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPaymentProcess();
    });
  }

  Future<void> _startPaymentProcess() async {
    // First, try to open the banking app with deeplink
    await _tryOpenDeepLink();
  }

  Future<void> _tryOpenDeepLink() async {
    setState(() {
      _deepLinkAttempted = true;
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(widget.deepLink);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        // Try to launch the banking app
        log('Attempting to launch deeplink: ${widget.deepLink}');
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          // Successfully opened banking app
          log('Banking app launched successfully');
          Get.snackbar(
            'Payment App Opened',
            'Please complete the payment in your banking app',
            backgroundColor: Colors.blue,
            colorText: Colors.white,
            duration: const Duration(milliseconds: 3000),
          );

          // Start checking payment status after a delay
          Future.delayed(const Duration(milliseconds: 3000), () {
            _topUpController.checkPaymentStatusManually();
          });

          // Set a timeout to fallback to webview if user doesn't complete in banking app
          Future.delayed(const Duration(milliseconds: 10000), () {
            if (mounted && !_paymentCompleted && !_showWebView) {
              _fallbackToWebView();
            }
          });

          return;
        } else {
          log('Banking app launch failed');
          _fallbackToWebView();
        }
      } else {
        log('Cannot launch deeplink');
        _fallbackToWebView();
      }
    } catch (e) {
      log('Error launching deeplink: $e');
      _fallbackToWebView();
    }
  }

  void _fallbackToWebView() {
    log('Falling back to webview with URL: ${widget.checkoutQrUrl}');
    setState(() {
      _showWebView = true;
      _isLoading = false;
    });

    _initializeWebView();
  }

  void _initializeWebView() {
    if (widget.checkoutQrUrl.isEmpty) {
      Get.snackbar(
        'Error',
        'Payment URL is not available',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) Get.back();
      });
      return;
    }

    // Create WebViewController
    _controller = WebViewController();

    // Set up navigation delegate
    _controller.setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar if needed
        },
        onPageStarted: (String url) {
          setState(() {
            _isLoading = true;
          });
          // Check for payment completion immediately
          if (_checkForPaymentCompletion(url)) {
            // Stop loading if payment completed
            setState(() {
              _isLoading = false;
            });
          }
        },
        onPageFinished: (String url) {
          setState(() {
            _isLoading = false;
          });
          _checkForPaymentCompletion(url);
        },
        onWebResourceError: (WebResourceError error) {
          log('WebView error: ${error.description}');
          setState(() {
            _isLoading = false;
          });
        },
        onNavigationRequest: (NavigationRequest request) {
          log('WebView navigation to: ${request.url}');

          // If payment already completed, prevent any further navigation
          if (_paymentCompleted) {
            return NavigationDecision.prevent;
          }

          // Check for payment completion in the target URL
          if (_checkForPaymentCompletion(request.url)) {
            return NavigationDecision.prevent;
          }

          // Handle deeplink navigation
          if (request.url.startsWith('abapay://') ||
              request.url.startsWith('aba://') ||
              request.url.startsWith('abamobilebank://') ||
              request.url.contains('abapay')) {
            // Launch banking app
            _launchDeepLinkFromWebView(request.url);

            // Don't close webview immediately - let controller handle navigation
            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ),
    );

    // Set JavaScript mode
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

    // Load the web URL
    _controller.loadRequest(Uri.parse(widget.checkoutQrUrl));
  }

  Future<void> _launchDeepLinkFromWebView(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Start checking payment status
        Future.delayed(const Duration(milliseconds: 2000), () {
          _topUpController.checkPaymentStatusManually();
        });
      }
    } catch (e) {
      log('Error launching deeplink from WebView: $e');
    }
  }

  bool _checkForPaymentCompletion(String url) {
    if (_paymentCompleted) return false;

    // More specific success patterns for KHQR/ABA Pay
    final successPatterns = [
      'success',
      'payment-success',
      'completed',
      'thank-you',
      'successful',
      'approved',
      'transaction-complete',
      'payment-done',
      'order-success',
      'paymentsuccess', // Common pattern
      'payment/success', // Common pattern
      'status=success', // Query parameter pattern
      'result=success', // Query parameter pattern
    ];

    // Check if URL contains success patterns
    final lowerUrl = url.toLowerCase();
    for (var pattern in successPatterns) {
      if (lowerUrl.contains(pattern)) {
        _handleSuccessfulPayment();
        return true;
      }
    }

    // Check for specific ABA/KHQR success indicators
    if (lowerUrl.contains('aba') &&
        (lowerUrl.contains('complete') ||
            lowerUrl.contains('success') ||
            lowerUrl.contains('done'))) {
      _handleSuccessfulPayment();
      return true;
    }

    return false;
  }

  void _handleSuccessfulPayment() {
    if (_paymentCompleted) return;

    _paymentCompleted = true;
    log('Payment success detected in WebView');

    // Clear webview cache
    if (_showWebView) {
      _controller.clearCache();
      _controller.clearLocalStorage();
    }

    // Just trigger the payment status check
    // The controller will handle all navigation
    _topUpController.checkPaymentStatusManually();
  }

  void _handlePaymentFailure() {
    if (_paymentCompleted) return;

    _paymentCompleted = true;
    log('Payment failure detected in WebView');

    // Close webview
    if (_showWebView) {
      _controller.clearCache();
      _controller.clearLocalStorage();
    }

    // Show failure message
    Get.snackbar(
      'Payment Failed',
      'Payment was not completed. Please try again.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 3000),
    );

    // Close payment screen after delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_paymentCompleted) {
          return false; // Don't allow manual close if payment completed
        }

        bool? shouldClose = await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Cancel Payment'),
                content: const Text(
                  'Are you sure you want to cancel this payment?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text('Yes'),
                  ),
                ],
              ),
        );

        if (shouldClose == true) {
          // When user manually closes payment screen, check payment status
          _topUpController.checkPaymentStatusManually();

          // Close webview if open
          if (_showWebView) {
            _controller.clearCache();
            _controller.clearLocalStorage();
          }
        }

        return shouldClose ?? false;
      },
      child: Scaffold(
        appBar: AppBarVET().appBar(context, "Payment"),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_showWebView) {
      // Show WebView for web payment
      return Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.9),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'Loading payment page...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    } else if (_deepLinkAttempted) {
      // Show loading while trying to open banking app
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text(
                'Opening Banking App...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Redirecting to ABA Pay...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Show webview fallback button after 3 seconds
              if (_deepLinkAttempted)
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 3000),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Column(
                        children: [
                          const Text(
                            'Taking too long?',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              _fallbackToWebView();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Use Web Payment Instead'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    } else {
      // Initial loading
      return const Center(child: CircularProgressIndicator());
    }
  }

  @override
  void dispose() {
    // If payment wasn't completed and we're closing the screen,
    // check payment status one last time
    if (!_paymentCompleted && mounted) {
      log('Payment screen disposed, checking status');
      _topUpController.checkPaymentStatusManually();
    }

    // Clear webview resources
    if (_showWebView) {
      _controller.clearCache();
      _controller.clearLocalStorage();
    }

    super.dispose();
  }
}
