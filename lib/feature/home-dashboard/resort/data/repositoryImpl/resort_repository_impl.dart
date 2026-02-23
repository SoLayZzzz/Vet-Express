import '../../../../../models/resort/resort_response.dart';
import '../../domain/repository/resort_repository.dart';
import '../network/resort_network_request.dart';

class ResortRepositoryImpl implements ResortRepository {
  final ResortNetworkRequest networkRequest;

  ResortRepositoryImpl(this.networkRequest);

  @override
  Future<ResortResponse> fetchResortList() {
    return networkRequest.fetchResortList();
  }
}
