import 'package:express_vet/base/network_data_source.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/contains.dart';
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
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.vehicleRentalBusType,
      fields: <String, String>{},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return CarRentalCarTypeResponse.fromJson(json);
  }

  Future<CarRentalProvinceResponse> fetchProvinceList({
    required dynamic context,
  }) async {
    final json = await netWorkDataSource.postFormUrlEncoded(
      Endpoint.vehicleRentalProvince,
      fields: <String, String>{},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return CarRentalProvinceResponse.fromJson(json);
  }

  Future<CarRentalAddResponse> addCarRental({
    required dynamic context,
    required CarRentalAddRequestBody body,
  }) async {
    final json = await netWorkDataSource.postMultipart(
      Endpoint.vehicleRentalAdd,
      fields: body.toFormFields(),
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return CarRentalAddResponse.fromJson(json);
  }
}
