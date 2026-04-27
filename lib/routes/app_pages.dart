import 'package:express_vet/feature/history-dashboard/other-history/presentation/screen/parcel_payment_screen.dart';
import 'package:express_vet/feature/home-dashboard/contact_us/presentation/screen/contact_us_screen.dart';
import 'package:express_vet/feature/home-dashboard/ev-charger/data/model/response/ev_charger_response.dart';
import 'package:express_vet/feature/home-dashboard/notifications/presentation/screen/notification_screen.dart';
import 'package:express_vet/feature/home-dashboard/passenger/presentation/screen/passenger_detail_screen.dart';
import 'package:express_vet/feature/home-dashboard/self_service/presentation/screen/select_screen.dart';
import 'package:express_vet/feature/home-dashboard/self_service/presentation/screen/self_service_check_screen.dart';
import 'package:express_vet/feature/home-dashboard/self_service/presentation/screen/self_service_qr_list_screen.dart';
import 'package:express_vet/feature/home-dashboard/self_service/presentation/screen/self_service_qr_screen.dart';
import 'package:get/get.dart';
import '../feature/home-dashboard/china-service/presentation/ui/registration_screen.dart';
import '../feature/home-dashboard/china-service/presentation/ui/warehouse_address_screen.dart';
import '../feature/home-dashboard/china-service/presentation/ui/china_edit_info_screen.dart';
import '../feature/history-dashboard/other-history/presentation/binding/goods_transfer_history_binding.dart';
import '../feature/history-dashboard/other-history/presentation/binding/package_history_binding.dart';
import '../feature/history-dashboard/other-history/presentation/binding/ticket_history_binding.dart';
import '../feature/history-dashboard/other-history/presentation/screen/goods_transfer_history_screen.dart';
import '../feature/history-dashboard/other-history/presentation/screen/package_history_screen.dart';
import '../feature/history-dashboard/other-history/presentation/screen/ticket_history_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/binding/ev_charger_binding.dart';
import '../feature/member-dashboard/presentation/screen/account_detail_screen.dart';
import '../feature/member-dashboard/presentation/binding/member_ship_binding.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_charging_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_charger_wallet_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_faq_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_fav_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_new_feed_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_payment_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_policy_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_province_selection_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_qr_scanner_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_station_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/ev_top_up_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/payment_success_screen.dart';
import '../feature/home-dashboard/ev-charger/presentation/screen/search_ev_screen.dart';
import '../feature/home-dashboard/booking_delivery/presentation/binding/booking_delivery_binding.dart';
import '../feature/home-dashboard/booking_delivery/presentation/screen/booking_delivery_screen.dart';
import '../feature/home-dashboard/self_service/presentation/binding/self_service_binding.dart';
import '../feature/home-dashboard/self_service/presentation/screen/self_service_screen.dart';
import '../feature/home-dashboard/vet-air/vet_airway.dart';
import '../feature/home-dashboard/menu/presentation/screen/package_list_screen.dart';
import '../feature/home-dashboard/car_rental/presentation/binding/car_rental_binding.dart';
import '../feature/home-dashboard/car_rental/presentation/screen/rental_car_detail_screen.dart';
import '../feature/home-dashboard/car_rental/presentation/screen/rental_car_info_screen.dart';
import '../feature/home-dashboard/car_rental/presentation/screen/rental_car_list_screen.dart';
import '../feature/home-dashboard/car_rental/presentation/screen/select_rental_province_screen.dart';
import '../feature/home-dashboard/schedule/presentation/screen/ticket_schedule_car_detail_screen.dart';
import '../feature/dash_board/presentation/screen/dashboard_screen.dart';
import '../splash_screen.dart';
import '../feature/auth/presentation/binding/auth_binding.dart';
import '../feature/auth/presentation/screen/sign_in_screen.dart';
import '../feature/home-dashboard/schedule/presentation/binding/ticket_binding.dart';
import '../feature/home-dashboard/schedule/presentation/screen/schedule_list_screen.dart';
import '../feature/home-dashboard/schedule/presentation/screen/review_rate_screen.dart';
import '../feature/home-dashboard/seat/presentation/screen/select_seat_screen.dart';
import '../feature/home-dashboard/ticket_menu/presentation/binding/ticket_menu_binding.dart';
import '../feature/home-dashboard/ticket_menu/presentation/screen/select_destination_screen.dart';
import '../feature/home-dashboard/ticket_menu/presentation/screen/ticket_menu_screen.dart';
import '../feature/dash_board/scan_qr/presentation/binding/scan_qr_binding.dart';
import '../feature/dash_board/scan_qr/presentation/screen/scan_qr_screen.dart';
import '../utils/contains.dart';
import 'app_routes.dart';

import '../feature/auth/presentation/screen/verify_code_screen.dart';
import '../feature/auth/presentation/screen/new_password_screen.dart';

import '../feature/home-dashboard/ev-charger/presentation/controller/ev_payment_controller.dart';
import '../feature/home-dashboard/payment/presentaion/ui/payment_screen.dart';
import '../feature/home-dashboard/payment/presentaion/ui/payment_aba_screen.dart';
import '../feature/home-dashboard/payment/presentaion/ui/payment_aba_package_screen.dart';
import '../feature/home-dashboard/payment/presentaion/ui/payment_wing_screen.dart';
import '../feature/home-dashboard/payment/presentaion/binding/payment_binding.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const DashboardScreen(from: 0),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.verifyCode,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return VerifyCodeScreen(
          identify: (args?['identify'] as int?) ?? 1,
          token: (args?['token'] as String?) ?? '',
          phone: (args?['phone'] as String?) ?? '',
        );
      },
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.newPassword,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return CreateNewPasswordScreen(
          token: (args?['token'] as String?) ?? '',
        );
      },
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.ticketMenu,
      page: () => const TicketMenuScreen(),
      binding: TicketMenuBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.selectTicket,
      page: () => const SelectDestinationScreen(),
      binding: TicketMenuBinding(),
    ),

    GetPage(
      name: AppRoutes.scheduleList,
      page: () => const ScheduleListScreen(),
      binding: TicketBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.reviewRate,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return ReviewRateScreen(
          scheduleId: args?['scheduleId'] as int?,
          status: args?['status'] as int?,
          type: args?['type'] as int?,
          id: args?['id'] as String?,
        );
      },
      binding: TicketBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.ticketScheduleCarDetail,
      page: () => const TicketScheduleCarDetailScreen(),
      binding: TicketBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.selectSeat,
      page: () => const SelectSeatScreen(),
      binding: TicketBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.passengerDetail,
      page: () => PassengerDetailScreen(),
      binding: TicketBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),

    GetPage(
      name: AppRoutes.evCharger,
      page: () => EvChargerScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),

    GetPage(
      name: AppRoutes.evWallet,
      page: () => const EvWalletScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evTopUp,
      page: () => const EvTopUpScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evPayment,
      page: () => const EvPaymentScreen(),
      binding: BindingsBuilder(() {
        if (Get.isRegistered<EvPaymentController>()) {
          Get.delete<EvPaymentController>();
        }
        Get.put(EvPaymentController());
      }),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evPaymentSuccess,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        final amount = (args?['amount'] as num?)?.toDouble() ?? 0.0;
        return PaymentSuccessScreen(amount: amount);
      },
      binding: EvChargerBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evQrScanner,
      page: () => const EvQrScannerScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evFaq,
      page: () => EvFaqScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evPolicy,
      page: () => EvPolicyScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evNewsFeed,
      page: () => const NewsFeedScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evAllStations,
      page: () => const EvAllStationScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evFavorites,
      page: () => EvFavoriteScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),

    // Payment routes
    GetPage(
      name: AppRoutes.payment,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return PaymentScreen(
          id: (args?['id'] as String?) ?? '',
          datas: args?['datas'],
        );
      },
      binding: PaymentBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.paymentAba,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return PaymentABAScreen(
          transactionId: (args?['transactionId'] as String?) ?? '',
          token: (args?['token'] as String?) ?? '',
          type: (args?['type'] as int?) ?? 1,
          title: (args?['title'] as String?) ?? '',
          url: (args?['url'] as String?) ?? '',
        );
      },
      binding: PaymentBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.paymentAbaPackage,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return PaymentABAPackageScreen(
          transactionId: (args?['transactionId'] as String?) ?? '',
          token: (args?['token'] as String?) ?? '',
          type: (args?['type'] as int?) ?? 1,
          title: (args?['title'] as String?) ?? '',
          url: (args?['url'] as String?) ?? '',
        );
      },
      binding: PaymentBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.paymentWing,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return PaymentWingScreen(
          transactionId: (args?['transactionId'] as String?) ?? '',
          token: (args?['token'] as String?) ?? '',
        );
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evSearchStations,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        final stations =
            (args?['allStations'] as List?)?.cast<BodyEV>() ?? <BodyEV>[];
        return SearchEvScreen(allStations: stations);
      },
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.evSelectProvince,
      page: () => EvProvinceSelectionScreen(),
      binding: EvChargerBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.contactUs,
      page: () => const ContactUsScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.carRentalList,
      page: () => const RentalCarListScreen(),
      binding: CarRentalBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.carRentalDetail,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return RentalCarDetailScreen(
          carType: (args?['carType'] as String?) ?? '',
          seat: (args?['seat'] as String?) ?? '',
          image: (args?['image'] as String?) ?? '',
          listSlide: args?['listSlide'],
          listIcon: args?['listIcon'],
        );
      },
      binding: CarRentalBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.carRentalInfo,
      page: () => const RentalCarInfoScreen(),
      binding: CarRentalBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.carRentalSelectProvince,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return SelectRentalProvinceScreen(
          selectType: (args?['selectType'] as String?) ?? '',
        );
      },
      binding: CarRentalBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.travelPackageList,
      page: () => const PackageListScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.selfService,
      page: () => SelfServiceScreen(),
      binding: SelfServiceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.selfServiceSelect,
      page: () {
        return SelectLogisticScreen();
      },
      binding: SelfServiceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.selfServiceCheck,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return SelfServiceCheckScreen(
          senderPhone: (args?['senderPhone'] as String?) ?? '',
          receiverPhone: (args?['receiverPhone'] as String?) ?? '',
          itemPrice: (args?['itemPrice'] as String?) ?? '',
          amount: (args?['amount'] as String?) ?? '',
        );
      },
      binding: SelfServiceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.selfServiceQr,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return SelfServiceQRScreen(qrCode: (args?['qrCode'] as String?) ?? '');
      },
      binding: SelfServiceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.selfServiceQrList,
      page: () {
        final args = Get.arguments as Map<dynamic, dynamic>?;
        return SelfServiceQRListScreen(
          qrCode: (args?['qrCode'] as String?) ?? '',
        );
      },
      binding: SelfServiceBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),

    GetPage(
      name: AppRoutes.scanQr,
      page: () => const ScanQrScreen(),
      binding: ScanQrBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.bookingDelivery,
      page: () => const BookingDeliveryScreen(),
      binding: BookingDeliveryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.warehouseAddress,
      page: () => WarehouseAddressScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.chinaRegistration,
      page: () => ChinaRegistrationScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.chinaEditInfo,
      page: () => const EditChinaAddressScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.vetAirway,
      page: () => const VetAirway(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),

    GetPage(
      name: AppRoutes.ticketHistory,
      page: () => const TicketHistoryScreen(),
      binding: TicketHistoryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.packageHistory,
      page: () => const PackageHistoryScreen(),
      binding: PackageHistoryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.goodsTransferHistory,
      page: () => const GoodsTransferHistoryScreen(),
      binding: GoodsTransferHistoryBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    // Member dashboard routes
    GetPage(
      name: AppRoutes.memberAccountDetail,
      page: () => const AccountDetailScreen(),
      binding: MemberShipBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    // Parcel Payment 
    GetPage(
      name: AppRoutes.parcelPayment,
      page: () =>  ParcelPaymentScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
  ];
}
