import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../../../../../controller/profile_controller.dart';
import '../../../../auth/data/model/response/nationality_response.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/button.dart';
import '../../../../../utils/check_input.dart';
import '../../../../../utils/style.dart';
import '../../../../../value_statics.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor:
            ValueStatic.ticketType == '3'
                ? AppColors.airBusColor
                : AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        centerTitle: true,
        title: Text(
          "view_pf".tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.userMeResponse.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildUserProfile(controller);
      }),
    );
  }

  Widget _buildUserProfile(ProfileController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileImage(controller),
            _buildTextField('name_pro', controller.nameController, 'name'),
            _buildTextField(
              'phone_number_info',
              controller.phoneNumberController,
              'phone_number_info',
              TextInputType.number,
              CheckInput().validatePhone,
              controller.isTelephoneReadOnly.value,
            ),
            _buildTextField(
              'email',
              controller.emailController,
              'email',
              TextInputType.emailAddress,
              CheckInput().validateEmailAddress,
              controller.isEmailReadOnly.value,
            ),
            _buildDropdownField(
              "gender",
              'gender',
              controller.gender,
              controller.genderItems,
            ),
            _buildDropdownFieldNationality(
              'nationality'.tr,
              'nationality'.tr,
              controller.selectedNationality,
              controller.nationalityList.map((e) => e.name ?? '').toList(),
              (String? newValue) {
                final selected = controller.nationalityList.firstWhere(
                  (e) => e.name == newValue,
                  orElse: () => NationalityResponseData(id: 0, name: ''),
                );
                controller.selectedNationality.value = selected.name;
                controller.selectedNationalityId.value = selected.id;
              },
            ),
            const SizedBox(height: 40),
            _buildSaveButton(controller),
          ],
        ),
      ),
    );
  }

  // Dropdown for gender
  Widget _buildDropdownField(
    String label,
    String hintKey,
    RxnString selectedValue,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: const TextStyle(
              color: AppColors.titleColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value:
                selectedValue.value?.isNotEmpty == true
                    ? selectedValue.value
                    : null,
            hint: Text(
              hintKey.tr,
              style: const TextStyle(fontSize: 14),
            ), // Shows "Select Gender" when value is null
            items:
                items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              selectedValue.value = newValue;
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 10, 5),
              hintText: hintKey.tr,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
            ),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.borderColor,
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown for nationality with search
  Widget _buildDropdownFieldNationality(
    String label,
    String hintKey,
    RxnString selectedValue,
    List<String> items,
    void Function(String?)? onChanged,
  ) {
    final TextEditingController searchController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr,
            style: const TextStyle(
              color: AppColors.titleColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton2<String>(
              isExpanded: true,
              hint: Text(
                hintKey.tr,
                style: const TextStyle(
                  color: AppColors.greyColor,
                  fontSize: 14,
                ),
              ),
              value:
                  selectedValue.value?.isNotEmpty == true &&
                          items.contains(selectedValue.value)
                      ? selectedValue.value
                      : null,
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.only(right: 10, bottom: 5),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderColor,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              iconStyleData: const IconStyleData(
                iconEnabledColor: AppColors.borderColor,
              ),
              dropdownStyleData: const DropdownStyleData(
                width: double.infinity,
              ),
              menuItemStyleData: const MenuItemStyleData(height: 40),
              dropdownSearchData: DropdownSearchData(
                searchController: searchController,
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
                    controller: searchController,
                    decoration: Style.inputText('search_nation'.tr),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  return item.value.toString().toLowerCase().contains(
                    searchValue.toLowerCase(),
                  );
                },
              ),
              onMenuStateChange: (isOpen) {
                if (!isOpen) {
                  searchController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(ProfileController controller) {
    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: controller.showImageSourceOptions,
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.borderColor,
                spreadRadius: 0.5,
                blurRadius: 4.0,
              ),
            ],
          ),
          width: 130,
          height: 130,
          child: ClipOval(
            child:
                controller.image.value == null
                    ? (controller
                                .userMeResponse
                                .value
                                ?.body
                                ?.filename
                                ?.isEmpty ??
                            true
                        ? Image.asset(
                          AssetImages.img_user_profile,
                          fit: BoxFit.cover,
                        )
                        : CachedNetworkImage(
                          imageUrl:
                              controller.userMeResponse.value!.body!.filename!,
                          placeholder: (context, url) => placeHolderImg(),
                          errorWidget:
                              (context, url, error) => placeHolderImg(),
                          fit: BoxFit.cover,
                        ))
                    : Image.file(controller.image.value!, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String labelKey,
    TextEditingController controller,
    String hintKey, [
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool isReadOnly = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelKey.tr,
            style: const TextStyle(
              color: AppColors.titleColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            autofocus: false,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: AppColors.textColor),
            validator: validator,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 10, 5),
              hintText: hintKey.tr,
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.borderColor,
                  width: 1.0,
                ),
              ),
            ),
            onTap: () {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(ProfileController controller) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: globalButton(
        context: Get.context!,
        buttonText: 'save'.tr,
        onPressed: controller.updateProfile,
      ),
    );
  }

  Widget placeHolderImg() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: const Image(
        image: AssetImage(AssetImages.img_user_profile),
        fit: BoxFit.cover,
      ),
    );
  }
}
