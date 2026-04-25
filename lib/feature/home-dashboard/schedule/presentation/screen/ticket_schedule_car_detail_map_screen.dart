import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TicketScheduleCarDetailMapScreen extends StatefulWidget {
  final String address;
  final String name;
  final double latitude;
  final double longitude;

  const TicketScheduleCarDetailMapScreen({
    super.key,
    required this.address,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<TicketScheduleCarDetailMapScreen> createState() =>
      _TicketScheduleCarDetailMapScreenState();
}

class _TicketScheduleCarDetailMapScreenState
    extends State<TicketScheduleCarDetailMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _kMapCenter;
  CameraPosition? _kInitialPosition;

  @override
  void initState() {
    super.initState();
    _kMapCenter = LatLng(widget.latitude, widget.longitude);
    _kInitialPosition = CameraPosition(target: _kMapCenter!, zoom: 15.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: Stack(
                  children: [
                    if (_kInitialPosition != null)
                      GoogleMap(
                        initialCameraPosition: _kInitialPosition!,
                        zoomControlsEnabled: false,
                        markers: {
                          Marker(
                            markerId: const MarkerId("_location"),
                            icon: BitmapDescriptor.defaultMarker,
                            position: _kMapCenter!,
                          ),
                        },
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
                    Positioned(
                      left: 10,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close, size: 24),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: MediaQuery.of(context).size.height * 1 / 7,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: IconButton(
                          onPressed: () {
                            _openGoogleMaps();
                          },
                          icon: Image.asset(
                            "assets/images/ic_to_map.png",
                            height: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 1,
              right: 1,
              bottom: 1,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text(
                            "Address: ",
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 5),
                          Expanded(child: Text(widget.address)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.latitude},${widget.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      debugPrint('Could not launch Google Maps for this location.');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose(); // Safely dispose of the controller
    super.dispose();
  }
}
