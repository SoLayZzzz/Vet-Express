import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../../models/china/customer_china_response.dart';

class EditChinaAddressScreen extends StatefulWidget {
  const EditChinaAddressScreen({super.key});

  @override
  State<EditChinaAddressScreen> createState() => _EditChinaAddressScreenState();
}

class _EditChinaAddressScreenState extends State<EditChinaAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers with your initial text from the screenshot
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  final RxString _selectedBranch = ''.obs;
  final List<String> _branches = ['ជ្រោយចង្វារ PP', 'Branch B', 'Branch C'];

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    final CustomerChinaListData? customer =
        args is CustomerChinaListData ? args : null;

    _nameController = TextEditingController(text: customer?.name ?? '');
    _phoneController = TextEditingController(
      text: _formatPhoneNumber(customer?.telephone ?? ''),
    );
    _addressController = TextEditingController(text: customer?.address ?? '');

    final branchName = customer?.branchName;
    if (branchName != null && branchName.trim().isNotEmpty) {
      if (!_branches.contains(branchName)) {
        _branches.insert(0, branchName);
      }
      _selectedBranch.value = branchName;
    } else {
      _selectedBranch.value = _branches.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFD35F27),
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back_outline, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Edit Access Address China',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Full name'),
              _buildTextField(_nameController),

              const SizedBox(height: 20),
              _buildLabel('Phone number'),
              _buildTextField(
                _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  _PhoneNumberSpacingFormatter(),
                ],
              ),

              const SizedBox(height: 20),
              _buildLabel('VET branch near you'),
              _buildDropdownField(),

              const SizedBox(height: 20),
              _buildLabel('address'.tr),
              _buildTextField(_addressController, isMultiline: true),

              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    bool isMultiline = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: isMultiline ? 4 : 1,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD35F27)),
        ),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBranch.value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD35F27)),
        ),
      ),
      items:
          _branches.map((String branch) {
            return DropdownMenuItem(value: branch, child: Text(branch));
          }).toList(),
      onChanged: (value) {
        _selectedBranch.value = value!;
      },
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          // Add your save logic here
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD35F27),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          'Save',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatPhoneNumber(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    final parts = <String>[];
    for (var i = 0; i < digits.length; i += 3) {
      final end = (i + 3 < digits.length) ? i + 3 : digits.length;
      parts.add(digits.substring(i, end));
    }
    return parts.join(' ');
  }
}

class _PhoneNumberSpacingFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && i % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
