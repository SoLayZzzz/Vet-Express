import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/api/vehicle_retal.dart';
import 'package:express_vet/utils/app_bar.dart';

import '../../models/destination/destination_province.dart';
import '../../utils/app_colors.dart';

class SelectRentalProvinceScreen extends StatefulWidget {
  final String selectType;

  const SelectRentalProvinceScreen({super.key, required this.selectType});

  @override
  State<SelectRentalProvinceScreen> createState() => _SelectRentalProvinceScreenState();
}

class _SelectRentalProvinceScreenState extends State<SelectRentalProvinceScreen> {
  late Future<ProvinceResponse> futureSelect;

  @override
  void initState() {
    super.initState();
    futureSelect = VehicleRental().getProvince(context);
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
              FutureBuilder<ProvinceResponse>(
                future: futureSelect,
                builder: (context, selectData) {
                  if (selectData.hasData) {
                    if (selectData.data!.header?.statusCode == 200 &&
                        selectData.data!.header?.result == true) {
                      if (selectData.data!.body!.data!.isNotEmpty) {
                        return Expanded(
                          child: ListView.builder(
                              itemCount: selectData.data!.body?.data?.length,
                              itemBuilder: (BuildContext context, int index) {
                                return InkWell(
                                  onTap: () {
                                    if (widget.selectType == 'From') {
                                      ValueStatic.provinceRentalFromName =
                                          (selectData.data!.body?.data?[index].name).toString();
                                      ValueStatic.provinceRentalFromId =
                                          (selectData.data!.body?.data?[index].id).toString();
                                    } else {
                                      ValueStatic.provinceRentalToName =
                                          (selectData.data!.body?.data?[index].name).toString();
                                      ValueStatic.provinceRentalToId =
                                          (selectData.data!.body?.data?[index].id).toString();
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Text((selectData.data!.body?.data?[index].name)
                                              .toString()),
                                        ),
                                        Container(
                                          height: 0.1,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        );
                      }
                    }
                  } else if (selectData.hasError) {}

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
            ],
          ),
        ),
      ),
    );
  }
}
