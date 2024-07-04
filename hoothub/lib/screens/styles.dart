import 'package:flutter/material.dart';

const double questionImageHeight = 200;
const double mediumScreenWidth = 768;
const double largeScreenWidth = 992;

const BoxConstraints userImageButtonConstraints = BoxConstraints(
  maxWidth: 60,
  maxHeight: 60,
);

const BoxConstraints questionImageConstraints = BoxConstraints(maxWidth: largeScreenWidth, maxHeight: questionImageHeight);

const double themeColorsSaturation = 1;
const double themeColorsValue = 1;

final List<Color> themeColors = <Color>[
  const HSVColor.fromAHSV(1, 0, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 * 2 / 3, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 / 6, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 / 3, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 * 11 / 24, themeColorsSaturation, themeColorsSaturation).toColor(),
  const HSVColor.fromAHSV(1, 360 * 19 / 24, themeColorsSaturation, themeColorsSaturation).toColor(),
];

const Color primaryColor = Colors.purple;
final Color secondaryColor = Colors.purple.shade800;
final Color tertiaryColor = Colors.purple.shade200;
const Color white = Colors.white;

const TextStyle questionTextStyle = TextStyle(fontSize: 60, color: primaryColor);
const TextStyle answerTextStyle = TextStyle(fontSize: 50, color: Colors.black);

final dropDownInputTheme = InputDecorationTheme(
      labelStyle: TextStyle(color: tertiaryColor),
      iconColor: primaryColor,
      prefixIconColor: primaryColor,
      suffixIconColor: primaryColor,
      focusColor: secondaryColor,
      hoverColor: primaryColor,
      errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: secondaryColor)),
      focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      disabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
      enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
      border: const OutlineInputBorder(borderSide: BorderSide(color: primaryColor)),
    );

final credentialsInputTheme = InputDecorationTheme(
  labelStyle: TextStyle(color: tertiaryColor),
  iconColor: primaryColor,
  prefixIconColor: primaryColor,
  suffixIconColor: primaryColor,
  focusColor: secondaryColor,
  hoverColor: primaryColor,
);
const submitCredentialsButtonStyle = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll(primaryColor),
  foregroundColor: MaterialStatePropertyAll(white),
);

final ThemeData outerTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: primaryColor,
    onPrimary: white,
    background: white,
    onBackground: primaryColor,
    surface: primaryColor,
    onSurface: white,
  ),
  appBarTheme: const AppBarTheme(
    foregroundColor: white,
    backgroundColor: primaryColor,
  ),
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll<Color>(primaryColor),
    ),
  ),
  textTheme: const TextTheme(
                    displayLarge: TextStyle(
                      color: primaryColor,
                    ),
                    displayMedium: TextStyle(
                      color: primaryColor,
                    ),
                    displaySmall: TextStyle(
                      color: primaryColor,
                    ),
                    headlineLarge: TextStyle(
                      color: primaryColor,
                    ),
                    headlineMedium: TextStyle(
                      color: primaryColor,
                    ),
                    headlineSmall: TextStyle(
                      color: primaryColor,
                    ),
                    titleLarge: TextStyle(
                      color: primaryColor,
                    ),
                    titleMedium: TextStyle(
                      color: primaryColor,
                    ),
                    titleSmall: TextStyle(
                      color: primaryColor,
                    ),
                    bodyLarge: TextStyle(
                      color: primaryColor,
                    ),
                    bodyMedium: TextStyle(
                      color: primaryColor,
                    ),
                    bodySmall: TextStyle(
                      color: primaryColor,
                    ),
                    labelLarge: TextStyle(
                      color: primaryColor,
                    ),
                    labelMedium: TextStyle(
                      color: primaryColor,
                    ),
                    labelSmall: TextStyle(
                      color: primaryColor,
                    ),
                  ),
  indicatorColor: primaryColor,
  inputDecorationTheme: credentialsInputTheme,
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: const TextStyle(color: primaryColor),
    inputDecorationTheme: dropDownInputTheme,
  ),
  checkboxTheme: const CheckboxThemeData(
    side: BorderSide(color: primaryColor),
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
  return themeColors[index % themeColors.length];
}
