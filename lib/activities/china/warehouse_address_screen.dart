import 'package:express_vet/activities/china/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../controller/china/china_controller.dart';
import '../../models/china/customer_china_response.dart';
import '../../utils/app_colors.dart';

class WarehouseAddressScreen extends StatelessWidget {
  WarehouseAddressScreen({super.key});

  final ChinaController controller = Get.put(ChinaController());
  final RxMap<String, bool> _copiedItems = <String, bool>{}.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Obx(() {
        final customer = controller.selectedCustomer.value;

        if (customer == null && !controller.hasCustomers) {
          // If no customers, automatically navigate to registration
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.off(() => ChinaRegistrationScreen());
          });
          return _buildLoading();
        }

        if (customer == null && controller.hasCustomers) {
          // Auto-select first customer
          controller.selectCustomer(controller.customerList.first);

          // Check if warehouse data needs to be fetched
          if (!controller.hasWarehouses && !controller.isLoading.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.fetchWarehouseList(controller.transportType.value);
            });
          }

          return _buildContent(customer!);
        }

        return _buildContent(customer!);
      }),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0.2,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Ionicons.chevron_back_outline, color: AppColors.whiteColor),
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

  Widget _buildWarehouseDetails(CustomerChinaListData customer) {
    return Obx(() {
      // Show loading when fetching new data
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final warehouse = controller.selectedWarehouse.value;

      // Check if we need to fetch warehouse data
      if (!controller.hasWarehouses && !controller.isLoading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchWarehouseList(controller.transportType.value);
        });
        return _buildNoWarehouseData();
      }

      // Show warehouse data if available
      if (warehouse != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _buildCopyableField('warehouse_name'.tr, warehouse.name ?? ''),
            _buildCopyableField('customer_code'.tr, customer.code ?? ''),
            _buildCopyableField('warehouse_phone'.tr, warehouse.telephone ?? ''),
            _buildCopyableField('address'.tr, warehouse.address ?? '', isLarge: true),
          ],
        );
      } else if (controller.hasWarehouses) {
        // Has warehouses but none selected (shouldn't happen, but just in case)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildNoWarehouseData()],
        );
      } else {
        // No warehouse data at all
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildNoWarehouseData()],
        );
      }
    });
  }

  Widget _buildNoWarehouseData() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          'no_warehouse_data_for_transport'.tr,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF333333)),
    );
  }

  Widget _buildCopyableField(String label, String value, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: isLarge ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Obx(() {
                  final isCopied = _copiedItems[value] ?? false;
                  return IconButton(
                    icon: Icon(
                      isCopied ? Ionicons.checkmark_outline : Ionicons.copy_outline,
                      color: isCopied ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => _copyToClipboard(value),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportModeSelector() {
    return Container(
      padding: const EdgeInsets.all(10),
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
      bool isSelected = controller.transportType.value == type;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            controller.updateTransportMode(type);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD35F27) : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD35F27), width: 1),
            ),
            child: Center(
              child: Text(
                mode,
                style: TextStyle(
                  color: isSelected ? AppColors.whiteColor : AppColors.titleColor,
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

    // Mark this item as copied
    _copiedItems[text] = true;

    // Reset after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      _copiedItems[text] = false;
    });
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
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact information
                _buildSectionTitle('contact_information'.tr),
                const SizedBox(height: 12),
                _buildInfoField('full_name'.tr, customer.name ?? ''),
                _buildInfoField('phone_number'.tr, customer.telephone ?? ''),
                _buildInfoField('vet_branch_near_you'.tr, customer.branchName ?? ''),
                _buildInfoField('address'.tr, customer.address ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 24),

          /// Warehouse details
          Container(
            color: AppColors.whiteColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transport mode
                _buildSectionTitle('warehouse_address_by'.tr),
                const SizedBox(height: 12),
                _buildTransportModeSelector(),

                const SizedBox(height: 24),

                // Warehouse details - Show based on selected transport mode
                _buildWarehouseDetails(customer),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: isLarge ? 3 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /*
  Widget _buildContent(CustomerChinaListData customer) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        color: const Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Contact Information Section
            Container(
              color: AppColors.whiteColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('contact_information'.tr),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        customer.name ?? '',
                        style: const TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(Ionicons.create_outline, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Phone Number Row
                  _buildContactDetailRow(Ionicons.call_outline, customer.telephone ?? ''),

                  // Branch/Office Row
                  _buildContactDetailRow(Ionicons.business_outline, customer.branchName ?? ''),

                  // Address/Location Row
                  _buildContactDetailRow(Ionicons.location_outline, customer.address ?? ''),
                ],
              ),
            ),

            const SizedBox(height: 12), // Grey divider space
            /// Warehouse details
            Container(
              color: AppColors.whiteColor,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('warehouse_address_by'.tr),
                  const SizedBox(height: 16),
                  _buildTransportModeSelector(),
                  const SizedBox(height: 24),
                  _buildWarehouseDetails(customer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // New helper for the contact list rows
  Widget _buildContactDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
*/
}
