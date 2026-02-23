import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../value_statics.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../controller/car_rental_controller.dart';
import '../../data/model/response/car_rental_province_response.dart';

class SelectRentalProvinceScreen extends StatefulWidget {
  final String selectType;

  const SelectRentalProvinceScreen({super.key, required this.selectType});

  @override
  State<SelectRentalProvinceScreen> createState() =>
      _SelectRentalProvinceScreenState();
}

class _SelectRentalProvinceScreenState
    extends State<SelectRentalProvinceScreen> {
  late final CarRentalController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CarRentalController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProvinces(context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        appBar: AppBarVET().appBar(context, 'province_city'.tr),
        body: SafeArea(
          child: Column(
            children: [
              Obx(
                () => FutureBuilder<CarRentalProvinceResponse>(
                  future: controller.state.futureProvinces,
                  builder: (context, selectData) {
                    if (selectData.hasData) {
                      if (selectData.data!.header?.statusCode == 200 &&
                          selectData.data!.header?.result == true) {
                        if (selectData.data!.body!.data!.isNotEmpty) {
                          return Expanded(
                            child: ListView.builder(
                              itemCount: selectData.data!.body?.data?.length,
                              itemBuilder: (BuildContext context, int index) {
                                final data =
                                    selectData.data?.body?.data?[index];
                                return InkWell(
                                  onTap: () {
                                    if (widget.selectType == 'From') {
                                      ValueStatic.provinceRentalFromName =
                                          (data?.name).toString();
                                      ValueStatic.provinceRentalFromId =
                                          (data?.id).toString();
                                    } else {
                                      ValueStatic.provinceRentalToName =
                                          (data?.name).toString();
                                      ValueStatic.provinceRentalToId =
                                          (data?.id).toString();
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Text((data?.name).toString()),
                                        ),
                                        Container(
                                          height: 0.1,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                      }
                    }

                    return const Expanded(
                      child: Center(
                        child: SizedBox(
                          height: 50.0,
                          width: 50.0,
                          child: CircularProgressIndicator(
                            value: null,
                            color: AppColors.primaryColor,
                            strokeWidth: 5.0,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
