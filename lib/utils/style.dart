import 'package:flutter/material.dart';
import 'app_colors.dart';

class Style {
  static OutlineInputBorder outlineInputBorder() {
    return const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(4)));
  }

  static InputDecoration inputText(
    String hint, {
    String? suffixText,
    IconData? iconLeft,
    IconData? iconRight,
    VoidCallback? onPressed, // Optional callback function
  }) {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.all(12),
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.greyColor),
      suffixText: suffixText,
      border: outlineInputBorder(),
      enabledBorder: outlineInputBorder(),
      focusedBorder: outlineInputBorder(),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.redColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.redColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      prefixIcon: iconLeft != null ? Icon(iconLeft, color: AppColors.textColor) : null,
      suffixIcon: iconRight != null
          ? IconButton(
              onPressed: onPressed,
              icon: Icon(iconRight, color: AppColors.borderColor),
            )
          : null,
    );
  }
}
