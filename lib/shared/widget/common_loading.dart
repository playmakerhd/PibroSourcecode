import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pibro/constants/app_colors.dart';

/// Common loading widget used throughout the app
class CommonLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const CommonLoading({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(
        color: color ?? AppColors.primaryColor,
        size: size,
      ),
    );
  }
}

/// Common loading widget for buttons
class ButtonLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const ButtonLoading({
    super.key,
    this.size = 20.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeArchedCircle(
      color: color ?? Colors.white,
      size: size,
    );
  }
}
