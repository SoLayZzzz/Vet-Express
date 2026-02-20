import 'package:express_vet/feature/location-dashboard/data/network/location_network_request.dart';
import 'package:express_vet/feature/location-dashboard/domain/repository/location_repository.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:flutter/material.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationNetworkRequest _network;

  LocationRepositoryImpl(this._network);

  @override
  Future<BranchResponse> getBranchList({required BuildContext context}) {
    return _network.getBranchList(context: context);
  }
}
