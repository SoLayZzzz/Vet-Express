import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/model/response/ev_charger_response.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../controller/ev_charger_controller.dart';

class SearchEvScreen extends GetView<EvChargerController> {
  final List<BodyEV> allStations;

  SearchEvScreen({super.key, required this.allStations});

  final TextEditingController _searchController = TextEditingController();

  void _onStationSelected(BuildContext context, BodyEV station) {
    Navigator.pop(context, station);
  }

  Widget _buildStationItem(BuildContext context, BodyEV station) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.ev_station, color: AppColors.primaryColor),
      ),
      title: Text(
        station.name ?? "Unknown Station",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle:
          station.address != null
              ? Text(
                station.address!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _onStationSelected(context, station),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/ev_no-data.png', width: 80, height: 80),
          const SizedBox(height: 16),
          Text(
            'data_not_found'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.setStationSearchSource(allStations);

    if (_searchController.text != controller.state.stationSearchQuery) {
      _searchController.text = controller.state.stationSearchQuery;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    }

    return Scaffold(
      appBar: AppBarVET().appBar(context, "search_station".tr),
      body: Column(
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
                onChanged: controller.updateStationSearchQuery,
                decoration: InputDecoration(
                  hintText: "search_station".tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      controller.state.stationSearchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              controller.updateStationSearchQuery('');
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
            child: Obx(() {
              final hasSearched =
                  controller.state.stationSearchQuery.isNotEmpty;
              final stations = controller.filteredStations;

              if (hasSearched && stations.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  return _buildStationItem(context, stations[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
