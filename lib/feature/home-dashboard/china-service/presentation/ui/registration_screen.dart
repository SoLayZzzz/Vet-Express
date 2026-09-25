import 'package:express_vet/components/input_text_field.dart';
import 'package:express_vet/feature/home-dashboard/china-service/presentation/controller/china_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../../utils/check_input.dart';

import '../../../../../utils/app_colors.dart';
import '../../../../../utils/button.dart';
import '../../../../../value_statics.dart';
import 'province_selection_screen.dart';
import '../../../../../models/china/list_by_province.dart';
import 'warehouse_address_screen.dart';

class ChinaRegistrationScreen extends StatefulWidget {
  const ChinaRegistrationScreen({super.key});

  @override
  State<ChinaRegistrationScreen> createState() => _ChinaRegistrationScreenState();
}

class _ChinaRegistrationScreenState extends State<ChinaRegistrationScreen> {
  final ChinaController controller = Get.find<ChinaController>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  void _clearControllerState() {
    controller.name.value = '';
    controller.phone.value = '';
    controller.address.value = '';
    controller.errorMessage.value = '';
    controller.clearAllSelections();
  }

  void _clearFormData() {
    _clearControllerState();

    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: controller.name.value);
    _phoneController = TextEditingController(text: controller.phone.value);
    _addressController = TextEditingController(text: controller.address.value);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearControllerState();
      _nameController.clear();
      _phoneController.clear();
      _addressController.clear();

      if (!controller.hasProvinces && !controller.isLoading.value) {
        controller.fetchInitialData();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clearControllerState();
    });

    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (didPop) {
          _clearControllerState();
        }
      },
      child: Scaffold(
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
              _clearFormData();
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
          if (controller.state.isLoading && !controller.hasProvinces) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildRegistrationForm();
        }),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
          children: [
            const SizedBox(height: 16),

            _buildTextField(
              label: 'full_name'.tr,
              hint: 'full_name'.tr,
              controller: _nameController,
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'fullname_required'.tr
                          : null,
              onChanged: (value) => controller.name.value = value,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              label: 'phone_number'.tr,
              hint: 'phone_number'.tr,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [PhoneNumberFormatter()],
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'phoneNumber_reuired'.tr
                          : null,
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
              validator:
                  (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'address_required'.tr
                          : null,
              onChanged: (value) => controller.address.value = value,
            ),

            const SizedBox(height: 20),

            // Error message (only for immediate validation errors)
            if (controller.errorMessage.value.isNotEmpty &&
                !controller.isLoading.value)
              _buildErrorMessage(),

            const SizedBox(height: 20),

            // Register button
            Obx(() {
              return AbsorbPointer(
                absorbing: controller.isLoading.value,
                child: Opacity(
                  opacity: controller.isLoading.value ? 0.7 : 1,
                  child: globalButton(
                    context: Get.context!,
                    buttonText: 'register_china_address'.tr,
                    onPressed: () async {
                  // Clear any previous error message
                  controller.errorMessage.value = '';

                  // Validate form fields — shows inline red errors
                  if (!(_formKey.currentState?.validate() ?? false)) {
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
                  ),
                ),
              );
            }),
          ],
          ),
        ),
      ),
    );
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
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 28,
                          ),
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
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
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
            child: Text(
              controller.errorMessage.value,
              style: const TextStyle(color: Colors.red),
            ),
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
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return InputTextField(
      label: label,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        color: AppColors.mainTitle,
        // fontSize: 16,
        fontSize: 14,
      ),
      hint: hint,
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
    );
  }


  Widget _buildBranchField() {
    Future<void> openSelection() async {
      final selectedBranch =
          await Get.to<BranchByProvinceData?>(() => ProvinceSelectionScreen());

      if (selectedBranch != null) {
        controller.selectBranch(selectedBranch);
      }
      _formKey.currentState?.validate();
    }

    void clearSelection() {
      controller.clearAllSelections();
      _formKey.currentState?.validate();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final isSelected = controller.isBranchSelected;
          final displayText =
              controller.isProvinceSelected || controller.isBranchSelected
                  ? _getBranchDisplayText()
                  : '';

          return InputTextField(
            key: ValueKey(displayText),
            label: 'vet_branch_near_you'.tr,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.titleColor,
              // fontSize: 16,
              fontSize: 14,
            ),
            hint: 'vet_branch_near_you'.tr,
            initialValue: displayText.isEmpty ? null : displayText,
            readOnly: true,
            showCursor: false,
            iconRight: isSelected ? Icons.close : Icons.keyboard_arrow_down,
            iconRightSize: 20,
            iconRightColor: isSelected ? AppColors.textColor : Colors.grey,
            onTap: openSelection,
            onIconRightPressed: isSelected ? clearSelection : openSelection,
            validator: (_) {
              return controller.state.selectedBranch == null
                  ? 'vetbranch_required'.tr
                  : null;
            },
          );
        }),
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
    final selectedBranch = controller.state.selectedBranch;
    if (selectedBranch != null) {
      return selectedBranch.name ?? '';
    }

    final selectedProvince = controller.state.selectedProvince;
    if (selectedProvince != null) {
      return selectedProvince.name ?? '';
    }

    return 'vet_branch_near_you'.tr;
  }
}
