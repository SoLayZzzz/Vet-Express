import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as goa;
import 'package:express_vet/activities/logistic/booking_delivery_screen.dart';

import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';

class BookingDeliveryLiveLocationScreen extends StatefulWidget {
  const BookingDeliveryLiveLocationScreen({super.key});

  @override
  State<BookingDeliveryLiveLocationScreen> createState() =>
      BookingDeliveryLiveLocationScreenState();
}

class BookingDeliveryLiveLocationScreenState extends State<BookingDeliveryLiveLocationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> markers = {};

  late String lats = " ", longs = "";
  late String address = '';
  bool loading = false;

  @override
  void initState() {
    super.initState();

    _initLocationService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'live_location_title'.tr),
      body: Stack(
        children: [
          if (!loading)
            const Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(
                  value: null,
                  strokeWidth: 5.0,
                ),
              ),
            ),
          if (lats != "" && longs != "")
            Column(
              children: [
                Expanded(
                    child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(double.parse(lats.toString()), double.parse(longs.toString())),
                    zoom: 16,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                )),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(address),
              ),
            ),
          ),
          if (loading)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: CupertinoButton(
                            color: AppColors.primaryColor,
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'next'.tr,
                                  style: const TextStyle(fontSize: 16, color: AppColors.whiteColor),
                                )),
                            onPressed: () {
                              BookingDeliveryScreen.lats = lats;
                              BookingDeliveryScreen.longs = longs;
                              BookingDeliveryScreen.address = address;

                              Navigator.of(context).pop("1");
                            }),
                      ),
                    ),
                  )),
            ),
        ],
      ),
    );
  }

  Future _initLocationService() async {
    var location = Location();

    if (!await location.serviceEnabled()) {
      if (!await location.requestService()) {
        return;
      }
    }

    var permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }

    var loc = await location.getLocation();

    getAddress(loc.latitude, loc.longitude);

    //print(loc.latitude.toString());
    //print(loc.longitude.toString());

    setState(() {
      lats = loc.latitude.toString();
      longs = loc.longitude.toString();

      loading = true;
    });
  }

  Future getAddress(latitude, longitude) async {
    List<goa.Placemark> addresses = await goa.placemarkFromCoordinates(latitude!, longitude!);

    //print(addresses);

    setState(() {
      address =
          "${"street".tr}${addresses[0].street}, ${addresses[0].name}, ${addresses[0].locality}, ${addresses[0].country}";
    });
  }
}
