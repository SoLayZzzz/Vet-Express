import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../controller/china/china_controller.dart';
import '../../utils/app_colors.dart';
import '../ticket/value_statics.dart';
import 'province_selection_screen.dart';
import 'warehouse_address_screen.dart';

class ChinaRegistrationScreen extends StatelessWidget {
  ChinaRegistrationScreen({super.key});

  final ChinaController controller = Get.put(ChinaController());
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor:
            ValueStatic.ticketType == '3' ? AppColors.airBusColor : AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back_outline, color: AppColors.whiteColor),
          onPressed: () {
            controller.clearAllSelections();
            Get.back();
          },
        ),
        centerTitle: true,
        title: Text(
          'access_address_china'.tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && !controller.hasProvinces) {
          return const Center(child: CircularProgressIndicator());
        }

        return _buildRegistrationForm();
      }),
    );
  }

  Widget _buildRegistrationForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 16),

            _buildTextField(
              label: 'full_name'.tr,
              hint: 'full_name'.tr,
              controller: _nameController,
              onChanged: (value) => controller.name.value = value,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'phone_number'.tr,
              hint: 'phone_number'.tr,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onChanged: (value) => controller.phone.value = value,
            ),
            const SizedBox(height: 16),

            _buildBranchField(),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'address'.tr,
              hint: 'address'.tr,
              controller: _addressController,
              maxLines: 3,
              onChanged: (value) => controller.address.value = value,
            ),

            const SizedBox(height: 20),

            // Error message (only for immediate validation errors)
            if (controller.errorMessage.value.isNotEmpty && !controller.isLoading.value)
              _buildErrorMessage(),

            const SizedBox(height: 20),

            // Register button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed:
                    controller.isLoading.value
                        ? null
                        : () async {
                          // Clear any previous error message
                          controller.errorMessage.value = '';

                          // First, validate form fields
                          final validationError = _validateForm();
                          if (validationError.isNotEmpty) {
                            // Show dialog for validation errors
                            _showErrorDialog(validationError);
                            return;
                          }

                          // Attempt registration
                          final success = await controller.registerCustomer();
                          if (success) {
                            // Navigate to warehouse screen
                            Get.off(() => WarehouseAddressScreen());
                          } else {
                            // Show error dialog for registration failure
                            if (controller.errorMessage.value.isNotEmpty) {
                              _showErrorDialog(controller.errorMessage.value);
                            }
                          }
                        },
                child:
                    controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          'register_china_address'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Validate form fields
  String _validateForm() {
    if (controller.name.value.isEmpty) {
      return 'please_enter_full_name'.tr;
    }
    if (controller.phone.value.isEmpty) {
      return 'please_enter_phone_number'.tr;
    }
    if (controller.selectedBranch.value == null) {
      return 'please_select_branch_near_you'.tr;
    }
    if (controller.address.value.isEmpty) {
      return 'please_enter_address'.tr;
    }
    return '';
  }

  // Show error dialog using your existing style
  void _showErrorDialog(String errorMessage) {
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title with error icon
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 28),
                          SizedBox(width: 8),
                          Text(
                            'registration_failed'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.titleColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error message
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25.0),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textColor),
                      ),
                    ),

                    // Single button
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color:
                              ValueStatic.ticketType == '3'
                                  ? AppColors.airBusColor
                                  : AppColors.primaryColor,
                        ),
                        child: Center(
                          child: Text(
                            'ok'.tr,
                            style: TextStyle(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      barrierDismissible: false,
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => controller.errorMessage.value = '',
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.titleColor,
              fontSize: 16,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (value) {
            onChanged(value);
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.textColor,
              fontSize: 14,
            ),
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.all(14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: const Color(0xFFD35F27)),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: 'vet_branch_near_you'.tr,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.titleColor,
              fontSize: 16,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            Get.to(() => ProvinceSelectionScreen());
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: controller.isBranchSelected ? 2 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: /*controller.isBranchSelected ? const Color(0xFFD35F27) :*/
                    Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      _getBranchDisplayText(),
                      style: TextStyle(
                        color: controller.isBranchSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                Obx(
                  () =>
                      controller.isBranchSelected
                          ? IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              controller.clearAllSelections();
                            },
                          )
                          : const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () =>
              controller.isProvinceSelected &&
                      !controller.isBranchSelected &&
                      controller.hasBranches
                  ? Text(
                    'please_select_branch_from'.tr,
                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                  )
                  : const SizedBox(),
        ),
      ],
    );
  }

  String _getBranchDisplayText() {
    if (controller.isBranchSelected) {
      return controller.selectedBranch.value!.name ?? '';
    } else if (controller.isProvinceSelected) {
      return controller.selectedProvince.value!.name ?? '';
    }
    return 'vet_branch_near_you'.tr;
  }
}
