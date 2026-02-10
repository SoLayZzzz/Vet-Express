import 'package:express_vet/feature/passenger/presentation/screen/passenger_detail_screen.dart';
import 'package:get/get.dart';
import '../activities/home_screen.dart';
import '../activities/splash_screen.dart';
import '../feature/auth/presentation/binding/auth_binding.dart';
import '../feature/auth/presentation/screen/sign_in_screen.dart';
import '../feature/schedule/presentation/binding/ticket_binding.dart';
import '../feature/schedule/presentation/screen/schedule_list_screen.dart';
import '../feature/seat/presentation/screen/select_seat_screen.dart';
import '../feature/ticket_menu/presentation/binding/ticket_menu_binding.dart';
import '../feature/ticket_menu/presentation/screen/select_ticket_screen.dart';
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
      page: () => const HomeScreen(from: 0),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.ticketMenu,
      page: () => const TicketMenuScreen(),
      binding: TicketMenuBinding(),
    ),
    GetPage(
      name: AppRoutes.selectTicket,
      page: () => const SelectTicketScreen(),
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
  ];
}
