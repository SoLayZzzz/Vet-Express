import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../../value_statics.dart';
import '../../../../../base/state_controller.dart';
import 'seat_data.dart';
import '../../data/model/response/seat_unavailable_response.dart'
    as seat_unavailable;
import '../../../../../routes/app_routes.dart';
import '../uiState/select_seat_ui_state.dart';
import '../../domain/uscase/select_seat_usecase.dart';

class SelectSeatController extends StateController<SelectSeatUiState> {
  final SelectSeatUseCase selectSeatUseCase;

  SelectSeatController(this.selectSeatUseCase);

  @override
  SelectSeatUiState onInitUiState() => const SelectSeatUiState();

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments as Map<dynamic, dynamic>?;
    final journeyId = (args?['journeyId'] as String?) ?? '';
    final isBack = (args?['isBack'] as bool?) ?? false;
    final context = Get.context;
    if (context == null) return;

    init(context: context, journeyId: journeyId, isBack: isBack);
  }

  void init({
    required BuildContext context,
    required String journeyId,
    required bool isBack,
    List<String>? markAsUnavailable,
  }) {
    final date = isBack ? ValueStatic.backDate : ValueStatic.goDate;
    final title =
        isBack
            ? '${ValueStatic.desTo} - ${ValueStatic.desfrom}'
            : '${ValueStatic.desfrom} - ${ValueStatic.desTo}';

    final initialUnavailable = <String>[];
    final initialUnavailableGender = <String>[];
    if (markAsUnavailable != null) {
      for (final seat in markAsUnavailable) {
        initialUnavailable.add(seat);
        initialUnavailableGender.add('1');
      }
    }

    uiState.value = state.copyWith(
      isBack: isBack,
      journeyId: journeyId,
      date: date,
      title: title,
      selectedSeat: <String>[],
      selectedSeatValue: <String>[],
      unavailableSeat: initialUnavailable,
      unavailableSeatGender: initialUnavailableGender,
      futureSeatLayout: selectSeatUseCase.fetchSeatLayout(
        context: context,
        date: date,
        journeyId: journeyId,
      ),
    );

    _loadUnavailable(context, additionalUnavailable: markAsUnavailable);
  }

  Future<void> _loadUnavailable(
    BuildContext context, {
    List<String>? additionalUnavailable,
  }) async {
    final res = await selectSeatUseCase.fetchUnavailable(
      context: context,
      date: state.date,
      journeyId: state.journeyId,
    );

    final unavailableSeat = <String>[];
    final unavailableSeatGender = <String>[];

    for (final item in (res.body ?? <seat_unavailable.Body>[])) {
      unavailableSeat.add(item.seatNumber.toString());
      unavailableSeatGender.add(item.gender.toString());
    }

    if (additionalUnavailable != null) {
      for (final seat in additionalUnavailable) {
        if (!unavailableSeat.contains(seat)) {
          unavailableSeat.add(seat);
          unavailableSeatGender.add('1');
        }
      }
    }

    uiState.value = state.copyWith(
      unavailableSeat: unavailableSeat,
      unavailableSeatGender: unavailableSeatGender,
    );
  }

  bool checkUnavailable(String seatValue) {
    for (int i = 0; i < state.unavailableSeat.length; i++) {
      if (state.unavailableSeat[i] == seatValue) return true;
    }
    return false;
  }

  String checkUnavailableGender(String seatValue) {
    for (int i = 0; i < state.unavailableSeat.length; i++) {
      if (state.unavailableSeat[i] == seatValue) {
        return state.unavailableSeatGender[i] == '1' ? '(M)' : '(F)';
      }
    }
    return '';
  }

  bool checkSelected(String seatLabel) {
    for (int i = 0; i < state.selectedSeat.length; i++) {
      if (state.selectedSeat[i] == seatLabel) return true;
    }
    return false;
  }

  void toggleSeat({required String seatLabel, required String seatValue}) {
    final selectedSeat = List<String>.from(state.selectedSeat);
    final selectedSeatValue = List<String>.from(state.selectedSeatValue);

    final idx = selectedSeat.indexOf(seatLabel);
    if (idx >= 0) {
      selectedSeat.removeAt(idx);
      selectedSeatValue.removeAt(idx);
    } else {
      selectedSeat.add(seatLabel);
      selectedSeatValue.add(seatValue);
    }

    uiState.value = state.copyWith(
      selectedSeat: selectedSeat,
      selectedSeatValue: selectedSeatValue,
    );
  }

  Future<void> next() async {
    final args = Get.arguments as Map<dynamic, dynamic>?;
    final flowId = (args?['flowId'] as String?) ?? '';

    if (state.isBack) {
      ValueStatic.twoWaySelectedSeat = state.selectedSeat;
      ValueStatic.twoWaySelectedSeatValue = state.selectedSeatValue;
      await Get.toNamed(
        AppRoutes.passengerDetail,
        arguments: {'flowId': flowId},
      );
      final context = Get.context;
      if (context != null) {
        _loadUnavailable(context);
      }
      return;
    }

    ValueStatic.oneWaySelectedSeat = state.selectedSeat;
    ValueStatic.oneWaySelectedSeatValue = state.selectedSeatValue;

    if (ValueStatic.journeyType == 2) {
      await Get.toNamed(
        AppRoutes.scheduleList,
        arguments: {'isBack': true, 'flowId': flowId},
      );
      final context = Get.context;
      if (context != null) {
        _loadUnavailable(context);
      }
    } else {
      await Get.toNamed(
        AppRoutes.passengerDetail,
        arguments: {'flowId': flowId},
      );
      final context = Get.context;
      if (context != null) {
        _loadUnavailable(context);
      }
    }
  }

  List<SeatData> buildSeatListFromLayout(dynamic layoutJson) {
    final result = json.decode(layoutJson as String) as List<dynamic>;
    final seats = <SeatData>[];

    for (int i = 0; i < result.length; i++) {
      final colJson = jsonEncode(result[i]['col']);
      final col = json.decode(colJson) as List<dynamic>;
      for (int j = 0; j < col.length; j++) {
        if (col[j]['label'] == null) {
          seats.add(SeatData('', ''));
        } else {
          if (col[j]['label'] == 'Capitain') {
            seats.add(SeatData('Captain', 'Captain'));
          } else {
            seats.add(SeatData(col[j]['label'], col[j]['value']));
          }
        }

        if (col[j]['attr']['colspan'] != '') {
          for (int k = 0; k < int.parse(col[j]['attr']['colspan']) - 1; k++) {
            seats.add(SeatData('', ''));
          }
        }
      }
    }

    return seats;
  }
}
