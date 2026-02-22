import '../../../ev-charger/data/model/response/ev_contact_response.dart';

abstract class ContactUsRepository {
  Future<EvContactResponse> fetchContactList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  });
}
