import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class StateController<UiState> extends GetxController {
  @protected
  UiState onInitUiState();

  late final Rx<UiState> uiState = onInitUiState().obs;

  UiState get state => uiState.value;
}
