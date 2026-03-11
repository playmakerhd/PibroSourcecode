import 'package:flutter/material.dart';
import 'package:pibro/constants/app_colors.dart';
import 'package:pibro/constants/app_constants.dart';
import 'package:pibro/constants/app_styles.dart';
import 'package:pibro/shared/custom_input/app_input_border.dart';

class CustomDropdown extends StatefulWidget {
  final String? hint;
  final String? label;
  final double? width;
  final double? height;
  final bool isRequired;
  final Widget? suffixIcon;
  final String? Function(dynamic)? validator;
  final String? errorText;
  final double labelSize;
  final Function(dynamic)? onChanged;
  final List<DropdownMenuItem<dynamic>>? items;
  final dynamic dropDownValue;

  const CustomDropdown({
    super.key,
    this.hint,
    this.label,
    this.validator,
    this.suffixIcon,
    this.errorText,
    this.width,
    this.isRequired = true,
    this.height,
    this.labelSize = 14,
    required this.onChanged,
    required this.items,
    this.dropDownValue,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  @override
  Widget build(BuildContext context) {
    InputDecoration decoration = InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      errorMaxLines: 1,
      filled: true,
      fillColor: AppColors.inputGrey.withValues(alpha: 0.4),
      focusedErrorBorder: AppInputBorders.withLabelFocusedBorder,
      focusedBorder: AppInputBorders.withLabelFocusedBorder,
      disabledBorder: AppInputBorders.disabledBorder,
      border: AppInputBorders.withLabelBorder,
      enabledBorder: AppInputBorders.withLabelBorder,
    );

    Widget textField = DropdownButtonFormField<dynamic>(
      initialValue: widget.dropDownValue,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      hint: Text(widget.hint!,
          style: Styles.regularTextStyle(
            size: 12,
            color: AppColors.hintColor,
          )),
      icon: widget.suffixIcon,
      style: Styles.mediumTextStyle(),
      decoration: decoration,
      isExpanded: true,
      items: widget.items,
      onChanged: widget.onChanged,
      validator: widget.validator,
    );

    return Container(
      padding: EdgeInsets.only(bottom: 20),
      width: widget.width ?? MediaQuery.of(context).size.width * 0.9,
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
            borderRadius: BorderRadius.circular(AppConstants.snackBarRadius),
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
