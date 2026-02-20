import 'package:express_vet/base/base_url.dart';
import 'package:express_vet/base/network_data_source.dart';
import 'package:express_vet/feature/dash_board/scan_qr/data/network/scan_qr_network_request.dart';
import 'package:express_vet/feature/dash_board/scan_qr/data/repositoryImpl/scan_qr_repository_impl.dart';
import 'package:express_vet/feature/dash_board/scan_qr/domain/repository/scan_qr_repository.dart';
import 'package:express_vet/feature/dash_board/scan_qr/domain/uscase/scan_qr_usecase.dart';
import 'package:get/get.dart';

import '../controller/scan_qr_controller.dart';

class ScanQrBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ScanQrNetworkRequest>()) {
      Get.lazyPut(
        () =>
            ScanQrNetworkRequest(NetworkDataSource(baseUrl: BaseUrl.BASE_URL)),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScanQrRepository>()) {
      Get.lazyPut<ScanQrRepository>(
        () => ScanQrRepositoryImpl(Get.find<ScanQrNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScanQrUseCase>()) {
      Get.lazyPut(
        () => ScanQrUseCase(Get.find<ScanQrRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ScanQrController>()) {
      Get.lazyPut(
        () => ScanQrController(Get.find<ScanQrUseCase>()),
        fenix: true,
      );
    }
  }
}
