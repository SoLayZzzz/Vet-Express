import 'package:get/get.dart';

import '../../../../../routes/app_routes.dart';
import '../../data/model/response/schedule_response.dart';

class ScheduleCarDetailController extends GetxController {
  final RxInt currentSlideIndex = 0.obs;

  String journeyId = '';
  String carType = '';
  String seat = '';
  String image = '';
  String description = '';
  int type = 1;
  int status = 0;
  List<SlidePhoto> listSlide = <SlidePhoto>[];
  List<Amenities> listIcon = <Amenities>[];
  List<BoardingPointList> boardingPoint = <BoardingPointList>[];
  List<DropOffPointList> dropOffPoint = <DropOffPointList>[];

  bool isBack = false;
  String flowId = '';

  @override
  void onInit() {
    super.onInit();

    applyArgs(Get.arguments as Map<dynamic, dynamic>?);
  }

  void applyArgs(Map<dynamic, dynamic>? args) {
    journeyId = (args?['journeyId'] as String?) ?? '';
    carType = (args?['carType'] as String?) ?? '';
    seat = (args?['seat'] as String?) ?? '';
    image = (args?['image'] as String?) ?? '';
    description = (args?['description'] as String?) ?? '';
    type = (args?['type'] as int?) ?? 1;
    status = (args?['status'] as int?) ?? 0;

    listSlide = (args?['listSlide'] as List<SlidePhoto>?) ?? <SlidePhoto>[];
    listIcon = (args?['listIcon'] as List<Amenities>?) ?? <Amenities>[];
    boardingPoint =
        (args?['boardingPoint'] as List<BoardingPointList>?) ??
        <BoardingPointList>[];
    dropOffPoint =
        (args?['dropOffPoint'] as List<DropOffPointList>?) ??
        <DropOffPointList>[];

    isBack = (args?['isBack'] as bool?) ?? (type != 1);
    flowId = (args?['flowId'] as String?) ?? '';

    currentSlideIndex.value = 0;
    update();
  }

  void onCarouselPageChanged(int index) {
    currentSlideIndex.value = index;
  }

  void openSelectSeat() {
    Get.toNamed(
      AppRoutes.selectSeat,
      arguments: {'journeyId': journeyId, 'isBack': isBack, 'flowId': flowId},
    );
  }
}
