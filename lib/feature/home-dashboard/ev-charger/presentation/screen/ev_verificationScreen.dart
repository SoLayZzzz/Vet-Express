import 'package:express_vet/asset_image.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class EvVerificationScreen extends StatefulWidget {
  const EvVerificationScreen({super.key});

  @override
  State<EvVerificationScreen> createState() => _EvVerificationScreenState();
}

class _EvVerificationScreenState extends State<EvVerificationScreen> {
  late final Future<Uint8List?> _verificationBytes =
      _loadEmbeddedPngBytes(AssetImages.verification);


  Timer? _plugInDialogTimer;

  bool _isConfirming = false;

  @override
  void dispose() {
    _plugInDialogTimer?.cancel();
    super.dispose();
  }

  Future<void> _showPlugInDialog() async {
    _plugInDialogTimer?.cancel();

    final canPopBackToChargingInfo =
        Get.previousRoute == AppRoutes.evChargingInformation;

    final secondsLeft = 5.obs;
    var handled = false;

    void closeDialogIfOpen() {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }

    void navigateToPaymentFlow() {
      if (handled) return;
      handled = true;
      _plugInDialogTimer?.cancel();
      closeDialogIfOpen();
      Get.offNamed(AppRoutes.evPaymentFlow);
    }

    void navigateBackToChargingInfo() {
      if (handled) return;
      handled = true;
      _plugInDialogTimer?.cancel();
      closeDialogIfOpen();

      if (canPopBackToChargingInfo && Get.key.currentState?.canPop() == true) {
        Get.back();
        return;
      }

      Get.offNamed(AppRoutes.evChargingInformation);
    }

    _plugInDialogTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        t.cancel();
        navigateToPaymentFlow();
        return;
      }
      secondsLeft.value = secondsLeft.value - 1;
    });

    await Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              
                Image.asset(AssetImages.green_car, width: 140,height: 140,fit: BoxFit.contain),
                const Text(
                  'Please plug in the charger',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plug the charger into your car',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Text(
                    'Continue in ${secondsLeft.value}s',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: navigateBackToChargingInfo,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      foregroundColor: const Color(0xFF374151),
                    ),
                    child: const Text(
                      'Return',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    ).whenComplete(() {
      if (!handled) {
        _plugInDialogTimer?.cancel();
      }
    });
  }

  Future<void> _onConfirmPayment() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    Get.dialog(
      const Center(
        child: CircularProgressIndicator( color: AppColors.primaryColor),
      ),
      barrierDismissible: false,
    );

    await Future.delayed(const Duration(milliseconds: 700));
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    if (!mounted) return;
    setState(() => _isConfirming = false);
    await _showPlugInDialog();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
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
              const Text(
                'Verification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
               Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Please check to make sure all information are correct.',
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
                  children: const [
                    _InfoRow(label: 'Transaction id', value: '00001'),
                    _InfoRow(label: 'Station Name', value: 'Station 1'),
                    _InfoRow(label: 'Order Date', value: '02 Jan 2025 04:00PM'),
                    _InfoRow(label: 'Sub Total', value: 'KHR (៛) 48,000'),
                    _InfoRow(label: 'Discount (20%)', value: '-KHR (៛) 4,000'),
                    _InfoRow(label: 'Total Amout', value: 'KHR (៛) 44,000', fontWeight: FontWeight.w600), // Kept typo from design ("Amout")
                    _InfoRow(label: 'Total kWh', value: '20 kWh', isLast: true,fontWeight: FontWeight.w600),
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
                    child: const Text(
                      'Confirm Payment',
                      style: TextStyle(
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
    final match =
        RegExp(r'data:image/png;base64,([^"\s]+)').firstMatch(svg);
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
          padding:  EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style:  TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                value,
                style:  TextStyle(
                  fontSize: 15,
                  fontWeight: fontWeight,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            color: Color(0xFFEEEEEE),
            height: 1,
            thickness: 1,
          ),
      ],
    );
  }
}