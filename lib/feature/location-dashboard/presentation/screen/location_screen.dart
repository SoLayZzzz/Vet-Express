import 'dart:async';
import 'dart:io';

import 'package:express_vet/feature/location-dashboard/presentation/binding/location_binding.dart';
import 'package:express_vet/feature/location-dashboard/presentation/controller/location_controller.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/style.dart';
import 'package:flutter/material.dart';
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
  late BitmapDescriptor iconBranch;
  late BitmapDescriptor iconAgency;
  late LatLng _currentPosition;

  int branch = 0;
  int agency = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(11.578036036368854, 104.922274625954),
    zoom: 6,
  );

  late final LocationController locationController;
  Location location = Location();
  List<Data> _allBranches = [];

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
    setState(() {
      _currentPosition = LatLng(
        userLocation.latitude!,
        userLocation.longitude!,
      );
    });
  }

  Future<void> _navigateToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15));
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
                  child: GoogleMap(
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
                            Image.asset(
                              'assets/images/ic_branch.png',
                              width: 34,
                            ),
                            const SizedBox(width: 10),
                            Text(branch.toString()),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/ic_agency.png',
                              width: 34,
                            ),
                            const SizedBox(width: 10),
                            Text(agency.toString()),
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
    var iconBranch = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_branch.png",
    );
    var iconAgency = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_agency.png",
    );
    setState(() {
      this.iconBranch = iconBranch;
      this.iconAgency = iconAgency;
    });
  }

  getIconsIOS() async {
    var iconBranch = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_branch_ios.png",
    );
    var iconAgency = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_agency_ios.png",
    );

    setState(() {
      this.iconBranch = iconBranch;
      this.iconAgency = iconAgency;
    });
  }

  Set<Marker> getMarkers(List<Data>? list) {
    branch = 0;
    agency = 0;
    markers.clear();

    final items = list ?? [];

    for (final item in items) {
      if (item.type == 1) {
        branch += 1;
      } else {
        agency += 1;
      }

      markers.add(
        Marker(
          markerId: MarkerId('${item.nameKh}'),
          position: LatLng((item.lats)!.toDouble(), (item.longs)!.toDouble()),
          infoWindow: InfoWindow(
            title: (item.nameKh)!.toString(),
            snippet: (item.name)!.toString(),
          ),
          icon: item.type == 1 ? iconBranch : iconAgency,
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
