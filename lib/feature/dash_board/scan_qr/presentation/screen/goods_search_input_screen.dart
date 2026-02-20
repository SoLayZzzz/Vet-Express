import 'package:express_vet/feature/dash_board/scan_qr/presentation/binding/scan_qr_binding.dart';
import 'package:express_vet/feature/dash_board/scan_qr/presentation/controller/scan_qr_controller.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/check_input.dart';
import 'package:express_vet/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/button.dart';

class GoodsSearchInputScreen extends StatefulWidget {
  const GoodsSearchInputScreen({super.key});

  @override
  State<GoodsSearchInputScreen> createState() => _GoodsSearchInputScreenState();
}

class _GoodsSearchInputScreenState extends State<GoodsSearchInputScreen> {
  final codeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'search_tracking_code'.tr),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: codeController,
                  autofocus: false,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(fontSize: 14),
                  validator: (String? value) {
                    return CheckInput().checkLength(
                      value!,
                      6,
                      'code_is_required'.tr,
                      'code_not_correct'.tr,
                    );
                  },
                  decoration: Style.inputText(
                    'enter_tracking_code'.tr,
                    iconLeft: Ionicons.person_outline,
                  ),
                ),
                const SizedBox(height: 20),
                globalButton(
                  context: context,
                  buttonText: 'search'.tr,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (codeController.text.isNotEmpty) {
                        if (!Get.isRegistered<ScanQrController>()) {
                          ScanQrBinding().dependencies();
                        }
                        Get.find<ScanQrController>().setScanFrom(0);
                        Get.find<ScanQrController>().goodsSearch(
                          context,
                          codeController.text,
                        );
                      } else {
                        alertDialogOneButton(
                          title: 'information'.tr,
                          description: 'plz_enter_code'.tr,
                          buttonText: 'yes'.tr,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
