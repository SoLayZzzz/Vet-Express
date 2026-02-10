
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:express_vet/utils/app_colors.dart';

import '../../utils/alert_dialog.dart';
import '../../utils/app_bar.dart';

class LocationDetailScreen extends StatefulWidget {
  final String lats;
  final String longs;
  final int type;
  final String nameKh;
  final String name;
  final String telephone;

  const LocationDetailScreen({
    super.key,
    required this.lats,
    required this.longs,
    required this.type,
    required this.nameKh,
    required this.name,
    required this.telephone,
  });

  @override
  State<LocationDetailScreen> createState() => LocationDetailScreenState();
}

class LocationDetailScreenState extends State<LocationDetailScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = {};

  // Change from late to nullable and initialized as null
  BitmapDescriptor? iconBranch;
  BitmapDescriptor? iconAgency;

  LatLng showLocation = const LatLng(27.7089427, 85.3086209);
  bool _isIconsLoaded = false; // Add a flag to track icon loading

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    if (Platform.isAndroid) {
      await getIcons();
    } else {
      await getIconsIOS();
    }
    setState(() {
      _isIconsLoaded = true;
    });
  }

  getIcons() async {
    var branchIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_branch.png",
    );
    var agencyIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_agency.png",
    );
    setState(() {
      iconBranch = branchIcon;
      iconAgency = agencyIcon;
    });
  }

  getIconsIOS() async {
    var branchIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_branch.png",
    );
    var agencyIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(10, 10)),
      "assets/images/ic_map_agency_ios.png",
    );

    setState(() {
      iconBranch = branchIcon;
      iconAgency = agencyIcon;
    });
  }

  Set<Marker> getMarkers(double lats, double longs, String nameKh, String name, int type) {
    markers.clear();

    // Check if icons are loaded before creating marker
    if ((type == 1 && iconBranch != null) || (type != 1 && iconAgency != null)) {
      markers.add(
        Marker(
          markerId: MarkerId(LatLng(lats, longs).toString()),
          position: LatLng(lats, longs),
          infoWindow: InfoWindow(title: nameKh, snippet: name),
          icon: type == 1 ? iconBranch! : iconAgency!,
        ),
      );
    }

    return markers;
  }

  Set<Marker> getMarkersType3(double lats, double longs, String nameKh, String name, int type) {
    markers.clear();

    markers.add(
      Marker(
        markerId: MarkerId(LatLng(lats, longs).toString()),
        position: LatLng(lats, longs),
        infoWindow: InfoWindow(title: nameKh, snippet: name),
      ),
    );

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'vet_location'.tr),
      body: _isIconsLoaded ? _buildMapContent() : _buildLoading(),
    );
  }

  Widget _buildMapContent() {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: GoogleMap(
                markers:
                    widget.type != 3
                        ? getMarkers(
                          double.parse(widget.lats),
                          double.parse(widget.longs),
                          widget.nameKh,
                          widget.name,
                          widget.type,
                        )
                        : getMarkersType3(
                          double.parse(widget.lats),
                          double.parse(widget.longs),
                          widget.nameKh,
                          widget.name,
                          widget.type,
                        ),
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(double.parse(widget.lats), double.parse(widget.longs)),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
          ],
        ),
        if (widget.type != 3)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          _open('google.navigation:q=${widget.lats},${widget.longs}&mode=d');
                        },
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.nameKh),
                                const SizedBox(height: 5),
                                Text(
                                  'click_to_find'.tr,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.location_on, color: AppColors.primaryColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Phone Number Section
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side - Labels
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('phone_number_dort'.tr),
                              const SizedBox(height: 5),
                              Text(
                                'check_to_call'.tr,
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Right side - Phone numbers
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ..._getPhoneNumbers().map(
                                (phone) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      final Uri launchUri = Uri(scheme: 'tel', path: phone);
                                      launchUrl(launchUri);
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          phone,
                                          style: const TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.phone_outlined,
                                          color: AppColors.primaryColor,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  /// Parse and get individual phone numbers from the telephone string split by "/"
  List<String> _getPhoneNumbers() {
    if (widget.telephone.isEmpty) return [];

    final phoneNumbers = widget.telephone.split('/');
    return phoneNumbers.map((phone) => phone.trim()).where((phone) => phone.isNotEmpty).toList();
  }

  Future<void> _open(String url) async {
    final Uri fbProtocolUrl = Uri.parse(url);
    try {
      final bool launched = await launchUrl(fbProtocolUrl, mode: LaunchMode.externalApplication);

      if (!launched) {
        alertDialogOneButton(
          title: 'information'.tr,
          description: 'plz_install'.tr,
          buttonText: 'yes'.tr,
        );
      }
    } catch (e) {
      alertDialogOneButton(
        title: 'information'.tr,
        description: 'plz_install_messager'.tr,
        buttonText: 'yes'.tr,
      );
    }
  }
}
