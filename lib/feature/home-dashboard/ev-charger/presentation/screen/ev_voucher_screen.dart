import 'package:cached_network_image/cached_network_image.dart';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../../base/base_url.dart';
import '../controller/ev_voucher_controller.dart';
import '../../data/model/response/ev_voucher_list_response.dart';

class EvVoucherScreen extends GetView<EvVoucherController> {
  const EvVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'voucher'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'enter_or_scan_voucher_code'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(
                          () => TextField(
                            controller: controller.searchController,
                            onChanged:
                                (val) => controller.searchQuery.value = val,
                            decoration: InputDecoration(
                              hintText: 'promo_code'.tr,
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              suffixIcon:
                                  controller.searchQuery.value.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          controller.searchController.clear();
                                          controller.searchQuery.value = '';
                                        },
                                      )
                                      : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  if (controller.isLoading.value &&
                      controller.voucherList.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.voucherList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetImages.emptyVoucher,
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'voucher_is_empty'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.voucherList.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final voucher = controller.voucherList[index];
                      return _buildVoucherCard(
                        voucher: voucher,
                        onTap:
                            () => _showAddVoucherDialog(
                              context,
                              voucher.voucherCode ?? '',
                            ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVoucherDialog(BuildContext context, String voucherCode) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(AssetImages.voucher),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'add_voucher'.tr,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'add_voucher_question'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey.shade200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'cancel'.tr,
                          style: const TextStyle(
                            color: Color(0xFF374151),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          controller.addVoucher(voucherCode);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'add_voucher'.tr,
                          style: const TextStyle(
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
    );
  }

  Widget _buildVoucherCard({required Data voucher, VoidCallback? onTap}) {
    const double cardHeight = 115;
    const double leftWidth = 112;
    const double notchRadius = 13;
    const double borderRadius = 14;
    final Color borderColor = Colors.grey.shade500;

    final String discountPct =
        voucher.discountType == 1
            ? '${(voucher.discountValue ?? 0.0).toStringAsFixed(1)}%'
            : '\$${voucher.discountValue}';
    final String discountOff =
        voucher.discountType == 1
            ? "${voucher.discountValue}% ${'off'.tr}"
            : "\$${voucher.discountValue} ${'off'.tr}";

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
                              Text(
                                'off'.tr,
                                style: const TextStyle(
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
                                ? "${'valid_till'.tr} - ${voucher.expiresDate}"
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
  });

  final double leftWidth;
  final double notchRadius;
  final double borderRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;

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
        oldDelegate.color != color;
  }
}
