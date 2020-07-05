import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  // MAIN
  Color _mainLightColor = Color(0xFF232c33);
  Color _mainDarkColor = Color(0xFFFAFAFA);

  // SECOND
  Color _secondLightColor = Color(0xFF232c33);
  Color _secondDarkColor = Color(0xFFccccdd);

  // ACCENT
  Color _accentLightColor = Color(0xFF87c694);
  Color _accentDarkColor = Color(0xFF9999aa);

  // SCAFFOLD
  Color _scaffoldDarkColor = Color(0xFF2C2C2C);
  Color _scaffoldLightColor = Color(0xFFFAFAFA);

  Color mainColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _mainLightColor.withOpacity(opacity)
        : _mainDarkColor.withOpacity(opacity));
  }

  Color secondColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _secondLightColor.withOpacity(opacity)
        : _secondDarkColor.withOpacity(opacity));
  }

  Color accentColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _accentLightColor.withOpacity(opacity)
        : _accentDarkColor.withOpacity(opacity));
  }

  Color scaffoldColor(
      {double opacity = 1, Brightness brightness = Brightness.light}) {
    return (brightness == Brightness.light
        ? _scaffoldLightColor.withOpacity(opacity)
        : _scaffoldDarkColor.withOpacity(opacity));
  }
}
