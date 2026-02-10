import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import '../../api/ev.dart';
import '../../models/ev/ev_station_list_response.dart';
import '../../models/ev/ev_province_response.dart';

class EvStationController extends GetxController {
  // Station related variables
  var evStationResponse = Rxn<EvStationListResponse>();
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // Province related variables
  var evProvinceResponse = Rxn<EvProvinceResponse>();
  var isLoadingProvinces = false.obs;
  var selectedProvince = Rxn<EvProvinceDatum>();
  var provinceSearchController = TextEditingController();

  // Map related variables
  final Completer<GoogleMapController> mapController = Completer<GoogleMapController>();
  final Location location = Location();
  final Rx<BitmapDescriptor?> markerIcon = Rx<BitmapDescriptor?>(null);
  final Rx<LatLng?> currentPosition = Rx<LatLng?>(null);

  // Search state
  final RxString searchQuery = ''.obs;
  var isSearching = false.obs;

  // Favorite animation state
  var showFavoriteAnimation = false.obs;
  var favoriteStationName = ''.obs;

  // Track favorite operations to prevent duplicates
  final Set<int> _pendingFavoriteOperations = <int>{};

  @override
  void onInit() {
    fetchEvStations();
    fetchEvProvinces(1, 100);
    _getUserLocation();
    _loadMarkerIcon();
    super.onInit();
  }

  // Station methods - Fetch with search and province filter
  Future<void> fetchEvStations({String? searchText, int? provinceId}) async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage.value = '';

      var response = await EV().getEvNewStation(
        Get.context!,
        searchText: searchText,
        provinceId: provinceId,
      );
      evStationResponse.value = response;
    } catch (e) {
      hasError(true);
      errorMessage.value = e.toString();
      _showErrorDialog(e);
    } finally {
      isLoading(false);
    }
  }

  // Toggle favorite with Facebook-like instant feedback
  Future<void> toggleFavorite(int stationId, String stationName) async {
    // Prevent duplicate operations
    if (_pendingFavoriteOperations.contains(stationId)) {
      return;
    }

    _pendingFavoriteOperations.add(stationId);

    try {
      // Find the station and update UI immediately (Facebook-style)
      final station = allStations.firstWhere(
        (s) => s.id == stationId,
        orElse: () => EvStationListDatum(),
      );

      if (station.id != null) {
        final wasFavorite = station.isFavorite ?? false;
        final newFavoriteState = !wasFavorite;

        // IMMEDIATE UI UPDATE (Facebook-style)
        station.isFavorite = newFavoriteState;
        update(); // Force UI refresh immediately

        // Show animation only when adding to favorites
        if (newFavoriteState) {
          favoriteStationName.value = stationName;
          showFavoriteAnimation.value = true;

          // Auto-hide animation after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            showFavoriteAnimation.value = false;
          });
        }

        // Call API in background (optimistic update)
        try {
          final response = await EV().eVFav(Get.context!, stationId);

          if (response.header?.result == true && response.body?.status == true) {
            // API success - state is already correct
            debugPrint('Favorite API success for station $stationId');
          } else {
            // API failed - revert to previous state
            station.isFavorite = wasFavorite;
            update();

            Get.snackbar(
              'error'.tr,
              response.body?.message ?? 'failed_to_update_favorite'.tr,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        } catch (apiError) {
          // API call failed - revert to previous state
          station.isFavorite = wasFavorite;
          update();

          Get.snackbar(
            'error'.tr,
            'failed_to_update_favorite'.tr,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          debugPrint('Favorite API error: $apiError');
        }
      }
    } catch (e) {
      debugPrint('Favorite toggle error: $e');
    } finally {
      _pendingFavoriteOperations.remove(stationId);
    }
  }

  // Search stations by name
  void searchStations(String query) {
    searchQuery.value = query;
    isSearching.value = query.isNotEmpty;

    if (query.isEmpty && selectedProvince.value == null) {
      // If no search and no province filter, show all stations
      fetchEvStations();
    } else {
      // Search with current province filter
      fetchEvStations(
        searchText: query.isEmpty ? null : query,
        provinceId: selectedProvince.value?.id,
      );
    }
  }

  // Province methods
  Future<void> fetchEvProvinces(int page, int rowPerPage) async {
    try {
      isLoadingProvinces(true);
      var response = await EV().getEvProvince(Get.context!, page, rowPerPage);
      evProvinceResponse.value = response;
    } catch (e) {
      debugPrint('Error fetching provinces: $e');
    } finally {
      isLoadingProvinces(false);
    }
  }

  // Select province and filter stations
  void selectProvince(EvProvinceDatum? province) {
    selectedProvince.value = province;

    // Fetch stations with province filter
    fetchEvStations(
      searchText: searchQuery.value.isEmpty ? null : searchQuery.value,
      provinceId: province?.id,
    );
  }

  void clearProvinceFilter() {
    selectedProvince.value = null;

    // Fetch all stations or with current search
    fetchEvStations(searchText: searchQuery.value.isEmpty ? null : searchQuery.value);
  }

  /// Get user current location
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled && !await location.requestService()) return;

      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied &&
          await location.requestPermission() != PermissionStatus.granted) {
        return;
      }

      final loc = await location.getLocation();
      if (loc.latitude != null && loc.longitude != null) {
        currentPosition.value = LatLng(loc.latitude!, loc.longitude!);
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  /// Load marker icon
  Future<void> _loadMarkerIcon() async {
    try {
      if (Platform.isAndroid) {
        final icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(10, 10)),
          "assets/icons/icon_location_ev.png",
        );
        markerIcon.value = icon;
      } else {
        final icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(10, 10)),
          "assets/icons/icon_location_ev_ios.png",
        );
        markerIcon.value = icon;
      }
    } catch (e) {
      markerIcon.value = BitmapDescriptor.defaultMarker;
      debugPrint('Marker icon error: $e');
    }
  }

  /// Go to current location
  Future<void> goToCurrentLocation() async {
    if (currentPosition.value == null) return;

    try {
      final controller = await mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(currentPosition.value!, 15));
    } catch (e) {
      debugPrint('Error moving to current location: $e');
    }
  }

  /// Move to specific station
  Future<void> moveToStation(LatLng position) async {
    try {
      final controller = await mapController.future;
      await controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
    } catch (e) {
      debugPrint('Error moving to station: $e');
    }
  }

  void _showErrorDialog(dynamic error) {
    Get.dialog(
      AlertDialog(
        title: Text('error'.tr),
        content: Text(error.toString()),
        actions: [TextButton(onPressed: () => Get.back(), child: Text('ok'.tr))],
      ),
    );
  }

  // Helper getters
  List<EvStationListDatum> get allStations => evStationResponse.value?.body?.data ?? [];
  List<EvProvinceDatum> get allProvinces => evProvinceResponse.value?.body?.data ?? [];
  List<EvStationListDatum> get favoriteStations =>
      allStations.where((station) => station.isFavorite == true).toList();
  bool get hasStations => allStations.isNotEmpty;
  bool get hasFavorites => favoriteStations.isNotEmpty;
  bool get hasProvinces => allProvinces.isNotEmpty;
  String get message => evStationResponse.value?.body?.message ?? '';
  bool get status => evStationResponse.value?.body?.status ?? false;

  /// Get stations for map markers
  List<EvStationListDatum> get stationsForMap => allStations;

  /// Build markers for Google Map
  Set<Marker> buildMarkers(Function(EvStationListDatum) onStationSelected) {
    return stationsForMap
        .where(
          (station) =>
              station.lats != null &&
              station.longs != null &&
              double.tryParse(station.lats!) != null &&
              double.tryParse(station.longs!) != null,
        )
        .map((station) {
          final position = LatLng(double.parse(station.lats!), double.parse(station.longs!));

          return Marker(
            markerId: MarkerId(station.id?.toString() ?? 'station'),
            position: position,
            icon: markerIcon.value ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: station.name ?? 'Unknown Station',
              snippet: station.address ?? '',
            ),
            onTap: () => onStationSelected(station),
          );
        })
        .toSet();
  }

  /// Refresh data
  void refreshData() {
    fetchEvStations(
      searchText: searchQuery.value.isEmpty ? null : searchQuery.value,
      provinceId: selectedProvince.value?.id,
    );
    fetchEvProvinces(1, 100);
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    isSearching.value = false;
    fetchEvStations(provinceId: selectedProvince.value?.id);
  }

  /// Clear all filters
  void clearAllFilters() {
    selectedProvince.value = null;
    searchQuery.value = '';
    isSearching.value = false;
    provinceSearchController.clear();
    fetchEvStations();
  }

  @override
  void onClose() {
    provinceSearchController.dispose();
    mapController.future.then((controller) => controller.dispose()).catchError((_) {});
    super.onClose();
  }
}
