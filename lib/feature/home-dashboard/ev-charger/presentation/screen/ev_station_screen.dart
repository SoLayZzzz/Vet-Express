import 'dart:async';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_station_list_response.dart';
import 'package:express_vet/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/ev_station_controller.dart';

import '../../../../../utils/app_colors.dart';

class EvAllStationScreen extends GetView<EvStationController> {
  const EvAllStationScreen({super.key});

  void _openSearchScreen() {
    Get.to(() => const EvStationSearchScreen());
  }

  void _onStationSelected(EvStationListDatum station) {
    if (station.lats != null && station.longs != null) {
      controller.moveToStation(
        LatLng(double.parse(station.lats!), double.parse(station.longs!)),
      );
    }
    controller.panelController.animatePanelToPosition(0.0);
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
    controller.filteredProvinces.assignAll(controller.allProvinces);
    Get.to(() => const EvProvinceFilterScreen());
  }

  @override
  Widget build(BuildContext context) {
    controller.autoOpenPanelOnEnter();
    final screenHeight = MediaQuery.of(context).size.height / 1.1;
    final safeTop = MediaQuery.of(context).padding.top;
    final reservedTop = safeTop + (screenHeight * 0.02) + 80;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarVET().appBar(context, "ev_charger".tr),
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
                  markers: controller.buildMarkers(_onStationSelected),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onMapCreated: (controller) {
                    this.controller.mapController.complete(controller);
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
                    onPressed: controller.goToCurrentLocation,
                    backgroundColor: Colors.white,
                    elevation: 4,
                    child: Icon(
                      Icons.my_location,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),

                // Filter Badge (if province is selected)
                if (controller.selectedProvince.value != null)
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
                            controller.selectedProvince.value?.nameEn ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () async {
                              controller.clearProvinceFilter();
                              await controller.resetMapToDefaultView();
                            },
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

                // Sliding Up Panel
                SlidingUpPanel(
                  controller: controller.panelController,
                  minHeight: 120.0,
                  isDraggable: false,
                  maxHeight: (screenHeight - reservedTop).clamp(
                    0.0,
                    screenHeight,
                  ),
                  snapPoint: 0.5,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  panel: _buildStationPanel(context),
                  body: Container(),
                  onPanelClosed: () {
                    controller.searchFocusNode.unfocus();
                  },
                ),
              ],
            );
          }),

          // Favorite Success Animation
          Obx(() {
            if (controller.showFavoriteAnimation.value) {
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
          color: Colors.black.withValues(
            alpha: controller.showFavoriteAnimation.value ? 0.5 : 0.0,
          ),
          child: Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: controller.showFavoriteAnimation.value ? 1.0 : 0.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Boom Fire Animation with scaling
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.elasticOut,
                    // transform:
                    //     Matrix4.identity()..scale(
                    //       controller.showFavoriteAnimation.value ? 1.2 : 0.8,
                    //     ),
                    transform: Matrix4.diagonal3Values(
                      controller.showFavoriteAnimation.value ? 1.2 : 0.8,
                      controller.showFavoriteAnimation.value ? 1.2 : 0.8,
                      1.0,
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
                          color: Colors.black.withValues(alpha: 0.2),
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
                          controller.favoriteStationName.value,
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
            onTap: _openSearchScreen,
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.searchController,
              builder: (context, value, _) {
                final searchText = value.text.trim();
                final hasValue = searchText.isNotEmpty;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: hasValue ? 0 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                        child: Text(
                          searchText.isEmpty ? 'search_station'.tr : searchText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                searchText.isEmpty ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                      if (hasValue)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () async {
                            controller.clearAllFilters();
                            await controller.resetMapToDefaultView();
                          },
                        ),
                    ],
                  ),
                );
              },
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
                if (controller.selectedProvince.value != null)
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

  Widget _buildStationPanel(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragUpdate: (details) {
            if (controller.panelController.isAttached) {
              double screenHeight = MediaQuery.of(context).size.height;
              double newPos =
                  controller.panelController.panelPosition +
                  (-details.delta.dy / screenHeight);
              controller.panelController.panelPosition = newPos.clamp(0.5, 1.0);
            }
          },
          onVerticalDragEnd: (details) {
            if (controller.panelController.isAttached) {
              double currentPos = controller.panelController.panelPosition;
              if (currentPos > 0.75) {
                controller.panelController.open();
              } else {
                controller.panelController.animatePanelToPosition(0.5);
              }
            }
          },
          child: Column(
            children: [
              // Drag handle
              GestureDetector(
                onTap: () {
                  controller.panelController.close();
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
                        controller.panelController.close();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Station List
        Expanded(
          child: Obx(() {
            // Watch currentPosition and isLocationLoading to update distance calculations when location is fetched
            controller.currentPosition.value;
            controller.isLocationLoading.value;

            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.hasError.value) {
              return _buildErrorState();
            }

            final stations = controller.stationsForMap;

            if (stations.isEmpty) {
              if (controller.searchQuery.value.isNotEmpty ||
                  controller.selectedProvince.value != null) {
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
                final selectedId = controller.selectedStationId.value;
                final isSelected =
                    selectedId != null &&
                    station.id != null &&
                    selectedId == station.id;
                final child = _buildStationCard(
                  station,
                  isSelected: isSelected,
                );
                if (station.id == null) {
                  return child;
                }
                return KeyedSubtree(
                  key: controller.stationItemKey(station.id!),
                  child: child,
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStationCard(
    EvStationListDatum station, {
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelected
                ? Border.all(color: AppColors.primaryColor, width: 1)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
                "https://newpapisystem.utebi.com/vetEvChargerFrontendAPi" +
                    station.imageUrl.toString(),
                width: 110,
                fit: BoxFit.contain,
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
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
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
                        const SizedBox(width: 10),
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

                        controller.isLocationLoading.value
                            ? Container(
                              width: 50,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                            : Text(
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

  String _calculateDistance(String? lat, String? lng) {
    if (lat == null || lng == null) {
      debugPrint('Distance Calculation: lat or lng is null');
      return 'N/A km';
    }

    final stationLat = double.tryParse(lat.trim());
    final stationLng = double.tryParse(lng.trim());
    if (stationLat == null || stationLng == null) {
      debugPrint(
        'Distance Calculation: failed to parse lat="$lat" or lng="$lng"',
      );
      return 'N/A km';
    }

    if (controller.currentPosition.value != null) {
      final userLat = controller.currentPosition.value!.latitude;
      final userLng = controller.currentPosition.value!.longitude;

      final distance = _calculateSimpleDistance(
        userLat,
        userLng,
        stationLat,
        stationLng,
      );
      final result = '${distance.toStringAsFixed(1)} km';
      debugPrint(
        'Distance Calculation: station($stationLat, $stationLng), user($userLat, $userLng) -> $result',
      );
      return result;
    }

    debugPrint(
      'Distance Calculation: currentPosition is null, station($stationLat, $stationLng)',
    );
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
            onPressed: controller.refreshData,
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
            onPressed: controller.clearAllFilters,
            child: Text('clear_filters'.tr),
          ),
        ],
      ),
    );
  }
}

class EvStationSearchScreen extends GetView<EvStationController> {
  const EvStationSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'search_station'.tr),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.searchController,
              builder: (context, value, _) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: value.text.isNotEmpty ? 0 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
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
                          controller: controller.searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'search_station'.tr,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (value.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.clearSearch();
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.hasError.value) {
                return Center(child: Text(controller.errorMessage.value));
              }

              final stations = controller.allStations;
              if (stations.isEmpty) {
                return const SizedBox.shrink();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: stations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final station = stations[index];
                  return InkWell(
                    onTap: () async {
                      final stationName = station.name?.trim() ?? '';

                      if (stationName.isNotEmpty) {
                        controller.searchController.text = stationName;
                        controller.searchQuery.value = stationName;
                        controller.isSearching.value = true;

                        await controller.fetchEvStations(
                          searchText: stationName,
                          provinceId: controller.selectedProvince.value?.id,
                        );
                      }

                      if (station.id != null) {
                        controller.selectedStationId.value = station.id;
                      }
                      if (station.lats != null && station.longs != null) {
                        controller.moveToStation(
                          LatLng(
                            double.parse(station.lats!),
                            double.parse(station.longs!),
                          ),
                        );
                      }
                      Get.back();

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.openPanelToDefaultPosition();
                        controller.revealSelectedStationInPanel();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),

                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.ev_station,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  station.name ?? 'Unknown Station',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  station.address ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class EvProvinceFilterScreen extends GetView<EvStationController> {
  const EvProvinceFilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.filteredProvinces.isEmpty &&
        controller.provinceSearchController.text.trim().isEmpty) {
      controller.filteredProvinces.assignAll(controller.allProvinces);
    }
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'select_province'.tr),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller.provinceSearchController,
                builder: (context, value, _) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: value.text.isNotEmpty ? 0 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
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
                            controller: controller.provinceSearchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'search_province'.tr,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (value.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: controller.clearProvinceSearch,
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingProvinces.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allProvinces = controller.allProvinces;
                  if (allProvinces.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  if (controller.filteredProvinces.isEmpty &&
                      controller.provinceSearchController.text.isNotEmpty) {
                    return const SizedBox.shrink();
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: controller.filteredProvinces.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final province = controller.filteredProvinces[index];
                      final isSelected =
                          controller.selectedProvince.value?.id == province.id;

                      return InkWell(
                        onTap: () {
                          controller.selectProvince(province);
                          Get.back();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.asset(
                                  AssetImages.location,
                                  color:
                                      isSelected
                                          ? AppColors.primaryColor
                                          : AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      province.nameEn ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      province.nameKh ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  color: AppColors.primaryColor,
                                )
                              else
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ProvinceFilterDialog is defined here at the bottom of the file
class ProvinceFilterDialog extends GetView<EvStationController> {
  const ProvinceFilterDialog({super.key});

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
                  onPressed: () => Get.back(),
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
                controller: controller.provinceSearchController,
                decoration: InputDecoration(
                  hintText: 'search_province'.tr,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon:
                      controller.provinceSearchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: controller.clearProvinceSearch,
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
                        'count': controller.filteredProvinces.length.toString(),
                      }),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (controller.provinceSearchController.text.isNotEmpty)
                      TextButton(
                        onPressed: controller.clearProvinceSearch,
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
                if (controller.isLoadingProvinces.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProvinces = controller.allProvinces;

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

                if (controller.filteredProvinces.isEmpty &&
                    controller.provinceSearchController.text.isNotEmpty) {
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
                          onPressed: controller.clearSearch,
                          child: Text('clear_search'.tr),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.filteredProvinces.length,
                  itemBuilder: (context, index) {
                    final province = controller.filteredProvinces[index];
                    final isSelected =
                        controller.selectedProvince.value?.id == province.id;

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
                                    ? AppColors.primaryColor.withValues(
                                      alpha: 0.8,
                                    )
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
                                ? AppColors.primaryColor.withValues(alpha: 0.1)
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
                          controller.selectProvince(province);
                          Get.back();
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
                      controller.clearProvinceFilter();
                      Get.back();
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
                    onPressed: () => Get.back(),
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
}
