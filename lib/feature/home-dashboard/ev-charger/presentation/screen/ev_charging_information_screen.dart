import 'package:express_vet/asset_image.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../base/base_url.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_voucher_list_response.dart'
    as list_resp;
import '../controller/ev_charging_information_controller.dart';

class EvChargingInformationScreen extends StatefulWidget {
  const EvChargingInformationScreen({super.key});

  @override
  State<EvChargingInformationScreen> createState() =>
      _ChargingInformationScreenState();
}

class _ChargingInformationScreenState
    extends State<EvChargingInformationScreen> {
  late final EvChargingInformationController controller;


  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<EvChargingInformationController>()) {
      controller = Get.put(EvChargingInformationController(Get.find()));
    } else {
      controller = Get.find<EvChargingInformationController>();
    }
    controller.kwhController.addListener(_onTextChanged);
    controller.khrController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    controller.kwhController.removeListener(_onTextChanged);
    controller.khrController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onContinue() {
    controller.createSaleOrderAppTmp();
  }

  String _formatCurrency(double val) {
    if (val == val.toInt()) {
      return val.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }
    return val.toStringAsFixed(2);
  }

  String _getSubTotal() {
    final isKwhTab = controller.isKwhTab.value;
    if (isKwhTab) {
      final text = controller.kwhController.text;
      if (text == "Full Charge") return "Full Charge";
      final val = double.tryParse(text) ?? 0.0;
      return 'KHR (៛) ${_formatCurrency(val * 2400)}';
    } else {
      final text = controller.khrController.text;
      if (text == "Full Charge") return "Full Charge";
      final val = double.tryParse(text.replaceAll(',', '')) ?? 0.0;
      return 'KHR (៛) ${_formatCurrency(val)}';
    }
  }

  String _getTotalPrice() {
    final isKwhTab = controller.isKwhTab.value;
    final discount = controller.getCalculatedDiscount().toDouble();
    if (isKwhTab) {
      final text = controller.kwhController.text;
      if (text == "Full Charge") return "Full Charge";
      final val = double.tryParse(text) ?? 0.0;
      final subTotal = val * 2400;
      final total = subTotal - discount;
      return 'KHR (៛) ${_formatCurrency(total < 0 ? 0 : total)}';
    } else {
      final text = controller.khrController.text;
      if (text == "Full Charge") return "Full Charge";
      final val = double.tryParse(text.replaceAll(',', '')) ?? 0.0;
      final total = val - discount;
      return 'KHR (៛) ${_formatCurrency(total < 0 ? 0 : total)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: const Text(
          'Charging Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Custom Slanted/Segmented Tab Bar ---
                    _buildTabSelect(),
                    const SizedBox(height: 15),

                    Text(
                      'Electrical input information',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- 2. Dynamic Option Grid ---
                    _buildOptionChoosePrice(),
                    const SizedBox(height: 12),

                    // --- 3. Promo & Points Rows ---
                    _buildListTile(
                      iconAsset: AssetImages.apply_code,
                      title: 'Apply Promotion Code',
                      valueOfff: '5% OFF',
                      iconSize: 15,
                      onTap: _showPromotionCodeDialog,
                    ),
                    _buildListTile(
                      iconAsset: AssetImages.star,
                      title: 'Apply Point',
                      valueOfff: '20 points',
                      iconSize: 20,
                      onTap: _showApplyPointDialog,
                    ),
                    const SizedBox(height: 10),

                    // --- 4. Custom Preferred Input Field ---
                    Text(
                      'Or enter your preferred amount',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final isKwhTab = controller.isKwhTab.value;
                      return TextField(
                        controller:
                            isKwhTab
                                ? controller.kwhController
                                : controller.khrController,
                        keyboardType: TextInputType.number,
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          suffixText: isKwhTab ? 'kWh' : 'KHR',
                          suffixStyle: TextStyle(color: Colors.grey[800]),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 15),

                    // --- 5. Dynamic Pricing Section ---
                    Obx(() => _buildPriceRow('Sub Total', _getSubTotal())),
                    const SizedBox(height: 5),
                    Obx(() {
                      final discount = controller.getCalculatedDiscount();
                      final discountPct = controller.getCalculatedDiscountPercentage();
                      return _buildPriceRow(
                        'Discount ($discountPct%)',
                        '-KHR (៛) ${_formatCurrency(discount.toDouble())}',
                      );
                    }),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Colors.grey),
                    ),
                    Obx(
                      () => _buildPriceRow(
                        'Total Price',
                        _getTotalPrice(),
                        isTotal: true,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- 6. Payment Method Section ---
                    Text(
                      'Choose your payment methods',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        // color: const Color(0xFFEDF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF3B82F6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SvgPicture.asset(
                              AssetImages.wallet,
                              width: 24,
                              height: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'E-Wallet',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Scan to pay with your E-Wallet',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Transform.scale(
                            scale: 1.35,
                            child: Radio(
                              value: true,
                              groupValue: true,
                              activeColor: const Color(0xFF2563EB),
                              onChanged: (val) {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    //
                  ],
                ),
              ),
            ),

            // --- 7. Bottom Button ---
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      _onContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard({
    required list_resp.Data voucher,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    const double cardHeight = 115;
    const double leftWidth = 112;
    const double notchRadius = 13;
    const double borderRadius = 14;
    final Color borderColor =
        isSelected ? AppColors.primaryColor : Colors.grey.shade500;
    final double strokeWidth = isSelected ? 2.0 : 1.2;

    final bool isActive =
        voucher.displayStatus == 1 ||
        (voucher.statusText?.toLowerCase() == 'active');
    final Color statusColor = isActive ? const Color(0xFF16A34A) : Colors.grey;
    final String statusText =
        voucher.statusText ?? (isActive ? 'Active' : 'In Active');
    final String discountPct =
        voucher.discountType == 1
            ? '${(voucher.discountValue ?? 0.0).toStringAsFixed(1)}%'
            : '\$${voucher.discountValue}';
    final String discountOff =
        voucher.discountType == 1
            ? '${voucher.discountValue}% OFF'
            : '\$${voucher.discountValue} OFF';

    final String banner = voucher.banner ?? '';
    final String bannerUrl =
        banner.isNotEmpty
            ? (banner.startsWith('http')
                ? banner
                : '${BaseUrl.BASE_URL_SLIDE_IMAGE_EV}${banner.startsWith('/') ? banner.substring(1) : banner}')
            : '';

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: SizedBox(
          height: cardHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: _VoucherBorderPainter(
              leftWidth: leftWidth,
              notchRadius: notchRadius,
              borderRadius: borderRadius,
              color: borderColor,
              strokeWidth: strokeWidth,
            ),
            child: Row(
              children: [
                ClipPath(
                  clipper: _VoucherLeftClipper(
                    notchRadius: notchRadius,
                    borderRadius: borderRadius,
                  ),
                  child: Container(
                    width: leftWidth,
                    height: cardHeight,
                    color: AppColors.primaryColor,
                    child: Stack(
                      children: [
                        if (bannerUrl.isNotEmpty)
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: bannerUrl,
                              fit: BoxFit.cover,
                              errorWidget:
                                  (context, url, error) =>
                                      const SizedBox.shrink(),
                            ),
                          ),
                        if (bannerUrl.isNotEmpty)
                          Positioned.fill(
                            child: Container(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.4,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          child: Column(
                            children: [
                              Text(
                                discountPct,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'OFF',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.1,
                                ),
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 7),
                                child: Divider(
                                  color: Colors.white,
                                  height: 1,
                                  thickness: 1,
                                ),
                              ),

                              Expanded(
                                child: Text(
                                  voucher.batchTitle ?? '',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: ClipPath(
                    clipper: _VoucherRightClipper(
                      notchRadius: notchRadius,
                      borderRadius: borderRadius,
                    ),
                    child: Container(
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(13),
                          bottomRight: Radius.circular(13),
                        ),
                        border: Border.all(
                          color: Colors.grey.shade500,
                          width: 0.3,
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(26, 15, 14, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      voucher.voucherCode ?? '',
                                      style: const TextStyle(
                                        color: Color(0xFF26232D),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                discountOff,
                                style: const TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            voucher.expiresDate != null
                                ? 'Valid Till - ${voucher.expiresDate}'
                                : '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9A9CAE),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionChoosePrice() {
    return Obx(() {
      final isKwhTab = controller.isKwhTab.value;
      final list = isKwhTab ? controller.kwhList : controller.priceList;
      final isLoading =
          isKwhTab
              ? controller.isLoadingKwh.value
              : controller.isLoadingPrice.value;
      final hasError =
          isKwhTab
              ? controller.hasErrorKwh.value
              : controller.hasErrorPrice.value;

      if (isLoading) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      if (hasError) {
        return SizedBox(
          height: 100,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Failed to load list"),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      isKwhTab
                          ? controller.fetchKwhData
                          : controller.fetchPriceData,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        );
      }

      if (list.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(child: Text("No items available")),
        );
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final item = list[index];
          final bool isSelected = controller.selectedGridIndex.value == index;

          final String label =
              item.name ??
              (item.isFullCharge == 1
                  ? "Full Charge"
                  : (isKwhTab ? "${item.value} kWh" : "KHR ${item.value}"));

          return GestureDetector(
            onTap: () => controller.selectGridItem(index),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.primaryColor
                        : const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildTabSelect() {
    return Obx(() {
      final isKwhTab = controller.isKwhTab.value;
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E9F0),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(true),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        isKwhTab ? AppColors.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AssetImages.small_car,
                        width: 12,
                        height: 12,
                        colorFilter: ColorFilter.mode(
                          isKwhTab ? Colors.white : Colors.grey[600]!,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Kilowatt/hour',
                        style: TextStyle(
                          color: isKwhTab ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectTab(false),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        !isKwhTab ? AppColors.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: "KHR ",
                      style: TextStyle(
                        color: !isKwhTab ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: "Amount",
                          style: TextStyle(
                            color: !isKwhTab ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Helper Widget for Promo/Points
  Widget _buildListTile({
    required String iconAsset,
    required String title,
    required String valueOfff,
    required double iconSize,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                Colors.black87,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              valueOfff,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 15),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black54,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showPromotionCodeDialog() {
    // Reset selected code and input field on open to avoid stale state
    controller.selectedVoucherCode.value = '';
    controller.promoCodeController.text = '';
    controller.searchQuery.value = '';

    return Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Apply Promotion Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.close, color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => TextField(
                        controller: controller.promoCodeController,
                        onChanged: (val) {
                          controller.selectedVoucherCode.value = val;
                          controller.searchQuery.value = val;
                        },
                        decoration: InputDecoration(
                          hintText: 'Code',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          suffixIcon:
                              controller.searchQuery.value.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      controller.promoCodeController.clear();
                                      controller.searchQuery.value = '';
                                      controller.selectedVoucherCode.value = '';
                                      controller.searchVoucher('');
                                    },
                                  )
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    height: 44,
                    width: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D4CFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AssetImages.small_scan),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 280,
                child: Obx(() {
                  if (controller.isLoadingVouchers.value &&
                      controller.voucherList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryColor,
                      ),
                    );
                  }
                  if (controller.voucherList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetImages.emptyVoucher,
                            width: 40,
                            height: 40,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'voucher_is_empty'.tr,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.voucherList.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final voucher = controller.voucherList[index];
                      return Obx(() {
                        final bool isSelected =
                            controller.selectedVoucherCode.value ==
                            voucher.voucherCode;
                        return _buildVoucherCard(
                          voucher: voucher,
                          isSelected: isSelected,
                          onTap: () {
                            controller.selectedVoucherCode.value =
                                voucher.voucherCode ?? '';
                            controller.promoCodeController.text =
                                voucher.voucherCode ?? '';
                            controller.searchQuery.value =
                                voucher.voucherCode ?? '';
                          },
                        );
                      });
                    },
                  );
                }),
              ),

              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final code = controller.promoCodeController.text;
                        controller.applySelectedVoucher(code);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showApplyPointDialog() {
    controller.pointController.text = '';
    int selectedIndex = -1;

    // Refresh point list from API when dialog opens
    controller.fetchPointList();

    return Get.dialog(
      StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Apply Point',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: const Icon(Icons.close, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Total Points',
                        style: TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                      Text(
                        '190 Points',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose amount',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (controller.isLoadingPoints.value &&
                        controller.pointList.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFE26A15),
                        ),
                      );
                    }
                    final displayOptions = controller.pointList.isNotEmpty
                        ? controller.pointList.map((item) => {
                            'name': item.name ?? (item.point != null ? '${(item.point! / 100).toStringAsFixed(0)} kWh' : ''),
                            'point': item.point ?? 0,
                          }).toList()
                        : [
                            {'name': '5 kWh', 'point': 500},
                            {'name': '10 kWh', 'point': 1000},
                            {'name': '50 kWh', 'point': 5000},
                          ];

                    return Row(
                      children: List.generate(displayOptions.length, (i) {
                        final opt = displayOptions[i];
                        final isSelected = selectedIndex == i;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i == displayOptions.length - 1 ? 0 : 10,
                            ),
                            child: InkWell(
                              onTap: () {
                                setDialogState(() {
                                  selectedIndex = i;
                                  controller.pointController.text =
                                      opt['point'].toString();
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFFE26A15)
                                          : const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      opt['name'].toString(),
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : const Color(0xFF2B3DBB),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${opt['point']} Points',
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : const Color(0xFF2B3DBB),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                  const SizedBox(height: 12),
                  const Text(
                    'Or enter your preferred amount',
                    style: TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller.pointController,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      setDialogState(() {
                        selectedIndex = -1;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      suffixText: 'Point',
                      suffixStyle: TextStyle(color: Colors.black),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1 kWh = 100Points',
                    style: TextStyle(
                      color: Color(0xFFE26A15),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedIndex >= 0 &&
                                controller.pointList.isNotEmpty &&
                                selectedIndex < controller.pointList.length) {
                              final selectedPoint =
                                  controller.pointList[selectedIndex];
                              final redeemId = selectedPoint.id;
                              controller.pointController.text =
                                  (selectedPoint.point ?? 0).toString();
                              Get.back();
                              if (redeemId != null) {
                                controller.applyPoint(redeemId);
                              }
                            } else {
                              Get.back();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: const Color(0xFFE26A15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  // Helper Widget for Price Breakdowns
  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w400 : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _VoucherLeftClipper extends CustomClipper<Path> {
  const _VoucherLeftClipper({
    required this.notchRadius,
    required this.borderRadius,
  });

  final double notchRadius;
  final double borderRadius;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(borderRadius, 0)
      ..lineTo(size.width - notchRadius, 0)
      ..quadraticBezierTo(
        size.width - notchRadius,
        notchRadius,
        size.width,
        notchRadius,
      )
      ..lineTo(size.width, size.height - notchRadius)
      ..quadraticBezierTo(
        size.width - notchRadius,
        size.height - notchRadius,
        size.width - notchRadius,
        size.height,
      )
      ..lineTo(borderRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - borderRadius)
      ..lineTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _VoucherLeftClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius ||
        oldClipper.borderRadius != borderRadius;
  }
}

class _VoucherRightClipper extends CustomClipper<Path> {
  const _VoucherRightClipper({
    required this.notchRadius,
    required this.borderRadius,
  });

  final double notchRadius;
  final double borderRadius;

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(notchRadius, 0)
      ..lineTo(size.width - borderRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, borderRadius)
      ..lineTo(size.width, size.height - borderRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - borderRadius,
        size.height,
      )
      ..lineTo(notchRadius, size.height)
      ..quadraticBezierTo(
        notchRadius,
        size.height - notchRadius,
        0,
        size.height - notchRadius,
      )
      ..lineTo(0, notchRadius)
      ..quadraticBezierTo(notchRadius, notchRadius, notchRadius, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _VoucherRightClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius ||
        oldClipper.borderRadius != borderRadius;
  }
}

class _VoucherBorderPainter extends CustomPainter {
  const _VoucherBorderPainter({
    required this.leftWidth,
    required this.notchRadius,
    required this.borderRadius,
    required this.color,
    this.strokeWidth = 1.2,
  });

  final double leftWidth;
  final double notchRadius;
  final double borderRadius;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

    final path =
        Path()
          ..moveTo(borderRadius, 0.6)
          ..lineTo(leftWidth - notchRadius, 0.6)
          ..quadraticBezierTo(
            leftWidth - notchRadius,
            notchRadius,
            leftWidth,
            notchRadius,
          )
          ..quadraticBezierTo(
            leftWidth + notchRadius,
            notchRadius,
            leftWidth + notchRadius,
            0.6,
          )
          ..lineTo(size.width - borderRadius, 0.6)
          ..quadraticBezierTo(
            size.width - 0.6,
            0.6,
            size.width - 0.6,
            borderRadius,
          )
          ..lineTo(size.width - 0.6, size.height - borderRadius)
          ..quadraticBezierTo(
            size.width - 0.6,
            size.height - 0.6,
            size.width - borderRadius,
            size.height - 0.6,
          )
          ..lineTo(leftWidth + notchRadius, size.height - 0.6)
          ..quadraticBezierTo(
            leftWidth + notchRadius,
            size.height - notchRadius,
            leftWidth,
            size.height - notchRadius,
          )
          ..quadraticBezierTo(
            leftWidth - notchRadius,
            size.height - notchRadius,
            leftWidth - notchRadius,
            size.height - 0.6,
          )
          ..lineTo(borderRadius, size.height - 0.6)
          ..quadraticBezierTo(
            0.6,
            size.height - 0.6,
            0.6,
            size.height - borderRadius,
          )
          ..lineTo(0.6, borderRadius)
          ..quadraticBezierTo(0.6, 0.6, borderRadius, 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _VoucherBorderPainter oldDelegate) {
    return oldDelegate.leftWidth != leftWidth ||
        oldDelegate.notchRadius != notchRadius ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}