import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/location-dashboard/data/model/response/branch_response.dart';
import 'package:flutter/material.dart';

class LocationNetworkRequest extends NetworkDataSource {
  LocationNetworkRequest({super.baseUrl});

  Future<BranchResponse> getBranchList({required BuildContext context}) async {
    final res = await postJson('branch/list');
    return BranchResponse.fromJson(res);
  }
}
