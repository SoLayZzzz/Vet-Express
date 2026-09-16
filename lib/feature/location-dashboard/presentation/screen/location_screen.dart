import 'dart:async';
import 'dart:io';

import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/location-dashboard/presentation/binding/location_binding.dart';
import 'package:express_vet/feature/location-dashboard/presentation/controller/location_controller.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/app_pref.dart';
import 'package:express_vet/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import './location_search_screen.dart';

enum _AreaFilterMode { province, city, any }

String _normalizeAreaName(String value) {
  var out = value.trim().replaceAll(RegExp(r'\s+'), ' ');
  out = out.replaceAll(RegExp(r'^[,\.-]+|[,\.-]+$'), '').trim();
  out = out.replaceAll(
    RegExp(r'^(city|province)\s*[:\-]?\s*', caseSensitive: false),
    '',
  );
  out = out.replaceAll(
    RegExp(r'^(city of|province of)\s+', caseSensitive: false),
    '',
  );
  out = out.replaceAll(RegExp(r'\b(city|province)\b', caseSensitive: false), '');
  out = out.replaceAll(RegExp(r'[\(\)\[\]\{\}]'), '');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  return out;
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = {};
  final Rxn<BitmapDescriptor> iconBranch = Rxn<BitmapDescriptor>();
  final Rxn<BitmapDescriptor> iconAgency = Rxn<BitmapDescriptor>();
  final Rxn<LatLng> _currentPosition = Rxn<LatLng>();

  bool _isLocating = false;
  bool _isFetchingLocation = false;

  static const _kPrefLastLat = 'location_screen_last_lat';
  static const _kPrefLastLng = 'location_screen_last_lng';
  static const _kPrefLastTs = 'location_screen_last_ts';
  static const Duration _kCachedLocationMaxAge = Duration(minutes: 30);

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(11.578036036368854, 104.922274625954),
    zoom: 6.5,
  );

  late final LocationController locationController;
  Location location = Location();
  List<Data> _allBranches = [];

  _AreaFilterMode _areaFilterMode = _AreaFilterMode.any;
  String? _selectedArea;


  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<LocationController>()) {
      LocationBinding().dependencies();
    }
    locationController = Get.find<LocationController>();

    if (Platform.isAndroid) {
      getIcons();
    } else {
      getIconsIOS();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_warmStartUserLocation());
    });

    // Fetch branches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationController.fetchBranches(context: context);
    });
  }

  LatLng? _readCachedLocation() {
    try {
      final lat = AppPref.preferences.getDouble(_kPrefLastLat);
      final lng = AppPref.preferences.getDouble(_kPrefLastLng);
      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (_) {
      return null;
    }
  }

  bool _isCachedLocationFresh() {
    try {
      final ts = AppPref.preferences.getInt(_kPrefLastTs);
      if (ts == null) return false;
      final ageMs = DateTime.now().millisecondsSinceEpoch - ts;
      return ageMs >= 0 && ageMs <= _kCachedLocationMaxAge.inMilliseconds;
    } catch (_) {
      return false;
    }
  }

  Future<void> _cacheLocation(LatLng value) async {
    try {
      await AppPref.preferences.setDouble(_kPrefLastLat, value.latitude);
      await AppPref.preferences.setDouble(_kPrefLastLng, value.longitude);
      await AppPref.preferences.setInt(
        _kPrefLastTs,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {}
  }

  Future<bool> _ensureLocationReady() async {
    final serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled && !await location.requestService()) return false;

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
    }
    if (permission != PermissionStatus.granted) return false;

    return true;
  }

  Future<LocationData?> _getQuickLocation({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    try {
      return await location.getLocation().timeout(timeout);
    } catch (_) {
      return null;
    }
  }

  Future<LocationData?> _getStreamLocation({
    Duration timeout = const Duration(seconds: 7),
  }) async {
    try {
      return await location.onLocationChanged.first.timeout(timeout);
    } catch (_) {
      return null;
    }
  }

  Future<void> _setCurrentPosition(LatLng pos, {bool cache = true}) async {
    _currentPosition.value = pos;
    if (cache) {
      await _cacheLocation(pos);
    }
  }

  Future<void> _warmStartUserLocation() async {
    final cached = _readCachedLocation();
    if (cached != null) {
      await _setCurrentPosition(cached, cache: false);
    }

    await _getUserLocation();
    unawaited(_refineHighAccuracy());
  }

  Future<bool> _getUserLocation({bool showLoading = false}) async {
    if (_isFetchingLocation) return false;
    _isFetchingLocation = true;

    if (showLoading && mounted) {
      setState(() {
        _isLocating = true;
      });
    }

    try {
      if (!await _ensureLocationReady()) return false;

      await location.changeSettings(
        accuracy: LocationAccuracy.low,
        interval: 1000,
        distanceFilter: 0.0,
      );

      final cachedFresh = _isCachedLocationFresh();
      final loc =
          await _getQuickLocation(
            timeout:
                cachedFresh
                    ? const Duration(seconds: 1)
                    : const Duration(seconds: 3),
          ) ??
          await _getStreamLocation(
            timeout:
                cachedFresh
                    ? const Duration(seconds: 4)
                    : const Duration(seconds: 7),
          );

      final lat = loc?.latitude;
      final lng = loc?.longitude;
      if (lat == null || lng == null) return false;

      await _setCurrentPosition(LatLng(lat, lng));
      return true;
    } catch (e) {
      debugPrint('Location error: $e');
      return false;
    } finally {
      _isFetchingLocation = false;
      if (showLoading && mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _refineHighAccuracy() async {
    try {
      if (!await _ensureLocationReady()) return;

      await location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 0.0,
      );

      final loc = await _getStreamLocation(timeout: const Duration(seconds: 6));
      final lat = loc?.latitude;
      final lng = loc?.longitude;
      if (lat == null || lng == null) return;

      await _setCurrentPosition(LatLng(lat, lng));
    } catch (_) {}
  }


  Future<void> _navigateToCurrentLocation() async {
    if (_isLocating) return;
    if (!_controller.isCompleted) return;

    var pos = _currentPosition.value;
    if (pos == null) {
      await _getUserLocation(showLoading: true);
      pos = _currentPosition.value;
    }
    if (pos == null) return;

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final uiState = locationController.state;
      if (uiState.loading) {
        return const Scaffold(
          body: Center(
            child: SizedBox(
              height: 50.0,
              width: 50.0,
              child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
            ),
          ),
        );
      }

      if (uiState.branches.isEmpty) {
        return Scaffold(body: Center(child: Text('no_data'.tr)));
      }

      _allBranches = uiState.branches;

      return Scaffold(
        appBar: AppBar(
          elevation: 0.2,
          backgroundColor: AppColors.primaryColor,
          centerTitle: false,
          title: Text(
            'location'.tr,
            style: const TextStyle(
              color: AppColors.whiteColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                ///display google map
                Expanded(
                  child: Obx(
                    () => GoogleMap(
                      markers: getMarkers(uiState.branches),
                      mapType: MapType.normal,
                      initialCameraPosition: _kGooglePlex,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        if (!_controller.isCompleted) {
                          _controller.complete(controller);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            /// searching location + filter
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: TextFormField(
                        onTap: () {
                          Get.to(
                            () => LocationSearchScreen(allBranches: _allBranches),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 350),
                          );
                        },
                        autofocus: false,
                        readOnly: true,
                        showCursor: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 14),
                        decoration: Style.inputText(
                          'search_virak'.tr,
                          iconLeft: Icons.location_on_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: InkWell(
                      onTap: _showAreaFilterSheet,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(
                              Icons.filter_alt_outlined,
                              color: AppColors.greyColor,
                            ),
                            if (_selectedArea != null)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// icon click to see the current user location
            Positioned(
              right: 10,
              bottom: 10,
              child: InkWell(
                onTap: _isLocating ? null : _navigateToCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child:
                      _isLocating
                          ? const SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                          : const Icon(
                            Icons.my_location,
                            color: AppColors.greyColor,
                            size: 36,
                          ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  getIcons() async {
    final branchIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      AssetImages.ic_map_branch,
    );
    final agencyIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      AssetImages.ic_map_agency,
    );
    iconBranch.value = branchIcon;
    iconAgency.value = agencyIcon;
  }

  getIconsIOS() async {
    final branchIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      AssetImages.ic_map_branch_ios,
    );
    final agencyIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      AssetImages.ic_map_agency_ios,
    );
    iconBranch.value = branchIcon;
    iconAgency.value = agencyIcon;
  }

  bool _matchesSelectedArea(Data data) {
    final selected = _selectedArea;
    if (selected == null) return true;

    final raw = (data.address ?? '').trim();
    if (raw.isEmpty) return false;

    final parts =
        raw
            .split(RegExp(r'[,/\\-|]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
    if (parts.isEmpty) return false;

    final city = _normalizeAreaName(parts.first);
    final province = _normalizeAreaName(parts.last);

    return switch (_areaFilterMode) {
      _AreaFilterMode.city => city == selected,
      _AreaFilterMode.province => province == selected,
      _AreaFilterMode.any => city == selected || province == selected,
    };
  }

  List<String> _getAreaOptionsCombined() {
    final values = <String>{};
    for (final b in _allBranches) {
      final raw = (b.address ?? '').trim();
      if (raw.isEmpty) continue;

      final parts =
          raw
              .split(RegExp(r'[,/\\-|]'))
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
      if (parts.isEmpty) continue;

      final city = _normalizeAreaName(parts.first);
      final province = _normalizeAreaName(parts.last);
      if (city.isNotEmpty) values.add(city);
      if (province.isNotEmpty) values.add(province);
    }
    final list = values.toList()..sort();
    return list;
  }

  Future<void> _focusOnSelectedArea() async {
    final selected = _selectedArea;
    if (selected == null) return;

    final points = <LatLng>[];
    for (final b in _allBranches) {
      if (!_matchesSelectedArea(b)) continue;
      if (b.lats == null || b.longs == null) continue;
      points.add(LatLng(b.lats!.toDouble(), b.longs!.toDouble()));
    }
    if (points.isEmpty) return;

    if (!_controller.isCompleted) return;
    final controller = await _controller.future;

    if (points.length == 1) {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(points.first, 12));
      return;
    }

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points.skip(1)) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    Future<void> animate() async {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    }

    try {
      await animate();
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 250));
      await animate();
    }
  }

  Future<void> _showAreaFilterSheet() async {
    final options = _getAreaOptionsCombined();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'City/Province',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: options.length + 1,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            title: const Text('Any'),
                            trailing:
                                _selectedArea == null
                                    ? const Icon(
                                      Icons.check,
                                      color: AppColors.primaryColor,
                                    )
                                    : null,
                            onTap: () {
                              setState(() {
                                _selectedArea = null;
                                _areaFilterMode = _AreaFilterMode.any;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        }

                        final value = options[index - 1];
                        final selected = value == _selectedArea;
                        return ListTile(
                          title: Text(value),
                          trailing:
                              selected
                                  ? const Icon(
                                    Icons.check,
                                    color: AppColors.primaryColor,
                                  )
                                  : const Icon(Icons.chevron_right),
                          onTap: () async {
                            setState(() {
                              _selectedArea = value;
                              _areaFilterMode = _AreaFilterMode.any;
                            });
                            Navigator.of(context).pop();
                            await _focusOnSelectedArea();
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Set<Marker> getMarkers(List<Data>? list) {
    markers.clear();

    final items = list ?? [];

    for (final item in items) {
      if (!_matchesSelectedArea(item)) continue;
      if (item.lats == null || item.longs == null) continue;

      markers.add(
        Marker(
          markerId: MarkerId('${item.id ?? item.nameKh ?? item.name ?? markers.length}'),
          position: LatLng(item.lats!.toDouble(), item.longs!.toDouble()),
          infoWindow: InfoWindow(
            title: (item.nameKh ?? item.name ?? '').toString(),
            snippet: (item.telephone ?? '').toString(),
          ),
          icon:
              item.type == 1
                  ? (iconBranch.value ?? BitmapDescriptor.defaultMarker)
                  : (iconAgency.value ?? BitmapDescriptor.defaultMarker),
        ),
      );
    }
    return markers;
  }

  @override
  void dispose() {
    _controller.future
        .then((controller) {
          controller.dispose();
        })
        .catchError((e) {
          debugPrint("Error disposing map controller: $e");
        });

    super.dispose();
  }
}
