import 'package:flutter/material.dart';

const TextStyle questionTextStyle = TextStyle(fontSize: 60);
const double questionImageHeight = 200;
const TextStyle answerTextStyle = TextStyle(fontSize: 50, color: Color(0xFFFFFFFF));
const double mediumScreenWidth = 768;

const double themeColorsSaturation = 5 / 6;
const double themeColorsValue =  5 / 6;

final List<Color> themeColors = <Color>[
  const HSVColor.fromAHSV(1, 0, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 * 2 / 3, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 / 6, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 / 3, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 / 2, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 * 5 / 6, themeColorsSaturation, themeColorsSaturation).toColor(),
];

const Color primaryColor = Colors.purple;
final Color secondaryColor = Colors.purple.shade800;
const Color white = Colors.white;

final ThemeData outerTheme = ThemeData(
  /* colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: white,
    onPrimary: primaryColor,
    secondary: white,
    onSecondary: secondaryColor,
    error: Colors.red,
    onError: white,
    background: Colors.purple.shade100,
    onBackground: secondaryColor,
    surface: primaryColor,
    onSurface: white,
  ), */
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    onPrimary: white,
    secondary: white,
    onSecondary: Colors.purple,
    background: Colors.purple.shade100,
    onBackground: secondaryColor,
    surface: primaryColor,
    onSurface: white,
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll(primaryColor),
      backgroundColor: MaterialStatePropertyAll(white),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: primaryColor,
    contentTextStyle: TextStyle(color: white),
  ),
  useMaterial3: true,
);

Color answerColor(int index) {
  return themeColors[index];
}
