import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../activities/ticket/value_statics.dart';

class TicketMenuFormController extends GetxController {
  final RxString goDate = ''.obs;
  final RxString backDate = ''.obs;

  final RxString fromName = ''.obs;
  final RxString fromId = ''.obs;
  final RxString toName = ''.obs;
  final RxString toId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    setNow();
    syncFromStatics();
  }

  void setNow() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd');
    goDate.value = formatter.format(now);
    if (backDate.value.isEmpty) {
      backDate.value = 'return_date'.tr;
    }
  }

  void setGoDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    goDate.value = formatter.format(date);
  }

  void setBackDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    backDate.value = formatter.format(date);
  }

  void clearBackDate() {
    backDate.value = 'return_date'.tr;
  }

  void syncFromStatics() {
    fromName.value = ValueStatic.desfrom;
    fromId.value = ValueStatic.desfromId;
    toName.value = ValueStatic.desTo;
    toId.value = ValueStatic.desToId;

    if (backDate.value.isEmpty) {
      backDate.value = 'return_date'.tr;
    }
  }
}
