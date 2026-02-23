import 'package:express_vet/feature/home-dashboard/china-service/presentation/controller/china_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

import '../../../../../models/china/province_response.dart';
import '../../../../../utils/app_colors.dart';

class BranchSelectionScreen extends StatefulWidget {
  final ProvinceBody province;

  const BranchSelectionScreen({super.key, required this.province});

  @override
  State<BranchSelectionScreen> createState() => _BranchSelectionScreenState();
}

class _BranchSelectionScreenState extends State<BranchSelectionScreen> {
  final ChinaController controller = Get.find();
  final _searchController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBranches();
    });
  }

  Future<void> _loadBranches() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await controller.selectProvince(widget.province);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'select_branch'.tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (controller.isBranchSelected)
            TextButton(
              onPressed: () {
                controller.clearBranchSelection();
                Get.back();
              },
              child: Text('clear'.tr),
            ),
        ],
      ),

      body: Obx(() {
        if (controller.isLoading.value && !controller.hasBranches) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.hasBranches) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 60, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'no_branches_available'.tr,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadBranches,
                  child: Text('retry'.tr),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // --- Styled Search Bar (Matches Province Screen) ---
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => controller.searchBranches(value),
                  decoration: InputDecoration(
                    hintText: 'search_branch'.tr,
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
                onRefresh:
                    () =>
                        controller.loadBranches(widget.province.id!.toString()),
                child: _buildBranchList(),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBranchList() {
    if (controller.filteredBranches.isEmpty &&
        controller.branchSearchText.value.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'no_branches_found'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: controller.filteredBranches.length,
      separatorBuilder:
          (context, index) =>
              Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
      itemBuilder: (context, index) {
        final branch = controller.filteredBranches[index];
        final isSelected = controller.selectedBranch.value?.id == branch.id;

        return Container(
          color: isSelected ? Colors.orange[50] : Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 8,
            ),
            leading: const Icon(
              Icons.business,
              color: Color(0xFFD35F27),
              size: 20,
            ),
            title: Text(
              branch.name ?? '',
              style: TextStyle(
                fontSize: 15,
                color: isSelected ? const Color(0xFFD35F27) : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
              ),
            ),
            trailing:
                isSelected
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
            onTap: () {
              controller.selectBranch(branch);
              Get.back();
              Get.back();
            },
          ),
        );
      },
    );
  }
}
