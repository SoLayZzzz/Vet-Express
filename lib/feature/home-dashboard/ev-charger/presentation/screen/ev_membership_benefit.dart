import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/presentation/controller/ev_charger_controller.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class MembershipBenefitScreen extends GetView<EvChargerController> {
  const MembershipBenefitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cardBgColor = Color(0xFFF2F2F2);

    if (controller.state.membershipBenefitResponse == null &&
        !controller.state.isLoadingMembershipBenefit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchMembershipBenefit();
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: SvgPicture.asset(AssetImages.ic_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Membership Benefit',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        final isLoading = controller.state.isLoadingMembershipBenefit;
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        final hasError = controller.state.hasErrorMembershipBenefit;
        if (hasError) {
          return Center(
            child: SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: controller.fetchMembershipBenefit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: Text('Retry'.tr),
              ),
            ),
          );
        }

        final data =
            controller.state.membershipBenefitResponse?.body?.data ?? [];
        if (data.isEmpty) {
          return Center(child: Text('No data'.tr));
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          children: [
            for (final item in data) ...[
              // const SizedBox(height: 16),
              _buildMembershipCard(
                title: item.name ?? '-',
                backgroundColor: cardBgColor,
                showRibbon: item.isYouAreHere == 1,
                ribbonText: 'You are here',
                children: [_buildBulletPoint(item.description ?? '-')],
              ),
              const SizedBox(height: 15),
            ],
          ],
        );
      }),
    );
  }

  Widget _buildMembershipCard({
    required String title,
    required Color backgroundColor,
    required List<Widget> children,
    bool showRibbon = false,
    String ribbonText = 'You are here',
  }) {
    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFD36125),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );

    if (!showRibbon) return card;

    final context = Get.context!;
    final screenWidth = MediaQuery.of(context).size.width;
    final ribbonSize = (screenWidth * 0.22).clamp(70.0, 110.0);
    final topOffset = (22.0 / 73.0) * ribbonSize;
    final rightOffset = (24.0 / 73.0) * ribbonSize;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -topOffset,
          right: -rightOffset,
          child: SvgPicture.asset(
            AssetImages.isYouAreHere,
            width: ribbonSize,
            height: ribbonSize,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
