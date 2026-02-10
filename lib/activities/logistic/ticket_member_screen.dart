import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../api/membership.dart';
import '../../models/membership/membership_ticket_response.dart';
import '../../utils/app_colors.dart';

import 'package:flutter_flip_card/flutter_flip_card.dart';

class TicketMemberScreen extends StatefulWidget {
  const TicketMemberScreen({super.key});

  @override
  State<TicketMemberScreen> createState() => _TicketMemberScreenState();
}

class _TicketMemberScreenState extends State<TicketMemberScreen> {
  late Future<GetTicketMemberCardResponse> futureMembershipTicket;
  bool showDetail = false;
  final con = FlipCardController();

  @override
  void initState() {
    super.initState();

    futureMembershipTicket = Membership().getMemberShipTicket(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(right: 15, left: 15, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<GetTicketMemberCardResponse>(
                  future: futureMembershipTicket,
                  builder: (context, membershipData) {
                    if (membershipData.hasData &&
                        membershipData.data!.header?.statusCode == 200 &&
                        membershipData.data?.header?.result == true) {
                      if ((membershipData.data!.body!.data!.isEmpty)) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: Row(
                            children: [
                              Icon(Ionicons.information_circle, color: Colors.grey),
                              SizedBox(width: 10),
                              Text('don_have_member_card'.tr)
                            ],
                          ),
                        );
                      } else {
                        return Column(children: [
                          FlipCard(
                              rotateSide: RotateSide.left,
                              onTapFlipping: false,
                              axis: FlipAxis.vertical,
                              controller: con,
                              animationDuration: const Duration(milliseconds: 800),
                              frontWidget: Center(
                                child: Image.asset(
                                  'assets/icons/card_ticket_vip.png',
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                              backWidget: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset('assets/icons/card_ticket_vip_background.png'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Name:",
                                                style: TextStyle(
                                                    fontSize: 14, color: AppColors.secondaryColor)),
                                            Text(
                                              "${membershipData.data!.body!.data![0].name}",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.secondaryColor),
                                            ),
                                            const SizedBox(height: 5),
                                            const Text("Tel:",
                                                style: TextStyle(
                                                    fontSize: 14, color: AppColors.secondaryColor)),
                                            Text("${membershipData.data!.body!.data![0].telephone}",
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.secondaryColor))
                                          ]),
                                      Column(
                                        children: [
                                          Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: AppColors.secondaryColor, width: 0.7),
                                                borderRadius: BorderRadius.circular(4),
                                                color: Colors.white),
                                            child: QrImageView(
                                              data: "${membershipData.data!.body!.data![0].code}",
                                              version: QrVersions.auto,
                                              size: 60,
                                              eyeStyle: const QrEyeStyle(
                                                  eyeShape: QrEyeShape.square,
                                                  color: AppColors.secondaryColor),
                                              dataModuleStyle: const QrDataModuleStyle(
                                                  dataModuleShape: QrDataModuleShape.square,
                                                  color: AppColors.secondaryColor),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text("${membershipData.data!.body!.data![0].code}",
                                              style: const TextStyle(
                                                  fontSize: 14, color: AppColors.secondaryColor)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                          const SizedBox(height: 20),
                          InkWell(
                            onTap: () {
                              con.flipcard();
                              setState(() {
                                showDetail = !showDetail;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppColors.borderColor, width: 0.3),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Ionicons.card_outline, color: AppColors.secondaryColor,),
                                  const SizedBox(width: 10),
                                  Text(showDetail
                                      ? 'hide_info_card'.tr
                        : 'see_info_card'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
                                  const Spacer(),
                                  const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20)
                        ]);
                      }
                    } else if (membershipData.hasError) {
                      log('${membershipData.error}');
                    }

                    return const Center(
                        child: SizedBox(
                            height: 40.0,
                            width: 40.0,
                            child: CircularProgressIndicator(value: null, strokeWidth: 3.0)));
                  }),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('condition'.tr,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.textColor, fontSize: 16)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ticket1".tr),
                        const SizedBox(height: 8),
                        Text("ticket2".tr),
                        const SizedBox(height: 8),
                        Text("ticket3".tr),
                      ],
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
