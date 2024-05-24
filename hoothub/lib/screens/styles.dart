import 'package:flutter/material.dart';

const TextStyle questionTextStyle = TextStyle(fontSize: 60);
const double questionImageHeight = 200;
const TextStyle answerTextStyle = TextStyle(fontSize: 50, color: Color(0xFFFFFFFF));
const double mediumScreenWidth = 768;
final List<Color> themeColors = <Color>[
  const HSVColor.fromAHSV(1, 0, 2 / 3, 5 / 6).toColor(),
  const HSVColor.fromAHSV(1, 360 / 6, 2 / 3, 5 / 6).toColor(),
  const HSVColor.fromAHSV(1, 360 / 3, 2 / 3, 5 / 6).toColor(),
  const HSVColor.fromAHSV(1, 360 * 2 / 3, 2 / 3, 5 / 6).toColor(),
];
