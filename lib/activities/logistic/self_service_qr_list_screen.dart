import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../utils/app_bar.dart';

class SelfServiceQRListScreen extends StatefulWidget {
  final String qrCode;

  const SelfServiceQRListScreen({super.key, required this.qrCode});

  @override
  State<SelfServiceQRListScreen> createState() => _SelfServiceQRListScreenState();
}

class _SelfServiceQRListScreenState extends State<SelfServiceQRListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'view_qr_code'.tr),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'plz_show'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
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
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
