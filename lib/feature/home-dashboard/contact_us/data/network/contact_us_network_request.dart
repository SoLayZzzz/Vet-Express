import '../../../../../base/endpoint.dart';
import '../../../../../base/network_data_source.dart';
import '../../../../../utils/contains.dart';
import '../../../ev-charger/data/model/response/ev_contact_response.dart';

class ContactUsNetworkRequest {
  final NetWorkDataSource dataSource;

  ContactUsNetworkRequest(this.dataSource);

  Future<EvContactResponse> fetchContactList({
    required dynamic context,
    required int page,
    required int rowsPerPage,
  }) async {
    final json = await dataSource.postJson(
      Endpoint.evDropdownContactUsList,
      body: {'page': page, 'rowsPerPage': rowsPerPage},
      timeout: const Duration(seconds: Constrains.timeout30),
      attachAuth: true,
    );
    return EvContactResponse.fromJson(json);
  }
}
