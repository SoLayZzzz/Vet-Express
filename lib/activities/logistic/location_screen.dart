import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:express_vet/activities/logistic/location_search_screen.dart';
import 'package:location/location.dart';

import '../../api/branch.dart';
import '../../models/branch/branch_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/style.dart';

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

  int totalBranch = 0;
  int branch = 0;
  int agency = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(11.578036036368854, 104.922274625954),
    zoom: 6,
  );

  late Future<BranchResponse> futureBranch;
  Location location = Location();
  List<Data> _allBranches = []; // Store all branches data

  @override
  void initState() {
    super.initState();
    futureBranch = BranchList().getBranchList(context);
    if (Platform.isAndroid) {
      getIcons();
    } else {
      getIconsIOS();
    }
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    // Check if location service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    // Check for permission
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the current location
    final userLocation = await location.getLocation();
    setState(() {
      _currentPosition = LatLng(userLocation.latitude!, userLocation.longitude!);
    });
  }

  Future<void> _navigateToCurrentLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15));
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<BranchResponse>(
        future: futureBranch,
        builder: (context, data) {
          if (data.hasData) {
            if ((data.data?.header?.result) == true && (data.data?.header?.statusCode) == 200) {
              if ((data.data?.body?.data)!.isNotEmpty) {
                // Store the branches data
                _allBranches = data.data!.body!.data!;

                return Scaffold(
                  body: Stack(
                    children: [
                      Column(
                        children: [
                          ///display google map
                          Expanded(
                            child: GoogleMap(
                              markers: getMarkers(data.data?.body?.data),
                              mapType: MapType.normal,
                              initialCameraPosition: _kGooglePlex,
                              zoomControlsEnabled: false, // Disable zoom control
                              myLocationEnabled:
                                  true, // Shows the user's current location on the map
                              myLocationButtonEnabled: false, // Hide the default location button
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
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/images/ic_branch.png', width: 34),
                                      const SizedBox(width: 10),
                                      Text(branch.toString()),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Image.asset('assets/images/ic_agency.png', width: 34),
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
              }
              if ((data.data?.body?.data)!.isEmpty) {
                return const Text('');
              }
            }
            return Scaffold(body: Center(child: Text('no_data'.tr)));
          } else if (data.hasError) {
            return const Text('');
          }

          return const Scaffold(
            body: Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
              ),
            ),
          );
        },
      ),
    );
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
    // Reset counters before processing the list
    branch = 0;
    agency = 0;
    markers.clear(); // Clear existing markers to prevent duplicates

    int size = list!.length;

    for (int i = 0; i < size; i++) {
      if (list[i].type == 1) {
        branch += 1;
      } else {
        agency += 1;
      }

      markers.add(
        Marker(
          markerId: MarkerId('${list[i].nameKh}'),
          position: LatLng((list[i].lats)!.toDouble(), (list[i].longs)!.toDouble()),
          infoWindow: InfoWindow(
            title: (list[i].nameKh)!.toString(),
            snippet: (list[i].name)!.toString(),
          ),
          icon: list[i].type == 1 ? iconBranch : iconAgency,
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
