import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:express_vet/utils/button.dart';

import '../../api/goods_transfer.dart';
import '../../utils/alert_dialog.dart';
import '../../utils/check_input.dart';
import '../../utils/style.dart';

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
                    return CheckInput()
                        .checkLength(value!, 6, 'code_is_required'.tr, 'code_not_correct'.tr);
                  },
                  decoration:
                      Style.inputText('enter_tracking_code'.tr, iconLeft: Ionicons.person_outline)),
              const SizedBox(height: 20),
              globalButton(
                  context: context,
                  buttonText: 'search'.tr,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (codeController.text.isNotEmpty) {
                        GoodsTransfer().goodsSearch(context, codeController.text, 0);
                      } else {
                        alertDialogOneButton(
                          title: 'information'.tr,
                          description: 'plz_enter_code'.tr,
                          buttonText: 'yes'.tr,
                        );
                      }
                    }
                  })
            ],
          ),
        ),
      )),
    );
  }
}
