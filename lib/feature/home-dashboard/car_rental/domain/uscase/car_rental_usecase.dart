import 'package:flutter/widgets.dart';

import '../../data/model/request/car_rental_add_request_body.dart';
import '../../data/model/response/car_rental_add_response.dart';
import '../../data/model/response/car_rental_car_type_response.dart';
import '../../data/model/response/car_rental_province_response.dart';
import '../repository/car_rental_repository.dart';

class CarRentalUseCase {
  final CarRentalRepository carRentalRepository;

  CarRentalUseCase(this.carRentalRepository);

  Future<CarRentalCarTypeResponse> fetchCarTypeList({
    required BuildContext context,
  }) {
    return carRentalRepository.fetchCarTypeList(context: context);
  }

  Future<CarRentalProvinceResponse> fetchProvinceList({
    required BuildContext context,
  }) {
    return carRentalRepository.fetchProvinceList(context: context);
  }

  Future<CarRentalAddResponse> addCarRental({
    required BuildContext context,
    required CarRentalAddRequestBody body,
  }) {
    return carRentalRepository.addCarRental(context: context, body: body);
  }
}
