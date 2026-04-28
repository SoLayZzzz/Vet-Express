import 'dart:convert';

import 'package:express_vet/models/boarding_point.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:express_vet/value_statics.dart';
import 'package:express_vet/controller/user_controller.dart';
import 'package:express_vet/feature/home-dashboard/passenger/presentation/controller/booking.dart';
import 'package:express_vet/feature/auth/presentation/binding/auth_binding.dart';
import 'package:express_vet/feature/auth/domain/uscase/auth_usecase.dart';
import 'package:express_vet/base/state_controller.dart';
import 'package:express_vet/feature/home-dashboard/passenger/data/model/request/check_booking_package_request.dart';
import 'package:express_vet/feature/home-dashboard/passenger/presentation/uistate/passenger_uistate.dart';
import 'package:express_vet/feature/auth/data/model/response/nationality_response.dart';

import '../../domain/uscase/passernger_uscase.dart';

class PassengerDetailInitResult {
  final Future<CarPointResponse> futureBoardingPointOneWay;
  final Future<CarPointResponse> futureDropOffPointOneWay;
  final Future<CarPointResponse>? futureBoardingPointTwoWay;
  final Future<CarPointResponse>? futureDropOffPointTwoWay;
  final Future<NationalityResponse> futureNationality;

  const PassengerDetailInitResult({
    required this.futureBoardingPointOneWay,
    required this.futureDropOffPointOneWay,
    required this.futureBoardingPointTwoWay,
    required this.futureDropOffPointTwoWay,
    required this.futureNationality,
  });
}

class PassengerDetailController extends StateController<PassengerUistate> {
  final PasserngerUscase passerngerUscase;

  PassengerDetailController(this.passerngerUscase);

  bool forceZeroDiscount = false;
  bool packageOnlyDiscountMode = false;

  String _formatDobForDisplay(String rawDob) {
    final raw = rawDob.trim();
    if (raw.isEmpty) return '';

    DateTime? parsed = DateTime.tryParse(raw);
    parsed ??= DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (parsed == null) {
      try {
        parsed = DateFormat('dd-MM-yyyy').parseStrict(raw);
      } catch (_) {
        parsed = null;
      }
    }
    if (parsed == null) return raw;
    return DateFormat('dd-MM-yyyy').format(parsed);
  }

  void _applyAutofillToSeatControllers({
    required int seatCount,
    required int companyType,
    required List<TextEditingController> nameControllers,
    required List<TextEditingController> dobDisplayControllers,
    required List<TextEditingController> dobValueControllers,
    required String name,
    required String dob,
  }) {
    if (seatCount != 1) return;
    if (companyType == 4 && nameControllers.isNotEmpty) {
      if (nameControllers[0].text.trim().isEmpty && name.trim().isNotEmpty) {
        nameControllers[0].text = name.trim();
      }
    }

    if (dobDisplayControllers.isNotEmpty && dobValueControllers.isNotEmpty) {
      final formattedDob = _formatDobForDisplay(dob);
      if (formattedDob.isNotEmpty) {
        if (dobDisplayControllers[0].text.trim().isEmpty) {
          dobDisplayControllers[0].text = formattedDob;
        }
        if (dobValueControllers[0].text.trim().isEmpty) {
          dobValueControllers[0].text = formattedDob;
        }
      }
    }
  }

  void onPassengerDetailScreenEnter() {
    updateTotals();
  }

  void onPassengerDetailScreenExit() {
    state.initialLoadFuture = null;
    state.isLoaded.value = false;

    state.isTravelPackage.value = false;
    state.isTravelPackageOk.value = false;
    state.isNoPackage.value = false;
    state.msgPackage.value = '';
    state.checkPackageContext = null;
    state.checkPackageCode = '';
    state.checkPackageJourneyId = '';
    state.checkPackageTravelDate = '';

    state.status.value = 0;
    state.balance.value = '';
    state.couponController.text = '';

    ValueStatic.travelPackageDis = 0;
    ValueStatic.totalPriceDiscount = 0;
    ValueStatic.luckyDrawValue = 0;
    ValueStatic.seatPriceGoDiscount = false;
    ValueStatic.seatPriceBackDiscount = false;

    forceZeroDiscount = false;
    packageOnlyDiscountMode = false;
  }

  @override
  PassengerUistate onInitUiState() => PassengerUistate();

  Worker? _userWorker;

  @override
  void onInit() {
    super.onInit();
    try {
      final user = Get.find<UserController>();
      if (user.userMeResponse.value == null && !user.isLoading.value) {
        user.fetchUserMe();
      }
      _userWorker = ever(user.userMeResponse, (_) {
        applyUserDefaultsToEmptySelections();
      });
    } catch (_) {}
  }

  @override
  void onClose() {
    _userWorker?.dispose();
    super.onClose();
  }

  Future<PassengerDetailInitResult> initPassengerDetail(
    BuildContext context,
  ) async {
    state.futureBoardingPointOneWay = passerngerUscase.getBoardingPoint(
      context: context,
      date: ValueStatic.goDate,
      journeyId: ValueStatic.journeyIdGo.toString(),
    );
    state.futureDropOffPointOneWay = passerngerUscase.getDropOffPoint(
      context: context,
      journeyId: ValueStatic.journeyIdGo.toString(),
    );

    state.futureBoardingPointTwoWay = null;
    state.futureDropOffPointTwoWay = null;
    if (ValueStatic.journeyType == 2) {
      state.futureBoardingPointTwoWay = passerngerUscase.getBoardingPoint(
        context: context,
        date: ValueStatic.backDate,
        journeyId: ValueStatic.journeyIdBack.toString(),
      );
      state.futureDropOffPointTwoWay = passerngerUscase.getDropOffPoint(
        context: context,
        journeyId: ValueStatic.journeyIdBack.toString(),
      );
    }

    updateTotals();

    if (!Get.isRegistered<AuthUseCase>()) {
      AuthBinding().dependencies();
    }
    state.futureNationality = Get.find<AuthUseCase>().nationalityListTicket();

    final futures = <Future<dynamic>>[
      state.futureBoardingPointOneWay!,
      state.futureDropOffPointOneWay!,
      state.futureNationality!,
    ];
    if (state.futureBoardingPointTwoWay != null) {
      futures.add(state.futureBoardingPointTwoWay!);
    }
    if (state.futureDropOffPointTwoWay != null) {
      futures.add(state.futureDropOffPointTwoWay!);
    }
    await Future.wait(futures);

    try {
      final boardingOneWay = await state.futureBoardingPointOneWay!;
      final dropOffOneWay = await state.futureDropOffPointOneWay!;
      debugPrint(
        '[Passenger] BoardingPoint OneWay: ${jsonEncode(boardingOneWay.toJson())}',
      );
      debugPrint(
        '[Passenger] DropOffPoint OneWay: ${jsonEncode(dropOffOneWay.toJson())}',
      );

      if (state.futureBoardingPointTwoWay != null) {
        final boardingTwoWay = await state.futureBoardingPointTwoWay!;
        debugPrint(
          '[Passenger] BoardingPoint TwoWay: ${jsonEncode(boardingTwoWay.toJson())}',
        );
      }
      if (state.futureDropOffPointTwoWay != null) {
        final dropOffTwoWay = await state.futureDropOffPointTwoWay!;
        debugPrint(
          '[Passenger] DropOffPoint TwoWay: ${jsonEncode(dropOffTwoWay.toJson())}',
        );
      }
    } catch (e) {
      debugPrint('[Passenger] Failed to log boarding/drop-off data: $e');
    }

    return PassengerDetailInitResult(
      futureBoardingPointOneWay: state.futureBoardingPointOneWay!,
      futureDropOffPointOneWay: state.futureDropOffPointOneWay!,
      futureBoardingPointTwoWay: state.futureBoardingPointTwoWay,
      futureDropOffPointTwoWay: state.futureDropOffPointTwoWay,
      futureNationality: state.futureNationality!,
    );
  }

  Future<bool> checkPackageApply() async {
    final ctx = uiState.value.checkPackageContext;
    if (ctx == null) {
      state.isTravelPackageOk.value = false;
      state.msgPackage.value = '';
      return false;
    }
    final body = CheckBookingPackageRequest(
      context: ctx,
      code: uiState.value.checkPackageCode,
      journeyId: uiState.value.checkPackageJourneyId,
      travelDate: uiState.value.checkPackageTravelDate,
    );

    final res = await passerngerUscase.checkPackageApply(body);

    if (res.header?.statusCode == 200 && res.header?.result == true) {
      final ok = (res.body?.status ?? 0) == 1;
      if (ok) {
        ValueStatic.travelPackageDis = res.body?.discount ?? 0;
        final _subTotal = double.tryParse(ValueStatic.totalPrice) ?? 0.0;
        final _discountAmt = getTravelPackageDiscountAmount(_subTotal);
        debugPrint(
          '[Package] apply ok: discount='
          '${ValueStatic.travelPackageDis}% -> amount=$_discountAmt on subTotal=$_subTotal',
        );
        state.msgPackage.value = '';
        state.isTravelPackageOk.value = true;
        return true;
      }

      state.isTravelPackageOk.value = false;
      state.msgPackage.value = res.body?.msg ?? '';
      return false;
    }

    state.isTravelPackageOk.value = false;
    state.msgPackage.value = res.body?.msg ?? '';
    return false;
  }

  List<double> seatPriceGo() {
    final seatPrice = <double>[];
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      seatPrice.add(double.parse(ValueStatic.seatPriceGo));
    }
    return seatPrice;
  }

  List<double> seatPriceBack() {
    final seatPrice = <double>[];
    if (ValueStatic.journeyType == 2) {
      for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
        seatPrice.add(double.parse(ValueStatic.seatPriceBack));
      }
    }
    return seatPrice;
  }

  List<String> seatNameGo() {
    final seatName = <String>[];
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      seatName.add(ValueStatic.username.toString());
    }
    return seatName;
  }

  List<String> seatNameBack() {
    final seatName = <String>[];
    if (ValueStatic.journeyType == 2) {
      for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
        seatName.add(ValueStatic.username.toString());
      }
    }
    return seatName;
  }

  List<String> seatJourneyGo() {
    final seatJourney = <String>[];
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      seatJourney.add(ValueStatic.journeyIdGo.toString());
    }
    if (ValueStatic.journeyType == 2) {
      for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
        seatJourney.add(ValueStatic.journeyIdBack.toString());
      }
    }
    return seatJourney;
  }

  void updateTotals() {
    if (ValueStatic.journeyType == 1) {
      ValueStatic.totalPrice = getTotalAmount(seatPriceGo()).toStringAsFixed(2);
    } else {
      ValueStatic.totalPrice = (getTotalAmount(seatPriceGo()) +
              getTotalAmount(seatPriceBack()))
          .toStringAsFixed(2);
    }

    ValueStatic.totalPriceBack = getTotalAmount(seatPriceBack());
    ValueStatic.totalPriceGo = getTotalAmount(seatPriceGo());
  }

  double getTotalAmount(List<double> seatPrice) {
    double totalPrice = 0;
    for (int i = 0; i < seatPrice.length; i++) {
      totalPrice += seatPrice[i];
    }
    return totalPrice;
  }

  double getTravelPackageDiscountAmount(double subTotal) {
    if (ValueStatic.travelPackageDis <= 0 || subTotal <= 0) {
      return 0.0;
    }

    final percent = ValueStatic.travelPackageDis.toDouble();
    final rawDiscount = subTotal * (percent / 100.0);
    final appliedDiscount = rawDiscount > subTotal ? subTotal : rawDiscount;
    return double.parse(appliedDiscount.toStringAsFixed(2));
  }

  double setDiscountTwoWay(List<double> seatPrice, List<double> seatPriceBack) {
    double disCountGo;
    double disCountBack;

    if (ValueStatic.seatPriceGoDiscount) {
      disCountGo = 0;
    } else {
      disCountGo = double.parse(
        (getTotalAmount(seatPrice) * 0.05).toStringAsFixed(2),
      );
    }

    if (ValueStatic.seatPriceBackDiscount) {
      disCountBack = 0;
    } else {
      disCountBack = double.parse(
        (getTotalAmount(seatPriceBack) * 0.05).toStringAsFixed(2),
      );
    }

    return disCountGo + disCountBack;
  }

  void confirmBooking({
    required BuildContext context,
    required bool isConfirm,
    required bool luckyDraw,
    required List<String> genderOneWay,
    required List<int> nationalOneWay,
    required List<String> genderTwoWay,
    required List<int> nationalTwoWay,
    required List<String> dobOneWay,
    required List<String> dobTwoWay,
    required List<String> passportOneWay,
    required List<String> passportTwoWay,
    required List<String> nameOneWay,
    required List<String> nameTwoWay,
    required String packageCode,
    required String couponCode,
    bool forceZeroDiscount = false,
  }) {
    debugPrint('--- Confirm Booking Started ---');
    debugPrint(
      'isConfirm: $isConfirm, luckyDraw: $luckyDraw, journeyType: ${ValueStatic.journeyType}',
    );

    final effectivePackageCode = forceZeroDiscount ? '' : packageCode;
    final effectiveCouponCode = forceZeroDiscount ? '' : couponCode;
    ValueStatic.luckyDrawValue =
        luckyDraw
            ? ValueStatic.journeyType == 2
                ? 0.25 *
                    (ValueStatic.oneWaySelectedSeat.length +
                        ValueStatic.twoWaySelectedSeat.length)
                : 0.25 * ValueStatic.oneWaySelectedSeat.length
            : 0;

    debugPrint('luckyDrawValue calculated: ${ValueStatic.luckyDrawValue}');
    if (!isConfirm) return;

    if (ValueStatic.journeyType == 1) {
      final boardingPointId = <int>[
        int.parse(ValueStatic.boardingPointOneWayId),
      ];
      final dropOffPointId = <int>[int.parse(ValueStatic.dropOffPointOneWayId)];
      final email =
          ValueStatic.email.isEmpty ? 'user@gmail.com' : ValueStatic.email;
      final journeyDate = <String>[ValueStatic.goDate];
      final journeyId = <String>[ValueStatic.journeyIdGo];
      const journeyType = 1;
      final name = ValueStatic.username;
      final seatGender = genderOneWay;
      final seatNationallyId = nationalOneWay;
      final seatJourney = seatJourneyGo();
      final seatName =
          ValueStatic.companyTypeOneWay == 4 ? nameOneWay : seatNameGo();
      final seatNum = ValueStatic.oneWaySelectedSeatValue;
      final seatPrice = seatPriceGo();
      final telephone = ValueStatic.phone;

      final totalAmount = getTotalAmount(seatPrice);
      double totalDiscount = 0;
      if (!forceZeroDiscount) {
        if (state.isTravelPackage.value &&
            state.isTravelPackageOk.value &&
            ValueStatic.travelPackageDis > 0) {
          totalDiscount = getTravelPackageDiscountAmount(totalAmount);
          debugPrint(
            'Applying travel package discount: ${ValueStatic.travelPackageDis}% -> $totalDiscount',
          );
        } else if (ValueStatic.seatPriceGoDiscount) {
          totalDiscount = 0;
          debugPrint('No standard 5% discount (seatPriceGoDiscount=true)');
        } else {
          totalDiscount = double.parse(
            (getTotalAmount(seatPrice) * 0.05).toStringAsFixed(2),
          );
          debugPrint('Applying standard 5% discount -> $totalDiscount');
        }
      }
      final totalSeat = ValueStatic.oneWaySelectedSeat.length.toString();

      ValueStatic.totalPrice = totalAmount.toString();

      final seatDob = dobOneWay;
      final seatPassport = passportOneWay;

      debugPrint(
        'One-Way Data: seats: $seatNum, total: $totalAmount, discount: $totalDiscount',
      );

      Booking().confirmBooking(
        context,
        boardingPointId,
        dropOffPointId,
        email,
        journeyDate,
        journeyId,
        journeyType,
        name,
        seatGender,
        seatJourney,
        seatName,
        seatNum,
        seatPrice,
        telephone,
        totalAmount,
        totalDiscount,
        totalSeat,
        '2',
        seatNationallyId,
        ValueStatic.national,
        luckyDraw,
        effectivePackageCode,
        effectiveCouponCode,
        seatDob: seatDob,
        seatPassport: seatPassport,
      );
    } else {
      final boardingPointId = <int>[
        int.parse(ValueStatic.boardingPointOneWayId),
        int.parse(ValueStatic.boardingPointTwoWayId),
      ];
      final dropOffPointId = <int>[
        int.parse(ValueStatic.dropOffPointOneWayId),
        int.parse(ValueStatic.dropOffPointTwoWayId),
      ];
      final email =
          ValueStatic.email.isEmpty ? 'user@gmail.com' : ValueStatic.email;
      final journeyDate = <String>[ValueStatic.goDate, ValueStatic.backDate];
      final journeyId = <String>[
        ValueStatic.journeyIdGo,
        ValueStatic.journeyIdBack,
      ];
      const journeyType = 2;
      final name = ValueStatic.username;

      final seatGender = <String>[];
      seatGender.addAll(genderOneWay);
      seatGender.addAll(genderTwoWay);

      final seatNationality = <int>[];
      seatNationality.addAll(nationalOneWay);
      seatNationality.addAll(nationalTwoWay);

      final seatJourney = seatJourneyGo();

      final seatName = <String>[];
      seatName.addAll(
        ValueStatic.companyTypeOneWay == 4 ? nameOneWay : seatNameGo(),
      );
      seatName.addAll(
        ValueStatic.companyTypeTwoWay == 4 ? nameTwoWay : seatNameBack(),
      );

      final seatNum = <String>[];
      seatNum.addAll(ValueStatic.oneWaySelectedSeatValue);
      seatNum.addAll(ValueStatic.twoWaySelectedSeatValue);

      final seatPrice = seatPriceGo();
      final seatPriceRound = seatPriceBack();

      final totalSeatPrice = <double>[];
      totalSeatPrice.addAll(seatPrice);
      totalSeatPrice.addAll(seatPriceRound);

      final telephone = ValueStatic.phone;

      final totalAmount = getTotalAmount(seatPrice);
      final totalAmountBack = getTotalAmount(seatPriceRound);

      ValueStatic.totalPriceGo = totalAmount;
      ValueStatic.totalPriceBack = totalAmountBack;

      final totalDiscount =
          forceZeroDiscount
              ? 0.0
              : (state.isTravelPackage.value &&
                  state.isTravelPackageOk.value &&
                  ValueStatic.travelPackageDis > 0)
              ? getTravelPackageDiscountAmount(totalAmount + totalAmountBack)
              : setDiscountTwoWay(seatPrice, seatPriceBack());
      ValueStatic.totalPriceDiscount = totalDiscount;

      final totalSeat =
          (ValueStatic.oneWaySelectedSeat.length +
                  ValueStatic.twoWaySelectedSeat.length)
              .toString();
      ValueStatic.totalPrice = (totalAmount + totalAmountBack).toString();

      final seatDob = <String>[];
      seatDob.addAll(dobOneWay);
      seatDob.addAll(dobTwoWay);

      final seatPassport = <String>[];
      seatPassport.addAll(passportOneWay);
      seatPassport.addAll(passportTwoWay);

      debugPrint(
        'Two-Way Data: totalSeats: $totalSeat, totalAmount: ${ValueStatic.totalPrice}, discount: $totalDiscount',
      );
      debugPrint('Seat Names: $seatName');

      Booking().confirmBooking(
        context,
        boardingPointId,
        dropOffPointId,
        email,
        journeyDate,
        journeyId,
        journeyType,
        name,
        seatGender,
        seatJourney,
        seatName,
        seatNum,
        totalSeatPrice,
        telephone,
        totalAmount + totalAmountBack,
        totalDiscount,
        totalSeat,
        '2',
        seatNationality,
        ValueStatic.national,
        luckyDraw,
        effectivePackageCode,
        effectiveCouponCode,
        seatDob: seatDob,
        seatPassport: seatPassport,
      );
    }
    debugPrint('--- Confirm Booking Method Execution Finished ---');
  }

  List<String> getDobOneWay(List<TextEditingController> controllers) {
    final seatDob = <String>[];
    for (final c in controllers) {
      seatDob.add(c.text);
    }
    return seatDob;
  }

  List<String> getDobTwoWay(List<TextEditingController> controllers) {
    final seatDob = <String>[];
    for (final c in controllers) {
      seatDob.add(c.text);
    }
    return seatDob;
  }

  List<String> getPassportOneWay(List<TextEditingController> controllers) {
    final seatPassport = <String>[];
    for (final c in controllers) {
      seatPassport.add(c.text);
    }
    return seatPassport;
  }

  List<String> getPassportTwoWay(List<TextEditingController> controllers) {
    final seatPassport = <String>[];
    for (final c in controllers) {
      seatPassport.add(c.text);
    }
    return seatPassport;
  }

  List<String> getNameOneWay(List<TextEditingController> controllers) {
    final seatName = <String>[];
    for (final c in controllers) {
      seatName.add(c.text);
    }
    return seatName;
  }

  List<String> getNameTwoWay(List<TextEditingController> controllers) {
    final seatName = <String>[];
    for (final c in controllers) {
      seatName.add(c.text);
    }
    return seatName;
  }

  void getData({
    required BuildContext context,
    required bool isConfirm,
    required bool luckyDraw,
    required List<String> genderOneWay,
    required List<int> nationalOneWay,
    required List<String> genderTwoWay,
    required List<int> nationalTwoWay,
    required List<TextEditingController> dobOneWayControllers,
    required List<TextEditingController> dobTwoWayControllers,
    required List<TextEditingController> passportOneWayControllers,
    required List<TextEditingController> passportTwoWayControllers,
    required List<TextEditingController> nameOneWayControllers,
    required List<TextEditingController> nameTwoWayControllers,
    required String packageCode,
    required String couponCode,
    required bool isLoaded,
    required VoidCallback markLoaded,
  }) {
    confirmBooking(
      context: context,
      isConfirm: isConfirm,
      luckyDraw: luckyDraw,
      genderOneWay: genderOneWay,
      nationalOneWay: nationalOneWay,
      genderTwoWay: genderTwoWay,
      nationalTwoWay: nationalTwoWay,
      dobOneWay: getDobOneWay(dobOneWayControllers),
      dobTwoWay: getDobTwoWay(dobTwoWayControllers),
      passportOneWay: getPassportOneWay(passportOneWayControllers),
      passportTwoWay: getPassportTwoWay(passportTwoWayControllers),
      nameOneWay: getNameOneWay(nameOneWayControllers),
      nameTwoWay: getNameTwoWay(nameTwoWayControllers),
      packageCode: packageCode,
      couponCode: couponCode,
      forceZeroDiscount: forceZeroDiscount,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isLoaded && ValueStatic.totalPrice.isNotEmpty) {
        markLoaded();
        update();
      }
    });
  }

  void createGenderListOneWay(List<String> genderOneWay) {
    while (genderOneWay.length > ValueStatic.oneWaySelectedSeat.length) {
      genderOneWay.removeLast();
    }
    for (
      int i = genderOneWay.length;
      i < ValueStatic.oneWaySelectedSeat.length;
      i++
    ) {
      genderOneWay.add('0');
    }
  }

  void createNationalListOneWay(List<int> nationalOneWay) {
    while (nationalOneWay.length > ValueStatic.oneWaySelectedSeat.length) {
      nationalOneWay.removeLast();
    }
    for (
      int i = nationalOneWay.length;
      i < ValueStatic.oneWaySelectedSeat.length;
      i++
    ) {
      nationalOneWay.add(0);
    }
  }

  void createDobOneWay(List<TextEditingController> dobOneWay) {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      dobOneWay.add(TextEditingController());
    }
  }

  void createDobOneWayList(List<TextEditingController> dobOneWayList) {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      dobOneWayList.add(TextEditingController());
    }
  }

  void createPassportOneWay(List<TextEditingController> passportOneWay) {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      passportOneWay.add(TextEditingController());
    }
  }

  void createNameOneWay(List<TextEditingController> nameOneWay) {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      nameOneWay.add(TextEditingController());
    }
  }

  void autofillFromUserIfSingle() {
    try {
      final user = Get.find<UserController>();
      if (ValueStatic.journeyType == 1 &&
          ValueStatic.oneWaySelectedSeat.length == 1) {
        if (state.genderOneWay.isEmpty) {
          state.genderOneWay.add('0');
        }
        final g = user.gender;
        if (g == 1 || g == 2) {
          state.genderOneWay[0] = g.toString();
        }

        if (state.nationalOneWay.isEmpty) {
          state.nationalOneWay.add(0);
        }
        final natId = user.nationalityId;
        if (natId > 0) {
          state.nationalOneWay[0] = natId;
          if (state.nationalityIds.isEmpty) {
            state.nationalityIds = List<int?>.filled(
              ValueStatic.oneWaySelectedSeat.length,
              null,
            );
          }
          state.nationalityIds[0] = natId;
        }
        update();
      }
    } catch (_) {}
  }

  void createGenderListTwoWay(List<String> genderTwoWay) {
    while (genderTwoWay.length > ValueStatic.twoWaySelectedSeat.length) {
      genderTwoWay.removeLast();
    }
    for (
      int i = genderTwoWay.length;
      i < ValueStatic.twoWaySelectedSeat.length;
      i++
    ) {
      genderTwoWay.add('0');
    }
  }

  void createNationalListTwoWay(List<int> nationalTwoWay) {
    while (nationalTwoWay.length > ValueStatic.twoWaySelectedSeat.length) {
      nationalTwoWay.removeLast();
    }
    for (
      int i = nationalTwoWay.length;
      i < ValueStatic.twoWaySelectedSeat.length;
      i++
    ) {
      nationalTwoWay.add(0);
    }
  }

  void createDobTwoWay(List<TextEditingController> dobTwoWay) {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      dobTwoWay.add(TextEditingController());
    }
  }

  void createDobTwoWayList(List<TextEditingController> dobTwoWayList) {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      dobTwoWayList.add(TextEditingController());
    }
  }

  void createPassportTwoWay(List<TextEditingController> passportTwoWay) {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      passportTwoWay.add(TextEditingController());
    }
  }

  void createNameTwoWay(List<TextEditingController> nameTwoWay) {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      nameTwoWay.add(TextEditingController());
    }
  }

  void syncUserProfileToForm({bool onlyIfEmpty = true}) {
    try {
      final user = Get.find<UserController>();
      final body = user.userMeResponse.value?.body;
      final displayName =
          (body?.name?.trim().isNotEmpty ?? false)
              ? body!.name!.trim()
              : (body?.username ?? '').trim();
      final phone = (body?.telephone ?? '').trim();
      final email = (body?.email ?? '').trim();
      final dob = (body?.dob ?? '').trim();
      final gender = body?.gender ?? 0;
      final nationalityId = body?.nationalityId ?? 0;
      final nationalityName = (body?.nationalityName ?? '').trim();

      if (displayName.isNotEmpty) {
        ValueStatic.username = displayName;
        if (!onlyIfEmpty || state.usernameController.text.isEmpty) {
          state.usernameController.text = displayName;
        }
      } else if (!onlyIfEmpty && ValueStatic.username.isNotEmpty) {
        state.usernameController.text = ValueStatic.username;
      }

      if (phone.isNotEmpty) {
        ValueStatic.phone = phone;
        if (!onlyIfEmpty || state.phoneNumberController.text.isEmpty) {
          state.phoneNumberController.text = phone;
        }
      } else if (!onlyIfEmpty && ValueStatic.phone.isNotEmpty) {
        state.phoneNumberController.text = ValueStatic.phone;
      }

      if (email.isNotEmpty) {
        ValueStatic.email = email;
        if (!onlyIfEmpty || state.emailController.text.isEmpty) {
          state.emailController.text = email;
        }
      } else if (!onlyIfEmpty && ValueStatic.email.isNotEmpty) {
        state.emailController.text = ValueStatic.email;
      }

      if (dob.isNotEmpty) {
        ValueStatic.dob = dob;
      }
      if (gender > 0) {
        ValueStatic.gender = gender;
      }
      if (nationalityId > 0) {
        ValueStatic.nationalityId = nationalityId;
      }
      if (nationalityName.isNotEmpty) {
        ValueStatic.nationalityName = nationalityName;
      }
    } catch (_) {
      if (!onlyIfEmpty) {
        if (state.usernameController.text.isEmpty &&
            ValueStatic.username.isNotEmpty) {
          state.usernameController.text = ValueStatic.username;
        }
        if (state.phoneNumberController.text.isEmpty &&
            ValueStatic.phone.isNotEmpty) {
          state.phoneNumberController.text = ValueStatic.phone;
        }
        if (state.emailController.text.isEmpty &&
            ValueStatic.email.isNotEmpty) {
          state.emailController.text = ValueStatic.email;
        }
      }
    }
  }

  void _ensurePassengerSelectionSlots() {
    createGenderListOneWay(state.genderOneWay);
    createNationalListOneWay(state.nationalOneWay);
    createGenderListTwoWay(state.genderTwoWay);
    createNationalListTwoWay(state.nationalTwoWay);

    final oldNationalityIds = state.nationalityIds;
    state.nationalityIds = List<int?>.generate(
      ValueStatic.oneWaySelectedSeat.length,
      (index) =>
          index < oldNationalityIds.length ? oldNationalityIds[index] : null,
    );

    final oldNationalityIdsTwoWay = state.nationalityIdsTwoWay;
    state.nationalityIdsTwoWay = List<int?>.generate(
      ValueStatic.twoWaySelectedSeat.length,
      (index) =>
          index < oldNationalityIdsTwoWay.length
              ? oldNationalityIdsTwoWay[index]
              : null,
    );
  }

  void applyUserDefaultsToEmptySelections() {
    try {
      final user = Get.find<UserController>();
      final g = user.gender; // 1 male, 2 female
      final natId = user.nationalityId; // >0 valid

      syncUserProfileToForm();
      _ensurePassengerSelectionSlots();

      if (state.genderOneWay.isNotEmpty &&
          (g == 1 || g == 2) &&
          state.genderOneWay[0] == '0') {
        state.genderOneWay[0] = g.toString();
      }
      if (state.nationalOneWay.isNotEmpty &&
          natId > 0 &&
          state.nationalOneWay[0] == 0) {
        state.nationalOneWay[0] = natId;
      }
      if (state.nationalityIds.isNotEmpty && natId > 0) {
        final current = state.nationalityIds[0] ?? 0;
        if (current == 0) {
          state.nationalityIds[0] = natId;
        }
      }

      if (state.genderTwoWay.isNotEmpty &&
          (g == 1 || g == 2) &&
          state.genderTwoWay[0] == '0') {
        state.genderTwoWay[0] = g.toString();
      }
      if (state.nationalTwoWay.isNotEmpty &&
          natId > 0 &&
          state.nationalTwoWay[0] == 0) {
        state.nationalTwoWay[0] = natId;
      }
      if (state.nationalityIdsTwoWay.isNotEmpty && natId > 0) {
        final current = state.nationalityIdsTwoWay[0] ?? 0;
        if (current == 0) {
          state.nationalityIdsTwoWay[0] = natId;
        }
      }

      _applyAutofillToSeatControllers(
        seatCount: ValueStatic.oneWaySelectedSeat.length,
        companyType: ValueStatic.companyTypeOneWay,
        nameControllers: state.nameOneWay,
        dobDisplayControllers: state.dobOneWayList,
        dobValueControllers: state.dobOneWay,
        name: ValueStatic.username,
        dob: user.dob,
      );
      _applyAutofillToSeatControllers(
        seatCount: ValueStatic.twoWaySelectedSeat.length,
        companyType: ValueStatic.companyTypeTwoWay,
        nameControllers: state.nameTwoWay,
        dobDisplayControllers: state.dobTwoWayList,
        dobValueControllers: state.dobTwoWay,
        name: ValueStatic.username,
        dob: user.dob,
      );

      update();
    } catch (_) {}
  }

  void boardingListOneway(List<String> boardingPointOneway) {
    boardingPointOneway.add(ValueStatic.boardingPointOneWay);
    update();
  }

  void dropOffListOneway(List<String> dropOffPointOneway) {
    dropOffPointOneway.add(ValueStatic.dropOffPointOneWay);
    update();
  }

  void boardingListTwoWay(List<String> boardingPointTwoWay) {
    boardingPointTwoWay.add(ValueStatic.boardingPointTwoWay);
    update();
  }

  bool checkData(List<String> data) {
    bool hasZero = false;
    for (int i = 0; i < data.length; i++) {
      if (data[i] == '0') {
        hasZero = true;
        break;
      }
    }
    return hasZero;
  }

  bool check(List<String> data) {
    return data.any((item) => item.isEmpty);
  }

  bool checkDataNation(List<int> data) {
    return data.contains(0);
  }

  void dropOffListTwoWay(List<String> dropOffPointTwoWay) {
    dropOffPointTwoWay.add(ValueStatic.dropOffPointTwoWay);
    update();
  }

  Color getColor(Set<WidgetState> states) {
    const Set<WidgetState> interactiveStates = <WidgetState>{
      WidgetState.pressed,
      WidgetState.hovered,
      WidgetState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.grey[300]!;
    }
    return Colors.grey[300]!;
  }

  void disposeResources({required FocusNode inputFocusNode}) {
    inputFocusNode.dispose();
    state.phoneNumberController.dispose();
    state.emailController.dispose();
    state.usernameController.dispose();
    state.codeController.dispose();
    state.couponController.dispose();
    state.nationalityController.dispose();

    for (final c in state.dobOneWay) {
      c.dispose();
    }
    for (final c in state.dobOneWayList) {
      c.dispose();
    }
    for (final c in state.passportOneWay) {
      c.dispose();
    }
    for (final c in state.nameOneWay) {
      c.dispose();
    }
    for (final c in state.dobTwoWay) {
      c.dispose();
    }
    for (final c in state.dobTwoWayList) {
      c.dispose();
    }
    for (final c in state.passportTwoWay) {
      c.dispose();
    }
    for (final c in state.nameTwoWay) {
      c.dispose();
    }
  }
}
