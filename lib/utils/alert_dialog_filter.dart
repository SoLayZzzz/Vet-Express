import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/destination.dart';
import '../models/destination/destination_from.dart';
import '../models/destination/destination_to.dart';
import 'app_colors.dart';

class AlertDialogFilter extends StatefulWidget {
  const AlertDialogFilter({super.key});

  @override
  AlertDialogFilterState createState() => AlertDialogFilterState();
}

class AlertDialogFilterState extends State<AlertDialogFilter> {
  late Future<DesFromResponse> futureDesFrom;
  late Future<DesToResponse> futureDesTo;

  late String desFrom;
  bool desFromCondition = true;
  int? desFromId = 0;

  late String desTo;
  bool desToCondition = true;
  int? desToId = 0;
  bool enable = true;

  // in this point not good but it nearly deadline (T_T)
  // if new developer is here please correct it

  String status = 'All';
  String statusKh = 'ទាំងអស់';
  int statusId = 0;

  var items = [
    'All',
    'Posting',
    'Shipping',
    'Arrival',
    'Received',
  ];

  var itemsKh = [
    'ទាំងអស់',
    'ផ្ញើរបញើរ',
    'ដឹកជញ្ជូន',
    'ដល់ទិសទៅ',
    'បានទទួល',
  ];

  @override
  void initState() {
    super.initState();
    futureDesFrom = Destination().getDesFrom(context);
    futureDesTo = Destination().getDesTo(context, 0);
    Get.locale.toString() == 'en_US' ? status = items[0] : statusKh = itemsKh[0];
    //status = items[0];
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Text(
              'Filters',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          FutureBuilder<DesFromResponse>(
              future: futureDesFrom,
              builder: (context, data) {
                //print(data);
                if (data.hasData) {
                  if ((data.data?.header?.result) == true &&
                      (data.data?.header?.statusCode) == 200) {
                    if ((data.data?.body?.data)!.isNotEmpty) {
                      if (desFromCondition) {
                        desFrom = Get.locale.toString() == 'en_US'
                            ? (data.data?.body?.data?[0].destinationsFromName).toString()
                            : (data.data?.body?.data?[0].destinationsFromNameKh).toString();
                        desFromCondition = false;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
                        child: InputDecorator(
                          decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                              labelText: 'Destination From',
                              border:
                                  OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                          child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                  value: desFrom,
                                  onChanged: (value) {
                                    setState(() {
                                      desFrom = value.toString();
                                    });
                                  },
                                  items: data.data?.body?.data
                                      ?.map((value) => DropdownMenuItem<String>(
                                            value: Get.locale.toString() == 'en_US'
                                                ? value.destinationsFromName.toString()
                                                : value.destinationsFromNameKh.toString(),
                                            onTap: () {
                                              //print(value);
                                              if (value.destinationsFromId == '0') {
                                                desFromId = 0;
                                              } else {
                                                desFromId = value.id;
                                              }
                                              desToCondition = true;
                                              futureDesTo =
                                                  Destination().getDesTo(context, desToId!);

                                              setState(() {});
                                            },
                                            child: SizedBox(
                                                width: MediaQuery.sizeOf(context).width * 0.6,
                                                child: Text(Get.locale.toString() == 'en_US'
                                                    ? value.destinationsFromName.toString()
                                                    : value.destinationsFromNameKh.toString())),
                                          ))
                                      .toList())),
                        ),
                      );
                    }
                  }
                } else if (data.hasError) {
                  return const Text('');
                }

                return const Center(
                  child: SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 3.0,
                    ),
                  ),
                );
              }),

          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: FutureBuilder<DesToResponse>(
                future: futureDesTo,
                builder: (context, data) {
                  //print(data);
                  if (data.hasData) {
                    if ((data.data?.header?.result) == true &&
                        (data.data?.header?.statusCode) == 200) {
                      if ((data.data?.body?.data)!.isNotEmpty) {
                        if (desToCondition) {
                          desTo = (data.data?.body?.data?[0].destinationsToName).toString();
                          desTo = Get.locale.toString() == 'en_US'
                              ? (data.data?.body?.data?[0].destinationsToName).toString()
                              : (data.data?.body?.data?[0].destinationsToNameKh).toString();
                          desToCondition = false;
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                          child: Column(
                            children: [
                              InputDecorator(
                                decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                                    labelText: 'Destination To',
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0))),
                                child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                        value: desTo,
                                        onChanged: (value) {
                                          setState(() {
                                            desTo = value.toString();
                                          });
                                        },
                                        items: data.data?.body?.data
                                            ?.map((value) => DropdownMenuItem<String>(
                                                  value: Get.locale.toString() == 'en_US'
                                                      ? value.destinationsToName.toString()
                                                      : value.destinationsToNameKh.toString(),
                                                  onTap: () {
                                                    //print('destination' + value.destinationsToId.toString());
                                                    if (value.destinationsToId == '0') {
                                                      desToId = 0;
                                                      //print('condition' + desToId.toString());
                                                    } else {
                                                      desToId = value.id;
                                                    }
                                                    setState(() {});
                                                  },
                                                  child: SizedBox(
                                                      width: MediaQuery.sizeOf(context).width * 0.6,
                                                      child: Text(Get.locale.toString() == 'en_US'
                                                          ? value.destinationsToName.toString()
                                                          : value.destinationsToNameKh.toString())),
                                                ))
                                            .toList())),
                              )
                            ],
                          ),
                        );
                      }
                    }
                  } else if (data.hasError) {
                    return const Text('');
                  }

                  return const Center(
                    child: SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 3.0,
                      ),
                    ),
                  );
                }),
          ),

          // in this point not good but it nearly deadline (T_T)
          // if new developer is here please correct it

          Padding(
            padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
            child: Column(
              children: [
                InputDecorator(
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                          value: Get.locale.toString() == 'en_US' ? status : statusKh,
                          onChanged: (value) {
                            setState(() {
                              Get.locale.toString() == 'en_US'
                                  ? status = value.toString()
                                  : statusKh = value.toString();
                            });
                          },
                          items: Get.locale.toString() == 'en_US'
                              ? items
                                  .map((value) => DropdownMenuItem<String>(
                                        value: value,
                                        onTap: () {
                                          if (value == 'All') {
                                            statusId = 0;
                                          } else if (value == 'Posting') {
                                            statusId = 1;
                                          } else if (value == 'Shipping') {
                                            statusId = 2;
                                          } else if (value == 'Arrival') {
                                            statusId = 3;
                                          } else if (value == 'Received') {
                                            statusId = 4;
                                          }
                                        },
                                        child: Text(value),
                                      ))
                                  .toList()
                              : itemsKh
                                  .map((value) => DropdownMenuItem<String>(
                                        value: value,
                                        onTap: () {
                                          //print(value);
                                          if (value == 'ទាំងអស់') {
                                            statusId = 0;
                                          } else if (value == 'ផ្ញើរបញ្ញើ') {
                                            statusId = 1;
                                          } else if (value == 'ដឹកជញ្ជូន') {
                                            statusId = 2;
                                          } else if (value == 'ដល់ទិសទៅ') {
                                            statusId = 3;
                                          } else if (value == 'បានទទួល') {
                                            statusId = 4;
                                          }
                                        },
                                        child: Text(value),
                                      ))
                                  .toList())),
                )
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(AppColors.redColor),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                      onPressed: () {
                        desFromCondition = true;
                        desToCondition = true;
                        futureDesFrom = Destination().getDesFrom(context);
                        futureDesTo = Destination().getDesTo(context, 0);
                        status = items[0];

                        List<int> list = <int>[];
                        list.add(0);
                        list.add(0);
                        list.add(0);
                        Navigator.pop(context, list);
                      },
                      child: const Text(
                        'Discard',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(AppColors.primaryColor),
                          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ))),
                      onPressed: () {
                        //print(desFromId);
                        //print(desToId);
                        if (desToId == 0) {
                          //print('right');
                        }
                        //print(statusId);

                        List<int> list = <int>[];
                        list.add(desFromId!);
                        list.add(desToId!);
                        list.add(statusId);
                        Navigator.pop(context, list);
                      },
                      child: const Text(
                        'Apply',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
