import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/utils/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputTextField extends StatefulWidget {
  const InputTextField({
    super.key,
    this.label,
    this.isRequired = true,
    this.labelStyle = const TextStyle(color: AppColors.mainTitle),
    this.hint,
    this.hintMaxLines,
    this.contentPadding,
    this.initialValue,
    this.controller,
    this.validator,
    this.onTap,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.textInputAction,
    this.iconLeft,
    this.iconRight,
    this.iconRightSize = 24,
    this.iconRightColor = AppColors.suffixIconColor,
    this.onIconRightPressed,
    this.suffixText,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String? label;
  final bool isRequired;
  final TextStyle labelStyle;
  final String? hint;
  final int? hintMaxLines;
  final EdgeInsetsGeometry? contentPadding;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final IconData? iconLeft;
  final IconData? iconRight;
  final double iconRightSize;
  final Color iconRightColor;
  final VoidCallback? onIconRightPressed;
  final String? suffixText;
  final bool readOnly;
  final bool? showCursor;
  final bool autofocus;
  final AutovalidateMode autovalidateMode;

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  TextEditingController? _internalController;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    if (widget.controller == null && widget.initialValue != null) {
      _internalController = TextEditingController(text: widget.initialValue);
      _internalController!.selection = TextSelection.collapsed(
        offset: widget.initialValue!.length,
      );
    }
  }

  @override
  void didUpdateWidget(covariant InputTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && widget.initialValue != oldWidget.initialValue) {
      final text = widget.initialValue ?? '';
      _controller.value = _controller.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
        composing: TextRange.empty,
      );
    }
  }

  static const double _kSidePadding = 12;
  static const double _kIconBox = 24;

  InputDecoration _inputDecoration({required bool hasError}) {
    final defaultPadding = EdgeInsetsDirectional.fromSTEB(
      widget.iconLeft == null ? _kSidePadding : 0,
      14,
      widget.iconRight == null && widget.suffixText == null ? _kSidePadding : 0,
      14,
    );

    return InputDecoration(
      isDense: true,
      constraints: const BoxConstraints(minHeight: 48),
      contentPadding: widget.contentPadding ?? defaultPadding,
      hintText: widget.hint,
      hintMaxLines: widget.hintMaxLines,
      hintStyle: const TextStyle(color: AppColors.placeholderColor, fontSize: 14),
      errorText: hasError ? '' : null,
      errorStyle: const TextStyle(fontSize: 0, height: 0),
      suffix: widget.suffixText == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(
                start: _kSidePadding,
                end: _kSidePadding,
              ),
              child: Text(
                widget.suffixText!,
                style: const TextStyle(color: AppColors.placeholderColor),
              ),
            ),
      border: Style.outlineInputBorder(),
      enabledBorder: Style.outlineInputBorder(),
      focusedBorder: Style.outlineInputBorder(),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.redColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: AppColors.redColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(4),
        ),
      ),
      prefixIcon: widget.iconLeft == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(
                start: _kSidePadding,
                end: _kSidePadding,
              ),
              child: SizedBox(
                width: _kIconBox,
                height: _kIconBox,
                child: Center(
                  child: Icon(
                    widget.iconLeft,
                    color: AppColors.textColor,
                    size: _kIconBox,
                  ),
                ),
              ),
            ),
      prefixIconConstraints: widget.iconLeft == null
          ? null
          : const BoxConstraints.tightFor(width: 48, height: 48),
      suffixIcon: widget.iconRight == null
          ? null
          : Padding(
              padding: const EdgeInsetsDirectional.only(
                start: _kSidePadding,
                end: _kSidePadding,
              ),
              child: IconButton(
                onPressed: widget.onIconRightPressed,
                // padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: _kIconBox,
                  height: _kIconBox,
                ),
                icon: SizedBox(
                  width: _kIconBox,
                  height: _kIconBox,
                  child: Center(
                    child: Icon(
                      widget.iconRight,
                      color: widget.iconRightColor,
                      size: widget.iconRightSize,
                    ),
                  ),
                ),
              ),
            ),
      suffixIconConstraints: widget.iconRight == null
          ? null
          : const BoxConstraints.tightFor(width: 48, height: 48),
    );
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: widget.label, style: widget.labelStyle),
                if (widget.isRequired)
                  TextSpan(
                    text: ' *',
                    style:
                        widget.labelStyle.copyWith(color: AppColors.redColor),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 7),
        ],
        FormField<String>(
          validator:
              widget.validator == null
                  ? null
                  : (_) => widget.validator!.call(_controller.text),
          autovalidateMode: widget.autovalidateMode,
          initialValue: _controller.text,
          builder: (field) {
            final errorText = field.errorText;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _controller,
                  autofocus: widget.autofocus,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  maxLines: widget.obscureText ? 1 : widget.maxLines,
                  minLines: widget.obscureText ? 1 : widget.minLines,
                  obscureText: widget.obscureText,
                  textInputAction: widget.textInputAction,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mainTitle,
                  ),
                  onChanged: (value) {
                    field.didChange(value);
                    widget.onChanged?.call(value);
                  },
                  onTap: widget.onTap,
                  readOnly: widget.readOnly,
                  showCursor: widget.showCursor,
                  decoration: _inputDecoration(hasError: errorText != null),
                ),
                if (errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      errorText,
                      style: const TextStyle(
                        color: AppColors.redColor,
                        fontSize: 12,
                        height: 0.5,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
