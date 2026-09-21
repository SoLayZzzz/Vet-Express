import 'package:cached_network_image/cached_network_image.dart';
import 'package:express_vet/asset_image.dart';
import 'package:express_vet/base/base_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/model/response/ev_station_detail_response.dart';
import '../../data/model/response/ev_station_list_response.dart';
import '../controller/ev_station_controller.dart';


class EVStationDetailSheet extends StatefulWidget {
  final EvStationListDatum station;

  const EVStationDetailSheet({super.key, required this.station});

  @override
  State<EVStationDetailSheet> createState() => _EVStationDetailSheetState();
}

class _EVStationDetailSheetState extends State<EVStationDetailSheet> {
  late final EvStationController controller = Get.find<EvStationController>();

  @override
  void initState() {
    super.initState();
    controller.stationDetail.value = null;
    final id = widget.station.id;
    if (id != null) {
      controller.fetchStationDetail(id);
    }
  }

  String _gunIconPath(String? name) {
  final n = (name ?? '').toUpperCase();
  if (n.contains('EU') || n.contains('CCS') || n.contains('DC') || n.contains('CH')) {
    return AssetImages.ic_ev_dc;
  }
  return AssetImages.ic_ev_gb;
}


  String? _resolveImageUrl(String? imageUrl) {
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

  Future<void> _openLink(String? link) async {
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _callPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:${phone.split('/').first.trim()}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Obx(() {
        if (controller.isLoadingStationDetail.value &&
            controller.stationDetail.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(context, controller.stationDetail.value);
      }),
    );
  }

  Widget _buildContent(BuildContext context, EvStationDetailDatum? detail) {
    final station = widget.station;
    final imageUrl = _resolveImageUrl(detail?.imageUrl ?? station.imageUrl);
    final profileUrl = _resolveImageUrl(detail?.franchiseProfileUrl);
    final chargerGuns = detail?.chargerGuns ?? [];
    final contacts = detail?.contactUs ?? [];
    final amenities = detail?.amenities ?? [];
    final surroundings = detail?.surroundings ?? [];
    final stationGuns = station.gunInform ?? [];

    final openStatus =
        detail?.is24Hours == 1 ? '24/7' : (detail?.openHour ?? '-');

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Image Section
              Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: imageUrl == null
                        ? Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.ev_station,
                              size: 48,
                              color: Colors.grey,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey.shade200),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.ev_station,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: 12,
                    left: 16,
                    child: Text(
                      detail?.name ?? station.name ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.black54, blurRadius: 4),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 16,
                    child: Row(
                      children: [
                        _buildCircleIconButton(
                          Icons.favorite_border,
                          onTap: () {
                            final id = station.id;
                            if (id != null) {
                              controller.toggleFavorite(
                                id,
                                detail?.name ?? station.name ?? '',
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildCircleIconButton(
                          Icons.close,
                          onTap: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${detail?.isHasCharger ?? '-'} 🔌  ${station.value ?? '-'} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Card Body
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Station Header
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          radius: 20,
                          backgroundImage: profileUrl != null
                              ? CachedNetworkImageProvider(profileUrl)
                              : null,
                          child: profileUrl == null
                              ? const Icon(
                                  Icons.ev_station,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail?.franchiseName ??
                                    detail?.name ??
                                    station.name ??
                                    '-',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                detail?.companyName ?? 'EV Station',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Location Box
                    _buildInfoContainer(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              detail?.address ?? station.address ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle('Charge Point Info'),
                    const SizedBox(height: 8),

                    // Open Status
                    _buildInfoContainer(
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey),
                          const SizedBox(width: 10),
                          const Text(
                            'Open ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            openStatus,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Charger Options Block
                    // Charger Options Block
_buildInfoContainer(
  child: Column(
    children: [
      // Display stationGuns if present, or fallback to default GB row
      if (stationGuns.isNotEmpty)
        for (var i = 0; i < stationGuns.length; i++) ...[
          if (i > 0) const Divider(height: 24),
          _buildChargerRow(
            stationGuns[i].name ?? 'GB',
            '-',
            '៛${station.pricePerKwh?.toStringAsFixed(0) ?? '-'}/kWh',
            'X${stationGuns[i].amount ?? '-'}',
            _gunIconPath(stationGuns[i].name),
          ),
        ]
      else
        _buildChargerRow(
          'GB',
          '-',
          '៛${station.pricePerKwh?.toStringAsFixed(0) ?? '-'}/kWh',
          'X-',
          AssetImages.ic_ev_gb,
        ),

      const Divider(height: 24),

      // Display chargerGuns if present, or fallback to default EU / DC row
      if (chargerGuns.isNotEmpty)
        for (var i = 0; i < chargerGuns.length; i++) ...[
          if (i > 0) const Divider(height: 24),
          _buildChargerRow(
            chargerGuns[i].name ?? 'EU',
            '${chargerGuns[i].maxAmperage?.toStringAsFixed(0) ?? '-'} kW',
            '៛${chargerGuns[i].pricePerKwh?.toStringAsFixed(0) ?? '-'}/kWh',
            'X${chargerGuns[i].qty ?? '-'}',
            _gunIconPath(chargerGuns[i].name),
          ),
        ]
      else
        _buildChargerRow(
          'EU',
          '-',
          '៛-/kWh',
          'X-',
          AssetImages.ic_ev_dc,
        ),

      const SizedBox(height: 16),
      Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.deepOrange,
            radius: 16,
            child: Icon(
              Icons.ev_station,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Operated by',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  detail?.companyName ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _callPhone(
              detail?.phoneNumber ?? station.phoneNumber,
            ),
            child: _buildSocialButton(
              Icons.phone_outlined,
              Colors.grey.shade200,
              Colors.black,
            ),
          ),
          for (final contact in contacts.take(2)) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _openLink(contact.link),
              child: _buildSocialButton(
                Icons.send,
                Colors.blue,
                Colors.white,
              ),
            ),
          ],
        ],
      ),
    ],
  ),
),

                    const SizedBox(height: 16),
                    _buildSectionTitle('Amenities'),
                    const SizedBox(height: 8),
                    _buildInfoContainer(
                      child: GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        childAspectRatio: 4,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          if (amenities.isEmpty)
                            const _AmenityItem(text: '-')
                          else
                            for (final amenity in amenities)
                              _AmenityItem(text: amenity.name ?? '-'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle('Surroundings'),
                    const SizedBox(height: 8),
                    _buildInfoContainer(
                      child: Column(
                        children: [
                          if (surroundings.isEmpty)
                            const _AmenityItem(text: '-')
                          else
                            for (final item in surroundings)
                              _AmenityItem(text: item.name ?? '-'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Navigation FAB
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: () => _openMap(
              detail?.lats ?? station.lats,
              detail?.longs ?? station.longs,
            ),
            backgroundColor: Colors.grey.shade300,
            elevation: 2,
            child: const Icon(Icons.turn_right, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.grey, fontSize: 13),
    );
  }

  Widget _buildInfoContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildCircleIconButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.black.withValues(alpha: 0.3),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color bg, Color iconColor) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: bg,
      child: Icon(icon, size: 16, color: iconColor),
    );
  }

  Widget _buildChargerRow(
  String title,
  String power,
  String price,
  String count,
  String iconPath,
) {
  return Row(
    children: [
      Image.asset(iconPath, width: 36, height: 36),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      const Spacer(),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on, size: 14, color: Colors.grey),
              Text(
                power,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.flash_on, size: 14, color: Colors.grey),
              Text(
                price,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(width: 20),
      Text(
        count,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ],
  );
}
}

class _AmenityItem extends StatelessWidget {
  final String text;
  const _AmenityItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check, size: 18, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ],
    );
  }
}