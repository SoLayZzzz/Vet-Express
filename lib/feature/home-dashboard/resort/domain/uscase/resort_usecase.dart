import '../../../../../models/resort/resort_response.dart';
import '../repository/resort_repository.dart';

class ResortUseCase {
  final ResortRepository repository;

  ResortUseCase(this.repository);

  Future<ResortResponse> fetchResortList() {
    return repository.fetchResortList();
  }
}
