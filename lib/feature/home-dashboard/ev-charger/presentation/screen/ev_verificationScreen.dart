import 'package:express_vet/asset_image.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_sale_order_apptmp_res.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/presentation/controller/ev_charging_information_controller.dart';
class EvVerificationScreen extends StatefulWidget {
  const EvVerificationScreen({super.key});

  @override
  State<EvVerificationScreen> createState() => _EvVerificationScreenState();
}

class _EvVerificationScreenState extends State<EvVerificationScreen> {
  late final Future<Uint8List?> _verificationBytes = _loadEmbeddedPngBytes(
    AssetImages.verification,
  );

  // Verification Screen Data Variables
  late String _transactionId;
  late String _stationName;
  late String _orderDate;
  late String _subTotal;
  late String _discount;
  late String _totalAmount;
  late String _totalKwh;
  bool _showDiscount = true;
  late String _discountLabel;
  dynamic _orderArgs;

  Timer? _plugInDialogTimer;

  bool _isConfirming = false;

  String _formatCurrencyDouble(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return val.toStringAsFixed(2);
  }

  @override
  void initState() {
    super.initState();
    _orderArgs = Get.arguments;
    debugPrint('====>> [EvVerificationScreen] _orderArgs runtimeType: ${_orderArgs.runtimeType}');
    debugPrint('====>> [EvVerificationScreen] _orderArgs: $_orderArgs');
    if (_orderArgs is EvSaleOrderApptmpResponse) {
      try {
        debugPrint('====>> [EvVerificationScreen] order args JSON: ${jsonEncode(_orderArgs.toJson())}');
      } catch (_) {}
    }
    final args = _orderArgs;
    if (args != null && args is EvSaleOrderApptmpResponse) {
      final orderData = args.body?.data;
      _transactionId = orderData?.transactionId ?? 'N/A';
      _stationName = orderData?.stationName ?? 'N/A';
      _orderDate = orderData?.orderDate ?? 'N/A';
      _subTotal = 'KHR (៛) ${_formatCurrencyDouble((orderData?.subTotal ?? 0).toDouble())}';
      _discount = '-KHR (៛) ${_formatCurrencyDouble((orderData?.discount ?? 0).toDouble())}';
      _totalAmount = 'KHR (៛) ${_formatCurrencyDouble((orderData?.totalAmount ?? 0).toDouble())}';
      _totalKwh = '${orderData?.totalKwh ?? 0} kWh';
      _showDiscount = (orderData?.discount ?? 0) > 0;
      _discountLabel = "${'discount'.tr} (${orderData?.discountPercentage ?? 0}%)";
      debugPrint('====>> [EvVerificationScreen] parsed from EvSaleOrderApptmpResponse:');
      debugPrint('transactionId: $_transactionId');
      debugPrint('stationName: $_stationName');
      debugPrint('orderDate: $_orderDate');
      debugPrint('subTotal: $_subTotal');
      debugPrint('discount: $_discount');
      debugPrint('totalAmount: $_totalAmount');
      debugPrint('totalKwh: $_totalKwh');
      debugPrint('discountPercentage: ${orderData?.discountPercentage ?? 0}');
      debugPrint('showDiscount: $_showDiscount');
    } else if (args != null && args is Map) {
      _transactionId = args['transactionId']?.toString() ?? 'N/A';
      _stationName = args['stationName']?.toString() ?? 'N/A';
      _orderDate = args['orderDate']?.toString() ?? 'N/A';
      _subTotal = args['subTotal']?.toString() ?? 'N/A';
      _discount = args['discount']?.toString() ?? 'N/A';
      _totalAmount = args['totalAmount']?.toString() ?? 'N/A';
      _totalKwh = args['totalKwh']?.toString() ?? 'N/A';
      final cleanDiscount = _discount.replaceAll(RegExp(r'[^0-9.]'), '');
      final parsedDiscount = double.tryParse(cleanDiscount) ?? 0.0;
      _showDiscount = parsedDiscount > 0;
      _discountLabel = 'discount'.tr;
      debugPrint('====>> [EvVerificationScreen] parsed from Map:');
      debugPrint('transactionId: $_transactionId');
      debugPrint('stationName: $_stationName');
      debugPrint('orderDate: $_orderDate');
      debugPrint('subTotal: $_subTotal');
      debugPrint('discount: $_discount');
      debugPrint('totalAmount: $_totalAmount');
      debugPrint('totalKwh: $_totalKwh');
      debugPrint('showDiscount: $_showDiscount');
    } else {
      _transactionId = '00001';
      _stationName = 'Station 1';
      _orderDate = '02 Jan 2025 04:00PM';
      _subTotal = 'KHR (៛) 48,000';
      _discount = '-KHR (៛) 4,000';
      _totalAmount = 'KHR (៛) 44,000';
      _totalKwh = '20 kWh';
      _showDiscount = true;
      _discountLabel = 'Discount (20%)';
    }
  }

  @override
  void dispose() {
    _plugInDialogTimer?.cancel();
    super.dispose();
  }

  // Future<void> _showPlugInDialog() async {
  //   _plugInDialogTimer?.cancel();

  //   final canPopBackToChargingInfo =
  //       Get.previousRoute == AppRoutes.evChargingInformation;

  //   final secondsLeft = 5.obs;
  //   var handled = false;

  //   void closeDialogIfOpen() {
  //     if (Get.isDialogOpen == true) {
  //       Get.back();
  //     }
  //   }

  //   void navigateToPaymentFlow() {
  //     if (handled) return;
  //     handled = true;
  //     _plugInDialogTimer?.cancel();
  //     closeDialogIfOpen();
  //     Get.offNamed(AppRoutes.evPaymentFlow);
  //   }

  //   void navigateBackToChargingInfo() {
  //     if (handled) return;
  //     handled = true;
  //     _plugInDialogTimer?.cancel();
  //     closeDialogIfOpen();

  //     if (canPopBackToChargingInfo && Get.key.currentState?.canPop() == true) {
  //       Get.back();
  //       return;
  //     }

  //     Get.offNamed(AppRoutes.evChargingInformation);
  //   }

  //   _plugInDialogTimer = Timer.periodic(const Duration(seconds: 1), (t) {
  //     if (secondsLeft.value <= 1) {
  //       secondsLeft.value = 0;
  //       t.cancel();
  //       navigateToPaymentFlow();
  //       return;
  //     }
  //     secondsLeft.value = secondsLeft.value - 1;
  //   });

  //   await Get.dialog(
  //     PopScope(
  //       canPop: false,
  //       child: Dialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         insetPadding: const EdgeInsets.symmetric(horizontal: 18),
  //         child: Padding(
  //           padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Image.asset(
  //                 AssetImages.green_car,
  //                 width: 140,
  //                 height: 140,
  //                 fit: BoxFit.contain,
  //               ),
  //               const Text(
  //                 'Please plug in the charger',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w700,
  //                   color: Colors.black,
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Text(
  //                 'Plug the charger into your car',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w400,
  //                   color: Colors.grey.shade500,
  //                 ),
  //               ),
  //               const SizedBox(height: 10),
  //               Obx(
  //                 () => Text(
  //                   'Continue in ${secondsLeft.value}s',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w500,
  //                     color: Colors.grey.shade700,
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 18),
  //               SizedBox(
  //                 width: double.infinity,
  //                 height: 48,
  //                 child: OutlinedButton(
  //                   onPressed: navigateBackToChargingInfo,
  //                   style: OutlinedButton.styleFrom(
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     side: const BorderSide(color: Color(0xFFE0E0E0)),
  //                     foregroundColor: const Color(0xFF374151),
  //                   ),
  //                   child: const Text(
  //                     'Return',
  //                     style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     barrierDismissible: false,
  //   ).whenComplete(() {
  //     if (!handled) {
  //       _plugInDialogTimer?.cancel();
  //     }
  //   });
  // }

  Future<void> _onConfirmPayment() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    Get.dialog(
      const Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
      barrierDismissible: false,
    );

    // Call WebSocket connection and send the verification screen's data
    try {
      final infoController = Get.isRegistered<EvChargingInformationController>()
          ? Get.find<EvChargingInformationController>()
          : null;

      final evseUidVal = (infoController != null && infoController.chargerUsername.value.isNotEmpty)
          ? infoController.chargerUsername.value
          : "ev01";

      final plugIdVal = infoController?.plugId.value ?? 0;

      final base = BaseUrl.BASE_URL_WEB_SOCKET;
      final wsBase = base
          .replaceAll('https://', 'wss://')
          .replaceAll('http://', 'ws://');
      final cleanBase = wsBase.endsWith('/') ? wsBase.substring(0, wsBase.length - 1) : wsBase;
      final wsUrl = cleanBase;

      debugPrint('Connecting to WebSocket for payment confirmation: $wsUrl');
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      final args = _orderArgs;
      EvSaleOrderApptmpResponse? response;
      if (args != null) {
        if (args is EvSaleOrderApptmpResponse) {
          response = args;
        } else if (args is Map) {
          try {
            final map = Map<String, dynamic>.from(args);
            if (map.containsKey('header') || map.containsKey('body')) {
              response = EvSaleOrderApptmpResponse.fromJson(map);
            }
          } catch (_) {}
        }
      }
      final orderData = response?.body?.data;

      // Extract transactionId, totalKwh, and totalPrice from the response data, default to 0 if not present
      String transactionIdVal = "0";
      int totalKwhVal = 0;
      double totalPriceVal = 0;

      if (orderData != null) {
        transactionIdVal = orderData.transactionId ?? "0";
        totalKwhVal = orderData.totalKwh ?? 0;
        totalPriceVal = (orderData.totalAmount ?? 0).toDouble();
      } else if (args != null && args is Map) {
        transactionIdVal = args['transactionId']?.toString() ?? "0";
        
        final kwhStr = args['totalKwh']?.toString() ?? "0";
        final cleanKwh = kwhStr.replaceAll(RegExp(r'[^0-9.]'), '');
        totalKwhVal = double.tryParse(cleanKwh)?.round() ?? 0;

        final priceStr = (args['totalAmount'] ?? args['subTotal'] ?? args['totalPrice'] ?? "0").toString();
        final cleanPrice = priceStr.replaceAll(RegExp(r'[^0-9.]'), '');
        totalPriceVal = double.tryParse(cleanPrice) ?? 0.0;
      }



      int isFullChargeVal = 0;
      if (infoController != null) {
        final isKwhTab = infoController.isKwhTab.value;
        final text = isKwhTab ? infoController.kwhController.text : infoController.khrController.text;
        if (text == "Full Charge") {
          isFullChargeVal = 1;
        }
      }

      final data = {
        'command_type': 'START_SESSION',
        'evse_uid': evseUidVal,
        'transactionId': transactionIdVal,
        'isFullCharge': isFullChargeVal,
        'paymentMethod': 5,
        'plug': plugIdVal,
        'durations': 0,
        'totalKwh': totalKwhVal,
        'totalPrice': totalPriceVal,
        'actualKwh': 0,
      };

      final payload = jsonEncode(data);

      // STOMP format
      final stompConnect = 'CONNECT\naccept-version:1.1,1.2\nheart-beat:10000,10000\n\n\u0000';
      final stompSend = 'SEND\ndestination:/topic/ocpi/commands/$evseUidVal\ncontent-type:application/json\n\n$payload\u0000';

      debugPrint('WebSocket URL: $wsUrl');
      debugPrint('Sending STOMP CONNECT');
      channel.sink.add(stompConnect);
      
      await Future.delayed(const Duration(milliseconds: 200));
      
      debugPrint('Sending STOMP SEND: $stompSend');
      channel.sink.add(stompSend);

      // Brief delay to ensure transmission before closing the connection
      await Future.delayed(const Duration(milliseconds: 800));
      await channel.sink.close();
    } catch (e) {
      debugPrint('Error sending data over WebSocket: $e');
    }

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    if (!mounted) return;
    setState(() => _isConfirming = false);
    Get.offNamed(AppRoutes.evPaymentFlow);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Container(
                height: 100,
                width: 100,
                alignment: Alignment.center,
                child: _buildVerificationIcon(),
              ),
              const SizedBox(height: 24),

              // --- Title & Subtitle ---
              Text(
                'verification'.tr,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'verify_info_correct'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- Info List Items ---
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _InfoRow(label: 'transaction_id'.tr, value: _transactionId),
                    _InfoRow(label: 'station_name'.tr, value: _stationName),
                    _InfoRow(label: 'order_date'.tr, value: _orderDate),
                    _InfoRow(label: 'ev_sub_total'.tr, value: _subTotal),
                    if (_showDiscount)
                      _InfoRow(label: _discountLabel, value: _discount),
                    _InfoRow(
                      label: 'total_amount'.tr,
                      value: _totalAmount,
                      fontWeight: FontWeight.w600,
                    ),
                    _InfoRow(
                      label: 'total_kwh'.tr,
                      value: _totalKwh,
                      isLast: true,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),

              // --- Bottom Action Button ---
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      _onConfirmPayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'confirm_payment'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationIcon() {
    return FutureBuilder<Uint8List?>(
      future: _verificationBytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(bytes, fit: BoxFit.contain);
        }
        return SvgPicture.asset(AssetImages.verification, fit: BoxFit.contain);
      },
    );
  }

  Future<Uint8List?> _loadEmbeddedPngBytes(String svgAssetPath) async {
    final svg = await rootBundle.loadString(svgAssetPath);
    final match = RegExp(r'data:image/png;base64,([^"\s]+)').firstMatch(svg);
    final data = match?.group(1);
    if (data == null || data.isEmpty) return null;

    try {
      return base64Decode(data);
    } catch (_) {
      return null;
    }
  }
}

// --- Custom Reusable Info Row Widget ---
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  final FontWeight fontWeight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
    this.fontWeight = FontWeight.w400,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: fontWeight,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(color: Color(0xFFEEEEEE), height: 1, thickness: 1),
      ],
    );
  }
}
