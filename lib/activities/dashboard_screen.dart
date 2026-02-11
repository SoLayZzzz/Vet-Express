import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import '../utils/contains.dart';
import 'logistic/location_screen.dart';
import 'logistic/scan_qr_screen.dart';
import 'logistic/self_service_screen.dart';
import 'member_ship_screen.dart';
import '../feature/menu/presentation/screen/menu_screen.dart';
import 'ticket/package_history_screen.dart';
import 'ticket/ticket_history_screen.dart';
import 'tracking_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int from;

  const DashboardScreen({super.key, required this.from});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _navigated = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const MenuScreen(),
    const TrackingScreen(),
    const ScanQR(scanFrom: 0),
    const MemberShipScreen(),
    LocationScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigated) return; // already navigated once

      if (widget.from == 1) {
        _navigated = true;
        Get.to(
          const SelfServiceScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: Constrains.duration),
        );
      } else if (widget.from == 2) {
        _navigated = true;
        Get.to(
          const TicketHistoryScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: Constrains.duration),
        );
      } else if (widget.from == 5) {
        _navigated = true;
        Get.to(
          const PackageHistoryScreen(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: Constrains.duration),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Container(
          color: AppColors.whiteColor,
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildNavItem(
                _selectedIndex == 0
                    ? 'assets/icons/home-active.png'
                    : 'assets/icons/home.png',
                'home'.tr,
                0,
              ),
              buildNavItem(
                _selectedIndex == 1
                    ? 'assets/icons/tracking-active.png'
                    : "assets/icons/tracking.png",
                'history'.tr,
                1,
              ),
              SizedBox(
                height: 40,
                width: MediaQuery.of(context).size.width * 0.2,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  backgroundColor: AppColors.secondaryColor,
                  elevation: 0,
                  child: Image.asset(
                    'assets/icons/icon_scan.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
              buildNavItem(
                _selectedIndex == 3
                    ? 'assets/icons/membership-active.png'
                    : 'assets/icons/membership.png',
                'membership_card'.tr,
                3,
              ),
              buildNavItem(
                _selectedIndex == 4
                    ? 'assets/icons/location-active.png'
                    : 'assets/icons/location.png',
                'location'.tr,
                4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNavItem(String iconPath, String label, int index) {
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        height: double.infinity,
        width: MediaQuery.of(context).size.width * 0.2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconPath, width: 24, height: 24),
            Text(
              label,
              style: TextStyle(
                color:
                    _selectedIndex == index
                        ? AppColors.primaryColor
                        : AppColors.greyColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
