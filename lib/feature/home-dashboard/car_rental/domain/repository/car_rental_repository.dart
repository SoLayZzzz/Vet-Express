import 'package:flutter/widgets.dart';

import '../../data/model/request/car_rental_add_request_body.dart';
import '../../data/model/response/car_rental_add_response.dart';
import '../../data/model/response/car_rental_car_type_response.dart';
import '../../data/model/response/car_rental_province_response.dart';

abstract class CarRentalRepository {
  Future<CarRentalCarTypeResponse> fetchCarTypeList({
    required BuildContext context,
  });

  Future<CarRentalProvinceResponse> fetchProvinceList({
    required BuildContext context,
  });

  Future<CarRentalAddResponse> addCarRental({
    required BuildContext context,
    required CarRentalAddRequestBody body,
  });
}
