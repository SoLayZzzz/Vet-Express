import 'dart:async';

import 'package:express_vet/base/network_data_source.dart';
import 'package:get/get.dart';

import '../../../../../base/endpoint.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/contains.dart';
import '../../../../auth/data/model/response/signup_response.dart';
import '../../../../../utils/loading.dart';

class ProfileNetworkRequest {
  final NetWorkDataSource netWorkDataSource;

  ProfileNetworkRequest(this.netWorkDataSource);

  Future<UploadImage> uploadUserProfilePhoto({
    required dynamic context,
    required String filePath,
  }) async {
    try {
      final json = await netWorkDataSource.postMultipartWithFile(
        Endpoint.uploadPhotoUserProfile,
        fields: const <String, String>{
          'token': 'wK4lxDowEfgnaEH2k226FppwAJSflRPG',
        },
        fileField: 'photo',
        filePath: filePath,
        timeout: const Duration(seconds: Constrains.timeout30),
        attachAuth: false,
      );
      return UploadImage.fromJson(json);
    } on TimeoutException {
      Loading().loadingClose();
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
