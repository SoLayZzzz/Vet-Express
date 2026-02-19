import '../../data/model/response/car_rental_car_type_response.dart';
import '../../data/model/response/car_rental_province_response.dart';

class CarRentalUiState {
  final Future<CarRentalCarTypeResponse>? futureCarTypes;
  final Future<CarRentalProvinceResponse>? futureProvinces;

  const CarRentalUiState({this.futureCarTypes, this.futureProvinces});

  CarRentalUiState copyWith({
    Future<CarRentalCarTypeResponse>? futureCarTypes,
    Future<CarRentalProvinceResponse>? futureProvinces,
  }) => CarRentalUiState(
    futureCarTypes: futureCarTypes ?? this.futureCarTypes,
    futureProvinces: futureProvinces ?? this.futureProvinces,
  );
}
