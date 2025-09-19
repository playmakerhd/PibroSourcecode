import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/shared/custom_input/app_input_border.dart';

class CustomInput extends StatefulWidget {
  final String? hint;
  final String? label;
  final double? width;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscure;
  final bool enabled;
  final bool isRequired;
  final String? Function(String?)? validator;
  final int? maxLines;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final double labelSize;
  final String? initialValue;
  final bool enableInteractiveSelection;
  final TextInputType? inputType;
  final bool hasFillColor;
  final bool noBottomPadding;
  final bool isReducedBorderRadius;
  final bool readonly;
  final Function()? onTap;

  const CustomInput({
    super.key,
    this.hint,
    this.label,
    this.obscure = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.width,
    this.enabled = true,
    this.isRequired = true,
    this.maxLines = 1,
    this.controller,
    this.inputFormatters,
    this.height,
    this.labelSize = 14,
    this.initialValue,
    this.enableInteractiveSelection = true,
    this.inputType,
    this.hasFillColor = false,
    this.noBottomPadding = false,
    this.isReducedBorderRadius = false,
    this.readonly = false,
    this.onTap,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  @override
  Widget build(BuildContext context) {
    bool hasLabel = widget.label != null && widget.label!.isNotEmpty;
    Widget textField = TextFormField(
      enableInteractiveSelection: widget.enableInteractiveSelection,
      initialValue: widget.initialValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller,
      obscureText: widget.obscure,
      enabled: widget.enabled,
      obscuringCharacter: '*',
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.inputType ?? TextInputType.text,
      maxLines: widget.maxLines,
      readOnly: widget.readonly,
      onTap: widget.onTap,
      style: Styles.mediumTextStyle(),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        errorMaxLines: 1,
        labelText: hasLabel ? null : widget.hint,
        hintText: !hasLabel ? null : widget.hint,
        hintStyle: Styles.regularTextStyle(
          size: 12,
          color: AppColors.hintColor,
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        labelStyle: Styles.regularTextStyle(),
        counterText: '',
        filled: true,
        fillColor: hasLabel
            ? AppColors.inputGrey.withValues(alpha: 0.4)
            : widget.hasFillColor
                ? AppColors.white
                : Colors.transparent,
        focusedErrorBorder: hasLabel
            ? AppInputBorders.withLabelFocusedBorder
            : widget.isReducedBorderRadius
                ? AppInputBorders.reducedFocusedBorder
                : AppInputBorders.outlineFocusedBorder,
        focusedBorder: hasLabel
            ? AppInputBorders.withLabelFocusedBorder
            : widget.isReducedBorderRadius
                ? AppInputBorders.reducedFocusedBorder
                : widget.hasFillColor
                    ? AppInputBorders.fillFocusedBorder
                    : AppInputBorders.outlineFocusedBorder,
        disabledBorder: AppInputBorders.disabledBorder,
        border: hasLabel
            ? AppInputBorders.withLabelBorder
            : widget.isReducedBorderRadius
                ? AppInputBorders.reducedBorder
                : widget.hasFillColor
                    ? AppInputBorders.fillBorder
                    : AppInputBorders.outlineBorder,
        enabledBorder: hasLabel
            ? AppInputBorders.withLabelBorder
            : widget.isReducedBorderRadius
                ? AppInputBorders.reducedBorder
                : widget.hasFillColor
                    ? AppInputBorders.fillBorder
                    : AppInputBorders.outlineBorder,
      ),
      validator: widget.validator,
    );

    return Container(
      padding: EdgeInsets.only(bottom: widget.noBottomPadding ? 0 : 20),
      width: widget.width ?? double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: widget.label,
                      style: Styles.mediumTextStyle(
                          color: AppColors.primaryColor, size: 14),
                    ),
                    if (widget.isRequired)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      )
                  ],
                ),
              ),
            ),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(
              widget.isReducedBorderRadius || hasLabel
                  ? AppConstants.snackBarRadius
                  : AppConstants.appRadius,
            ),
            child: textField,
          ),
          if (widget.errorText != '' && widget.errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 5),
              child: Text(
                style: Styles.lightTextStyle(color: Colors.red, size: 12),
                widget.errorText ?? '',
              ),
            ),
        ],
      ),
    );
  }
}
