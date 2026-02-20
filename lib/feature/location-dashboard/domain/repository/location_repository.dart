import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:flutter/material.dart';

abstract class LocationRepository {
  Future<BranchResponse> getBranchList({required BuildContext context});
}
