import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api/goods_transfer.dart';
import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/button.dart';
import '../../../../utils/check_input.dart';
import '../../../../utils/style.dart';
import '../../../../activities/logistic/scan_qr_screen.dart';

class SearchGoodsTransferScreen extends StatefulWidget {
  const SearchGoodsTransferScreen({super.key});

  @override
  SearchGoodsTransferScreenState createState() =>
      SearchGoodsTransferScreenState();
}

class SearchGoodsTransferScreenState extends State<SearchGoodsTransferScreen> {
  final _formKey = GlobalKey<FormState>();

  final codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'scan_parcel'.tr),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        'enter_goods_transfer'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                      child: Text(
                        'goods_transfer_code'.tr,
                        style: const TextStyle(color: AppColors.primaryColor),
                      ),
                    ),
                    TextFormField(
                      controller: codeController,
                      autofocus: false,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.text,
                      style: const TextStyle(fontSize: 14),
                      validator: (String? value) {
                        return CheckInput().checkLength(
                          value!,
                          1,
                          'code_requ'.tr,
                          '',
                        );
                      },
                      decoration: Style.inputText(
                        'code'.tr,
                        iconLeft: Icons.confirmation_num_outlined,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: globalButton(
                          context: context,
                          buttonText: 'search'.tr,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              GoodsTransfer().goodsSearch(
                                context,
                                codeController.text,
                                1,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 1,
                            color: AppColors.borderColor,
                          ),
                          Text(
                            'or'.tr,
                            style: const TextStyle(color: AppColors.textColor),
                          ),
                          Container(
                            width: 100,
                            height: 1,
                            color: AppColors.borderColor,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'scan_qr_info'.tr,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: globalButton(
                          context: context,
                          buttonText: 'scan_btn'.tr,
                          onPressed: () {
                            Get.to(
                              () => const ScanQR(scanFrom: 1),
                              transition: Transition.rightToLeft,
                              duration: const Duration(milliseconds: 350),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
