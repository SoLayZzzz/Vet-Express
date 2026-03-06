import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:express_vet/asset_image.dart';
import 'package:express_vet/feature/location-dashboard/presentation/binding/location_binding.dart';
import 'package:express_vet/feature/location-dashboard/presentation/controller/location_controller.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import './location_search_screen.dart';

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

  final RxInt branch = 0.obs;
  final RxInt agency = 0.obs;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(11.578036036368854, 104.922274625954),
    zoom: 6,
  );

  late final LocationController locationController;
  Location location = Location();
  List<Data> _allBranches = [];

  Future<BitmapDescriptor> _bitmapFromAsset(
    String assetPath, {
    int targetWidth = 64,
  }) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth,
    );
    final fi = await codec.getNextFrame();
    final bytes = await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

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

    _getUserLocation();

    // Fetch branches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationController.fetchBranches(context: context);
    });
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final userLocation = await location.getLocation();
    _currentPosition.value = LatLng(
      userLocation.latitude!,
      userLocation.longitude!,
    );
  }

  Future<void> _navigateToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    if (_currentPosition.value != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition.value!, 15),
      );
    }
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

      final int branchCount = uiState.branches.where((e) => e.type == 1).length;
      final int agencyCount = uiState.branches.length - branchCount;

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
                        _controller.complete(controller);
                      },
                    ),
                  ),
                ),

                /// display total branch and agency
                Container(
                  color: AppColors.whiteColor,
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(AssetImages.ic_branch, width: 34),
                            const SizedBox(width: 10),
                            Text(branchCount.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(AssetImages.ic_agency, width: 34),
                            const SizedBox(width: 10),
                            Text(agencyCount.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            /// searching location
            Padding(
              padding: const EdgeInsets.all(15),
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

            /// icon click to see the current user location
            Positioned(
              right: 10,
              bottom: MediaQuery.of(context).size.height * 0.09,
              child: InkWell(
                onTap: _navigateToCurrentLocation,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
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
    final branchIcon = await _bitmapFromAsset(AssetImages.ic_map_branch);
    final agencyIcon = await _bitmapFromAsset(AssetImages.ic_map_agency);
    iconBranch.value = branchIcon;
    iconAgency.value = agencyIcon;
  }

  getIconsIOS() async {
    final branchIcon = await _bitmapFromAsset(AssetImages.ic_map_branch_ios);
    final agencyIcon = await _bitmapFromAsset(AssetImages.ic_map_agency_ios);
    iconBranch.value = branchIcon;
    iconAgency.value = agencyIcon;
  }

  Set<Marker> getMarkers(List<Data>? list) {
    markers.clear();

    final items = list ?? [];

    for (final item in items) {
      markers.add(
        Marker(
          markerId: MarkerId('${item.nameKh}'),
          position: LatLng((item.lats)!.toDouble(), (item.longs)!.toDouble()),
          infoWindow: InfoWindow(
            title: (item.nameKh)!.toString(),
            snippet: (item.name)!.toString(),
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
