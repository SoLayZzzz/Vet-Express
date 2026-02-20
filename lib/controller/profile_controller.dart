import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../activities/ticket/value_statics.dart';
import '../base/base_url.dart';
import '../feature/auth/presentation/binding/auth_binding.dart';
import '../feature/auth/domain/uscase/auth_usecase.dart';
import '../feature/auth/data/model/response/nationality_response.dart';
import '../feature/auth/data/model/response/signup_response.dart';
import '../feature/auth/data/model/response/user_me.dart';
import '../utils/alert_dialog.dart';
import '../utils/app_colors.dart';
import '../utils/check_input.dart';
import '../utils/loading.dart';

class ProfileController extends GetxController {
  var userMeResponse = Rxn<UserMeResponse>();
  var image = Rxn<File>();
  var imagePath = Rxn<String>();
  var nameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  //check userName == phone or email
  var isEmailReadOnly = false.obs;
  var isTelephoneReadOnly = false.obs;

  RxnString gender = RxnString();
  final genderItems = ['male'.tr, 'female'.tr].obs;

  RxnString selectedNationality = RxnString();
  RxnInt selectedNationalityId = RxnInt();
  RxList<NationalityResponseData> nationalityList =
      <NationalityResponseData>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserMe();
    fetchNationalities();
  }

  void fetchNationalities() async {
    try {
      if (!Get.isRegistered<AuthUseCase>()) {
        AuthBinding().dependencies();
      }
      final response = await Get.find<AuthUseCase>().nationalityList();
      if (response.header?.result == true &&
          response.header?.statusCode == 200) {
        if (response.body?.status == true && response.body?.data != null) {
          nationalityList.assignAll(response.body!.data!);
          // If the user data is already loaded, set the selected nationality
          if (userMeResponse.value != null &&
              selectedNationalityId.value != null) {
            _setSelectedNationalityFromId();
          }
        }
      }
    } catch (e) {
      log("Error fetching nationalities: $e");
    }
  }

  Future<void> fetchUserMe() async {
    try {
      if (!Get.isRegistered<AuthUseCase>()) {
        AuthBinding().dependencies();
      }
      final user = await Get.find<AuthUseCase>().getUserMe();
      userMeResponse.value = user;
      nameController.text = user.body?.name ?? '';
      phoneNumberController.text = user.body?.telephone ?? '';
      emailController.text = user.body?.email ?? '';

      // Check if username matches email or telephone
      isEmailReadOnly.value = user.body?.username == user.body?.email;
      isTelephoneReadOnly.value = user.body?.username == user.body?.telephone;

      // Handle gender
      if (user.body?.gender == 1) {
        gender.value = 'male'.tr;
      } else if (user.body?.gender == 2) {
        gender.value = 'female'.tr;
      } else {
        gender.value = null; // Shows "Select Gender" when null
      }

      // Handle nationality
      if (user.body?.nationalityId != null) {
        selectedNationalityId.value = user.body!.nationalityId;
        if (nationalityList.isNotEmpty) {
          _setSelectedNationalityFromId();
        }
      } else {
        selectedNationality.value = null;
      }

      if (emailController.text == 'null') {
        emailController.clear();
      }
    } catch (e) {
      log('Error fetching user data: $e');
    }
  }

  void _setSelectedNationalityFromId() {
    if (selectedNationalityId.value != null) {
      final nationality = nationalityList.firstWhere(
        (n) => n.id == selectedNationalityId.value,
        orElse: () => NationalityResponseData(id: 0, name: null),
      );
      if (nationality.id != 0 && nationality.name != null) {
        selectedNationality.value = nationality.name;
      } else {
        selectedNationality.value = null;
      }
    }
  }

  Future<void> updateProfile() async {
    if (formKey.currentState!.validate()) {
      if (nameController.text.isNotEmpty) {
        if (phoneNumberController.text.isEmpty &&
            emailController.text.isEmpty) {
          alertDialogOneButton(
            title: 'information'.tr,
            description: 'plz_fill_phone_or_email'.tr,
            buttonText: 'yes'.tr,
          );
        } else {
          bool checkValidate = true;
          int invalidType = 0;
          if (phoneNumberController.text.isNotEmpty) {
            if (CheckInput().validatePhoneNumber(phoneNumberController.text) ==
                false) {
              invalidType = 1;
              checkValidate = false;
            }
          }

          if (emailController.text.isNotEmpty) {
            if (CheckInput().validateEmail(emailController.text) == false) {
              invalidType = 2;
              checkValidate = false;
            }
          }

          if (checkValidate) {
            if (!Get.isRegistered<AuthUseCase>()) {
              AuthBinding().dependencies();
            }
            await Get.find<AuthUseCase>().profileUpdate(
              name: nameController.text,
              telephone:
                  phoneNumberController.text.isEmpty
                      ? null
                      : phoneNumberController.text,
              email: emailController.text.isEmpty ? null : emailController.text,
              filename: imagePath.value,
              gender:
                  gender.value == 'male'.tr
                      ? 1
                      : gender.value == 'female'.tr
                      ? 2
                      : 0,
              nationalityId: selectedNationalityId.toInt(),
            );

            // Update static values
            ValueStatic.username = nameController.text;
            ValueStatic.phone = phoneNumberController.text;
            ValueStatic.email = emailController.text;
            ValueStatic.gender =
                gender.value == 'male'.tr
                    ? 1
                    : gender.value == 'female'.tr
                    ? 2
                    : 0;
            ValueStatic.nationalityId = selectedNationalityId.toInt()!;
            ValueStatic.nationalityName = selectedNationality.value!;
          } else {
            if (invalidType == 1) {
              alertDialogOneButton(
                title: 'information'.tr,
                description: 'invalid_phone'.tr,
                buttonText: 'yes'.tr,
              );
            } else {
              alertDialogOneButton(
                title: 'information'.tr,
                description: 'invalid_email'.tr,
                buttonText: 'yes'.tr,
              );
            }
          }
        }
      } else {
        alertDialogOneButton(
          title: 'information'.tr,
          description: 'plz_fill_name'.tr,
          buttonText: 'yes'.tr,
        );
      }
    }

    FocusScope.of(Get.context!).unfocus();
  }

  Future<void> uploadImageUpdate(File filepath) async {
    Loading().loadingShow(Get.context!);
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '${BaseUrl.BASE_URL_UPLOAD_IMAGE}uploads/uploadPhotoUserProfile',
      ),
    );
    request.headers['Content-Type'] = 'multipart/form-data';
    request.fields['token'] = 'wK4lxDowEfgnaEH2k226FppwAJSflRPG';
    request.files.add(
      await http.MultipartFile.fromPath('photo', filepath.path),
    );

    request.send().then((result) async {
      http.Response.fromStream(result).then((response) async {
        Loading().loadingClose(Get.context!);
        if (response.statusCode == 200) {
          final registerImageResponse = UploadImage.fromJson(
            jsonDecode(response.body),
          );
          if (registerImageResponse.img!.isNotEmpty) {
            imagePath.value = registerImageResponse.img;
            image.value = filepath;
          } else {
            alertDialogOneButton(
              title: 'Information',
              description: 'Upload photo failed',
              buttonText: 'yes'.tr,
            );
          }
        } else {
          alertDialogOneButton(
            title: 'Error',
            description: 'Failed to upload image.',
            buttonText: 'ok'.tr,
          );
        }
      });
    });
  }

  void showImageSourceOptions() {
    Get.bottomSheet(
      Stack(
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 5,
                          width: MediaQuery.sizeOf(Get.context!).width * 0.25,
                          decoration: BoxDecoration(
                            color: AppColors.greyColor,
                            borderRadius: BorderRadius.circular(10),
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
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildImageSourceOption('camera', ImageSource.camera),
                          const Divider(height: 1),
                          _buildImageSourceOption(
                            'gallery',
                            ImageSource.gallery,
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
                  Get.back();
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
      ),
    );
  }

  Widget _buildImageSourceOption(String sourceKey, ImageSource source) {
    return InkWell(
      onTap: () async {
        Navigator.pop(Get.context!);
        final picker = ImagePicker();
        final pickedImage = await picker.pickImage(source: source);
        if (pickedImage != null) {
          await uploadImageUpdate(File(pickedImage.path));
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              sourceKey == 'camera'
                  ? 'assets/images/ic_camera2.png'
                  : 'assets/images/ic_gallery.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 20),
            Text(
              sourceKey.tr,
              style: const TextStyle(fontSize: 16, color: AppColors.textColor),
            ),
          ],
        ),
      ),
    );
  }
}
