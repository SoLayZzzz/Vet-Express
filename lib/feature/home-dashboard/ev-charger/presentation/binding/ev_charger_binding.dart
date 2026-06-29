import 'package:get/get.dart';

import '../../../../../base/base_url.dart';
import '../../../../../base/network_data_source.dart';
import '../../data/network/ev_charger_network_request.dart';
import '../../data/repositoryImpl/ev_charger_repository_impl.dart';
import '../../domain/repository/ev_charger_repository.dart';
import '../../domain/uscase/ev_charger_usecase.dart';
import '../controller/ev_charger_controller.dart';
import '../controller/ev_charging_information_controller.dart';
import '../controller/ev_contact_controller.dart';
import '../controller/ev_faq_controller.dart';
import '../controller/ev_news_feed_controller.dart';
import '../controller/ev_policy_controller.dart';
import '../controller/ev_scanner_controller.dart';
import '../controller/ev_slide_show_controller.dart';
import '../controller/ev_station_controller.dart';
import '../controller/ev_top_up_controller.dart';
import '../controller/ev_wallet_controller.dart';
import '../controller/ev_voucher_controller.dart';

class EvChargerBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EvChargerNetworkRequest>()) {
      Get.lazyPut(
        () => EvChargerNetworkRequest(
          ticketDataSource: NetworkDataSource(baseUrl: BaseUrl.BASE_URL_TICKET),
          evDataSource: NetworkDataSource(baseUrl: BaseUrl.BASE_URL_EV),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EvChargerRepository>()) {
      Get.lazyPut<EvChargerRepository>(
        () => EvChargerRepositoryImpl(Get.find<EvChargerNetworkRequest>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EvChargerUseCase>()) {
      Get.lazyPut(
        () => EvChargerUseCase(Get.find<EvChargerRepository>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<EvChargerController>()) {
      Get.lazyPut(() => EvChargerController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvChargingInformationController>()) {
      Get.lazyPut(() => EvChargingInformationController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvContactController>()) {
      Get.lazyPut(() => EvContactController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvSlideshowController>()) {
      Get.lazyPut(() => EvSlideshowController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvStationController>()) {
      Get.lazyPut(() => EvStationController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvWalletController>()) {
      Get.lazyPut(() => EvWalletController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvTopUpController>()) {
      Get.lazyPut(() => EvTopUpController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvScannerController>()) {
      Get.lazyPut(() => EvScannerController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvFaqController>()) {
      Get.lazyPut(() => EvFaqController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvPolicyController>()) {
      Get.lazyPut(() => EvPolicyController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvNewsFeedController>()) {
      Get.lazyPut(() => EvNewsFeedController(Get.find()), fenix: true);
    }

    if (!Get.isRegistered<EvVoucherController>()) {
      Get.lazyPut(() => EvVoucherController(Get.find()), fenix: true);
    }
  }
}
