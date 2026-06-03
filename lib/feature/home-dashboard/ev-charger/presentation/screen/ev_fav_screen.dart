import 'package:express_vet/utils/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controller/ev_station_controller.dart';
import '../../data/model/response/ev_station_list_response.dart';

class EvFavoriteScreen extends GetView<EvStationController> {
  const EvFavoriteScreen({super.key});

  Future<void> _openMap(String lat, String lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error'.tr, 'Could not launch maps'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'favorites'.tr),
      body: Obx(() {
        controller.currentPosition.value;
        controller.isLocationLoading.value;

        if (controller.isLoading.value && controller.favoriteStations.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.hasError.value) {
          return _buildErrorState();
        }

        if (controller.favoriteStations.isEmpty) {
          return _buildEmptyState();
        }

        return _buildStationList(controller.favoriteStations);
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
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
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'no_favorites'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'add_stations_to_favorites'.tr,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStationList(List<EvStationListDatum> stations) {
    return ListView(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: stations.map((station) => _buildStationCard(station)).toList(),
    );
  }

  Widget _buildStationCard(EvStationListDatum station) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        // Ensures the image stretches to match content height
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. LEFT SIDE IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                // Using the image from your code, or a placeholder
                "https://images.unsplash.com/photo-1593941707882-a5bba14938c7?auto=format&fit=crop&q=80&w=200",
                width: 110, // Fixed width to match screenshot proportion
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 110,
                    color: Colors.grey[200],
                    child: const Icon(Icons.ev_station, color: Colors.grey),
                  );
                },
              ),
            ),

            // 2. RIGHT SIDE CONTENT
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // -- Header: Name + Favorite Button --
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

                        Icon(Icons.favorite, color: Colors.red, size: 22),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // -- Address --
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

                    // -- Connector & Price Info --
                    Row(
                      children: [
                        // Connector
                        Icon(
                          Icons.ev_station,
                          size: 16,
                          color: Colors.blueGrey[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "DC 1/6", // Or use ${controller.allStations.length}/6
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Price
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
                        Text(
                          "${station.pricePerKwh?.toStringAsFixed(2) ?? '0.35'} KHR/kWh",
                          style: const TextStyle(
                            color: Color(0xFFE65100),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // -- Bottom Actions: Direction & Distance --
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Clickable Direction Area
                        InkWell(
                          onTap: () {
                            if (station.lats != null && station.longs != null) {
                              _openMap(station.lats!, station.longs!);
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Get Direction",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Distance Text
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
      debugPrint('Distance Calculation (Fav): lat or lng is null');
      return 'N/A km';
    }

    final stationLat = double.tryParse(lat.trim());
    final stationLng = double.tryParse(lng.trim());
    if (stationLat == null || stationLng == null) {
      debugPrint(
        'Distance Calculation (Fav): failed to parse lat="$lat" or lng="$lng"',
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
        'Distance Calculation (Fav): station($stationLat, $stationLng), user($userLat, $userLng) -> $result',
      );
      return result;
    }

    debugPrint(
      'Distance Calculation (Fav): currentPosition is null, station($stationLat, $stationLng)',
    );
    return 'N/A km';
  }

  double _calculateSimpleDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    // Simple approximation - for production use Haversine formula
    final latDiff = (lat1 - lat2).abs();
    final lngDiff = (lng1 - lng2).abs();
    return (latDiff + lngDiff) * 111.0; // Rough conversion to kilometers
  }
}
