import 'dart:async';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_province_response.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_station_list_response.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/ev_station_controller.dart';

import '../../../../../utils/app_colors.dart';

class EvAllStationScreen extends StatefulWidget {
  const EvAllStationScreen({super.key});

  @override
  State<EvAllStationScreen> createState() => _EvAllStationScreenState();
}

class _EvAllStationScreenState extends State<EvAllStationScreen> {
  final EvStationController stationController = Get.put(EvStationController());
  final PanelController _panelController = PanelController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onSearchFocusChanged);
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus) {
      _panelController.open();
    }
  }

  void _onSearchChanged() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == stationController.searchQuery.value) return;
      stationController.searchStations(_searchController.text);
    });
  }

  void _onStationSelected(EvStationListDatum station) {
    if (station.lats != null && station.longs != null) {
      stationController.moveToStation(
        LatLng(double.parse(station.lats!), double.parse(station.longs!)),
      );
    }
    _panelController.animatePanelToPosition(0.0);
  }

  Future<void> _openMap(String lat, String lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error'.tr, 'Could not launch maps'.tr);
    }
  }

  void _showProvinceFilterDialog() {
    showDialog(
      context: context,
      builder:
          (context) =>
              ProvinceFilterDialog(stationController: stationController),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarVET().appBar(context, "ev_station".tr),
      body: Stack(
        children: [
          Obx(() {
            return Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(11.578036036368854, 104.922274625954),
                    zoom: 6,
                  ),
                  markers: stationController.buildMarkers(_onStationSelected),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    stationController.mapController.complete(controller);
                  },
                ),

                // Search Bar
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.02,
                  left: 16,
                  right: 16,
                  child: _buildSearchBar(),
                ),

                // Current Location Button
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).size.height * 0.1,
                  child: FloatingActionButton(
                    heroTag: "location_btn",
                    onPressed: stationController.goToCurrentLocation,
                    backgroundColor: Colors.white,
                    elevation: 4,
                    child: Icon(
                      Icons.my_location,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),

                // Filter Badge (if province is selected)
                if (stationController.selectedProvince.value != null)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.12,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            stationController.selectedProvince.value?.nameEn ??
                                '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: stationController.clearProvinceFilter,
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Search Badge (if searching)
                if (stationController.searchQuery.value.isNotEmpty)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.12,
                    left:
                        stationController.selectedProvince.value != null
                            ? 120
                            : 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"${stationController.searchQuery.value}"',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: stationController.clearSearch,
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Sliding Up Panel
                SlidingUpPanel(
                  controller: _panelController,
                  minHeight: 0,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  panel: _buildStationPanel(),
                  body: Container(),
                  onPanelClosed: () {
                    _searchFocusNode.unfocus();
                  },
                ),
              ],
            );
          }),

          // Favorite Success Animation
          Obx(() {
            if (stationController.showFavoriteAnimation.value) {
              return _buildFavoriteAnimation();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildFavoriteAnimation() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: Colors.black.withOpacity(
            stationController.showFavoriteAnimation.value ? 0.5 : 0.0,
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity:
                  stationController.showFavoriteAnimation.value ? 1.0 : 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Boom Fire Animation with scaling
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    transform:
                        Matrix4.identity()..scale(
                          stationController.showFavoriteAnimation.value
                              ? 1.2
                              : 0.8,
                        ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Success Message with fade-in
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'added_to_favorites'.tr,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stationController.favoriteStationName.value,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              _panelController.open();
              FocusScope.of(context).requestFocus(_searchFocusNode);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: _searchController.text.isNotEmpty ? 0 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'search_station'.tr,
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: const TextStyle(fontSize: 16),
                      onTap: () {
                        _panelController.open();
                      },
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        stationController.clearSearch();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Transform.scale(
          scale: 0.8,
          child: FloatingActionButton(
            heroTag: "provinceBtn",
            onPressed: _showProvinceFilterDialog,
            backgroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: Stack(
              children: [
                const Icon(
                  Icons.filter_alt,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
                if (stationController.selectedProvince.value != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationPanel() {
    return Column(
      children: [
        // Drag handle
        GestureDetector(
          onTap: () {
            _panelController.close();
          },
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ev_station'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _panelController.close();
                },
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Station List
        Expanded(
          child: Obx(() {
            if (stationController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (stationController.hasError.value) {
              return _buildErrorState();
            }

            final stations = stationController.allStations;

            if (stations.isEmpty) {
              if (stationController.searchQuery.value.isNotEmpty ||
                  stationController.selectedProvince.value != null) {
                return _buildNoResultsState();
              }
              return _buildEmptyState();
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: stations.length,
              itemBuilder: (context, index) {
                final station = stations[index];
                return _buildStationCard(station);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStationCard(EvStationListDatum station) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // LEFT SIDE IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&q=80&w=200",
                width: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 110,
                    color: Colors.grey[200],
                    child: const Icon(Icons.ev_station, color: Colors.grey),
                  );
                },
              ),
            ),

            // RIGHT SIDE CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header: Name + Favorite Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            station.name ?? 'Unknown Station',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Facebook-style heart button with instant feedback
                        GetBuilder<EvStationController>(
                          builder: (controller) {
                            return GestureDetector(
                              onTap: () {
                                if (station.id != null) {
                                  // Provide haptic feedback
                                  _vibrate();
                                  controller.toggleFavorite(
                                    station.id!,
                                    station.name ?? 'Unknown Station',
                                  );
                                }
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                padding: const EdgeInsets.all(4),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    );
                                  },
                                  child: Icon(
                                    station.isFavorite ?? false
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    key: ValueKey(
                                      station.isFavorite,
                                    ), // Important for animation
                                    color:
                                        (station.isFavorite ?? false)
                                            ? const Color(0xFFE65100)
                                            : Colors.grey,
                                    size: 22,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Address
                    Text(
                      station.address ?? 'No address available',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Connector & Price Info
                    Row(
                      children: [
                        Icon(
                          Icons.ev_station,
                          size: 16,
                          color: Colors.blueGrey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "DC 1/6",
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.blueGrey[700],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          "Start from ",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          "${station.pricePerKwh?.toStringAsFixed(2) ?? '0.35'}\$/kWh",
                          style: const TextStyle(
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Bottom Actions: Direction & Distance
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            if (station.lats != null && station.longs != null) {
                              _openMap(station.lats!, station.longs!);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "direction".tr,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        Text(
                          _calculateDistance(station.lats, station.longs),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add haptic feedback function
  void _vibrate() {
    // You can add haptic feedback here if needed
    // HapticFeedback.lightImpact();
  }
  String _calculateDistance(String? lat, String? lng) {
    if (lat == null || lng == null) return 'N/A km';

    if (stationController.currentPosition.value != null) {
      final userLat = stationController.currentPosition.value!.latitude;
      final userLng = stationController.currentPosition.value!.longitude;
      final stationLat = double.parse(lat);
      final stationLng = double.parse(lng);

      final distance = _calculateSimpleDistance(
        userLat,
        userLng,
        stationLat,
        stationLng,
      );
      return '${distance.toStringAsFixed(1)} km';
    }

    return 'N/A km';
  }

  double _calculateSimpleDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final latDiff = (lat1 - lat2).abs();
    final lngDiff = (lng1 - lng2).abs();
    return (latDiff + lngDiff) * 111.0;
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'failed_to_load_stations'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: stationController.refreshData,
            child: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.ev_station_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_stations_available'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_stations_found'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'try_different_search'.tr,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: stationController.clearAllFilters,
            child: Text('clear_filters'.tr),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}

// ProvinceFilterDialog is defined here at the bottom of the file
class ProvinceFilterDialog extends StatefulWidget {
  final EvStationController stationController;

  const ProvinceFilterDialog({super.key, required this.stationController});

  @override
  State<ProvinceFilterDialog> createState() => _ProvinceFilterDialogState();
}

class _ProvinceFilterDialogState extends State<ProvinceFilterDialog> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<EvProvinceDatum> _filteredProvinces = <EvProvinceDatum>[].obs;

  @override
  void initState() {
    super.initState();
    _filteredProvinces.assignAll(widget.stationController.allProvinces);
    _searchController.addListener(_filterProvinces);
  }

  void _filterProvinces() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      _filteredProvinces.assignAll(widget.stationController.allProvinces);
    } else {
      final filtered =
          widget.stationController.allProvinces.where((province) {
            final nameEn = province.nameEn?.toLowerCase() ?? '';
            final nameKh = province.nameKh?.toLowerCase() ?? '';
            return nameEn.contains(query) || nameKh.contains(query);
          }).toList();
      _filteredProvinces.assignAll(filtered);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _filterProvinces();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'select_province'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search_province'.tr,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearSearch,
                          )
                          : null,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'provinces_found'.trParams({
                        'count': _filteredProvinces.length.toString(),
                      }),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      TextButton(
                        onPressed: _clearSearch,
                        child: Text(
                          'clear_search'.tr,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                if (widget.stationController.isLoadingProvinces.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProvinces = widget.stationController.allProvinces;

                if (allProvinces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_city_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_provinces_available'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredProvinces.isEmpty &&
                    _searchController.text.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_provinces_found'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'try_different_search'.tr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _clearSearch,
                          child: Text('clear_search'.tr),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: _filteredProvinces.length,
                  itemBuilder: (context, index) {
                    final province = _filteredProvinces[index];
                    final isSelected =
                        widget.stationController.selectedProvince.value?.id ==
                        province.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      child: ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.location_city_outlined,
                          color:
                              isSelected ? AppColors.primaryColor : Colors.grey,
                        ),
                        title: Text(
                          province.nameEn ?? '',
                          style: TextStyle(
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                isSelected
                                    ? AppColors.primaryColor
                                    : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          province.nameKh ?? '',
                          style: TextStyle(
                            color:
                                isSelected
                                    ? AppColors.primaryColor.withOpacity(0.8)
                                    : Colors.grey,
                          ),
                        ),
                        trailing:
                            isSelected
                                ? Icon(
                                  Icons.check,
                                  color: AppColors.primaryColor,
                                )
                                : null,
                        tileColor:
                            isSelected
                                ? AppColors.primaryColor.withOpacity(0.1)
                                : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                            width: isSelected ? 1 : 0,
                          ),
                        ),
                        onTap: () {
                          widget.stationController.selectProvince(province);
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      widget.stationController.clearProvinceFilter();
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryColor,
                      side: BorderSide(color: AppColors.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('clear_filter'.tr),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('close'.tr),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filteredProvinces.close();
    super.dispose();
  }
}
