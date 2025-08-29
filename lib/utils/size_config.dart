import 'package:flutter/material.dart';

extension SizeExt on num {
  double get h => this * SizeConfig.screenHeight / 100;
  double get w => this * SizeConfig.screenWidth / 100;
  double get sp => this * (SizeConfig.screenHeight / 3) / 100;
}

class SizeConfig {
  static double _screenWidth = 0;
  static double _screenHeight = 0;

  static double screenWidth = 0;
  static double screenHeight = 0;

  void init(BoxConstraints constraints) {
    _screenWidth = constraints.maxWidth;
    _screenHeight = constraints.maxHeight;
    screenWidth = _screenWidth;
    screenHeight = _screenHeight;
  }
}
