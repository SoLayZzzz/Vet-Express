import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '../../../../api/saving_point.dart';
import '../../data/model/reponse/membership_response.dart';
import '../../../../models/saving_point/saving_point_response.dart';
import '../../../../utils/app_colors.dart';
import '../../../../activities/logistic/account_detail_screen.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';

import '../binding/member_ship_binding.dart';
import '../controller/member_ship_controller.dart';

class LogisticMemberScreen extends StatefulWidget {
  const LogisticMemberScreen({super.key});

  @override
  State<LogisticMemberScreen> createState() => _LogisticMemberScreenState();
}

class _LogisticMemberScreenState extends State<LogisticMemberScreen> {
  late Future<SavingPointResponse> futureData;
  late Future<MemberShipResponse> futureMembership;
  bool showInfo = false;
  final cong = FlipCardController();

  String status = 'January';
  String statusKh = 'មករា';
  int statusId = 0;

  var items = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  var itemsKh = [
    'មករា',
    'កុម្ភៈ',
    'មិនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];

  @override
  void initState() {
    super.initState();
    setState(() {
      status = items[getMonth() - 1];
      statusKh = itemsKh[getMonth() - 1];
    });
    futureData = SavingPoint().getSavingPoint(
      context,
      (getMonth()).toString(),
      getYear().toString(),
    );

    if (!Get.isRegistered<MemberShipController>()) {
      MemberShipBinding().dependencies();
    }
    futureMembership = Get.find<MemberShipController>().loadMemberShip(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<MemberShipResponse>(
                    future: futureMembership,
                    builder: (context, membershipData) {
                      if (membershipData.hasData &&
                          membershipData.data!.header?.statusCode == 200 &&
                          membershipData.data?.header?.result == true) {
                        if ((membershipData.data!.body!.data!.isEmpty)) {
                          return Row(
                            children: [
                              Icon(
                                Ionicons.information_circle,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 10),
                              Text('don_have_member_card'.tr),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Column(
                                children: [
                                  FlipCard(
                                    rotateSide: RotateSide.left,
                                    onTapFlipping: false,
                                    axis: FlipAxis.vertical,
                                    controller: cong,
                                    animationDuration: const Duration(
                                      milliseconds: 800,
                                    ),
                                    frontWidget: Center(
                                      child: Image.asset(
                                        'assets/icons/card_ticket_vip.png',
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    backWidget: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icons/card_ticket_vip_background_logistic.png',
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Name:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors
                                                            .secondaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  "${membershipData.data!.body!.data![0].name}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors
                                                            .secondaryColor,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                const Text(
                                                  "Tel:",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors
                                                            .secondaryColor,
                                                  ),
                                                ),
                                                Text(
                                                  "${membershipData.data!.body!.data![0].telephone}",
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors
                                                            .secondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Container(
                                                  height: 80,
                                                  width: 80,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          AppColors
                                                              .secondaryColor,
                                                      width: 0.7,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                    color: Colors.white,
                                                  ),
                                                  child: QrImageView(
                                                    data:
                                                        "${membershipData.data!.body!.data![0].code}",
                                                    version: QrVersions.auto,
                                                    size: 60,
                                                    eyeStyle: const QrEyeStyle(
                                                      eyeShape:
                                                          QrEyeShape.square,
                                                      color:
                                                          AppColors
                                                              .secondaryColor,
                                                    ),
                                                    dataModuleStyle:
                                                        const QrDataModuleStyle(
                                                          dataModuleShape:
                                                              QrDataModuleShape
                                                                  .square,
                                                          color:
                                                              AppColors
                                                                  .secondaryColor,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  "${membershipData.data!.body!.data![0].code}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        AppColors
                                                            .secondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  InkWell(
                                    onTap: () {
                                      cong.flipcard();
                                      setState(() {
                                        showInfo = !showInfo;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.whiteColor,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: AppColors.borderColor,
                                          width: 0.3,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Ionicons.card_outline,
                                            color: AppColors.secondaryColor,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            showInfo
                                                ? 'hide_info_card'.tr
                                                : 'see_info_card'.tr,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Spacer(),
                                          const Icon(
                                            Icons.chevron_right,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                              FutureBuilder<SavingPointResponse>(
                                future: futureData,
                                builder: (context, selectData) {
                                  if (selectData.hasData) {
                                    if (selectData.data!.header?.statusCode ==
                                            200 &&
                                        selectData.data!.header?.result ==
                                            true) {
                                      return SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: AppColors.whiteColor,
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20.0,
                                              horizontal: 15,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      RichText(
                                                        text: TextSpan(
                                                          children: <TextSpan>[
                                                            const TextSpan(
                                                              text:
                                                                  'Total package: ',
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    AppColors
                                                                        .textColor,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  '${selectData.data!.body!.data![0].totalTransfer}',
                                                              style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    AppColors
                                                                        .secondaryColor,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 80,
                                                        height: 80,
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                50,
                                                              ),
                                                          gradient: const LinearGradient(
                                                            colors: [
                                                              Color(
                                                                0xFFE38F5A,
                                                              ), // Example end color
                                                              Color(
                                                                0xFF312783,
                                                              ), // Example start color
                                                            ],
                                                            begin:
                                                                Alignment
                                                                    .topLeft,
                                                            end:
                                                                Alignment
                                                                    .bottomRight,
                                                          ),
                                                        ),
                                                        child: Center(
                                                          child: Container(
                                                            width: 72,
                                                            height: 72,
                                                            decoration:
                                                                BoxDecoration(
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        50,
                                                                      ),
                                                                ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "Paid Fee",
                                                                  style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  height: 4,
                                                                ),
                                                                Text(
                                                                  "${selectData.data?.body?.data?[0].totalAmount}៛",
                                                                  style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color:
                                                                        AppColors
                                                                            .primaryColor,
                                                                    fontSize:
                                                                        12,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                                  child: Divider(),
                                                ),
                                                Text(
                                                  'select_month'.tr,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.5,
                                                      child: InputDecorator(
                                                        decoration: InputDecoration(
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets.fromLTRB(
                                                                10,
                                                                0,
                                                                10,
                                                                0,
                                                              ),
                                                          border: OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10.0,
                                                                ),
                                                          ),
                                                        ),
                                                        child: DropdownButtonHideUnderline(
                                                          child: DropdownButton<
                                                            String
                                                          >(
                                                            value:
                                                                Get.locale.toString() ==
                                                                        'en_US'
                                                                    ? status
                                                                    : statusKh,
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_drop_down,
                                                              color:
                                                                  AppColors
                                                                      .borderColor,
                                                            ),
                                                            onChanged: (value) {
                                                              futureData = SavingPoint().getSavingPoint(
                                                                context,
                                                                Get.locale
                                                                            .toString() ==
                                                                        'en_US'
                                                                    ? (items.indexOf(
                                                                              value!,
                                                                            ) +
                                                                            1)
                                                                        .toString()
                                                                    : (itemsKh.indexOf(
                                                                              value!,
                                                                            ) +
                                                                            1)
                                                                        .toString(),
                                                                getYear()
                                                                    .toString(),
                                                              );
                                                              setState(() {
                                                                Get.locale.toString() ==
                                                                        'en_US'
                                                                    ? status =
                                                                        value
                                                                            .toString()
                                                                    : statusKh =
                                                                        value.toString();
                                                              });
                                                            },
                                                            items:
                                                                Get.locale
                                                                            .toString() ==
                                                                        'en_US'
                                                                    ? items
                                                                        .map(
                                                                          (
                                                                            value,
                                                                          ) => DropdownMenuItem<
                                                                            String
                                                                          >(
                                                                            value:
                                                                                value,
                                                                            onTap: () {
                                                                              //print(value);
                                                                            },
                                                                            child: Text(
                                                                              value,
                                                                            ),
                                                                          ),
                                                                        )
                                                                        .toList()
                                                                    : itemsKh
                                                                        .map(
                                                                          (
                                                                            value,
                                                                          ) => DropdownMenuItem<
                                                                            String
                                                                          >(
                                                                            value:
                                                                                value,
                                                                            onTap: () {
                                                                              //print(value);
                                                                            },
                                                                            child: Text(
                                                                              value,
                                                                            ),
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        Get.to(
                                                          () =>
                                                              const AccountDetailScreen(),
                                                          transition:
                                                              Transition
                                                                  .rightToLeft,
                                                          duration:
                                                              const Duration(
                                                                milliseconds:
                                                                    350,
                                                              ),
                                                        );
                                                      },
                                                      child: Container(
                                                        width:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width *
                                                            0.3,
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color:
                                                                AppColors
                                                                    .borderColor,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                15,
                                                              ),
                                                          child: Center(
                                                            child: Text(
                                                              'detail_new'.tr,
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                color:
                                                                    AppColors
                                                                        .titleColor,
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
                                        ),
                                      );
                                    }
                                  } else if (selectData.hasError) {}
                                  return SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.7,
                                    child: const Center(
                                      child: SizedBox(
                                        height: 40.0,
                                        width: 40.0,
                                        child: CircularProgressIndicator(
                                          value: null,
                                          strokeWidth: 3.0,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        }
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  ),

                  //* condition
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      WidgetZoom(
                        heroAnimationTag:
                            'vip_image_tag', // Unique tag for Hero animation
                        zoomWidget: Image.asset(
                          'assets/images/ic_vet_vip.jpg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'note100'.tr,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('mem'.tr),
                      Text('mem1'.tr),
                      Text('mem2'.tr),
                    ],
                  ),
                ],
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
        Text(
          name,
          style: const TextStyle(fontSize: 14, color: AppColors.textColor),
        ),
        const Text(':'),
        const SizedBox(width: 10),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: AppColors.textColor),
        ),
      ],
    );
  }

  int getMonth() {
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('MM');
    return int.parse(formatter.format(now).toString());
  }

  int getYear() {
    DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('yyyy');
    return int.parse(formatter.format(now).toString());
  }
}
