import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:express_vet/feature/home-dashboard/payment/presentaion/controller/payment_aba_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:express_vet/feature/home-dashboard/payment/presentaion/ui/payment_aba_package_screen.dart';
import 'package:express_vet/value_statics.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/api/travel_package.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/response/process_payment_response.dart';
import 'package:express_vet/feature/home-dashboard/payment/data/model/response/aba_payment_response.dart';
import 'package:express_vet/models/travel_package/find_travel_package_response.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/button.dart';
import 'package:express_vet/utils/loading.dart';
import 'package:http/http.dart' as http;
import 'package:express_vet/utils/style.dart';
import 'package:express_vet/feature/auth/presentation/binding/auth_binding.dart';
import 'package:express_vet/feature/auth/domain/uscase/auth_usecase.dart';
import '../../../../auth/data/model/response/nationality_response.dart';
import '../../../../auth/data/model/response/signup_response.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_pref.dart';
import '../../../../../utils/check_input.dart';
import '../../../../../utils/contains.dart';
import '../../../../dash_board/presentation/screen/dashboard_screen.dart';

class PackageInfoScreen extends StatefulWidget {
  final int? travelPackageId;

  const PackageInfoScreen({super.key, required this.travelPackageId});

  @override
  State<PackageInfoScreen> createState() => _PackageInfoScreenState();
}

class _PackageInfoScreenState extends State<PackageInfoScreen> {
  int status = 1;

  File? _image;
  String? imageFile;

  bool _uploadSuccess = false;

  // * Gender
  String? gender;

  var genderItems = ['male'.tr, 'female'.tr];

  // * National
  String? nationalityValue;
  int? nationalityId;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final dateOfBirthController = TextEditingController();
  final addressController = TextEditingController();

  //
  late Future<FindTravelPackageResponse> _findTravelPackageResponse;

  //
  int paymentMethodID = 0;
  int paymentMethodSelected = 0;

  String transactionID = '';

  late Future<NationalityResponse> futureNationality;
  final TextEditingController nationalityController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _findTravelPackageResponse = TravelPackage().find(
      context,
      widget.travelPackageId!,
    );

    nameController.text = ValueStatic.username;
    phoneController.text = ValueStatic.phone;
    emailController.text = ValueStatic.email;
    dateOfBirthController.text = ValueStatic.dob;

    if (ValueStatic.gender == 0) {
      setState(() {
        gender = null;
      });
    } else {
      setState(() {
        if (ValueStatic.gender == 1) {
          gender = 'male'.tr;
        } else {
          gender = 'female'.tr;
        }
      });
    }

    if (ValueStatic.nationalityId == 0) {
      setState(() {
        nationalityValue = null;
      });
    } else {
      setState(() {
        nationalityValue = ValueStatic.nationalityName.toString();
        nationalityId = ValueStatic.nationalityId;
      });
    }

    if (!Get.isRegistered<AuthUseCase>()) {
      AuthBinding().dependencies();
    }
    futureNationality = Get.find<AuthUseCase>().nationalityListTicket();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            if (status > 1) {
              setState(() {
                status = status - 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'booking_travel_package2'.tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              statusView(
                'assets/images/ic_package_info_2.png',
                1,
                'confirm_package'.tr,
              ),
              statusView(
                'assets/images/ic_package_info_1.png',
                2,
                'register_info'.tr,
              ),
              statusView(
                'assets/images/ic_package_info_3.png',
                3,
                'confirm_payment'.tr,
              ),
            ],
          ),
          Expanded(
            child: Stack(
              children: [
                Visibility(
                  visible: status == 1,
                  maintainAnimation: true,
                  maintainState: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutSine,
                    opacity: status == 1 ? 1 : 0,
                    child: status1(),
                  ),
                ),
                Visibility(
                  visible: status == 2,
                  maintainAnimation: true,
                  maintainState: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutSine,
                    opacity: status == 2 ? 1 : 0,
                    child: status2(),
                  ),
                ),
                Visibility(
                  visible: status == 3,
                  maintainAnimation: true,
                  maintainState: true,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeInOutSine,
                    opacity: status == 3 ? 1 : 0,
                    child: status3(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          color: AppColors.whiteColor,
          width: double.infinity,
          child: globalButton(
            context: context,
            buttonText: status == 3 ? 'pay_now'.tr : 'continue'.tr,
            onPressed: () {
              if (status == 1) {
                _onStatus1Tap();
              } else if (status == 2) {
                _onStatus2Tap();
              } else if (status == 3) {
                _onStatus3Tap();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<bool> popScreen() async {
    if (status > 1) {
      setState(() {
        status = status - 1;
      });
    } else {
      Navigator.pop(context);
    }
    return false;
  }

  SizedBox statusView(String image, int range, String title) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.333333,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(image, width: 50, height: 50),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color:
                      range == 2 || range == 3
                          ? AppColors.greyColor
                          : Colors.transparent,
                ),
              ),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color:
                      status >= range
                          ? AppColors.primaryColor
                          : AppColors.secondaryColor,
                ),
                child: Center(
                  child: Text(
                    range.toString(),
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color:
                      range == 2 || range == 1
                          ? AppColors.greyColor
                          : Colors.transparent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.textColor),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // * Status 1
  Widget status1() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: FutureBuilder(
        future: _findTravelPackageResponse,
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data!.header?.statusCode == 200 &&
              snapshot.data?.header?.result == true) {
            if (snapshot.data!.body!.data!.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.26,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl:
                              snapshot
                                  .data!
                                  .body!
                                  .data![0]
                                  .otherPhoto![0]
                                  .photo!,
                          placeholder: (context, url) => placeHolder(),
                          errorWidget: (context, url, error) => placeHolder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          "${'price'.tr}: ",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.titleColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '\$${snapshot.data!.body!.data![0].price ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      Get.locale.toString() == 'km_KH'
                          ? (snapshot.data!.body!.data![0].nameKh?.isNotEmpty ==
                                  true
                              ? snapshot.data!.body!.data![0].nameKh!
                              : snapshot.data!.body!.data![0].name ?? '')
                          : Get.locale.toString() == 'zh_CN'
                          ? (snapshot.data!.body!.data![0].nameCn?.isNotEmpty ==
                                  true
                              ? snapshot.data!.body!.data![0].nameCn!
                              : snapshot.data!.body!.data![0].name ?? '')
                          : snapshot.data!.body!.data![0].name ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Get.locale.toString() == 'km_KH'
                          ? (snapshot
                                      .data!
                                      .body!
                                      .data![0]
                                      .descriptionKh
                                      ?.isNotEmpty ==
                                  true
                              ? snapshot.data!.body!.data![0].descriptionKh!
                              : snapshot.data!.body!.data![0].description ?? '')
                          : Get.locale.toString() == 'zh_CN'
                          ? (snapshot
                                      .data!
                                      .body!
                                      .data![0]
                                      .descriptionCn
                                      ?.isNotEmpty ==
                                  true
                              ? snapshot.data!.body!.data![0].descriptionCn!
                              : snapshot.data!.body!.data![0].description ?? '')
                          : snapshot.data!.body!.data![0].description ?? '',
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'condition'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      Get.locale.toString() == 'km_KH'
                          ? (snapshot
                                      .data!
                                      .body!
                                      .data![0]
                                      .termConditionKh
                                      ?.isNotEmpty ==
                                  true
                              ? snapshot.data!.body!.data![0].termConditionKh!
                              : snapshot.data!.body!.data![0].termCondition ??
                                  '')
                          : Get.locale.toString() == 'zh_CN'
                          ? (snapshot
                                      .data!
                                      .body!
                                      .data![0]
                                      .termConditionCn
                                      ?.isNotEmpty ==
                                  true
                              ? snapshot.data!.body!.data![0].termConditionCn!
                              : snapshot.data!.body!.data![0].termCondition ??
                                  '')
                          : snapshot.data!.body!.data![0].termCondition ?? '',
                    ),
                  ],
                ),
              );
            }
          }
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: double.infinity,
            child: const Center(
              child: SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onStatus1Tap() {
    status += 1;
    setState(() {});
  }

  // * Status 2
  Widget status2() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  //* image
                  Center(
                    child: Column(
                      children: [
                        InkWell(
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
                                        color: AppColors.whiteColor,
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
                                                      color:
                                                          AppColors.greyColor,
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

                                                        XFile? photo =
                                                            await ImagePicker()
                                                                .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera,
                                                                );
                                                        if (photo != null) {
                                                          await uploadImageTravelPackage(
                                                            File(photo.path),
                                                          );
                                                        }
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
                                                              'assets/images/ic_camera2.png',
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

                                                        XFile?
                                                        photo = await ImagePicker()
                                                            .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery,
                                                            );
                                                        if (photo != null) {
                                                          await uploadImageTravelPackage(
                                                            File(photo.path),
                                                          );
                                                        }
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
                                                              'assets/images/ic_gallery.png',
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
                                            color: AppColors.greyColor,
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
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  left: 0,
                                  top: 0,
                                  child:
                                      _image == null
                                          ? const Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  AppColors.whiteColor,
                                              backgroundImage: AssetImage(
                                                'assets/images/img_user_profile.png',
                                              ),
                                            ),
                                          )
                                          : Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  AppColors.whiteColor,
                                              child: ClipOval(
                                                child: Image.file(
                                                  _image!,
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 8,
                                      right: 8,
                                    ),
                                    child: Image.asset(
                                      'assets/images/ic_edit.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text.rich(
                          TextSpan(
                            text: 'add_img'.tr,
                            style: const TextStyle(
                              color: AppColors.textColor,
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
                        Text(
                          "plz_upload".tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //* username
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: 'name_pro'.tr,
                      style: const TextStyle(
                        color: AppColors.greyColor,
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
                    controller: nameController,
                    autofocus: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(fontSize: 14),
                    validator: (String? value) {
                      return CheckInput().checkLength(
                        value!,
                        2,
                        'username_req'.tr,
                        'username_inco'.tr,
                      );
                    },
                    decoration: Style.inputText('name'.tr),
                  ),

                  //* gender
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: 'gender'.tr,
                      style: const TextStyle(
                        color: AppColors.greyColor,
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
                  ValueStatic.gender == 0
                      ? InputDecorator(
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(
                            10,
                            1,
                            10,
                            5,
                          ), // Match nationality padding
                          border: Style.outlineInputBorder(),
                          enabledBorder: Style.outlineInputBorder(),
                          focusedBorder: Style.outlineInputBorder(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            hint: Text(
                              'select_gender'.tr,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                            items:
                                genderItems
                                    .map(
                                      (String item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                            value: gender,
                            onChanged: (String? value) {
                              setState(() {
                                gender = value;

                                //ValueStatic.gender = gender == 'male'.tr ? 1 : 2;
                              });
                            },
                            iconStyleData: const IconStyleData(
                              iconEnabledColor: AppColors.borderColor,
                            ),
                            dropdownStyleData: DropdownStyleData(
                              width: MediaQuery.of(context).size.width * 0.9,
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 40,
                            ),
                          ),
                        ),
                      )
                      : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Text(
                          ValueStatic.gender == 1 ? 'male'.tr : 'female'.tr,
                        ),
                      ),

                  //* nationality
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: 'nationality'.tr,
                      style: const TextStyle(
                        color: AppColors.greyColor,
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
                  ValueStatic.nationalityId == 0
                      ? FutureBuilder<NationalityResponse>(
                        future: futureNationality,
                        builder: (context, data) {
                          if (data.hasData) {
                            if ((data.data?.header?.result) == true &&
                                (data.data?.header?.statusCode) == 200) {
                              if ((data.data?.body)!.status == true &&
                                  (data.data?.body)!.data!.isNotEmpty) {
                                return InputDecorator(
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      10,
                                      1,
                                      10,
                                      5,
                                    ),
                                    border: Style.outlineInputBorder(),
                                    enabledBorder: Style.outlineInputBorder(),
                                    focusedBorder: Style.outlineInputBorder(),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2<String>(
                                      isExpanded: true,
                                      hint: Text(
                                        'select_nation'.tr,
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      items:
                                          data.data?.body!.data
                                              ?.map(
                                                (item) =>
                                                    DropdownMenuItem<String>(
                                                      value: item.name,
                                                      child: Text(
                                                        "${item.name}",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                              )
                                              .toList(),
                                      value: nationalityValue,
                                      onChanged: (value) {
                                        setState(() {
                                          nationalityValue = value;
                                          nationalityId =
                                              data.data?.body!.data
                                                  ?.firstWhere(
                                                    (item) =>
                                                        item.name == value,
                                                  )
                                                  .id;
                                        });
                                      },
                                      iconStyleData: const IconStyleData(
                                        iconEnabledColor: AppColors.borderColor,
                                      ),
                                      dropdownStyleData:
                                          const DropdownStyleData(
                                            width: double.infinity,
                                          ),
                                      menuItemStyleData:
                                          const MenuItemStyleData(height: 40),
                                      dropdownSearchData: DropdownSearchData(
                                        searchController: nationalityController,
                                        searchInnerWidgetHeight: 50,
                                        searchInnerWidget: Container(
                                          height: 60,
                                          padding: const EdgeInsets.only(
                                            top: 8,
                                            bottom: 4,
                                            right: 8,
                                            left: 8,
                                          ),
                                          child: TextFormField(
                                            expands: true,
                                            maxLines: null,
                                            controller: nationalityController,
                                            decoration: Style.inputText(
                                              'search_nation'.tr,
                                            ),
                                          ),
                                        ),
                                        searchMatchFn: (item, searchValue) {
                                          return item.value
                                              .toString()
                                              .toLowerCase()
                                              .contains(
                                                searchValue.toLowerCase(),
                                              );
                                        },
                                      ),
                                      //This to clear the search value when you close the menu
                                      onMenuStateChange: (isOpen) {
                                        if (!isOpen) {
                                          nationalityController.clear();
                                        }
                                      },
                                    ),
                                  ),
                                );
                              }
                            }
                          } else if (data.hasError) {
                            return const Text('');
                          }
                          return Center(
                            child: SizedBox(
                              height: 30.0,
                              width: 30.0,
                              child: CircularProgressIndicator(
                                value: null,
                                color:
                                    ValueStatic.ticketType == '3'
                                        ? AppColors.airBusColor
                                        : AppColors.primaryColor,
                                strokeWidth: 3.0,
                              ),
                            ),
                          );
                        },
                      )
                      : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        child: Text(ValueStatic.nationalityName.toString()),
                      ),

                  //* phone number
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: 'phone_number'.tr,
                      style: const TextStyle(
                        color: AppColors.greyColor,
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
                      return CheckInput().validatePhone(value);
                    },
                    decoration: Style.inputText('phone_number'.tr),
                  ),

                  //* email
                  const SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      text: 'email'.tr,
                      style: const TextStyle(
                        color: AppColors.greyColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: emailController,
                    autofocus: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14),
                    validator: (String? value) => validateEmail(value),
                    decoration: Style.inputText('email'.tr),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onStatus2Tap() {
    if (_formKey.currentState!.validate() &&
        _image != null &&
        nameController.text.isNotEmpty &&
        gender != null &&
        phoneController.text.isNotEmpty &&
        nationalityValue != null) {
      //
      Loading().loadingShow();
      //
      TravelPackage().confirm(
        context: context,
        name: nameController.text,
        sex: gender == 'male'.tr ? 1 : 2,
        nationality: nationalityId!.toInt(),
        photo: imageFile.toString(),
        telephone: phoneController.text,
        email: emailController.text.isEmpty ? '' : emailController.text,
        dob: dateOfBirthController.text,
        address: addressController.text,
        travelPackageId: widget.travelPackageId!,
        doOnSuccess: (response) {
          //
          if (response.header?.result == true &&
              response.header?.statusCode == 200) {
            //
            Loading().loadingClose();
            //
            status += 1;
            //
            transactionID = (response.body?.transactionId)!;

            setState(() {});
          }
        },
        doOnFailed: () {
          //
          Loading().loadingClose();
        },
      );
    } else {
      alertDialogOneButton(
        title: 'information'.tr,
        description: "please_input_require_data".tr,
        buttonText: 'yes'.tr,
      );
    }
  }

  // * Status 3
  Widget status3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                'choose_payment'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.titleColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                paymentMethodID = 5;
                paymentMethodSelected = 1;
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color:
                        paymentMethodSelected == 1
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Image.asset('assets/images/ic_khqr.png', height: 44),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ABA KHQR',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.titleColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  'tap_to_pay_with_KHQR'.tr,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Radio(
                        value: 1,
                        groupValue: paymentMethodSelected,
                        fillColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.primaryColor,
                        ),
                        onChanged: (value) {
                          paymentMethodSelected = 1;
                          paymentMethodID = 5;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                paymentMethodID = 6;
                paymentMethodSelected = 2;
                setState(() {});
              },
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color:
                        paymentMethodSelected == 2
                            ? AppColors.primaryColor
                            : AppColors.borderColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Image.asset('assets/images/ic_big_visa.png', height: 44),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Credit/Debit Card',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.titleColor,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Image.asset(
                                  'assets/images/ic_visa_small.png',
                                  height: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Radio(
                        value: 2,
                        groupValue: paymentMethodSelected,
                        fillColor: WidgetStateColor.resolveWith(
                          (states) => AppColors.primaryColor,
                        ),
                        onChanged: (value) {
                          paymentMethodSelected = 2;
                          paymentMethodID = 6;
                          setState(() {});
                        },
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

  void _onStatus3Tap() {
    if (paymentMethodID == 0) {
      alertDialogOneButton(
        title: 'information'.tr,
        description: 'choose_payment_method'.tr,
        buttonText: 'yes'.tr,
      );
    } else {
      processBooking(transactionID);
    }
  }

  String? validateEmail(String? value) {
    final emailRegExp = RegExp(
      r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
    );
    // * Validate
    if (value != null) {
      if (value.isNotEmpty && !emailRegExp.hasMatch(value)) {
        return 'Invalid format email address';
      }
    }
    return null;
  }

  Future<void> payWithABAMobile(transactionId, token) async {
    log(
      '${BaseUrl.PAYMENT_URL}payments/abaMobilePayPackage/$transactionId/$token',
    );

    final response = await http.post(
      Uri.parse(
        '${BaseUrl.PAYMENT_URL}payments/abaMobilePayPackage/$transactionId/$token',
      ),
      headers: <String, String>{'Authorization': AppPref.getToken() ?? ''},
    );

    if (response.statusCode == 200) {
      log('This is response ABA Payment ==>>${response.body}');
      var data = ABAPayResponse.fromJson(jsonDecode(response.body));

      log('QR Link ${data.checkout_qr_url}');
      var result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => PaymentABAPackageScreen(
                transactionId: transactionId,
                token: token.toString(),
                title: 'ABA KHQR',
                type: 1,
                url: data.checkout_qr_url ?? '',
              ),
        ),
      );
      // Ensure payment controller stops polling after returning
      if (Get.isRegistered<PaymentAbaController>()) {
        try {
          Get.find<PaymentAbaController>().stop();
        } catch (_) {}
        Get.delete<PaymentAbaController>(force: true);
      }
      if (result == "1") {
        /// Payment ABA KHQR success
        showDialogPaymentComplete();
      } else {
        showDialogPaymentFail();
      }
    } else {
      throw Exception('Failed to load to server!');
    }
  }

  void showDialogPaymentComplete() {
    alertDialogTwoButton(
      title: 'Your Travel Package Has Been Completed',
      description: 'You can use the travel package to book your trips with us.',
      buttonText1: 'home'.tr,
      buttonText2: 'show_package'.tr,
      onButtonPressed1: () {
        ValueStatic().clearDataTicket();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(from: 0),
          ),
          (Route<dynamic> route) => false,
        );
      },
      onButtonPressed2: () {
        ValueStatic().clearDataTicket();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(from: 5),
          ),
          (Route<dynamic> route) => false,
        );
      },
    );
  }

  void showDialogPaymentFail() {
    alertDialogOneButton(
      title: 'information'.tr,
      description: 'payment_not_success'.tr,
      buttonText: 'ok'.tr,
    );
  }

  Future<void> processBooking(transactionId) async {
    Loading().loadingShow();

    final fields = <String, String>{};
    fields['code'] = transactionId.toString();
    fields['paymentMethodId'] = paymentMethodID.toString();
    fields['totalAmount'] = "22.22";

    log(fields.toString());

    try {
      Future<http.Response> sendOnce() {
        return http
            .post(
              Uri.parse(
                '${BaseUrl.BASE_URL_TICKET}travelPackage/processPayment',
              ),
              headers: <String, String>{
                'Authorization': AppPref.getToken() ?? '',
                'Content-Type': 'application/x-www-form-urlencoded',
                'Accept': 'application/json',
                'Connection': 'close',
              },
              body: fields,
            )
            .timeout(const Duration(seconds: Constrains.timeout30));
      }

      http.Response response;
      try {
        response = await sendOnce();
      } on http.ClientException catch (_) {
        await Future.delayed(const Duration(milliseconds: 400));
        response = await sendOnce();
      }

      if (response.statusCode == 200) {
        log('This is response booking process ==>>${response.body}');
        var data = PaymentResponse.fromJson(jsonDecode(response.body));
        Loading().loadingClose();

        if (data.header?.statusCode == 200 && data.header?.result == true) {
          if (paymentMethodSelected == 1) {
            /// do payment with ABA mobile
            log('Pay by ABA Mobile');
            var token = data.body?.token;
            payWithABAMobile(transactionId, token);
          } else if (paymentMethodSelected == 2) {
            /// open web view for credit payment
            log('===> Pay Credit card');
            var token = data.body?.token;
            var result = await Navigator.push(
              Get.context!,
              MaterialPageRoute(
                builder:
                    (context) => PaymentABAPackageScreen(
                      transactionId: transactionId,
                      token: token.toString(),
                      title: 'Credit/Debit Card',
                      type: 2,
                      url: '',
                    ),
              ),
            );

            // Ensure payment controller stops polling after returning
            if (Get.isRegistered<PaymentAbaController>()) {
              try {
                Get.find<PaymentAbaController>().stop();
              } catch (_) {}
              Get.delete<PaymentAbaController>(force: true);
            }

            log('Result $result');

            if (result == "1") {
              /// Payment Credit card success
              showDialogPaymentComplete();
            } else {
              showDialogPaymentFail();
            }
          }
        }
      } else {
        throw Exception('Failed to load to server!');
      }
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } on http.ClientException catch (e) {
      Loading().loadingClose();
      log('Network client error: $e');
      alertDialogOneButton(
        title: 'information'.tr,
        description: 'payment_not_success'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (e) {
      Loading().loadingClose();
      log('Unexpected error: $e');
      rethrow;
    }
  }

  Future<void> uploadImageTravelPackage(File filepath) async {
    Loading().loadingShow();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${BaseUrl.BASE_URL_UPLOAD_IMAGE}uploads/uploadPhotoTravelPackageOrder',
      ),
    );
    request.headers['Authorization'] = AppPref.getToken() ?? '';
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['token'] = 'wK4lxDowEfgnaEH2k226FppwAJSflRPG';
    request.files.add(
      await http.MultipartFile.fromPath('photo', filepath.path),
    );

    try {
      final result = await request.send().timeout(
        const Duration(seconds: Constrains.timeout30),
      );
      final response = await http.Response.fromStream(result);

      if (response.statusCode == 200) {
        Loading().loadingClose();
        log('This is response image travel package ==>>${response.body}');
        final registerImageResponse = UploadImage.fromJson(
          jsonDecode(response.body),
        );
        if (registerImageResponse.img != '') {
          setState(() {
            imageFile = registerImageResponse.img;
            _uploadSuccess = true;
            _image = filepath;
          });
        } else {
          alertDialogOneButton(
            title: 'Information',
            description: 'Upload photo failed',
            buttonText: 'ok'.tr,
          );
        }
      } else {
        throw Exception('Failed to upload photo');
      }
    } on TimeoutException {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
    } catch (e) {
      Loading().loadingClose();
      log('An error occurred: $e');
      rethrow;
    }
  }

  SizedBox placeHolder() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.26,
      width: double.infinity,
      child: const Image(
        image: AssetImage('assets/images/place_holder.png'),
        fit: BoxFit.cover,
      ),
    );
  }
}
