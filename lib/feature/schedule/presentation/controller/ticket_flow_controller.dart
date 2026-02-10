import 'package:get/get.dart';

class TicketFlowController extends GetxController {
  final RxBool isBack = false.obs;
  final RxString journeyId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<dynamic, dynamic>?;
    isBack.value = (args?['isBack'] as bool?) ?? false;
    journeyId.value = (args?['journeyId'] as String?) ?? '';
  }
}
