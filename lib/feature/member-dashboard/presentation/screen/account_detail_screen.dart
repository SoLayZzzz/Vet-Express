import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/models/saving_point/saving_list_response.dart';
import 'package:express_vet/utils/app_bar.dart';

import '../../../../utils/app_colors.dart';
import '../controller/member_ship_controller.dart';

class AccountDetailScreen extends GetView<MemberShipController> {
  const AccountDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'detail_new'.tr),
      body: SafeArea(
        child: FutureBuilder<SavingListResponse>(
          future: controller.loadSavingPointList(context),
          builder: (context, selectData) {
            if (selectData.hasData) {
              if (selectData.data!.header?.statusCode == 200 &&
                  selectData.data!.header?.result == true) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 0.5,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // const Text("Tel: 012 345 678"),
                                  // const SizedBox(height: 10),
                                  Text(
                                    'available_point'.tr,
                                    style: const TextStyle(
                                      color: AppColors.textColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFE38F5A),
                                      Color(0xFF312783),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (selectData.data?.body?.message)
                                            .toString(),
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 140),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          itemCount: selectData.data!.body?.data?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                    width: 0.5,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/ic_card.jpg',
                                        width: 24,
                                      ),
                                      const SizedBox(width: 14),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (selectData
                                                    .data!
                                                    .body
                                                    ?.data?[index]
                                                    .transactionNo)
                                                .toString(),
                                          ),
                                          Text(
                                            (selectData
                                                    .data!
                                                    .body
                                                    ?.data?[index]
                                                    .reference)
                                                .toString(),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(
                                        (selectData
                                                .data!
                                                .body
                                                ?.data?[index]
                                                .amount)
                                            .toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
            } else if (selectData.hasError) {}
            return const Center(
              child: SizedBox(
                height: 50.0,
                width: 50.0,
                child: CircularProgressIndicator(value: null, strokeWidth: 5.0),
              ),
            );
          },
        ),
      ),
    );
  }
}
