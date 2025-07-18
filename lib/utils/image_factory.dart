import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

abstract class CustomImage {
  Widget render({
    double? height,
    double? width,
    BoxFit? fit,
    Color? color,
    bool excludeFromSemantics,
  });
}

class PngImage implements CustomImage {
  final String assetName;

  PngImage(this.assetName);

  @override
  Widget render(
      {double? height,
      double? width,
      BoxFit? fit,
      Color? color,
      bool excludeFromSemantics = false}) {
    return Image.asset(
      assetName,
      height: height,
      width: width,
      fit: fit,
      color: color,
      excludeFromSemantics: excludeFromSemantics,
    );
  }
}

class SvgImage implements CustomImage {
  final String assetName;

  SvgImage(this.assetName);

  @override
  Widget render(
      {double? height,
      double? width,
      BoxFit? fit,
      Color? color,
      bool excludeFromSemantics = false}) {
    return SvgPicture.asset(
      assetName,
      height: height,
      width: width,
      fit: fit ?? BoxFit.contain,
      excludeFromSemantics: excludeFromSemantics,
    );
  }
}

class ImageFactory {
  static CustomImage getImage(String assetName) {
    if (assetName.endsWith('.svg')) {
      return SvgImage(assetName);
    } else if (assetName.endsWith('.png')) {
      return PngImage(assetName);
    } else {
      throw UnsupportedError('Image format not supported');
    }
  }
}
