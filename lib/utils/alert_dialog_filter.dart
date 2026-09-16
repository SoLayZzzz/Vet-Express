import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:express_vet/feature/common/netowrk/destination_network_request.dart';
import '../feature/common/model/reponse/destination_from.dart' as destination_from;
import '../feature/common/model/reponse/destination_to.dart' as destination_to;
import 'app_colors.dart';

class AlertDialogFilter extends StatefulWidget {
  final int initialDesFromId;
  final int initialDesToId;
  final int initialStatusId;

  const AlertDialogFilter({
    super.key,
    this.initialDesFromId = 0,
    this.initialDesToId = 0,
    this.initialStatusId = 0,
  });

  @override
  AlertDialogFilterState createState() => AlertDialogFilterState();
}

class AlertDialogFilterState extends State<AlertDialogFilter> {
  late Future<destination_from.DesFromResponse> futureDesFrom;
  late Future<destination_to.DesToResponse> futureDesTo;
  final DestinationNetworkRequest _destination = DestinationNetworkRequest();

  bool _loadingDesFrom = true;
  bool _loadingDesTo = true;

  String desFrom = 'All';
  bool desFromCondition = true;
  int? desFromId = 0;

  String desTo = 'All';
  bool desToCondition = true;
  int? desToId = 0;
  bool enable = true;

  String status = 'All';
  String statusKh = 'ទាំងអស់';
  int statusId = 0;

  var items = ['All', 'Posting', 'Shipping', 'Arrival', 'Received'];

  var itemsKh = ['ទាំងអស់', 'ផ្ញើរបញើរ', 'ដឹកជញ្ជូន', 'ដល់ទិសទៅ', 'បានទទួល'];

  void _setFutureDesFrom(Future<destination_from.DesFromResponse> future) {
    _loadingDesFrom = true;
    futureDesFrom = future;
    future.whenComplete(() {
      if (!mounted) return;
      setState(() {
        _loadingDesFrom = false;
      });
    });
  }

  void _setFutureDesTo(Future<destination_to.DesToResponse> future) {
    _loadingDesTo = true;
    futureDesTo = future;
    future.whenComplete(() {
      if (!mounted) return;
      setState(() {
        _loadingDesTo = false;
      });
    });
  }

  String _allLabel(bool isEn) => isEn ? 'All' : 'ទាំងអស់';

  String _safeLabel(String? value, bool isEn) {
    final v = value?.trim();
    if (v == null || v.isEmpty || v.toLowerCase() == 'null') {
      return _allLabel(isEn);
    }
    return v;
  }

  void _syncStatusText() {
    final idx = statusId >= 0 && statusId < items.length ? statusId : 0;
    if (Get.locale.toString() == 'en_US') {
      status = items[idx];
    } else {
      statusKh = itemsKh[idx];
    }
  }

  @override
  void initState() {
    super.initState();

    desFromId = widget.initialDesFromId;
    desToId = widget.initialDesToId;
    statusId = widget.initialStatusId;

    _syncStatusText();

    final isEn = Get.locale.toString() == 'en_US';
    desFrom = _allLabel(isEn);
    desTo = _allLabel(isEn);

    _setFutureDesFrom(_destination.getDesFrom(context));
    _setFutureDesTo(_destination.getDesTo(context, desFromId ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Stack(
        children: [
          Column(
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

              FutureBuilder<destination_from.DesFromResponse>(
                future: futureDesFrom,
                builder: (context, data) {
                  //print(data);
                  final isEn = Get.locale.toString() == 'en_US';
                  final allItem = destination_from.Data(
                    destinationsFromId: '0',
                    destinationsFromName: 'All',
                    destinationsFromNameKh: 'ទាំងអស់',
                    code: '',
                    id: 0,
                  );

                  final list =
                      data.data?.body?.data ?? const <destination_from.Data>[];
                  final listWithAll = <destination_from.Data>[
                    allItem,
                    ...list.where((e) {
                      final id = e.id ?? int.tryParse(e.destinationsFromId ?? '');
                      return id != 0;
                    }),
                  ];

                  if (desFromCondition) {
                    destination_from.Data? selected;
                    if ((desFromId ?? 0) != 0) {
                      selected = listWithAll.firstWhereOrNull((e) {
                        final id = e.id ?? int.tryParse(e.destinationsFromId ?? '');
                        return id == desFromId;
                      });
                    }
                    selected ??= listWithAll.first;

                    desFromId =
                        selected.id ?? int.tryParse(selected.destinationsFromId ?? '') ?? 0;
                    desFrom =
                        isEn
                            ? _safeLabel(selected.destinationsFromName, isEn)
                            : _safeLabel(selected.destinationsFromNameKh, isEn);
                    desFromCondition = false;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 15,
                      left: 10,
                      right: 10,
                    ),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.fromLTRB(
                          20,
                          10,
                          10,
                          0,
                        ),
                        labelText: 'Destination From',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: desFrom,
                          onChanged: (value) {
                            if (value == null) return;
                            final selected = listWithAll.firstWhereOrNull((e) {
                              final name =
                                  isEn
                                      ? _safeLabel(e.destinationsFromName, isEn)
                                      : _safeLabel(e.destinationsFromNameKh, isEn);
                              return name == value;
                            });

                            setState(() {
                              desFrom = value;
                              desFromId =
                                  selected?.id ??
                                  int.tryParse(selected?.destinationsFromId ?? '') ??
                                  0;

                              desTo = _allLabel(isEn);
                              desToId = 0;
                              desToCondition = true;
                              _setFutureDesTo(
                                _destination.getDesTo(context, desFromId ?? 0),
                              );
                            });
                          },
                          items:
                              listWithAll
                                  .map((e) {
                                    final label =
                                        isEn
                                            ? _safeLabel(e.destinationsFromName, isEn)
                                            : _safeLabel(e.destinationsFromNameKh, isEn);
                                    return DropdownMenuItem<String>(
                                      value: label,
                                      child: SizedBox(
                                        width: MediaQuery.sizeOf(context).width * 0.6,
                                        child: Text(label),
                                      ),
                                    );
                                  })
                                  .toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),

              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: FutureBuilder<destination_to.DesToResponse>(
                  future: futureDesTo,
                  builder: (context, data) {
                    //print(data);
                    final isEn = Get.locale.toString() == 'en_US';
                    final allItem = destination_to.Data(
                      destinationsToId: '0',
                      destinationsToName: 'All',
                      destinationsToNameKh: 'ទាំងអស់',
                      code: '',
                      id: 0,
                    );

                    final list =
                        data.data?.body?.data ?? const <destination_to.Data>[];
                    final listWithAll = <destination_to.Data>[
                      allItem,
                      ...list.where((e) {
                        final id = e.id ?? int.tryParse(e.destinationsToId ?? '');
                        return id != 0;
                      }),
                    ];

                    if (desToCondition) {
                      destination_to.Data? selected;
                      if ((desToId ?? 0) != 0) {
                        selected = listWithAll.firstWhereOrNull((e) {
                          final id = e.id ?? int.tryParse(e.destinationsToId ?? '');
                          return id == desToId;
                        });
                      }
                      selected ??= listWithAll.first;

                      desToId =
                          selected.id ?? int.tryParse(selected.destinationsToId ?? '') ?? 0;
                      desTo =
                          isEn
                              ? _safeLabel(selected.destinationsToName, isEn)
                              : _safeLabel(selected.destinationsToNameKh, isEn);
                      desToCondition = false;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        left: 10,
                        right: 10,
                      ),
                      child: Column(
                        children: [
                          InputDecorator(
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.fromLTRB(
                                20,
                                10,
                                10,
                                0,
                              ),
                              labelText: 'Destination To',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: desTo,
                                onChanged: (value) {
                                  if (value == null) return;
                                  final selected = listWithAll.firstWhereOrNull((e) {
                                    final name =
                                        isEn
                                            ? _safeLabel(e.destinationsToName, isEn)
                                            : _safeLabel(e.destinationsToNameKh, isEn);
                                    return name == value;
                                  });

                                  setState(() {
                                    desTo = value;
                                    desToId =
                                        selected?.id ??
                                        int.tryParse(selected?.destinationsToId ?? '') ??
                                        0;
                                  });
                                },
                                items:
                                    listWithAll
                                        .map((e) {
                                          final label =
                                              isEn
                                                  ? _safeLabel(e.destinationsToName, isEn)
                                                  : _safeLabel(e.destinationsToNameKh, isEn);
                                          return DropdownMenuItem<String>(
                                            value: label,
                                            child: SizedBox(
                                              width: MediaQuery.sizeOf(context).width * 0.6,
                                              child: Text(label),
                                            ),
                                          );
                                        })
                                        .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
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
                        contentPadding: const EdgeInsets.fromLTRB(
                          20,
                          10,
                          10,
                          0,
                        ),
                        labelText: 'Status',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value:
                              Get.locale.toString() == 'en_US'
                                  ? status
                                  : statusKh,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              final isEn = Get.locale.toString() == 'en_US';
                              if (isEn) {
                                status = value;
                                statusId = items.indexOf(value).clamp(0, items.length - 1);
                              } else {
                                statusKh = value;
                                statusId = itemsKh.indexOf(value).clamp(0, itemsKh.length - 1);
                              }
                            });
                          },
                          items:
                              (Get.locale.toString() == 'en_US' ? items : itemsKh)
                                  .map(
                                    (value) => DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  top: 30,
                  left: 10,
                  right: 10,
                  bottom: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              AppColors.redColor,
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                          ),
                          onPressed: () {
                            desFromCondition = true;
                            desToCondition = true;
                            desFromId = 0;
                            desToId = 0;
                            statusId = 0;
                            _syncStatusText();

                            final isEn = Get.locale.toString() == 'en_US';
                            desFrom = _allLabel(isEn);
                            desTo = _allLabel(isEn);

                            setState(() {
                              _setFutureDesFrom(
                                _destination.getDesFrom(context),
                              );
                              _setFutureDesTo(
                                _destination.getDesTo(context, 0),
                              );
                            });

                            List<int> list = <int>[];
                            list.add(0);
                            list.add(0);
                            list.add(0);
                            Get.back(result: list);
                          },
                          child: const Text(
                            'Discard',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              AppColors.primaryColor,
                            ),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                          ),
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
                            Get.back(result: list);
                          },
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_loadingDesFrom || _loadingDesTo)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    height: 30.0,
                    width: 30.0,
                    child: CircularProgressIndicator(
                      value: null,
                      strokeWidth: 3.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
