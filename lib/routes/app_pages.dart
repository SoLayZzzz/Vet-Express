import 'package:express_vet/feature/passenger/presentation/screen/passenger_detail_screen.dart';
import 'package:get/get.dart';
import '../activities/china/registration_screen.dart';
import '../activities/china/warehouse_address_screen.dart';
import '../activities/ev/ev_charging_screen.dart';
import '../activities/logistic/booking_delivery_screen.dart';
import '../activities/logistic/self_service_screen.dart';
import '../activities/notification_screen.dart';
import '../activities/screen/contact_us_screen.dart';
import '../activities/screen/vet_airway.dart';
import '../activities/ticket/package_list_screen.dart';
import '../activities/ticket/rental_car_list_screen.dart';
import '../feature/schedule/presentation/screen/ticket_schedule_car_detail_screen.dart';
import '../feature/dash_board/presentation/screen/dashboard_screen.dart';
import '../activities/splash_screen.dart';
import '../feature/auth/presentation/binding/auth_binding.dart';
import '../feature/auth/presentation/screen/sign_in_screen.dart';
import '../feature/schedule/presentation/binding/ticket_binding.dart';
import '../feature/schedule/presentation/screen/schedule_list_screen.dart';
import '../feature/schedule/presentation/screen/review_rate_screen.dart';
import '../feature/seat/presentation/screen/select_seat_screen.dart';
import '../feature/ticket_menu/presentation/binding/ticket_menu_binding.dart';
import '../feature/ticket_menu/presentation/screen/select_destination_screen.dart';
import '../feature/ticket_menu/presentation/screen/ticket_menu_screen.dart';
import '../utils/contains.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const DashboardScreen(from: 0),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.ticketMenu,
      page: () => const TicketMenuScreen(),
      binding: TicketMenuBinding(),
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
      page: () => const PassengerDetailScreen(),
      binding: TicketBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),

    GetPage(
      name: AppRoutes.evCharger,
      page: () => EvChargerScreen(),
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
      page: () => const SelfServiceScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
    GetPage(
      name: AppRoutes.bookingDelivery,
      page: () => const BookingDeliveryScreen(),
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
      name: AppRoutes.vetAirway,
      page: () => const VetAirway(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: Constrains.duration),
    ),
  ];
}
