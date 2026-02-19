import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../../utils/loading.dart';
import '../model/request/car_rental_add_request_body.dart';
import '../model/response/car_rental_add_response.dart';
import '../model/response/car_rental_car_type_response.dart';
import '../model/response/car_rental_province_response.dart';

class CarRentalNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  CarRentalNetworkRequest(this.netWorkDataSource);

  Future<CarRentalCarTypeResponse> fetchCarTypeList({
    required dynamic context,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.vehicleRentalBusType,
        fields: <String, String>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return CarRentalCarTypeResponse.fromJson(json);
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

  Future<CarRentalProvinceResponse> fetchProvinceList({
    required dynamic context,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.vehicleRentalProvince,
        fields: <String, String>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return CarRentalProvinceResponse.fromJson(json);
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

  Future<CarRentalAddResponse> addCarRental({
    required dynamic context,
    required CarRentalAddRequestBody body,
  }) async {
    try {
      final json = await netWorkDataSource.postMultipart(
        Endpoint.vehicleRentalAdd,
        fields: body.toFormFields(),
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return CarRentalAddResponse.fromJson(json);
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
