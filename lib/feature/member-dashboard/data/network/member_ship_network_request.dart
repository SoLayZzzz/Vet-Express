import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../base/endpoint.dart';
import '../model/reponse/membership_response.dart';
import '../model/reponse/membership_ticket_response.dart';
import '../../../../utils/alert_dialog.dart';
import '../../../../utils/contains.dart';
import '../../../../utils/loading.dart';

class MemberShipNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  MemberShipNetworkRequest(this.netWorkDataSource);

  Future<MemberShipResponse> getMemberShip({required dynamic context}) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.membershipList,
        fields: <String, String>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return MemberShipResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<GetTicketMemberCardResponse> getMemberShipTicket({
    required dynamic context,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.membershipGetTicketMemberCard,
        fields: <String, String>{},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return GetTicketMemberCardResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      rethrow;
    }
  }
}
