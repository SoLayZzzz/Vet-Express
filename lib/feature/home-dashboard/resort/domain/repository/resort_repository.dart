import '../../../../../models/resort/resort_response.dart';

abstract class ResortRepository {
  Future<ResortResponse> fetchResortList();
}
