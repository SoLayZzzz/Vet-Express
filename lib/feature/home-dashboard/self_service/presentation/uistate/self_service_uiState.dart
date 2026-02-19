import 'dart:async';

import 'package:express_vet/feature/home-dashboard/self_service/data/model/response/uom.dart';
import 'package:express_vet/models/destination/destination_province.dart';
import 'package:flutter/widgets.dart';

class SelfServiceUistate {
  String? selectType;
  String? locationProvinceId;
  String searchText;

  Future<ProvinceResponse>? futureSelect;
  Future<UomListResponse>? futureSelectUom;

  List<Data>? allProvinceData;
  List<Data>? filteredProvinceData;
  List<UomData>? allUomData;
  List<UomData>? filteredUomData;

  Timer? debounceTimer;

  final TextEditingController phoneSenderController;
  final TextEditingController phoneReceivedController;
  final TextEditingController provinceController;
  final TextEditingController locationController;
  final TextEditingController itemPriceController;
  final TextEditingController amountController;
  final TextEditingController unitController;

  SelfServiceUistate({
    this.selectType,
    this.locationProvinceId,
    this.searchText = '',
    this.futureSelect,
    this.futureSelectUom,
    this.allProvinceData,
    this.filteredProvinceData,
    this.allUomData,
    this.filteredUomData,
    TextEditingController? phoneSenderController,
    TextEditingController? phoneReceivedController,
    TextEditingController? provinceController,
    TextEditingController? locationController,
    TextEditingController? itemPriceController,
    TextEditingController? amountController,
    TextEditingController? unitController,
  }) : phoneSenderController = phoneSenderController ?? TextEditingController(),
       phoneReceivedController =
           phoneReceivedController ?? TextEditingController(),
       provinceController = provinceController ?? TextEditingController(),
       locationController = locationController ?? TextEditingController(),
       itemPriceController = itemPriceController ?? TextEditingController(),
       amountController = amountController ?? TextEditingController(),
       unitController = unitController ?? TextEditingController();
}
