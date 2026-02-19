import 'package:flutter/widgets.dart';

import '../../domain/repository/car_rental_repository.dart';
import '../model/request/car_rental_add_request_body.dart';
import '../model/response/car_rental_add_response.dart';
import '../model/response/car_rental_car_type_response.dart';
import '../model/response/car_rental_province_response.dart';
import '../network/car_rental_network_request.dart';

class CarRentalRepositoryImpl implements CarRentalRepository {
  final CarRentalNetworkRequest carRentalNetworkRequest;

  CarRentalRepositoryImpl(this.carRentalNetworkRequest);

  @override
  Future<CarRentalCarTypeResponse> fetchCarTypeList({
    required BuildContext context,
  }) {
    return carRentalNetworkRequest.fetchCarTypeList(context: context);
  }

  @override
  Future<CarRentalProvinceResponse> fetchProvinceList({
    required BuildContext context,
  }) {
    return carRentalNetworkRequest.fetchProvinceList(context: context);
  }

  @override
  Future<CarRentalAddResponse> addCarRental({
    required BuildContext context,
    required CarRentalAddRequestBody body,
  }) {
    return carRentalNetworkRequest.addCarRental(context: context, body: body);
  }
}
