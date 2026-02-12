import 'package:get/get.dart';

import '../../../../routes/app_routes.dart';
import '../../data/model/response/schedule_response.dart';

class ScheduleCarDetailController extends GetxController {
  final RxInt currentSlideIndex = 0.obs;

  late final String journeyId;
  late final String carType;
  late final String seat;
  late final String image;
  late final String description;
  late final int type;
  late final int status;
  late final List<SlidePhoto> listSlide;
  late final List<Amenities> listIcon;
  late final List<BoardingPointList> boardingPoint;
  late final List<DropOffPointList> dropOffPoint;

  late final bool isBack;
  late final String flowId;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<dynamic, dynamic>?;

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
