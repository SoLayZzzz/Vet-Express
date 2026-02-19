import 'package:express_vet/models/boarding_point.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/api/boarding_point.dart';
import 'package:express_vet/api/booking.dart';
import 'package:express_vet/api/user.dart';
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

  @override
  PassengerUistate onInitUiState() => PassengerUistate();

  Future<PassengerDetailInitResult> initPassengerDetail(
    BuildContext context,
  ) async {
    futureBoardingPointOneWay = CarPoint().getBoardingPoint(
      context,
      ValueStatic.goDate,
      ValueStatic.journeyIdGo.toString(),
    );
    futureDropOffPointOneWay = CarPoint().getDropOffPoint(
      context,
      ValueStatic.journeyIdGo.toString(),
    );

    futureBoardingPointTwoWay = null;
    futureDropOffPointTwoWay = null;
    if (ValueStatic.journeyType == 2) {
      futureBoardingPointTwoWay = CarPoint().getBoardingPoint(
        context,
        ValueStatic.backDate,
        ValueStatic.journeyIdBack.toString(),
      );
      futureDropOffPointTwoWay = CarPoint().getDropOffPoint(
        context,
        ValueStatic.journeyIdBack.toString(),
      );
    }

    updateTotals();

    futureNationality = User().getNationalityTicket(context);

    await Future.wait([
      futureBoardingPointOneWay,
      futureDropOffPointOneWay,
      if (futureBoardingPointTwoWay != null) futureBoardingPointTwoWay!,
      if (futureDropOffPointTwoWay != null) futureDropOffPointTwoWay!,
      futureNationality,
    ]);

    return PassengerDetailInitResult(
      futureBoardingPointOneWay: futureBoardingPointOneWay,
      futureDropOffPointOneWay: futureDropOffPointOneWay,
      futureBoardingPointTwoWay: futureBoardingPointTwoWay,
      futureDropOffPointTwoWay: futureDropOffPointTwoWay,
      futureNationality: futureNationality,
    );
  }

  BuildContext? checkPackageContext;
  String checkPackageCode = '';
  String checkPackageJourneyId = '';
  String checkPackageTravelDate = '';

  Future<void>? initialLoadFuture;

  // Futures for boarding, drop-off points and nationality
  late Future<CarPointResponse> futureBoardingPointOneWay;
  late Future<CarPointResponse> futureDropOffPointOneWay;
  Future<CarPointResponse>? futureBoardingPointTwoWay;
  Future<CarPointResponse>? futureDropOffPointTwoWay;

  late Future<NationalityResponse> futureNationality;

  // Text controllers for contact/package info
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final codeController = TextEditingController();
  final couponController = TextEditingController();
  final nationalityController = TextEditingController();

  // One-way passenger info
  List<String> genderOneWay = [];
  List<int> nationalOneWay = [];
  List<TextEditingController> dobOneWay = [];
  List<TextEditingController> dobOneWayList = [];
  List<TextEditingController> passportOneWay = [];
  List<TextEditingController> nameOneWay = [];

  // Round-trip passenger info
  List<String> genderTwoWay = [];
  List<int> nationalTwoWay = [];
  List<TextEditingController> dobTwoWay = [];
  List<TextEditingController> dobTwoWayList = [];
  List<TextEditingController> passportTwoWay = [];
  List<TextEditingController> nameTwoWay = [];

  // Destination selections
  List<String> boardingPointOneway = [];
  List<String> dropOffPointOneway = [];
  List<String> boardingPointTwoWay = [];
  List<String> dropOffPointTwoWay = [];

  // Nationality selections
  List<int?> nationalityIds = List.filled(
    ValueStatic.oneWaySelectedSeat.length,
    null,
  );
  List<int?> nationalityIdsTwoWay = List.filled(
    ValueStatic.twoWaySelectedSeat.length,
    null,
  );

  // Boarding / drop-off UI labels and selected indexes
  String selectedBoardingPointOneWay = 'select_boarding'.tr;
  String selectedBoardingPointAddressOneWay = '';
  int isSelectedIndexBoardingOneWay = -1;
  int isSelectedIndexDropOffOneWay = -1;
  String selectBoardingPointTwoWay = 'select_boarding'.tr;
  String selectBoardingPointAddressTwoWay = '';
  int isSelectIndexBoardingTwoWay = -1;
  int isSelectIndexDropOffTwoWay = -1;
  String selectedDropPointOneWay = 'select_drop'.tr;
  String selectedDropPointAddressOneWay = '';
  String selectDropPointTwoWay = 'select_drop'.tr;
  String selectDropPointAddressTwoWay = '';

  //* lucky draw tick or un_tick
  bool get luckyDraw => state.luckyDraw.value;
  set luckyDraw(bool value) {
    state.luckyDraw.value = value;
  }

  //* tick or un_tick apply package
  bool get isTravelPackage => state.isTravelPackage.value;
  set isTravelPackage(bool value) {
    state.isTravelPackage.value = value;
  }

  bool get isLoaded => state.isLoaded.value;
  set isLoaded(bool value) {
    state.isLoaded.value = value;
  }

  bool get isTravelPackageOk => state.isTravelPackageOk.value;
  set isTravelPackageOk(bool value) {
    state.isTravelPackageOk.value = value;
  }

  //* check phone number change or not change
  bool get isPhone => state.isPhone.value;
  set isPhone(bool value) {
    state.isPhone.value = value;
  }

  //* check this acc has package or not
  bool get isNoPackage => state.isNoPackage.value;
  set isNoPackage(bool value) {
    state.isNoPackage.value = value;
  }

  String get msgPackage => state.msgPackage.value;
  set msgPackage(String value) {
    state.msgPackage.value = value;
  }

  int get packageTypeOneWay => state.packageTypeOneWay.value;
  set packageTypeOneWay(int value) {
    state.packageTypeOneWay.value = value;
  }

  int get packageTypeTwoWay => state.packageTypeTwoWay.value;
  set packageTypeTwoWay(int value) {
    state.packageTypeTwoWay.value = value;
  }

  /// coupon code
  int get status => state.status.value;
  set status(int value) {
    state.status.value = value;
  }

  String get balance => state.balance.value;
  set balance(String value) {
    state.balance.value = value;
  }

  Future<bool> checkPackageApply() async {
    final ctx = checkPackageContext;
    if (ctx == null) {
      state.isTravelPackageOk.value = false;
      state.msgPackage.value = '';
      return false;
    }
    final body = CheckBookingPackageRequest(
      context: ctx,
      code: checkPackageCode,
      journeyId: checkPackageJourneyId,
      travelDate: checkPackageTravelDate,
    );

    final res = await passerngerUscase.checkPackageApply(body);

    if (res.header?.statusCode == 200 && res.header?.result == true) {
      final ok = (res.body?.status ?? 0) == 1;
      if (ok) {
        ValueStatic.travelPackageDis = res.body?.discount ?? 0;
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
  }) {
    ValueStatic.luckyDrawValue =
        luckyDraw
            ? ValueStatic.journeyType == 2
                ? 0.25 *
                    (ValueStatic.oneWaySelectedSeat.length +
                        ValueStatic.twoWaySelectedSeat.length)
                : 0.25 * ValueStatic.oneWaySelectedSeat.length
            : 0;

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
      if (ValueStatic.seatPriceGoDiscount) {
        totalDiscount = 0;
      } else {
        totalDiscount = double.parse(
          (getTotalAmount(seatPrice) * 0.05).toStringAsFixed(2),
        );
      }
      final totalSeat = ValueStatic.oneWaySelectedSeat.length.toString();

      ValueStatic.totalPrice = totalAmount.toString();

      final seatDob = dobOneWay;
      final seatPassport = passportOneWay;

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
        packageCode,
        couponCode,
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

      final totalDiscount = setDiscountTwoWay(seatPrice, seatPriceBack());
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
        packageCode,
        couponCode,
        seatDob: seatDob,
        seatPassport: seatPassport,
      );
    }
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
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isLoaded && ValueStatic.totalPrice.isNotEmpty) {
        markLoaded();
        update();
      }
    });
  }

  void createGenderListOneWay(List<String> genderOneWay) {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
      genderOneWay.add('0');
    }
  }

  void createNationalListOneWay(List<int> nationalOneWay) {
    for (int i = 0; i < ValueStatic.oneWaySelectedSeat.length; i++) {
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

  void createGenderListTwoWay(List<String> genderTwoWay) {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
      genderTwoWay.add('0');
    }
  }

  void createNationalListTwoWay(List<int> nationalTwoWay) {
    for (int i = 0; i < ValueStatic.twoWaySelectedSeat.length; i++) {
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
    phoneNumberController.dispose();
    emailController.dispose();
    usernameController.dispose();
    codeController.dispose();
    couponController.dispose();
    nationalityController.dispose();

    for (final c in dobOneWay) {
      c.dispose();
    }
    for (final c in dobOneWayList) {
      c.dispose();
    }
    for (final c in passportOneWay) {
      c.dispose();
    }
    for (final c in nameOneWay) {
      c.dispose();
    }
    for (final c in dobTwoWay) {
      c.dispose();
    }
    for (final c in dobTwoWayList) {
      c.dispose();
    }
    for (final c in passportTwoWay) {
      c.dispose();
    }
    for (final c in nameTwoWay) {
      c.dispose();
    }
  }
}
