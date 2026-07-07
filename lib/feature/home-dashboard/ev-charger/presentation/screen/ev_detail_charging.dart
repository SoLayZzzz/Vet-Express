import 'dart:async';
import 'dart:convert';

import 'package:express_vet/asset_image.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:vector_math/vector_math_64.dart' as math;
import 'dart:math' as math;
import 'package:express_vet/routes/app_routes.dart';
import '../controller/ev_detail_charging_controller.dart';

class EvDetailCharging extends StatefulWidget {
  const EvDetailCharging({super.key});

  @override
  State<EvDetailCharging> createState() => _EvDetailChargingState();
}

class _EvDetailChargingState extends State<EvDetailCharging> {
  late final EvDetailChargingController controller;
  StreamSubscription<int>? _percentSubscription;
  bool _fullyChargedDialogShown = false;

  late final Future<Uint8List?> _stopChargBytes = _loadEmbeddedPngBytes(
    AssetImages.stopCharg,
  );

  late final Future<Uint8List?> _fullChargBytes = _loadEmbeddedPngBytes(
    AssetImages.full_charg,
  );

  @override
  void initState() {
    super.initState();
    controller = Get.put(EvDetailChargingController());

    _percentSubscription = controller.percent.listen((val) {
      if (val >= 100) {
        _showFullyChargedIfNeeded();
      }
    });
  }

  void _showFullyChargedIfNeeded() {
    if (_fullyChargedDialogShown) return;
    _fullyChargedDialogShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showFullyChargedDialog();
    });
  }

  @override
  void dispose() {
    _percentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, "Charging".tr),
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Battery'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: _BatteryGauge(percent: controller.percent.value),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${'Estimated Time'.tr} : ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      controller.estimatedTime.value.tr,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2E9E4E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _InfoCard(
                        title: 'Time Elapsed',
                        value: controller.timeElapsed.value,
                        icon: const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: _InfoCard(
                        title: 'Current',
                        value: controller.current.value,
                        icon: SvgPicture.asset(
                          AssetImages.ammeter,
                          width: 20,
                          height: 20,
                        ),
                        color: const Color(0xFF2E9E4E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _InfoCard(
                        title: 'Voltage',
                        value: controller.voltage.value,
                        icon: SvgPicture.asset(
                          AssetImages.volt,
                          width: 20,
                          height: 20,
                        ),
                        color: const Color(0xFF2D4CFF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: _InfoCard(
                        title: 'Energy',
                        value: controller.energy.value,
                        icon: SvgPicture.asset(
                          AssetImages.energy,
                          width: 20,
                          height: 20,
                        ),
                        color: const Color(0xFFFF3B30),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoCard(
                  title: 'Estimated Cost',
                  value: controller.estimatedCost.value,
                  icon: SvgPicture.asset(
                    AssetImages.current,
                    width: 20,
                    height: 20,
                  ),
                  color: const Color(0xFFF6B33C),
                  fullWidth: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              height: 60,
                              width: 60,
                              child: _buildCarChargingImage(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '${'Note'.tr}: ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE53935),
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          'You cannot unplug the power while charging.'
                                              .tr,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 100,
                      width: 86,
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: _onStopPressed,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 34,
                              width: 34,
                              child: SvgPicture.asset(
                                AssetImages.buttonStop,
                                width: 20,
                                height: 20,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Stop'.tr,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
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

  Widget _buildCarChargingImage() {
    return FutureBuilder<Uint8List?>(
      future: _stopChargBytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return Stack(
                children: [
                  Positioned(
                    left: w * (5 / 70),
                    top: h * (16 / 70),
                    width: w * (64 / 70),
                    height: h * (44 / 70),
                    child: Image.memory(bytes, fit: BoxFit.fill),
                  ),
                  Positioned.fill(
                    child: SvgPicture.asset(
                      AssetImages.stopCharg,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              );
            },
          );
        }
        return SvgPicture.asset(AssetImages.stopCharg, fit: BoxFit.contain);
      },
    );
  }

  Widget _buildFullChargIcon() {
    return FutureBuilder<Uint8List?>(
      future: _fullChargBytes,
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(bytes, fit: BoxFit.contain);
        }
        return SvgPicture.asset(AssetImages.full_charg, fit: BoxFit.contain);
      },
    );
  }

  Future<void> _onStopPressed() async {
    final confirmed = await _showStopConfirmDialog();
    if (confirmed != true) return;

    await controller.stopCharging();
    Get.offNamed(AppRoutes.home);
  }

  Future<bool?> _showStopConfirmDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  alignment: Alignment.center,
                  child: SvgPicture.asset(AssetImages.stop),
                ),
                const SizedBox(height: 14),
                Text(
                  'Message'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Do you really want to stop the charging process?'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: const Color(0xFF374151),
                        ),
                        child: Text(
                          'Cancel'.tr,
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: const Color(0xFFE53935),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: Text(
                          'Stop'.tr,
                          style: TextStyle(
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

  Future<void> _showFullyChargedDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  alignment: Alignment.center,
                  // child: _buildFullChargIcon(),
                  child: Transform.rotate(
                    angle:
                        90 *
                        math.pi /
                        180, // Change 90 to whatever angle you want
                    child: _buildFullChargIcon(),
                  ),
                ),

                const SizedBox(height: 10),
                Text(
                  'Fully Charged!'.tr,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please unplug the charger before traveling.\nThank you.'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: const Color(0xFF374151),
                    ),
                    child: Text(
                      'Continue'.tr,
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BatteryGauge extends StatefulWidget {
  final int percent;

  const _BatteryGauge({required this.percent});

  @override
  State<_BatteryGauge> createState() => _BatteryGaugeState();
}

class _BatteryGaugeState extends State<_BatteryGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final target = (widget.percent.clamp(0, 100)) / 100;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final progress = target * _animation.value;
        return SizedBox(
          height: 200,
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CustomPaint(
              painter: _BatteryGaugePainter(
                progress: progress,
                percent: widget.percent,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 100,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            bottom: -60,
                            right: -35,
                            child: Image.asset(
                              AssetImages.gifCharging,
                              height: 170,
                              width: 170,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.percent}',
                          style: Theme.of(
                            context,
                          ).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E232B),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Text(
                            '%',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BatteryGaugePainter extends CustomPainter {
  final double progress;
  final int percent;

  const _BatteryGaugePainter({required this.progress, required this.percent});

  Color _progressColor() {
    final p = (percent.clamp(0, 100)) / 100.0;

    const red = Color(0xFFC62828);
    const lime = Color(0xFFA8C61A);
    const green = Color(0xFF00B050);

    if (p <= 0.30) {
      return Color.lerp(red, lime, p / 0.30) ?? red;
    }
    return Color.lerp(lime, green, (p - 0.30) / 0.70) ?? green;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final trackPaint =
        Paint()
          ..color = const Color(0xFFE0E0E0)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 25;

    final progressPaint =
        Paint()
          ..color = _progressColor()
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 25;

    canvas.drawCircle(center, radius, trackPaint);

    final clampedProgress = progress.clamp(0.0, 1.0);
    if (clampedProgress >= 0.999) {
      canvas.drawCircle(center, radius, progressPaint);
      return;
    }

    final start = math.radians(-90);
    final sweep = math.radians(360 * clampedProgress);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BatteryGaugePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.percent != percent;
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;
  final Color color;
  final bool fullWidth;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.tr,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.blueGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 20,
                child: Center(child: icon),
              ),
              const SizedBox(width: 10),
              Text(value.tr),
            ],
          ),
        ],
      ),
    );

    if (!fullWidth) return card;
    return SizedBox(width: double.infinity, child: card);
  }
}
