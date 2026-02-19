import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../models/destination/destination_ev.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../controller/ev_charger_controller.dart';

class EvProvinceSelectionScreen extends GetView<EvChargerController> {
  EvProvinceSelectionScreen({super.key});

  final TextEditingController _searchController = TextEditingController();

  /// Get localized province name based on locale
  String _localizedProvinceName(BodyEv province) {
    final locale = Get.locale?.toString() ?? '';

    if (locale == 'km_KH') {
      return province.nameKh ?? 'Unknown Province';
    } else if (locale == 'en_US') {
      return province.name ?? 'Unknown Province';
    } else {
      return province.nameCn ?? 'Unknown Province';
    }
  }

  /// Handle province selection
  void _onProvinceSelected(BuildContext context, BodyEv province) {
    Navigator.pop(context, {
      'id': province.id!.toString(),
      'name': _localizedProvinceName(province),
    });
  }

  /// Build province item
  Widget _buildProvinceItem(BuildContext context, BodyEv province) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.location_on, color: AppColors.primaryColor),
      ),
      title: Text(
        _localizedProvinceName(province),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _onProvinceSelected(context, province),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/ev_no-data.png', width: 80, height: 80),
          const SizedBox(height: 16),
          Text(
            'data_not_found'.tr,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.loadTicketProvincesIfNeeded();

    if (_searchController.text != controller.state.ticketProvinceSearchQuery) {
      _searchController.text = controller.state.ticketProvinceSearchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Scaffold(
      appBar: AppBarVET().appBar(context, 'select_province'.tr),
      body: Obx(() {
        if (controller.state.isLoadingTicketProvinces &&
            controller.state.ticketProvinces.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.state.hasErrorTicketProvinces) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('failed_to_load_provinces'.tr),
              ],
            ),
          );
        }

        if (controller.state.ticketProvinces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text('no_provinces_available'.tr),
              ],
            ),
          );
        }

        final provinces = controller.filteredTicketProvinces;

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: controller.updateProvinceSearchQuery,
                  decoration: InputDecoration(
                    hintText: "search_province".tr,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        controller.state.ticketProvinceSearchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                controller.updateProvinceSearchQuery('');
                              },
                            )
                            : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Results
            Expanded(
              child:
                  provinces.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: provinces.length,
                        itemBuilder: (context, index) {
                          return _buildProvinceItem(context, provinces[index]);
                        },
                      ),
            ),
          ],
        );
      }),
    );
  }
}
