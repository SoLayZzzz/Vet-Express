import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:express_vet/feature/auth/data/model/response/nationality_response.dart';
import 'package:express_vet/models/boarding_point.dart';

class PassengerUistate {
  final RxBool luckyDraw = false.obs;
  final RxBool isTravelPackage = false.obs;
  final RxBool isLoaded = false.obs;
  final RxBool isTravelPackageOk = false.obs;
  final RxBool isPhone = false.obs;
  final RxBool isNoPackage = false.obs;

  final RxString msgPackage = ''.obs;
  final RxInt packageTypeOneWay = 0.obs;
  final RxInt packageTypeTwoWay = 0.obs;

  final RxInt status = 0.obs;
  final RxString balance = ''.obs;

  final RxString selectedBoardingPointOneWay = 'select_boarding'.tr.obs;
  final RxString selectedBoardingPointAddressOneWay = ''.obs;
  final RxInt isSelectedIndexBoardingOneWay = (-1).obs;
  final RxInt isSelectedIndexDropOffOneWay = (-1).obs;

  final RxString selectBoardingPointTwoWay = 'select_boarding'.tr.obs;
  final RxString selectBoardingPointAddressTwoWay = ''.obs;
  final RxInt isSelectIndexBoardingTwoWay = (-1).obs;
  final RxInt isSelectIndexDropOffTwoWay = (-1).obs;

  final RxString selectedDropPointOneWay = 'select_drop'.tr.obs;
  final RxString selectedDropPointAddressOneWay = ''.obs;
  final RxString selectDropPointTwoWay = 'select_drop'.tr.obs;
  final RxString selectDropPointAddressTwoWay = ''.obs;

  List<String> boardingPointOneway = [];
  List<String> dropOffPointOneway = [];
  List<String> boardingPointTwoWay = [];
  List<String> dropOffPointTwoWay = [];

  List<int?> nationalityIds = [];
  List<int?> nationalityIdsTwoWay = [];

  BuildContext? checkPackageContext;
  String checkPackageCode = '';
  String checkPackageJourneyId = '';
  String checkPackageTravelDate = '';

  Future<void>? initialLoadFuture;

  Future<CarPointResponse>? futureBoardingPointOneWay;
  Future<CarPointResponse>? futureDropOffPointOneWay;
  Future<CarPointResponse>? futureBoardingPointTwoWay;
  Future<CarPointResponse>? futureDropOffPointTwoWay;
  Future<NationalityResponse>? futureNationality;

  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final codeController = TextEditingController();
  final couponController = TextEditingController();
  final nationalityController = TextEditingController();

  List<String> genderOneWay = [];
  List<int> nationalOneWay = [];
  List<TextEditingController> dobOneWay = [];
  List<TextEditingController> dobOneWayList = [];
  List<TextEditingController> passportOneWay = [];
  List<TextEditingController> nameOneWay = [];

  List<String> genderTwoWay = [];
  List<int> nationalTwoWay = [];
  List<TextEditingController> dobTwoWay = [];
  List<TextEditingController> dobTwoWayList = [];
  List<TextEditingController> passportTwoWay = [];
  List<TextEditingController> nameTwoWay = [];
}
