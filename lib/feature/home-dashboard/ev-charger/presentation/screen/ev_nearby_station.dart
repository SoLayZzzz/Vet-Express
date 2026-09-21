import 'package:cached_network_image/cached_network_image.dart';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/response/ev_station_list_response.dart';
import '../controller/ev_station_controller.dart';
import 'ev_detailStation_sheet.dart';

class EVNearbyStationsScreen extends GetView<EvStationController> {
  const EVNearbyStationsScreen({super.key});

  String? _resolveStationImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    if (imageUrl.startsWith('http')) return imageUrl;
    final clean = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    return '${BaseUrl.BASE_URL_SLIDE_IMAGE_EV}${Uri.encodeFull(clean)}';
  }

  Future<void> _openMap(String? lat, String? lng) async {
    if (lat == null || lng == null) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openEVDetailsModal(BuildContext context, EvStationListDatum station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EVStationDetailSheet(station: station),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Nearby Station'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allStations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.allStations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.ev_station_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'no_stations_found'.tr,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          itemCount: controller.allStations.length,
          itemBuilder: (context, index) {
            return StationCard(
              station: controller.allStations[index],
              onTap:
                  () => _openEVDetailsModal(
                    context,
                    controller.allStations[index],
                  ),
              onDirection:
                  () => _openMap(
                    controller.allStations[index].lats,
                    controller.allStations[index].longs,
                  ),
              imageUrlResolver: _resolveStationImageUrl,
            );
          },
        );
      }),
    );
  }
}

class StationCard extends StatelessWidget {
  final EvStationListDatum station;
  final VoidCallback? onTap;
  final VoidCallback? onDirection;
  final String? Function(String?) imageUrlResolver;

  const StationCard({
    super.key,
    required this.station,
    this.onTap,
    this.onDirection,
    required this.imageUrlResolver,
  });

  String _gunIconPath(String? name) {
    final n = (name ?? '').toUpperCase();
    if (n.contains('GB')) return AssetImages.ic_ev_gb;
    if (n.contains('CCS') || n.contains('DC') || n.contains('CH')) {
      return AssetImages.ic_ev_dc;
    }
    return AssetImages.ic_ev_gb;
  }

  @override
  Widget build(BuildContext context) {
    final bool isOpen = (station.totalChargerAvailable ?? 0) > 0;
    final imageUrl = imageUrlResolver(station.imageUrl);
    final guns = station.gunInform ?? [];
    final distanceValue = double.tryParse(station.value ?? '');
    final distanceText =
        distanceValue != null
            ? '${distanceValue.toStringAsFixed(1)} km'
            : '-';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F9),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Station Image
            SizedBox(
              width: 130,
              height: double.infinity,
              child:
                  imageUrl == null
                      ? Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.ev_station,
                          size: 36,
                          color: Colors.grey,
                        ),
                      )
                      : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) =>
                                Container(color: Colors.grey.shade200),
                        errorWidget:
                            (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.ev_station,
                                size: 36,
                                color: Colors.grey,
                              ),
                            ),
                      ),
            ),

            // Station Content Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            station.name ?? '-',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isOpen ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOpen ? 'Open' : 'Closed',
                              style: TextStyle(
                                color:
                                    isOpen ? Colors.grey[600] : Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Power & Price Specs
                    Row(
                      children: [
                        const Icon(
                          Icons.ev_station,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          'DC ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${station.totalChargerAvailable ?? '-'}/${station.totalCharger ?? '-'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          '\$ ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Start from ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${station.pricePerKwh?.toStringAsFixed(2) ?? '-'} KHR/kWh',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Plug Types
                    Row(
                      children: [
                        if (guns.isEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                AssetImages.ic_ev_dc,
                                width: 16,
                                height: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '-',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          )
                        else
                          for (var i = 0; i < guns.length; i++) ...[
                            if (i > 0) const SizedBox(width: 16),
                            Image.asset(
                              _gunIconPath(guns[i].name),
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              guns[i].name ?? '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                      ],
                    ),

                    // Get Direction Action
                    GestureDetector(
                      onTap: onDirection,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.near_me_outlined,
                            size: 16,
                            color: Color(0xFF5C6BC0),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Get Direction $distanceText',
                            style: const TextStyle(
                              color: Color(0xFF5C6BC0),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
}
