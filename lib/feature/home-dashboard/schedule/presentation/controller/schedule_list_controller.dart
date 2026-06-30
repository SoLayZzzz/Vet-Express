import 'dart:convert';

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
import '../../../../../controller/connectivity_controller.dart';

class ScheduleListController extends StateController<ScheduleListUiState> {
  final ScheduleListUseCase scheduleListUseCase;

  ScheduleListController(this.scheduleListUseCase);

  @override
  ScheduleListUiState onInitUiState() => const ScheduleListUiState();

  @override
  void onInit() {
    super.onInit();
    ever(Get.find<ConnectivityController>().isConnected, (bool connected) {
      if (connected) {
        final context = Get.context;
        if (context != null) {
          init(isBack: state.isBack, context: context);
        }
      }
    });
  }

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

    if (isBack && _isBackDateBeforeGoDate()) {
      final adjusted = _firstAllowedBackDate();
      final formatted = DateFormat('yyyy-MM-dd').format(adjusted);
      ValueStatic.backDate = formatted;

      uiState.value = state.copyWith(
        isBack: isBack,
        currentDate: formatted,
        titleRoute: _computeTitleRoute(isBack),
        futureSchedule: _buildFutureSchedule(context: context, isBack: isBack),
      );

      _notifyInvalidBackDateAndPick(context);
      return;
    }

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
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    var initial = fmt.parse(state.currentDate);

    DateTime firstDate = now;
    if (state.isBack) {
      final go =
          ValueStatic.goDate.isNotEmpty ? fmt.parse(ValueStatic.goDate) : now;
      firstDate = go.isAfter(now) ? go : now;
      if (initial.isBefore(firstDate)) initial = firstDate;
    }

    final pickedDate = await showDatePicker(
      context: context,
      locale:
          Get.locale.toString() == 'km_KH'
              ? const Locale('km', 'KH')
              : Get.locale.toString() == 'en_US'
              ? const Locale('en', 'US')
              : const Locale('zh', 'CN'),
      initialDate: initial,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 90)),
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

  bool _isBackDateBeforeGoDate() {
    if (ValueStatic.goDate.isEmpty || ValueStatic.backDate.isEmpty)
      return false;
    final fmt = DateFormat('yyyy-MM-dd');
    final go = fmt.parse(ValueStatic.goDate);
    final back = fmt.parse(ValueStatic.backDate);
    return back.isBefore(go);
  }

  DateTime _firstAllowedBackDate() {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');
    final go =
        ValueStatic.goDate.isNotEmpty ? fmt.parse(ValueStatic.goDate) : now;
    return go.isAfter(now) ? go : now;
  }

  void _notifyInvalidBackDateAndPick(BuildContext context) {
    Get.snackbar(
      'info'.tr,
      'please_select_back_date'.tr,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
    Future.microtask(() {
      pickDate(context);
    });
  }

  void applySelectedScheduleData(Body data) {
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

  Future<void> openSelectSeat(Body data) async {
    applySelectedScheduleData(data);

    final args = Get.arguments as Map<dynamic, dynamic>?;
    final flowId = (args?['flowId'] as String?) ?? '';

    debugPrint('Body: ${jsonEncode(data.toJson())}');
    debugPrint("args: $args");

    await Get.toNamed(
      AppRoutes.selectSeat,
      arguments: {
        'journeyId': (data.id).toString(),
        'isBack': state.isBack,
        'flowId': flowId,
      },
    );

    final context = Get.context;
    if (context != null) {
      refreshSchedule(context);
    }
  }

  void refreshSchedule(BuildContext context) {
    uiState.value = state.copyWith(
      futureSchedule: _buildFutureSchedule(context: context, isBack: state.isBack),
    );
  }

  Future<void> decreaseAvailableSeats({
    required String journeyId,
    required int count,
  }) async {
    if (state.futureSchedule == null) return;
    try {
      final scheduleResponse = await state.futureSchedule!;
      final list = scheduleResponse.body;
      if (list == null) return;
      for (final item in list) {
        if (item.id == journeyId) {
          if (item.seatAvailable != null) {
            item.seatAvailable = (item.seatAvailable! - count).clamp(0, item.totalSeat ?? 0);
          }
          break;
        }
      }
      uiState.value = state.copyWith(
        futureSchedule: Future.value(scheduleResponse),
      );
    } catch (e) {
      debugPrint('Error updating schedule seats: $e');
    }
  }
}
