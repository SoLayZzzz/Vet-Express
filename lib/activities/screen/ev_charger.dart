import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../utils/app_colors.dart';
import '../../api/ev_charger.dart';
import '../../models/ev_charger/ev_charger_response.dart';
import 'province_selection_screen.dart';
import 'search_ev_screen.dart';

class EvCharger extends StatefulWidget {
  const EvCharger({super.key});

  @override
  State<EvCharger> createState() => _EvChargerState();
}

class _EvChargerState extends State<EvCharger> {
  late Future<EvChargerResponse> futureEvCharger;
  Completer<GoogleMapController>? _controller;
  final PanelController _panelController = PanelController();
  final Location location = Location();
  BitmapDescriptor? icon;
  LatLng? _currentPosition;
  BodyEV? _selectedStation;
  List<BodyEV> _allStations = [];
  String? _selectedProvinceId;
  String? _selectedProvinceName;
  bool _isRetrying = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(11.578036036368854, 104.922274625954),
    zoom: 6,
  );

  // Helper method to get the appropriate field based on current locale
  String _getLocalizedField({
    required String? englishField,
    required String? khmerField,
    required String? chineseField,
  }) {
    final currentLocale = Get.locale?.languageCode ?? 'en';

    switch (currentLocale) {
      case 'km': // Khmer
        return khmerField?.trim().isNotEmpty == true ? khmerField! : englishField ?? '';
      case 'zh': // Chinese
        return chineseField?.trim().isNotEmpty == true ? chineseField! : englishField ?? '';
      default: // English or other languages
        return englishField ?? '';
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = Completer<GoogleMapController>();
    _loadInitialData();
    _getUserLocation();
    _loadMarkerIcon();
  }

  /// Load initial data with proper error handling
  void _loadInitialData() {
    setState(() {
      _isRetrying = false;
      futureEvCharger = EvChargerList()
          .getEvChargerList(context)
          .then((response) {
            if (response.body != null && response.header?.result == true) {
              return response;
            } else {
              throw Exception('Invalid response format or empty data');
            }
          })
          .catchError((error) {
            log('❌ Initial API Error: $error');
            // Return a valid empty response instead of throwing
            return EvChargerResponse(
              header: Header(result: false, statusCode: 500, serverTimestamp: 0),
              body: [],
            );
          });
    });
  }

  /// Refresh EV stations based on province filter
  void _refreshStations({String? provinceId, String? name}) {
    setState(() {
      _isRetrying = false;
      // Create a new controller to avoid "Future already completed" error
      _controller = Completer<GoogleMapController>();

      // Clear the stations immediately when filtering
      _allStations = [];
      _selectedStation = null;

      futureEvCharger = EvChargerList()
          .getEvChargerList(context, provinceId: provinceId, name: name)
          .then((response) {
            if (response.body != null && response.header?.result == true) {
              return response;
            } else {
              throw Exception('No valid data received');
            }
          })
          .catchError((error) {
            log('❌ Filter API Error: $error');
            // Return empty response to prevent FutureBuilder error
            return EvChargerResponse(
              header: Header(result: false, statusCode: 500, serverTimestamp: 0),
              body: [],
            );
          });
    });
  }

  /// Retry loading data
  void _retryLoading() {
    setState(() {
      _isRetrying = true;
    });

    if (_selectedProvinceId != null) {
      _refreshStations(provinceId: _selectedProvinceId);
    } else {
      _loadInitialData();
    }
  }

  /// Handle province selection
  void _onProvinceSelected(String provinceId, String provinceName) {
    setState(() {
      _selectedProvinceId = provinceId;
      _selectedProvinceName = provinceName;
    });

    // Refresh stations with province filter
    _refreshStations(provinceId: provinceId);
  }

  /// Clear province filter
  void _clearProvinceFilter() {
    setState(() {
      _selectedProvinceId = null;
      _selectedProvinceName = null;
    });

    // Refresh stations without filter
    _refreshStations();
  }

  ///get the user current location
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
        setState(() {
          _currentPosition = LatLng(loc.latitude!, loc.longitude!);
        });
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  ///load the marker icon
  Future<void> _loadMarkerIcon() async {
    try {
      if (Platform.isAndroid) {
        icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(140, 140)),
          "assets/icons/icon_location_ev.png",
        );
      } else {
        icon = await BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(140, 140)),
          "assets/icons/icon_location_ev_ios.png",
        );
      }
      if (mounted) setState(() {});
    } catch (e) {
      log('Error loading marker icon: $e');
      icon = BitmapDescriptor.defaultMarker;
    }
  }

  ///get the user current location and move the camera to it
  Future<void> _goToCurrentLocation() async {
    if (_currentPosition == null || _controller == null) return;
    final controller = await _controller!.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));
  }

  ///handle the station selection
  void _onStationSelected(BodyEV station) {
    setState(() {
      _selectedStation = station;
    });

    // Move camera to selected station
    if (station.lats != null && station.longs != null) {
      _moveToStation(LatLng(double.parse(station.lats!), double.parse(station.longs!)));
    }

    // Close panel if open
    _panelController.animatePanelToPosition(0.0, duration: const Duration(milliseconds: 300));
  }

  ///move the camera to the selected station
  Future<void> _moveToStation(LatLng position) async {
    if (_controller == null) return;
    final controller = await _controller!.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 15));
  }

  ///build the markers for the map
  Set<Marker> _buildMarkers() {
    final stationsToShow = _selectedStation != null ? [_selectedStation!] : _allStations;

    return stationsToShow
        .where(
          (s) => double.tryParse(s.lats ?? '') != null && double.tryParse(s.longs ?? '') != null,
        )
        .map(
          (s) => Marker(
            markerId: MarkerId(s.name ?? "station_${s.lats}_${s.longs}"),
            position: LatLng(double.parse(s.lats!), double.parse(s.longs!)),
            icon: icon ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(
              title: _getLocalizedField(
                englishField: s.name,
                khmerField: s.nameKh,
                chineseField: s.nameCn,
              ),
              snippet: _getLocalizedField(
                englishField: s.address,
                khmerField: s.addressKh,
                chineseField: s.addressCn,
              ),
              onTap: () => _openMap(s.lats!, s.longs!),
            ),
            onTap: () => _onStationSelected(s),
          ),
        )
        .toSet();
  }

  ///open the google map with the selected station
  Future<void> _openMap(String lat, String lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  ///build the header for the panel
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("ev_station".tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              InkWell(
                onTap:
                    () => _panelController.animatePanelToPosition(
                      0.0,
                      duration: const Duration(milliseconds: 300),
                    ),
                child: const Icon(Icons.close, color: Colors.black54, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///build the station item for the list
  Widget _buildStationItem(BodyEV station) {
    final stationName = _getLocalizedField(
      englishField: station.name,
      khmerField: station.nameKh,
      chineseField: station.nameCn,
    );

    final chargerQty = _getLocalizedField(
      englishField: station.evChargerQty,
      khmerField: station.evChargerQtyKh,
      chineseField: station.evChargerQtyCn,
    );

    final vehicleQty = _getLocalizedField(
      englishField: station.vehicleQty,
      khmerField: station.vehicleQtyKh,
      chineseField: station.vehicleQtyCn,
    );

    final chargePoint = _getLocalizedField(
      englishField: station.chargePoint,
      khmerField: station.chargePointKh,
      chineseField: station.chargePointCn,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      color: AppColors.whiteColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Image and Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildStationImage(station.image),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName.isNotEmpty ? stationName : "Unknown",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tel: ${station.telephone ?? ''}",
                      style: TextStyle(fontSize: 16, color: AppColors.textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Middle Section: Technical Specs
          Text(chargerQty, style: TextStyle(fontSize: 16, color: AppColors.textColor)),
          const SizedBox(height: 12),
          Text(vehicleQty, style: TextStyle(fontSize: 16, color: AppColors.textColor)),
          const SizedBox(height: 12),
          Text(chargePoint, style: TextStyle(fontSize: 16, color: AppColors.textColor)),

          const SizedBox(height: 20),

          // Bottom Section: Action Buttons
          Row(
            children: [
              // Coming Soon / Status Button
              station.isOpen == 0
                  ? Expanded(
                    child: OutlinedButton(
                      onPressed: null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(
                        "coming_soon".tr,
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  : const SizedBox.shrink(),
              station.isOpen == 0 ? const SizedBox(width: 12) : const SizedBox.shrink(),
              // Direction Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openMap(station.lats!, station.longs!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(
                    "direction".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///build the station image
  Widget _buildStationImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:
          imageUrl != null && imageUrl.isNotEmpty
              ? CachedNetworkImage(
                imageUrl: imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                memCacheHeight: 200,
                memCacheWidth: 200,
                errorWidget: (_, __, ___) => _defaultImage(),
              )
              : _defaultImage(),
    );
  }

  ///default image for the station
  Widget _defaultImage() =>
      Image.asset('assets/icons/icon_ev.png', height: 70, width: 70, fit: BoxFit.cover);

  ///build the search field
  Widget _buildSearchField() {
    String displayText = "search_station".tr;
    if (_selectedStation != null) {
      displayText = _getLocalizedField(
        englishField: _selectedStation!.name,
        khmerField: _selectedStation!.nameKh,
        chineseField: _selectedStation!.nameCn,
      );
      if (displayText.isEmpty) {
        displayText = "Unknown";
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: Colors.grey[500],
                    padding: const EdgeInsets.only(left: 12),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final selectedStation = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchEvScreen(allStations: _allStations),
                          ),
                        );

                        if (selectedStation != null && selectedStation is BodyEV) {
                          _onStationSelected(selectedStation);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          displayText,
                          style: TextStyle(
                            color: _selectedStation != null ? Colors.black : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedStation != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedStation = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 20),
                      color: Colors.grey[500],
                      padding: const EdgeInsets.only(right: 12),
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Transform.scale(
            scale: 0.8,
            child: FloatingActionButton(
              heroTag: "provinceBtn",
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EvProvinceSelectionScreen()),
                );

                if (result != null && result is Map<String, String>) {
                  _onProvinceSelected(result['id']!, result['name']!);
                }
              },
              backgroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.filter_alt, color: AppColors.primaryColor, size: 30),
            ),
          ),
        ],
      ),
    );
  }

  ///build the station list
  Widget _buildStationList() {
    final stationsToShow = _selectedStation != null ? [_selectedStation!] : _allStations;

    if (stationsToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ev_station_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _selectedProvinceName != null
                  ? '${'no_station_available'.tr} $_selectedProvinceName'
                  : 'no_station_available'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (_selectedProvinceName != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: _clearProvinceFilter, child: Text('see_all_provinces'.tr)),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        // Province filter indicator
        if (_selectedProvinceName != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Chip(
                  label: Text(
                    '$_selectedProvinceName',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _clearProvinceFilter,
                  child: const Icon(Icons.clear, color: Colors.grey, size: 20),
                ),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: stationsToShow.length,
            itemBuilder: (_, i) => _buildStationItem(stationsToShow[i]),
          ),
        ),
      ],
    );
  }

  /// Build error widget
  Widget _buildErrorWidget(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            error.toString().contains('Timeout') || error.toString().contains('timeout')
                ? 'request_timed_out'.tr
                : 'failed_to_load_ev_chargers'.tr,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isRetrying ? null : _retryLoading,
            child:
                _isRetrying
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  /// Build loading widget
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading EV stations...'),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.ev_station_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _selectedProvinceName != null
                ? '${'no_station_available'.tr} $_selectedProvinceName'
                : 'no_station_available'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (_selectedProvinceName != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: _clearProvinceFilter, child: Text('see_all_provinces'.tr)),
          ],
        ],
      ),
    );
  }

  /// Build main map UI
  Widget _buildMapUI() {
    return Stack(
      children: [
        GoogleMap(
          markers: _buildMarkers(),
          mapType: MapType.normal,
          initialCameraPosition: _initialPosition,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            if (!_controller!.isCompleted) {
              _controller!.complete(controller);
            }
          },
        ),

        Positioned(
          top: MediaQuery.of(context).size.height * 0.07,
          left: 0,
          right: 0,
          child: _buildSearchField(),
        ),

        Positioned(
          right: 16,
          bottom: MediaQuery.of(context).size.height * 0.4,
          child: FloatingActionButton(
            heroTag: "myLocationBtn",
            onPressed: _goToCurrentLocation,
            backgroundColor: Colors.white,
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.my_location, color: AppColors.primaryColor, size: 30),
          ),
        ),

        SlidingUpPanel(
          controller: _panelController,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          minHeight: MediaQuery.of(context).size.height * 0.38,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          color: AppColors.backgroundColor,
          panelBuilder:
              (sc) => Column(children: [_buildHeader(), Expanded(child: _buildStationList())]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<EvChargerResponse>(
        future: futureEvCharger,
        builder: (context, snapshot) {
          // Handle connection state
          if (snapshot.connectionState == ConnectionState.waiting && !_isRetrying) {
            return _buildLoadingWidget();
          }

          // Check for errors
          if (snapshot.hasError) {
            log('FutureBuilder Error: ${snapshot.error}');
            return _buildErrorWidget(snapshot.error);
          }

          // Check if data is available
          if (!snapshot.hasData) {
            return _buildEmptyWidget();
          }

          final data = snapshot.data!;

          // Check if response is valid
          if (data.header?.result != true || data.body == null) {
            return _buildErrorWidget('Invalid response from server');
          }

          // Check if data is empty
          if (data.body!.isEmpty) {
            return _buildEmptyWidget();
          }

          // Update stations data
          _allStations = data.body!;

          // Build main UI with data
          return _buildMapUI();
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.future.then((c) => c.dispose()).catchError((_) {});
    super.dispose();
  }
}
