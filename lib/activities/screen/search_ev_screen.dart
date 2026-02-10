import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ev_charger/ev_charger_response.dart';
import '../../utils/app_bar.dart';
import '../../utils/app_colors.dart';

class SearchEvScreen extends StatefulWidget {
  final List<BodyEV> allStations;

  const SearchEvScreen({super.key, required this.allStations});

  @override
  State<SearchEvScreen> createState() => _SearchEvScreenState();
}

class _SearchEvScreenState extends State<SearchEvScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<BodyEV> _filteredStations = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterStations);
    _filteredStations = widget.allStations;
  }

  ///filter the stations based on the search query
  void _filterStations() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _hasSearched = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredStations = widget.allStations;
      } else {
        _filteredStations =
            widget.allStations.where((station) {
              final name = station.name?.toLowerCase() ?? '';
              final address = station.address?.toLowerCase() ?? '';
              return name.contains(query) || address.contains(query);
            }).toList();
      }
    });
  }

  ///handle the station selection
  void _onStationSelected(BodyEV station) {
    Navigator.pop(context, station);
  }

  ///build the station item
  Widget _buildStationItem(BodyEV station) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.ev_station, color: AppColors.primaryColor),
      ),
      title: Text(
        station.name ?? "Unknown Station",
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle:
          station.address != null
              ? Text(station.address!, maxLines: 1, overflow: TextOverflow.ellipsis)
              : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _onStationSelected(station),
    );
  }

  ///build the empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/ev_no-data.png', width: 80, height: 80),
          const SizedBox(height: 16),
          Text('data_not_found'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, "search_station".tr),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "search_station".tr,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                          : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child:
                _hasSearched && _filteredStations.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filteredStations.length,
                      itemBuilder: (context, index) {
                        return _buildStationItem(_filteredStations[index]);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
