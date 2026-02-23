import 'package:express_vet/feature/home-dashboard/schedule/data/model/request/schedule_request_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../base/state_controller.dart';
import '../../data/model/response/schedule_response.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../../value_statics.dart';
import '../../../../../utils/app_colors.dart';
import '../uiState/schedule_list_ui_state.dart';
import '../../domain/uscase/schedule_list_usecase.dart';

class ScheduleListController extends StateController<ScheduleListUiState> {
  final ScheduleListUseCase scheduleListUseCase;

  ScheduleListController(this.scheduleListUseCase);

  @override
  ScheduleListUiState onInitUiState() => const ScheduleListUiState();

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments as Map<dynamic, dynamic>?;
    final isBack = (args?['isBack'] as bool?) ?? false;
    final context = Get.context;
    if (context == null) return;

    init(isBack: isBack, context: context);
  }

  void init({required bool isBack, required BuildContext context}) {
    final currentDate = _computeCurrentDate(isBack);
    uiState.value = state.copyWith(
      isBack: isBack,
      currentDate: currentDate,
      titleRoute: _computeTitleRoute(isBack),
      futureSchedule: _buildFutureSchedule(context: context, isBack: isBack),
    );
  }

  Future<ScheduleResponse> _buildFutureSchedule({
    required BuildContext context,
    required bool isBack,
  }) {
    final currentDate = _computeCurrentDate(isBack);
    final fromId = isBack ? ValueStatic.desToId : ValueStatic.desfromId;
    final toId = isBack ? ValueStatic.desfromId : ValueStatic.desToId;
    final scheduleType = isBack ? '2' : '3';

    final body = ScheduleRequestBody(
      date: currentDate,
      fromId: fromId,
      toId: toId,
      type: ValueStatic.ticketType == '3' ? '1' : ValueStatic.ticketType,
      app: scheduleType,
      national: ValueStatic.national,
    );

    return scheduleListUseCase.fetchSchedule(context: context, body: body);
  }

  String _computeCurrentDate(bool isBack) =>
      isBack ? ValueStatic.backDate : ValueStatic.goDate;

  String _computeTitleRoute(bool isBack) =>
      isBack
          ? '${ValueStatic.desTo} - ${ValueStatic.desfrom}'
          : '${ValueStatic.desfrom} - ${ValueStatic.desTo}';

  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      locale:
          Get.locale.toString() == 'km_KH'
              ? const Locale('km', 'KH')
              : Get.locale.toString() == 'en_US'
              ? const Locale('en', 'US')
              : const Locale('zh', 'CN'),
      initialDate: DateFormat('yyyy-MM-dd').parse(state.currentDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  ValueStatic.ticketType == '3'
                      ? AppColors.airBusColor
                      : AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    ValueStatic.ticketType == '3'
                        ? AppColors.airBusColor
                        : AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final formatted = DateFormat('yyyy-MM-dd').format(pickedDate);

    if (state.isBack) {
      ValueStatic.backDate = formatted;
    } else {
      ValueStatic.goDate = formatted;
    }

    uiState.value = state.copyWith(
      currentDate: formatted,
      titleRoute: _computeTitleRoute(state.isBack),
      futureSchedule: _buildFutureSchedule(
        context: Get.context!,
        isBack: state.isBack,
      ),
    );
  }

  void applySelectedScheduleData(ScheduleResponseBody data) {
    if (state.isBack) {
      ValueStatic.departureBackTime = (data.departure).toString();
      ValueStatic.carBackType = (data.transportationType).toString();
      ValueStatic.journeyIdBack = (data.id).toString();
      ValueStatic.seatPriceBack = (data.price).toString();
      ValueStatic.seatPriceBackDiscount = (data.priceOriginal) != '';
      ValueStatic.priceOriginalTwoWay = (data.priceOriginal ?? '').toString();
      ValueStatic.companyTypeTwoWay = (data.journeyType ?? 0);
      ValueStatic.vehicleTypeTwoWay = (data.vehicleType ?? 0);
    } else {
      ValueStatic.departureGoTime = (data.departure).toString();
      ValueStatic.carGoType = (data.transportationType).toString();
      ValueStatic.journeyIdGo = (data.id).toString();
      ValueStatic.seatPriceGo = (data.price).toString();
      ValueStatic.seatPriceGoDiscount = (data.priceOriginal) != '';
      ValueStatic.priceOriginalOneWay = (data.priceOriginal ?? '').toString();
      ValueStatic.companyTypeOneWay = (data.journeyType ?? 0);
      ValueStatic.vehicleTypeOneWay = (data.vehicleType ?? 0);
    }
  }

  void openSelectSeat(ScheduleResponseBody data) {
    applySelectedScheduleData(data);

    final args = Get.arguments as Map<dynamic, dynamic>?;
    final flowId = (args?['flowId'] as String?) ?? '';

    Get.toNamed(
      AppRoutes.selectSeat,
      arguments: {
        'journeyId': (data.id).toString(),
        'isBack': state.isBack,
        'flowId': flowId,
      },
    );
  }
}
