import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/api/uom.dart';
import 'dart:async';

import '../../api/destination.dart';
import '../../models/destination/destination_province.dart';
import '../../models/uom/uom.dart';
import '../../utils/app_colors.dart';

class SelectLogisticScreen extends StatefulWidget {
  final String selectType;

  const SelectLogisticScreen({super.key, required this.selectType});

  @override
  State<SelectLogisticScreen> createState() => _SelectLogisticScreenState();
}

class _SelectLogisticScreenState extends State<SelectLogisticScreen> {
  late Future<ProvinceResponse> _futureSelect;
  late Future<UomListResponse> _futureSelectUom;

  // Store all data locally
  List<Data>? _allProvinceData;
  List<Data>? _filteredProvinceData;
  List<UomData>? _allUomData;
  List<UomData>? _filteredUomData;

  Timer? _debounceTimer;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.selectType == 'province') {
      _futureSelect = Destination().province(context, '');
    } else if (widget.selectType == 'location') {
      _futureSelect = Destination().desByProvince(context, ValueStatic.provinceId, '');
    } else {
      _futureSelectUom = UOMList().uom(context);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String searchText) {
    // Debounce to prevent filtering on every keystroke
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return; // Extra safety check
      _filterData(searchText);
    });
  }

  void _filterData(String searchText) {
    final query = searchText.toLowerCase().trim();

    setState(() {
      if (widget.selectType != "uom") {
        // Filter province/location data
        if (_allProvinceData != null) {
          if (query.isEmpty) {
            _filteredProvinceData = _allProvinceData;
          } else {
            _filteredProvinceData =
                _allProvinceData!.where((item) {
                  final name = item.name?.toLowerCase() ?? '';
                  return name.contains(query);
                }).toList();
          }
        }
      } else {
        // Filter UOM data
        if (_allUomData != null) {
          if (query.isEmpty) {
            _filteredUomData = _allUomData;
          } else {
            _filteredUomData =
                _allUomData!.where((item) {
                  final name = item.name?.toLowerCase() ?? '';
                  return name.contains(query);
                }).toList();
          }
        }
      }
    });
  }

  Widget _buildProvinceList() {
    if (_filteredProvinceData == null) {
      return _buildLoading();
    }

    if (_filteredProvinceData!.isEmpty) {
      return Expanded(child: Center(child: Text('data_not_found'.tr)));
    }

    return Expanded(
      child: ListView.separated(
        itemCount: _filteredProvinceData!.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _filteredProvinceData![index];
          return _ProvinceListItem(item: item, selectType: widget.selectType);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }

  Widget _buildUomList() {
    if (_filteredUomData == null) {
      return _buildLoading();
    }

    if (_filteredUomData!.isEmpty) {
      return Expanded(child: Center(child: Text('data_not_found'.tr)));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _filteredUomData!.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _filteredUomData![index];
          return _UomListItem(item: item);
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Expanded(
      child: Center(
        child: SizedBox(
          height: 50.0,
          width: 50.0,
          child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            ValueStatic.ticketType == '3' ? AppColors.airBusColor : AppColors.primaryColor,
        elevation: 0.2,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back_outline, color: AppColors.whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Card(
          child: Container(
            height: 45,
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'search'.tr,
                contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                suffixIcon: const Icon(Icons.search),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (widget.selectType != "uom")
              FutureBuilder<ProvinceResponse>(
                future: _futureSelect,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.header?.statusCode == 200 &&
                        snapshot.data!.header?.result == true) {
                      if (snapshot.data!.body!.data!.isNotEmpty) {
                        // Store data once when first loaded
                        if (_allProvinceData == null) {
                          _allProvinceData = snapshot.data!.body!.data!;
                          _filteredProvinceData = _allProvinceData;
                        }
                        return _buildProvinceList();
                      }
                    }
                  } else if (snapshot.hasError) {
                    // Handle error
                    return Expanded(child: Center(child: Text('error_loading_data'.tr)));
                  }

                  return _buildLoading();
                },
              ),
            if (widget.selectType == "uom")
              FutureBuilder<UomListResponse>(
                future: _futureSelectUom,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.header?.statusCode == 200 &&
                        snapshot.data!.header?.result == true) {
                      if (snapshot.data!.body!.data!.isNotEmpty) {
                        // Store data once when first loaded
                        if (_allUomData == null) {
                          _allUomData = snapshot.data!.body!.data!;
                          _filteredUomData = _allUomData;
                        }
                        return _buildUomList();
                      }
                    }
                  } else if (snapshot.hasError) {
                    // Handle error
                    return Expanded(child: Center(child: Text('error_loading_data'.tr)));
                  }

                  return _buildLoading();
                },
              ),
          ],
        ),
      ),
    );
  }
}

// Optimized province list item widget
class _ProvinceListItem extends StatelessWidget {
  final Data item;
  final String selectType;

  const _ProvinceListItem({required this.item, required this.selectType});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (selectType == 'province') {
          ValueStatic.provinceName = item.name?.toString() ?? '';
          ValueStatic.provinceId = item.id?.toString() ?? '';
          ValueStatic.locationId = '';
          ValueStatic.locationName = '';
        } else {
          ValueStatic.locationName = item.name?.toString() ?? '';
          ValueStatic.locationId = item.id?.toString() ?? '';
        }
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        child: Text(item.name?.toString() ?? ''),
      ),
    );
  }
}

// Optimized UOM list item widget
class _UomListItem extends StatelessWidget {
  final UomData item;

  const _UomListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ValueStatic.uomName = item.name?.toString() ?? '';
        ValueStatic.uomId = item.id?.toString() ?? '';
        Navigator.pop(context);
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(15), child: Text(item.name?.toString() ?? '')),
            Container(height: 0.1, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
