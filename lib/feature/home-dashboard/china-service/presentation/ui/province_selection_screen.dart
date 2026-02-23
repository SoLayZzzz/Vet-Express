import 'package:express_vet/feature/home-dashboard/china-service/presentation/controller/china_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../../utils/app_colors.dart';
import 'branch_selection_screen.dart';

class ProvinceSelectionScreen extends StatelessWidget {
  ProvinceSelectionScreen({super.key});

  final ChinaController controller = Get.find();
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'select_province'.tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (controller.isProvinceSelected)
            TextButton(
              onPressed: () {
                controller.clearAllSelections();
                Get.back();
              },
              child: Text('clear'.tr),
            ),
        ],
      ),
      body: Obx(() {
        if (controller.state.isLoading && !controller.hasProvinces) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasProvinces) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'no_provinces_available'.tr,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.fetchInitialData(),
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // --- Styled Search Bar ---
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => controller.searchProvinces(value),
                  decoration: InputDecoration(
                    hintText: 'search'.tr,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    suffixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.fetchInitialData(),
                child: _buildProvinceList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProvinceList() {
    if (controller.filteredProvinces.isEmpty &&
        controller.provinceSearchText.value.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'no_provinces_found'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: controller.filteredProvinces.length,
      separatorBuilder:
          (context, index) => const Divider(height: 1, thickness: 1),
      itemBuilder: (context, index) {
        final province = controller.filteredProvinces[index];
        final isSelected = controller.selectedProvince.value?.id == province.id;

        return Container(
          color: isSelected ? Colors.orange[50] : Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            title: Text(
              province.name ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing:
                isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
            onTap: () {
              if (controller.selectedProvince.value?.id != province.id) {
                controller.clearBranchData();
              }
              Get.to(() => BranchSelectionScreen(province: province));
            },
          ),
        );
      },
    );
  }
}
