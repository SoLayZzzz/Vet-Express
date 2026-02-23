import 'package:express_vet/feature/home-dashboard/contact_us/data/network/contact_us_network_request.dart';
import 'package:express_vet/feature/home-dashboard/contact_us/domain/repository/contact_us_repository.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_contact_response.dart';

class ContactUsRepositoryImpl implements ContactUsRepository {
  final ContactUsNetworkRequest networkRequest;

  ContactUsRepositoryImpl(this.networkRequest);

  @override
  Future<EvContactResponse> fetchContactList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) {
    return networkRequest.fetchContactList(
      context: context,
      page: page,
      rowsPerPage: rowsPerPage,
    );
  }
}
