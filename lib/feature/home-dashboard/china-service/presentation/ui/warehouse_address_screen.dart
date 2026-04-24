import 'package:express_vet/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/feature/home-dashboard/china-service/presentation/controller/china_controller.dart';
import 'package:express_vet/feature/home-dashboard/china-service/presentation/ui/registration_screen.dart';
import '../../../../../models/china/customer_china_response.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../routes/app_routes.dart';

class WarehouseAddressScreen extends GetView<ChinaController> {
  WarehouseAddressScreen({super.key});

  final RxMap<String, bool> _copiedItems = <String, bool>{}.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Obx(() {
        final customer = controller.state.selectedCustomer;

        if (customer == null && !controller.hasCustomers) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.off(() => ChinaRegistrationScreen());
          });
          return _buildLoading();
        }

        if (customer == null && controller.hasCustomers) {
          controller.selectCustomer(controller.state.customerList.first);
          if (!controller.hasWarehouses && !controller.state.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              controller.fetchWarehouseList(controller.state.transportType);
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
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      leading: IconButton(
        icon: const Icon(Ionicons.chevron_back_outline, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      centerTitle: true,
      title: Text(
        'access_address_china'.tr,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildContent(CustomerChinaListData customer) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Contact Info Section
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
                    // GestureDetector(
                    //   onTap: () => Get.toNamed(AppRoutes.chinaEditInfo),
                    //   child: const Icon(
                    //     MaterialCommunityIcons.square_edit_outline,
                    //     color: Colors.grey,
                    //     size: 22,
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildContactRow(AssetImages.phone, customer.telephone ?? ''),
                _buildContactRow(
                  AssetImages.building,
                  customer.branchName ?? '',
                ),
                _buildContactRow(AssetImages.location, customer.address ?? ''),
              ],
            ),
          ),
          const SizedBox(height: 12), // Grey divider space
          // Warehouse Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'warehouse_address_by'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTransportModeSelector(),
                const SizedBox(height: 24),
                _buildWarehouseDetails(customer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(String imagePath, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Using Image.asset instead of Icon
          Image.asset(
            imagePath,
            width: 18,
            height: 18,
            // ColorFilter ensures the PNG behaves like a monochrome icon
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

  Widget _buildTransportModeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTransportButton('land'.tr, 1),
          _buildTransportButton('sea'.tr, 2),
          _buildTransportButton('air'.tr, 3),
        ],
      ),
    );
  }

  Widget _buildTransportButton(String label, int type) {
    return Obx(() {
      final isSelected = controller.transportType.value == type;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.updateTransportMode(type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              // border: isSelected ? null : Border.all(color: Colors.grey[400]!),
              border: Border.all(color: AppColors.primaryColor),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildWarehouseDetails(CustomerChinaListData customer) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!controller.hasWarehouses && !controller.isLoading.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.fetchWarehouseList(controller.transportType.value);
        });
        return const Center(child: CircularProgressIndicator());
      }

      final warehouse = controller.selectedWarehouse.value;
      if (warehouse == null) return _buildNoWarehouseData();

      return Column(
        children: [
          _buildCopyableField(
            'warehouse_name'.tr,
            // warehouse.name ?? ''
            'Vet Livhong',
          ),
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

  Widget _buildCopyableField(
    String label,
    String value, {
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    maxLines: isLarge ? 3 : 1,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ),
                Obx(() {
                  final isCopied = _copiedItems[value] ?? false;
                  return GestureDetector(
                    onTap: () => _copyToClipboard(value),
                    child: Icon(
                      isCopied
                          ? Ionicons.checkmark_done
                          : MaterialCommunityIcons.content_copy,
                      color: isCopied ? Colors.green : Colors.grey[400],
                      size: 22,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoWarehouseData() {
    return Center(
      child: Text(
        'no_warehouse_data_for_transport'.tr,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _copiedItems[text] = true;
    Future.delayed(
      const Duration(seconds: 2),
      () => _copiedItems[text] = false,
    );
  }
}
