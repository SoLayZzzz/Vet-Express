import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import '../../../../../models/destination/destination_province.dart';
import '../../data/model/response/uom.dart';
import '../../../../../utils/app_colors.dart';

import '../controller/self_service_controller.dart';

class SelectLogisticScreen extends GetView<SelfServiceController> {
  SelectLogisticScreen({super.key});

  String get _selectType {
    final args = Get.arguments;
    if (args is Map && args['selectType'] != null) {
      return args['selectType'].toString();
    }
    return '';
  }

  final TextEditingController _searchController = TextEditingController();

  Widget _buildProvinceList() {
    final list = controller.state.filteredProvinceData;
    if (list == null) {
      return _buildLoading();
    }

    if (list.isEmpty) {
      return Expanded(child: Center(child: Text('data_not_found'.tr)));
    }

    return Expanded(
      child: ListView.separated(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          final item = list[index];
          return _ProvinceListItem(item: item, selectType: _selectType);
        },
        separatorBuilder: (BuildContext context, int index) {
          return const Divider();
        },
      ),
    );
  }

  Widget _buildUomList() {
    final list = controller.state.filteredUomData;
    if (list == null) {
      return _buildLoading();
    }

    if (list.isEmpty) {
      return Expanded(child: Center(child: Text('data_not_found'.tr)));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          final item = list[index];
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initSelect(
        context: context,
        selectType: _selectType,
        provinceId: ValueStatic.provinceId,
      );
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            ValueStatic.ticketType == '3'
                ? AppColors.airBusColor
                : AppColors.primaryColor,
        elevation: 0.2,
        leading: IconButton(
          icon: const Icon(
            Ionicons.chevron_back_outline,
            color: AppColors.whiteColor,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Card(
          child: Container(
            height: 45,
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: controller.onSearchChanged,
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
            if (_selectType != "uom")
              Obx(
                () => FutureBuilder<ProvinceResponse>(
                  future: controller.state.futureSelect,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.header?.statusCode == 200 &&
                          snapshot.data!.header?.result == true) {
                        final data = snapshot.data!.body?.data;
                        if (data != null && data.isNotEmpty) {
                          return _buildProvinceList();
                        }
                      }
                    } else if (snapshot.hasError) {
                      return Expanded(
                        child: Center(child: Text('error_loading_data'.tr)),
                      );
                    }
                    return _buildLoading();
                  },
                ),
              ),
            if (_selectType == "uom")
              Obx(
                () => FutureBuilder<UomListResponse>(
                  future: controller.state.futureSelectUom,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data!.header?.statusCode == 200 &&
                          snapshot.data!.header?.result == true) {
                        final data = snapshot.data!.body?.data;
                        if (data != null && data.isNotEmpty) {
                          return _buildUomList();
                        }
                      }
                    } else if (snapshot.hasError) {
                      return Expanded(
                        child: Center(child: Text('error_loading_data'.tr)),
                      );
                    }
                    return _buildLoading();
                  },
                ),
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
        Get.back();
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
        Get.back();
      },
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Text(item.name?.toString() ?? ''),
            ),
            Container(height: 0.1, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
