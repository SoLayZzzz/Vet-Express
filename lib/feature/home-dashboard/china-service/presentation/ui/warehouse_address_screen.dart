import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/home-dashboard/china-service/presentation/controller/china_controller.dart';
import 'package:express_vet/feature/home-dashboard/china-service/presentation/ui/registration_screen.dart';
import 'package:express_vet/models/china/customer_china_response.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/check_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class WarehouseAddressScreen extends GetView<ChinaController> {
  WarehouseAddressScreen({super.key});

  final RxMap<String, bool> _copiedItems = <String, bool>{}.obs;
  final RxBool _didLoadCustomers = false.obs;
  final RxSet<int> _warehouseRequestedTypes = <int>{}.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        final customer = controller.selectedCustomer.value;

        if (customer == null) {
          if (!_didLoadCustomers.value) {
            _didLoadCustomers.value = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!controller.isLoading.value && controller.customerList.isEmpty) {
                controller.fetchCustomerList();
              }
            });
            return _buildLoading();
          }

          if (controller.isLoading.value) {
            return _buildLoading();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return _buildError(controller.errorMessage.value);
          }

          if (!controller.hasCustomers) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.off(() => ChinaRegistrationScreen());
            });
            return _buildLoading();
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.selectCustomer(controller.customerList.last);
          });
          return _buildLoading();
        }

        final type = controller.transportType.value;
        if (!_warehouseRequestedTypes.contains(type) && !controller.isLoading.value) {
          _warehouseRequestedTypes.add(type);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.fetchWarehouseList(type);
          });
        }

        return _buildContent(customer);
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0.2,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(
          Ionicons.chevron_back_outline,
          color: AppColors.whiteColor,
        ),
        onPressed: () {
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
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.fetchCustomerList();
              },
              child: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(CustomerChinaListData customer) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Customer details
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'contact_information'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      customer.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildContactRow(
                  AssetImages.ic_phone_china,
                  CheckInput.formatPhoneNumber(customer.telephone ?? ''),
                ),
                _buildContactRow(
                  AssetImages.ic_bussness_ountline,
                  customer.branchName ?? '',
                ),
                _buildContactRow(
                  AssetImages.ic_map_pin,
                  customer.address ?? '',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// Warehouse details (China)
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('warehouse_address_by'.tr),
                const SizedBox(height: 12),
                _buildTransportModeSelector(),
                const SizedBox(height: 24),
                _buildWarehouseDetails(customer),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Warehouse details (Cambodia)
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('warehouse_address_cambodia'.tr),
                const SizedBox(height: 16),
                _buildCopyableField(
                  'warehouse_phone'.tr,
                  '098880456',
                  showCallIcon: true,
                  showCopyIcon: false,
                ),
                InkWell(
                  onTap: () async {
                    final url = Uri.parse('https://t.me/+85598880456');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(Get.context!).showSnackBar(
                        SnackBar(content: Text('can_not_open_telegram'.tr)),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.telegram, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'telegram_support'.tr,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: Color(0xFF333333),
      ),
    );
  }

  Widget _buildContactRow(String imagePath, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Image.asset(
            imagePath,
            width: 20,
            height: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseDetails(CustomerChinaListData customer) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final warehouse = controller.selectedWarehouse.value;
      if (warehouse == null) {
        return _buildNoWarehouseData();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCopyableField('customer_code'.tr, customer.code ?? ''),
          _buildCopyableField('warehouse_phone'.tr, warehouse.telephone ?? ''),
          _buildCopyableField(
            'address'.tr,
            warehouse.address ?? '',
            isLarge: true,
          ),
        ],
      );
    });
  }

  Widget _buildNoWarehouseData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'no_warehouse_data_for_transport'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCopyableField(
    String label,
    String value, {
    bool isLarge = false,
    bool showCallIcon = false,
    bool showCopyIcon = true,
  }) {
    final isCopied = _copiedItems[value] ?? false;
    final canCall = showCallIcon && value.trim().isNotEmpty;
    final canCopy = showCopyIcon && value.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: isLarge ? 12 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment:
                  isLarge ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: isLarge ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                if (canCall)
                  GestureDetector(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Center(
                        child: Image.asset(
                          'assets/icons/phone.png',
                          width: 20,
                          height: 20,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    onTap: () {
                      _callPhoneNumber(value);
                    },
                  ),
                if (canCopy)
                  GestureDetector(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: Icon(
                        isCopied
                            ? Ionicons.checkmark_outline
                            : Ionicons.copy_outline,
                        color: isCopied ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ),
                    onTap: () {
                      _copyToClipboard(value);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTransportModeButton('land'.tr, 1),
          _buildTransportModeButton('sea'.tr, 2),
          _buildTransportModeButton('air'.tr, 3),
        ],
      ),
    );
  }

  Widget _buildTransportModeButton(String mode, int type) {
    return Obx(() {
      final isSelected = controller.transportType.value == type;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            if (controller.isLoading.value || isSelected) return;
            _warehouseRequestedTypes.add(type);
            controller.updateTransportMode(type);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color:
                  isSelected ? const Color(0xFFD35F27) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD35F27), width: 1),
            ),
            child: Center(
              child: Text(
                mode,
                style: TextStyle(
                  color:
                      isSelected ? AppColors.whiteColor : AppColors.titleColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _copiedItems[text] = true;
    Future.delayed(const Duration(milliseconds: 2500), () {
      _copiedItems[text] = false;
    });
  }

  Future<void> _callPhoneNumber(String phoneNumber) async {
    final sanitized = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (sanitized.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: sanitized);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
