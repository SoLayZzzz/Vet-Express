import 'package:express_vet/asset_image.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class EvVoucherScreen extends StatelessWidget {
  const EvVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Voucher'.tr,
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
                    'Enter or scan voucher code'.tr,
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
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Code'.tr,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
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
                              borderSide:
                                  const BorderSide(color: AppColors.primaryColor),
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
                child: ListView(
                  children: [
                    _buildVoucherCard(isActive: true),
                    const SizedBox(height: 12),
                    _buildVoucherCard(isActive: false),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add New Voucher'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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

  Widget _buildVoucherCard({required bool isActive}) {
    const double cardHeight = 115;
    const double leftWidth = 112;
    const double notchRadius = 13;
    const double borderRadius = 14;
    final Color borderColor = Colors.grey.shade500;
    final Color statusColor = isActive ? const Color(0xFF16A34A) : Colors.grey;
    final String statusText = isActive ? 'Active' : 'In Active';

    return Padding(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: const Column(
                    children: [
                      Text(
                        '5.0%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'OFF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.1,
                        ),
                      ),

                      Padding(
                        padding:  EdgeInsets.symmetric(vertical: 7),
                        child: Divider(color: Colors.white, height: 1, thickness: 1),
                      ),

                      Text(
                        '5% off with\nany charge',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
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
                      borderRadius: BorderRadius.only(topRight: Radius.circular(13), bottomRight: Radius.circular(13)),
                      border: Border.all(color: Colors.grey.shade500,width: 0.3),
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
                                const Expanded(
                                  child: Text(
                                    'Voucher Code',
                                    style: TextStyle(
                                      color: Color(0xFF26232D),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Icon(Icons.circle, size: 8, color: statusColor),
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
                          '5% OFF',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                          ],
                        ),
                        Text(
                          'Valid Till - 31 December 2024',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
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
      ..quadraticBezierTo(size.width - notchRadius, notchRadius, size.width, notchRadius)
      ..lineTo(size.width, size.height - notchRadius)
      ..quadraticBezierTo(size.width - notchRadius, size.height - notchRadius, size.width - notchRadius, size.height)
      ..lineTo(borderRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - borderRadius)
      ..lineTo(0, borderRadius)
      ..quadraticBezierTo(0, 0, borderRadius, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _VoucherLeftClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius || oldClipper.borderRadius != borderRadius;
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
      ..quadraticBezierTo(size.width, size.height, size.width - borderRadius, size.height)
      ..lineTo(notchRadius, size.height)
      ..quadraticBezierTo(notchRadius, size.height - notchRadius, 0, size.height - notchRadius)
      ..lineTo(0, notchRadius)
      ..quadraticBezierTo(notchRadius, notchRadius, notchRadius, 0)
      ..close();
  }

  @override
  bool shouldReclip(covariant _VoucherRightClipper oldClipper) {
    return oldClipper.notchRadius != notchRadius || oldClipper.borderRadius != borderRadius;
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
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(borderRadius, 0.6)
      ..lineTo(leftWidth - notchRadius, 0.6)
      ..quadraticBezierTo(leftWidth - notchRadius, notchRadius, leftWidth, notchRadius)
      ..quadraticBezierTo(leftWidth + notchRadius, notchRadius, leftWidth + notchRadius, 0.6)
      ..lineTo(size.width - borderRadius, 0.6)
      ..quadraticBezierTo(size.width - 0.6, 0.6, size.width - 0.6, borderRadius)
      ..lineTo(size.width - 0.6, size.height - borderRadius)
      ..quadraticBezierTo(size.width - 0.6, size.height - 0.6, size.width - borderRadius, size.height - 0.6)
      ..lineTo(leftWidth + notchRadius, size.height - 0.6)
      ..quadraticBezierTo(leftWidth + notchRadius, size.height - notchRadius, leftWidth, size.height - notchRadius)
      ..quadraticBezierTo(leftWidth - notchRadius, size.height - notchRadius, leftWidth - notchRadius, size.height - 0.6)
      ..lineTo(borderRadius, size.height - 0.6)
      ..quadraticBezierTo(0.6, size.height - 0.6, 0.6, size.height - borderRadius)
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
