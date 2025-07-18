import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfStyles {
  static const PdfColor colorPrimary = PdfColor.fromInt(0xff1b2537);
  static const PdfColor colorWhite = PdfColor.fromInt(0xffffffff);
  static const PdfColor toorlogLightGrey = PdfColor.fromInt(0xfff5f6f8);
  static const PdfColor toorlogBlue = PdfColor.fromInt(0xff12408e);
  static const PdfColor toorlogRed = PdfColor.fromInt(0xffd22932);
  static const PdfColor inactiveBar = PdfColor.fromInt(0xffe2e2e2);

  static Future<TextStyle> thinTextStyle({
    PdfColor color = colorPrimary,
    double size = 15,
    FontStyle fontStyle = FontStyle.normal,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansThin(),
        fontSize: size,
        fontStyle: fontStyle);
  }

  static Future<TextStyle> lightTextStyle({
    PdfColor color = colorPrimary,
    double size = 15,
    bool italic = false,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansLight(),
        fontSize: size,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal);
  }

  static Future<TextStyle> regularTextStyle({
    PdfColor color = colorPrimary,
    double size = 15,
    FontStyle fontStyle = FontStyle.normal,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansRegular(),
        fontSize: size,
        fontStyle: fontStyle,
        decoration: TextDecoration.none);
  }

  static Future<TextStyle> mediumTextStyle({
    PdfColor color = colorPrimary,
    double size = 15,
    FontStyle fontStyle = FontStyle.normal,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansMedium(),
        fontSize: size,
        fontStyle: fontStyle);
  }

  static Future<TextStyle> semiBoldTextStyle({
    PdfColor color = colorPrimary,
    double size = 14,
    FontStyle fontStyle = FontStyle.normal,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansSemiBold(),
        fontSize: size,
        fontStyle: fontStyle,
        decoration: TextDecoration.none);
  }

  static Future<TextStyle> boldTextStyle({
    PdfColor color = colorPrimary,
    double size = 15,
    FontStyle fontStyle = FontStyle.normal,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansBold(),
        fontSize: size,
        fontStyle: fontStyle);
  }

  static Future<TextStyle> extraBoldTextStyle({
    PdfColor color = colorPrimary,
    double size = 15,
    FontStyle fontStyle = FontStyle.normal,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansExtraBold(),
        fontSize: size,
        fontStyle: fontStyle);
  }

  static Future<TextStyle> linkTextStyle({
    double size = 12,
    PdfColor color = toorlogBlue,
  }) async {
    return TextStyle(
        color: color,
        font: await PdfGoogleFonts.workSansMedium(),
        fontSize: size,
        decoration: TextDecoration.underline);
  }

  static Future<Map> collectFonts() async {
    return {
      'workSansSemiBold': await PdfGoogleFonts.workSansSemiBold(),
      'workSansMedium': await PdfGoogleFonts.workSansMedium(),
      'workSansRegular': await PdfGoogleFonts.workSansRegular()
    };
  }

  static Future<Map> collectSvgImages() async {
    return {
      'groupage': await rootBundle.loadString("assets/images/groupage.svg"),
      'calendarIconSmall':
          await rootBundle.loadString("assets/images/calendar_icon_small.svg"),
      'spokenLang':
          await rootBundle.loadString("assets/images/spoken_lang.svg"),
      'clock': await rootBundle.loadString("assets/images/icon_time.svg")
    };
  }

  static TextStyle getTextStyle(
    Font font, {
    PdfColor color = PdfColors.white,
    double size = 15,
    FontStyle fontStyle = FontStyle.normal,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return TextStyle(
        color: color,
        font: font,
        fontSize: size,
        fontStyle: fontStyle,
        decoration: decoration);
  }

  static pw.SvgImage getSvgImage(
    String svg, {
    PdfColor color = PdfColors.white,
    double height = 10,
  }) {
    return pw.SvgImage(svg: svg, colorFilter: color, height: height);
  }
}
