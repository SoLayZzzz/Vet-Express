import 'package:get/get.dart';

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

  final RxString selectedBoardingPointOneWay = ''.obs;
  final RxString selectedBoardingPointAddressOneWay = ''.obs;
  final int isSelectedIndexBoardingOneWay = -1;
  final int isSelectedIndexDropOffOneWay = -1;

  final RxString selectBoardingPointTwoWay = ''.obs;
  final RxString selectBoardingPointAddressTwoWay = ''.obs;
  final int isSelectIndexBoardingTwoWay = -1;
  final int isSelectIndexDropOffTwoWay = -1;

  final RxString selectedDropPointOneWay = ''.obs;
  final RxString selectedDropPointAddressOneWay = ''.obs;
  final RxString selectDropPointTwoWay = ''.obs;
  final RxString selectDropPointAddressTwoWay = ''.obs;
}
