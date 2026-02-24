import 'package:express_vet/feature/auth/data/model/response/nationality_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthUiState {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool signInPasswordVisible = false.obs;
  final RxString activeLanguage = 'km'.obs;

  final RxBool signUpPasswordVisible = false.obs;
  final RxBool signUpRePasswordVisible = false.obs;
  final RxString signUpGender = ''.obs;
  final RxString signUpNationalityValue = ''.obs;
  final RxInt signUpNationalityId = 0.obs;
  final RxString signUpImagePath = ''.obs;

  final RxBool newPasswordVisible = false.obs;
  final RxBool newRePasswordVisible = false.obs;

  final RxBool verifyTimeExpired = false.obs;
  final RxBool verifyResend = false.obs;
  final RxInt verifyCountResend = 0.obs;
  final RxInt verifyIdentify = 0.obs;

  //
  final signInFormKey = GlobalKey<FormState>();
  final signUpFormKey = GlobalKey<FormState>();

  late TextEditingController signInPhoneController;
  late TextEditingController signInPasswordController;

  late TextEditingController signUpUsernameController;
  late TextEditingController signUpPhoneController;
  late TextEditingController signUpPasswordController;
  late TextEditingController signUpRePasswordController;
  late TextEditingController signUpEmailController;
  late TextEditingController signUpDateOfBirthController;
  late TextEditingController signUpNationalitySearchController;

  final forgotPasswordFormKey = GlobalKey<FormState>();
  late TextEditingController forgotPasswordPhoneController;

  final createNewPasswordFormKey = GlobalKey<FormState>();
  late TextEditingController createNewPasswordController;
  late TextEditingController createNewRePasswordController;

  Future<NationalityResponse>? nationalityFuture;
}
