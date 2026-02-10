import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/ev_charger.dart';
import '../../models/destination/destination_ev.dart';
import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';

class EvProvinceSelectionScreen extends StatefulWidget {
  const EvProvinceSelectionScreen({super.key});

  @override
  State<EvProvinceSelectionScreen> createState() => _EvProvinceSelectionScreenState();
}

class _EvProvinceSelectionScreenState extends State<EvProvinceSelectionScreen> {
  late Future<DestinationEvResponse> futureProvinces;
  final TextEditingController _searchController = TextEditingController();
  List<BodyEv> _allProvinces = [];
  List<BodyEv> _filteredProvinces = [];

  @override
  void initState() {
    super.initState();
    futureProvinces = EvChargerList().getProvinceEV(context);
    _searchController.addListener(_filterProvinces);
  }

  /// Filter provinces based on search query
  void _filterProvinces() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredProvinces = _allProvinces;
      } else {
        _filteredProvinces =
            _allProvinces.where((province) {
              final name = province.name?.toLowerCase() ?? '';
              return name.contains(query);
            }).toList();
      }
    });
  }

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
  void _onProvinceSelected(BodyEv province) {
    Navigator.pop(context, {
      'id': province.id!.toString(),
      'name': _localizedProvinceName(province),
    });
  }

  /// Build province item
  Widget _buildProvinceItem(BodyEv province) {
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
      onTap: () => _onProvinceSelected(province),
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
          Text('data_not_found'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'select_province'.tr),
      body: FutureBuilder<DestinationEvResponse>(
        future: futureProvinces,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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

          if (snapshot.data?.body == null || snapshot.data!.body!.isEmpty) {
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

          // Initialize provinces data
          if (_allProvinces.isEmpty) {
            _allProvinces = snapshot.data!.body!;
            _filteredProvinces = _allProvinces;
          }

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
                    decoration: InputDecoration(
                      hintText: "search_province".tr,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              // Results
              Expanded(
                child:
                    _filteredProvinces.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredProvinces.length,
                          itemBuilder: (context, index) {
                            return _buildProvinceItem(_filteredProvinces[index]);
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
