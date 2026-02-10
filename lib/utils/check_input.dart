import 'package:get/get.dart';

class CheckInput {
  String? checkLength(String value, int length, String checkNull, String checkLength) {
    if (value == '') {
      return checkNull;
    } else if (value.length < length) {
      return checkLength;
    }
    return null;
  }

  //check password and re_password
  String? checkMatch(String value1, String value2, String checkMatch) {
    if (value1 != value2) {
      return checkMatch;
    }
    return null;
  }

  //check email validate (optional)
  String? validateEmailAddress(String? value) {
    const pattern = r"^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';

    final regex = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return null;
    } else if (value.contains(' ')) {
      return 'Email cannot contain spaces';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null; // Email is valid
  }

  //check phone number validate (optional)
  String? validatePhone(String? value) {
    const pattern = r"^0[0-9]{2}[0-9]{6,7}$";

    final regex = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return null;
    } else if (value.contains(' ')) {
      return 'phone number cannot contain spaces';
    } else if (!regex.hasMatch(value)) {
      return 'Invalid phone number format';
    }

    return null; // Email is valid
  }

  //check phone number validate (require)
  String? validatePhoneRe(String? value) {
    const pattern = r"^0[0-9]{2}[0-9]{6,7}$";

    final regex = RegExp(pattern);

    if (value == null || value.isEmpty) {
      return 'phone_r'.tr;
    } else if (value.contains(' ')) {
      return 'phone number cannot contain spaces';
    } else if (!regex.hasMatch(value)) {
      return 'phone_in'.tr;
    }

    return null; // Email is valid
  }

//check boolean value in profile
  bool? validatePhoneNumber(String? value) {
    final RegExp phoneRegex = RegExp(r"^0[0-9]{2}[0-9]{6,7}$");

    if (value == null || value.isEmpty) {
      return false;
    } else if (!phoneRegex.hasMatch(value)) {
      return false;
    }
    return true;
  }

  //check boolean value in profile
  bool? validateEmail(String? value) {
    final RegExp emailRegex = RegExp(r"^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');

    if (value == null || value.isEmpty) {
      return false;
    } else if (!emailRegex.hasMatch(value)) {
      return false;
    }
    return true;
  }
}
