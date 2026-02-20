import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../activities/ticket/value_statics.dart';
import '../feature/home-dashboard/passenger/data/model/response/booking_detail_model.dart';
import 'app_colors.dart';

class AlertDialogQRCodeTicket extends StatefulWidget {
  const AlertDialogQRCodeTicket({
    super.key,
    required this.title,
    required this.description,
    required this.ans,
    required this.data,
    required this.code,
  });

  final String title, description, ans, code;
  final List<BookingSeatDetailList> data;

  @override
  AlertDialogQRCodeTicketState createState() => AlertDialogQRCodeTicketState();
}

class AlertDialogQRCodeTicketState extends State<AlertDialogQRCodeTicket>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.data.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppColors.primaryColor,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  for (int i = 0; i < widget.data.length; i++)
                    Tab(text: widget.data[i].seatNumber),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (int i = 0; i < widget.data.length; i++) seatTab(i),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          ValueStatic.ticketType == '3'
                              ? AppColors.secondaryColor
                              : AppColors.primaryColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    width: MediaQuery.of(context).size.width / 1.5,
                    height: 50,
                    child: Center(
                      child: Text(
                        widget.ans,
                        style: const TextStyle(color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column seatTab(int index) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/images/ic_seat_free.png', height: 54),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'seat_number'.tr} : ${widget.data[index].seatNumber}',
                  ),
                  Text(
                    '${'gender'.tr} : ${widget.data[index].gender == "Male" ? 'male'.tr : 'female'.tr}',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1, thickness: 1),
        const SizedBox(height: 10),
        SizedBox(
          height: 180,
          width: 180,
          child: QrImageView(
            data: '${widget.code}_${widget.data[index].seatNumber}',
            version: QrVersions.auto,
            size: 200.0,
          ),
        ),
      ],
    );
  }
}
