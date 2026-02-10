import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_colors.dart';
import 'logistic/logistic_member_screen.dart';
import 'logistic/ticket_member_screen.dart';

class MemberShipScreen extends StatefulWidget {
  const MemberShipScreen({super.key});

  @override
  State<MemberShipScreen> createState() => _MemberShipScreenState();
}

class _MemberShipScreenState extends State<MemberShipScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.2,
        backgroundColor: AppColors.primaryColor,
        centerTitle: false,
        title: Text(
          'membership_card'.tr,
          style: const TextStyle(
            color: AppColors.whiteColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 15, top: 15),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0XFFE6E8EA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    labelColor: AppColors.primaryColor,
                    unselectedLabelColor: AppColors.secondaryColor,
                    tabs: [Tab(text: 'ticket'.tr), Tab(text: 'logistic'.tr)],
                  ),
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [TicketMemberScreen(), LogisticMemberScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row view(String name, String description) {
    return Row(
      children: [
        SizedBox(width: 70, child: Text(name)),
        const SizedBox(width: 10),
        const Text(' : ', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Text(description),
      ],
    );
  }
}
