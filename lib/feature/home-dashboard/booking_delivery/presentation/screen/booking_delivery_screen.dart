import 'dart:io';

import 'package:express_vet/asset_image.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/utils/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../feature/dash_board/presentation/screen/dashboard_screen.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/check_input.dart';
import '../../../../../utils/style.dart';
import 'booking_delivery_live_location_screen.dart';
import '../../../../history-dashboard/other-history/presentation/binding/goods_transfer_action_binding.dart';
import '../../../../history-dashboard/other-history/presentation/controller/goods_transfer_action_controller.dart';
import '../../../../history-dashboard/other-history/data/model/request/goods_transfer_add_request_body.dart';

class BookingDeliveryScreen extends StatefulWidget {
  static String lats = '', longs = '', address = '';

  const BookingDeliveryScreen({super.key});

  @override
  State<BookingDeliveryScreen> createState() => _BookingDeliveryScreenState();
}

class _BookingDeliveryScreenState extends State<BookingDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final Rxn<File> _image = Rxn<File>();

  late final GoodsTransferActionController goodsTransferActionController;

  final phoneController = TextEditingController();
  final itemTypeController = TextEditingController();
  final addressController = TextEditingController();

  final RxInt itemTypeSelected = 0.obs;
  final RxInt deliverySelected = 0.obs;
  final RxInt pickUpSelected = 0.obs;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<GoodsTransferActionController>()) {
      GoodsTransferActionBinding().dependencies();
    }
    goodsTransferActionController = Get.find<GoodsTransferActionController>();
    phoneController.text = ValueStatic.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'booking_delivery'.tr),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Form(
          key: _formKey,
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 15,
                      right: 15,
                      top: 15,
                      bottom: 100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'phone_number'.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: phoneController,
                          autofocus: false,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 14),
                          validator: (String? value) {
                            return CheckInput().checkLength(
                              value!,
                              9,
                              'phone_r'.tr,
                              'phone_in'.tr,
                            );
                          },
                          decoration: Style.inputText('phone_number'.tr),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text: 'item_type'.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: '',
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        TextFormField(
                          controller: itemTypeController,
                          autofocus: false,
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 14),
                          decoration: Style.inputText(''),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text: 'item_size'.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    itemTypeSelected.value = 1;
                                  },
                                  child: motoPickUp(itemTypeSelected.value),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    itemTypeSelected.value = 2;
                                  },
                                  child: tuktukPickUp(itemTypeSelected.value),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (BuildContext context) {
                                return Stack(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(height: 10),
                                            Align(
                                              alignment: Alignment.center,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height: 5,
                                                    width:
                                                        MediaQuery.sizeOf(
                                                          context,
                                                        ).width *
                                                        0.25,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              'choose_gallery'.tr,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Flexible(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        final photo =
                                                            await ImagePicker()
                                                                .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera,
                                                                );
                                                        _image.value = File(
                                                          photo!.path,
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              15.0,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              AssetImages
                                                                  .ic_camera2,
                                                              width: 30,
                                                              height: 30,
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              'camera'.tr,
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    AppColors
                                                                        .textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const Divider(height: 1),
                                                    InkWell(
                                                      onTap: () async {
                                                        Navigator.pop(context);

                                                        final photo =
                                                            await ImagePicker()
                                                                .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .gallery,
                                                                );
                                                        _image.value = File(
                                                          photo!.path,
                                                        );
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              15.0,
                                                            ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Image.asset(
                                                              AssetImages
                                                                  .ic_gallery,
                                                              width: 30,
                                                              height: 30,
                                                            ),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Text(
                                                              'gallery'.tr,
                                                              style: const TextStyle(
                                                                fontSize: 16,
                                                                color:
                                                                    AppColors
                                                                        .textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.grey,
                                            size: 28,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Obx(
                            () => Row(
                              children: [
                                if (_image.value == null)
                                  Image.asset(
                                    AssetImages.ic_camera,
                                    width: 100,
                                  ),
                                if (_image.value != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      _image.value!,
                                      width: 100,
                                    ),
                                  ),
                                const SizedBox(width: 20),
                                if (_image.value == null)
                                  Text(
                                    'take_photo'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                if (_image.value != null)
                                  Text(
                                    'change_photo'.tr,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text: 'delivery'.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    deliverySelected.value = 1;
                                  },
                                  child: ppDelivery(deliverySelected.value),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    deliverySelected.value = 2;
                                  },
                                  child: provinceDelivery(deliverySelected.value),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text.rich(
                          TextSpan(
                            text: 'pick_up_address'.tr,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            children: const <TextSpan>[
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).unfocus();
                                    final result = await Get.to(
                                      () =>
                                          const BookingDeliveryLiveLocationScreen(),
                                    );
                                    if (result == '1') {
                                      pickUpSelected.value = 1;
                                    } else {
                                      pickUpSelected.value = 0;
                                    }
                                  },
                                  child: liveLocation(pickUpSelected.value),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    pickUpSelected.value = 2;
                                  },
                                  child: manualLocation(pickUpSelected.value),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(
                          () =>
                              pickUpSelected.value == 2
                                  ? TextFormField(
                                    controller: addressController,
                                    autofocus: false,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: null,
                                    style: const TextStyle(fontSize: 14),
                                    validator: (String? value) {
                                      return CheckInput().checkLength(
                                        value!,
                                        1,
                                        'add_is_req'.tr,
                                        '',
                                      );
                                    },
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        10,
                                        10,
                                        10,
                                        20,
                                      ),
                                      hintText: 'enter_address'.tr,
                                      hintMaxLines: 6,
                                      border: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: MaterialColor(
                                            0xFF44459c,
                                            <int, Color>{},
                                          ),
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5),
                                        ),
                                      ),
                                    ),
                                  )
                                  : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    color: AppColors.whiteColor,
                    width: double.infinity,
                    child: globalButton(
                      context: context,
                      buttonText: 'booking'.tr,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (itemTypeSelected.value == 0 ||
                              deliverySelected.value == 0 ||
                              pickUpSelected.value == 0) {
                            alertDialogOneButton(
                              title: 'info'.tr,
                              description: 'plz_com_info'.tr,
                              buttonText: 'yes'.tr,
                            );
                          } else {
                            final senderAddr =
                                pickUpSelected.value == 2
                                    ? addressController.text.toString()
                                    : BookingDeliveryScreen.address.toString();

                            goodsTransferActionController.addGoodsTransfer(
                              context: context,
                              body: GoodsTransferAddRequestBody(
                                filePath: _image.value?.path,
                                itemName: itemTypeController.text.toString(),
                                lats: BookingDeliveryScreen.lats.toString(),
                                longs: BookingDeliveryScreen.longs.toString(),
                                qtyType: itemTypeSelected.value.toString(),
                                senderAddr: senderAddr,
                                serviceType: deliverySelected.value.toString(),
                                telephone: phoneController.text.toString(),
                              ),
                              onSuccess: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const DashboardScreen(from: 0),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                            );
                          }
                        }
                      },
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

  Container liveLocation(int selected) {
    return selected == 1
        ? Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    AssetImages.ic_check,
                    width: 20,
                    color: Colors.green,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'live_location'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        )
        : Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'live_location'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
  }

  Container manualLocation(int selected) {
    return selected == 2
        ? Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    AssetImages.ic_check,
                    width: 20,
                    color: Colors.green,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'manual_address'.tr,
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        )
        : Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'manual_address'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
  }

  Container ppDelivery(int selected) {
    return selected == 1
        ? Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    AssetImages.ic_check,
                    width: 20,
                    color: Colors.green,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'in_pp'.tr,
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        )
        : Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'in_pp'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
  }

  Container provinceDelivery(int selected) {
    return selected == 2
        ? Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Image.asset(
                    AssetImages.ic_check,
                    width: 20,
                    color: Colors.green,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    'in_province'.tr,
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        )
        : Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Text(
                'in_province'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
        );
  }

  Container motoPickUp(int selected) {
    return selected == 1
        ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    AssetImages.ic_check,
                    width: 24,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Image.asset(
                        AssetImages.ic_moto,
                        width: 50,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'small_moto'.tr,
                        style: const TextStyle(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Image.asset(
                        AssetImages.ic_moto,
                        width: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'small_moto'.tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Container tuktukPickUp(int selected) {
    return selected == 2
        ? Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset(
                    AssetImages.ic_check,
                    width: 24,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Image.asset(
                        AssetImages.ic_tuktuk,
                        width: 50,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'big_tuk_tuk'.tr,
                        style: const TextStyle(color: AppColors.primaryColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      Image.asset(
                        AssetImages.ic_tuktuk,
                        width: 50,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'big_tuk_tuk'.tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
