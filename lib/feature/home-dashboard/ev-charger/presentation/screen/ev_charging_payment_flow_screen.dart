import 'package:express_vet/asset_image.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/feature/dash_board/presentation/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class EvChargingPaymentFlowScreen extends StatefulWidget {
  const EvChargingPaymentFlowScreen({super.key});

  @override
  State<EvChargingPaymentFlowScreen> createState() => _EvChargingPaymentFlowScreenState();
}

class _EvChargingPaymentFlowScreenState extends State<EvChargingPaymentFlowScreen> {


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Get.offAll(
          () => const DashboardScreen(from: 0),
          transition: Transition.leftToRight,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 70),
              Expanded(
                child: Center(
                  child: _buildPaymentSuccess(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.offNamedUntil(
                        AppRoutes.evCharger,
                        (route) => route.settings.name == AppRoutes.home,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildPaymentSuccess() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(AssetImages.success, width: 80,height: 80,),
       
        const SizedBox(height: 10),
        const Text(
          'Payment Successfully',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'The charging process will begin shortly',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

}
