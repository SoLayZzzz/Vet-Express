import 'package:express_vet/feature/dash_board/presentation/screen/dashboard_screen.dart';
import 'package:express_vet/routes/app_routes.dart';
import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/value_statics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TicketPaymentSuccess extends StatefulWidget {
  const TicketPaymentSuccess({super.key});

  @override
  State<TicketPaymentSuccess> createState() => _TicketPaymentSuccessState();
}

class _TicketPaymentSuccessState extends State<TicketPaymentSuccess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Get.offAll(() => const DashboardScreen(from: 0));
        }, icon: Icon(Icons.close)),
        title: Text("payment_comeplete".tr),),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
           
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              
                children: [
                  Text(
                    'your_ticket_has_been_reserved'.tr,
                    // textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'ticket_info1'.tr,
                      // textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: (){
                             ValueStatic().clearDataTicket();
                            Get.offAll(() => const DashboardScreen(from: 0));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: Center(
                              child: Text(
                                'home'.tr,
                                style: TextStyle(
                                  color:
                                      ValueStatic.ticketType == '3'
                                          ? AppColors.airBusColor
                                          : AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap:  (){
                            ValueStatic().clearDataTicket();
                            Get.offAll(() => const DashboardScreen(from: 2));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color:
                                  ValueStatic.ticketType == '3'
                                      ? AppColors.airBusColor
                                      : AppColors.primaryColor,
                            ),
                            child: Center(
                              child: Text(
                                'show_ticket'.tr,
                                style: const TextStyle(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}