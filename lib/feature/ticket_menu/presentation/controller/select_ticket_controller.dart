import 'package:get/get.dart';

import '../../../../activities/ticket/value_statics.dart';
import '../../data/model/response/destination_response.dart';
import 'ticket_menu_controller.dart';

class SelectTicketController extends GetxController {
  final TicketMenuController ticketMenuController;

  SelectTicketController(this.ticketMenuController);

  final RxString searchText = ''.obs;
  final RxBool isLoading = false.obs;
  final RxList<DestinationItem> items = <DestinationItem>[].obs;

  late final String selectType;

  @override
  void onInit() {
    super.onInit();
    selectType = (Get.arguments?['selectType'] as String?) ?? '';
    load('');
  }

  Future<void> load(String search) async {
    searchText.value = search;
    isLoading.value = true;
    try {
      final type = ValueStatic.ticketType == '3' ? '1' : ValueStatic.ticketType;
      final DestinationResponse res;
      if (selectType == 'Destination From') {
        res = await ticketMenuController.destinationsFrom(
          type: type,
          searchText: search,
        );
      } else {
        res = await ticketMenuController.destinationsTo(
          fromId: ValueStatic.desfromId,
          type: type,
          searchText: search,
        );
      }

      if (res.header?.statusCode == 200 && res.header?.result == true) {
        items.assignAll(res.body ?? <DestinationItem>[]);
      } else {
        items.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectItem(DestinationItem item) {
    if (selectType == 'Destination From') {
      ValueStatic.desfrom = item.name?.toString() ?? '';
      ValueStatic.desfromId = item.id?.toString() ?? '';
      ValueStatic.desTo = '';
      ValueStatic.desToId = '';
    } else {
      ValueStatic.desTo = item.name?.toString() ?? '';
      ValueStatic.desToId = item.id?.toString() ?? '';
    }

    Get.back(result: true);
  }
}
