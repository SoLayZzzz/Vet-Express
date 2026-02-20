import 'package:express_vet/feature/location-dashboard/domain/repository/location_repository.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:flutter/material.dart';

class LocationUseCase {
  final LocationRepository repository;
  LocationUseCase(this.repository);

  Future<BranchResponse> getBranchList({required BuildContext context}) {
    return repository.getBranchList(context: context);
  }
}
