import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_contact_response.dart';
import '../../data/model/request/contact_us_list_request.dart';
import '../repository/contact_us_repository.dart';

class ContactUsUseCase {
  final ContactUsRepository repository;

  ContactUsUseCase(this.repository);

  Future<EvContactResponse> fetchContactList({
    required dynamic context,
    int page = 1,
    int rowsPerPage = 100,
  }) {
    final req = ContactUsListRequest(page: page, rowsPerPage: rowsPerPage);
    return repository.fetchContactList(
      context: context,
      page: req.page,
      rowsPerPage: req.rowsPerPage,
    );
  }
}
