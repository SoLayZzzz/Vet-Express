import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../value_statics.dart';
import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../../../auth/presentation/binding/auth_binding.dart';
import '../../../../auth/domain/uscase/auth_usecase.dart';
import '../../../../auth/data/model/response/nationality_response.dart';
import '../../../../auth/data/model/response/user_me.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/check_input.dart';
import '../../../../../utils/loading.dart';
import '../../../profile/data/network/profile_network_request.dart';
import '../../../../../controller/user_controller.dart';
import '../../../../../models/simple_response.dart';

class ProfileController extends GetxController {
  var userMeResponse = Rxn<UserMeResponse>();
  var image = Rxn<File>();
  var imagePath = Rxn<String>();
  var nameController = TextEditingController();
  var phoneNumberController = TextEditingController();
  var emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final canSave = false.obs;

  String _initialName = '';
  String _initialPhone = '';
  String _initialEmail = '';
  int _initialGenderCode = 0;
  int _initialNationalityId = 0;
  bool _hasInitialSnapshot = false;

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

    nameController.addListener(_recomputeCanSave);
    phoneNumberController.addListener(_recomputeCanSave);
    emailController.addListener(_recomputeCanSave);

    ever<String?>(gender, (_) => _recomputeCanSave());
    ever<int?>(selectedNationalityId, (_) => _recomputeCanSave());
    ever<File?>(image, (_) => _recomputeCanSave());

    fetchUserMe();
    fetchNationalities();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneNumberController.dispose();
    emailController.dispose();
    super.onClose();
  }

  int _currentGenderCode() {
    if (gender.value == 'male'.tr) return 1;
    if (gender.value == 'female'.tr) return 2;
    return 0;
  }

  void _captureInitialSnapshot() {
    _initialName = nameController.text.trim();
    _initialPhone = phoneNumberController.text.trim();
    _initialEmail = emailController.text.trim();
    _initialGenderCode = _currentGenderCode();
    _initialNationalityId = selectedNationalityId.value ?? 0;
    _hasInitialSnapshot = true;
    canSave.value = false;
  }

  void _recomputeCanSave() {
    if (!_hasInitialSnapshot) {
      canSave.value = false;
      return;
    }

    final hasChanged =
        nameController.text.trim() != _initialName ||
        phoneNumberController.text.trim() != _initialPhone ||
        emailController.text.trim() != _initialEmail ||
        _currentGenderCode() != _initialGenderCode ||
        (selectedNationalityId.value ?? 0) != _initialNationalityId ||
        image.value != null;

    canSave.value = hasChanged;
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
      debugPrint("Error fetching nationalities: $e");
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
      phoneNumberController.text = CheckInput.formatPhoneNumber(
        user.body?.telephone ?? '',
      );
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

      _captureInitialSnapshot();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
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
            SimpleResponse? response;
            Loading().loadingShow();
            try {
              response = await Get.find<AuthUseCase>().profileUpdate(
                name: nameController.text,
                telephone:
                    phoneNumberController.text.isEmpty
                        ? null
                        : phoneNumberController.text.replaceAll(' ', ''),
                email:
                    emailController.text.isEmpty ? null : emailController.text,
                filename: imagePath.value,
                gender:
                    gender.value == 'male'.tr
                        ? 1
                        : gender.value == 'female'.tr
                        ? 2
                        : 0,
                nationalityId: selectedNationalityId.toInt(),
              );
            } catch (e) {
              debugPrint('Error updating profile: $e');
            } finally {
              Loading().loadingClose();
            }

            if (response != null &&
                response.header?.result == true &&
                response.header?.statusCode == 200 &&
                response.body?.status == true) {
              // Update static values
              ValueStatic.username = nameController.text;
              ValueStatic.phone = phoneNumberController.text.replaceAll(
                ' ',
                '',
              );
              ValueStatic.email = emailController.text;
              ValueStatic.gender =
                  gender.value == 'male'.tr
                      ? 1
                      : gender.value == 'female'.tr
                      ? 2
                      : 0;
              ValueStatic.nationalityId = selectedNationalityId.toInt()!;
              ValueStatic.nationalityName = selectedNationality.value!;

              // Refresh global user store so other screens react immediately
              try {
                if (Get.isRegistered<UserController>()) {
                  final userController = Get.find<UserController>();
                  await userController.fetchUserMe();
                  userMeResponse.value = userController.userMeResponse.value;
                }
              } catch (_) {}

              image.value = null;
              imagePath.value = null;
              _captureInitialSnapshot();

              // Ensure the loading dialog is fully closed before popping the profile screen
              int attempts = 0;
              while (Get.isDialogOpen == true && attempts < 10) {
                await Future.delayed(const Duration(milliseconds: 50));
                attempts++;
              }
            

              // A brief delay to let GetX route transitions settle and guarantee the screen is popped correctly
              await Future.delayed(const Duration(milliseconds: 100));

              Get.back(result: true);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.snackbar(
                  '',
                  '',
                  snackPosition: SnackPosition.TOP,
                  snackStyle: SnackStyle.FLOATING,
                  backgroundColor: Colors.white,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  borderRadius: 16,
                  boxShadows: [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 18,
                      offset: Offset(0, 10),
                    ),
                  ],
                  leftBarIndicatorColor: Colors.green,
                  duration: const Duration(seconds: 2),
                  animationDuration: const Duration(milliseconds: 450),
                  isDismissible: true,
                  dismissDirection: DismissDirection.horizontal,
                  titleText: Row(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutBack,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0x1A16A34A),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.check,
                            color: Color(0xFF16A34A),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'pf_success'.tr,
                              style: const TextStyle(
                                color: Color(0xFF16A34A),
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'update_profile'.tr,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  messageText: const SizedBox.shrink(),
                );
              });
            } else {
              final errorMsg =
                  response?.body?.message ?? 'something_went_wrong'.tr;
              alertDialogOneButton(
                title: 'information'.tr,
                description: errorMsg,
                buttonText: 'yes'.tr,
              );
            }
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
    Loading().loadingShow();
    try {
      if (!Get.isRegistered<ProfileNetworkRequest>()) {
        Get.lazyPut(
          () => ProfileNetworkRequest(
            NetworkDataSource(baseUrl: BaseUrl.BASE_URL_UPLOAD_IMAGE),
          ),
          fenix: true,
        );
      }

      final registerImageResponse = await Get.find<ProfileNetworkRequest>()
          .uploadUserProfilePhoto(
            context: Get.context!,
            filePath: filepath.path,
          );
      Loading().loadingClose();

      if (registerImageResponse.img != null &&
          registerImageResponse.img!.isNotEmpty) {
        imagePath.value = registerImageResponse.img;
        image.value = filepath;
      } else {
        alertDialogOneButton(
          title: 'Information',
          description: 'Upload photo failed',
          buttonText: 'yes'.tr,
        );
      }
    } catch (e) {
      Loading().loadingClose();
      alertDialogOneButton(
        title: 'Error',
        description: 'Failed to upload image.',
        buttonText: 'ok'.tr,
      );
    }
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
