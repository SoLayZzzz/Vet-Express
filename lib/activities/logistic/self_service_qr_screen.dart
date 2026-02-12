import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:express_vet/feature/dash_board/presentation/screen/dashboard_screen.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';

import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';

class SelfServiceQRScreen extends StatefulWidget {
  final String qrCode;

  const SelfServiceQRScreen({super.key, required this.qrCode});

  @override
  State<SelfServiceQRScreen> createState() => _SelfServiceQRScreenState();
}

class _SelfServiceQRScreenState extends State<SelfServiceQRScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBarNotBack(context, 'successful_deposit'.tr),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned(
              child: Column(
                children: [
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            ValueStatic().clearSelfService();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DashboardScreen(from: 0),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'home'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            ValueStatic().clearSelfService();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const DashboardScreen(from: 1),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.3,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'book_more'.tr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 10,
                    bottom: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'plz_show'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        height: 200,
                        width: 200,
                        child: QrImageView(
                          data: widget.qrCode,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        widget.qrCode,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        'plz_view'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
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
    );
  }
}
