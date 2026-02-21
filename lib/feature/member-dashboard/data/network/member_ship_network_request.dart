import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../base/endpoint.dart';
import '../model/reponse/membership_response.dart';
import '../model/reponse/membership_ticket_response.dart';
import '../../../../models/saving_point/saving_point_response.dart';
import '../../../../models/saving_point/saving_list_response.dart';
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

  // ===== Saving Point APIs (migrated from lib/api/saving_point.dart) =====
  Future<SavingPointResponse> getSavingPointAccount({
    required dynamic context,
    required String month,
    required String year,
  }) async {
    try {
      final json = await netWorkDataSource.postFormUrlEncoded(
        Endpoint.savingPointAccount,
        fields: <String, String>{'month': month, 'year': year},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return SavingPointResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      Loading().loadingClose(context);
      rethrow;
    }
  }

  Future<SavingListResponse> getSavingPointList({
    required dynamic context,
  }) async {
    try {
      final json = await netWorkDataSource.postJson(
        Endpoint.savingPointList,
        body: <String, dynamic>{'page': 1, 'rowsPerPage': 100},
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: true,
      );
      return SavingListResponse.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose(context);
      alertDialogOneButton(
        title: 'timeout'.tr,
        description: 'request_timed_out'.tr,
        buttonText: 'ok'.tr,
      );
      rethrow;
    } catch (_) {
      Loading().loadingClose(context);
      rethrow;
    }
  }
}
