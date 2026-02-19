import 'dart:async';

import 'package:express_vet/base/endpoint.dart';
import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/models/destination/destination_province.dart';
import 'package:get/get.dart';

import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';
import '../model/response/uom.dart';

class SelfServiceNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  SelfServiceNetworkRequest(this.netWorkDataSource);

  Future<ProvinceResponse> fetchProvinceList({
    required dynamic context,
    String searchText = '',
  }) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.destinationsProvince,
        body: <String, dynamic>{
          'page': '1',
          'rowsPerPage': '100',
          'searchText': searchText,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return ProvinceResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<ProvinceResponse> fetchDestinationByProvince({
    required dynamic context,
    required String provinceId,
    String searchText = '',
  }) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.destinationsDestinationByProvince,
        body: <String, dynamic>{
          'page': '1',
          'rowsPerPage': '100',
          'provinceId': provinceId,
          'searchText': searchText,
        },
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return ProvinceResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<UomListResponse> fetchUomList({required dynamic context}) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.uomList,
        body: <String, dynamic>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return UomListResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
