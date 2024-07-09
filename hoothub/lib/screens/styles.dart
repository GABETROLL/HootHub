import 'package:flutter/material.dart';

const double questionImageHeight = 200;
const double mediumScreenWidth = 768;
const double largeScreenWidth = 992;

const BoxConstraints userImageButtonConstraints = BoxConstraints(
  maxWidth: 60,
  maxHeight: 60,
);

const BoxConstraints questionImageConstraints = BoxConstraints(
  maxWidth: largeScreenWidth,
  maxHeight: questionImageHeight,
);

const double themeColorsSaturation = 1;
const double themeColorsValue = 1;

final List<Color> themeColors = <Color>[
  const HSVColor
    .fromAHSV(1, 0, themeColorsSaturation, themeColorsSaturation)
    .toColor(),
  const Color.fromARGB(255, 64, 64, 255),
  const HSVColor
    .fromAHSV(1, 360 / 6, themeColorsSaturation, themeColorsSaturation)
    .toColor(),
  const HSVColor
    .fromAHSV(1, 360 / 3, themeColorsSaturation, themeColorsSaturation)
    .toColor(),
  const HSVColor
    .fromAHSV(1, 360 * 11 / 24, themeColorsSaturation, themeColorsSaturation)
    .toColor(),
  const HSVColor
    .fromAHSV(1, 360 * 19 / 24, themeColorsSaturation, themeColorsSaturation)
    .toColor(),
];

const Color primaryColor = Colors.purple;
final Color secondaryColor = Colors.purple.shade800;
final Color tertiaryColor = Colors.purple.shade200;
const Color white = Colors.white;

const double questionFontSize = 60;
const double answerFontSize = 50;

const TextStyle questionTextStyle = TextStyle(fontSize: questionFontSize, color: Colors.black);
const TextStyle answerTextStyle = TextStyle(fontSize: answerFontSize, color: Colors.black);

final dropDownInputTheme = InputDecorationTheme(
  labelStyle: TextStyle(color: tertiaryColor),
  iconColor: primaryColor,
  prefixIconColor: primaryColor,
  suffixIconColor: primaryColor,
  focusColor: secondaryColor,
  hoverColor: primaryColor,
  errorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: secondaryColor),
  ),
  focusedErrorBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red),
  ),
  disabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey),
  ),
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(color: primaryColor),
  ),
  border: const OutlineInputBorder(
    borderSide: BorderSide(color: primaryColor),
  ),
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

const double normalFontSize = 18;
const double smallHeadingFontSize = 24;

const purpleOuterTextStyle = TextStyle(
  color: primaryColor,
  fontSize: normalFontSize,
);

const whiteOuterTextStyle = TextStyle(
  color: white,
  fontSize: normalFontSize,
);

const blackOuterTextStyle = TextStyle(
  fontSize: normalFontSize,
);

const purpleOuterTextTheme = TextTheme(
  displayLarge: purpleOuterTextStyle,
  displayMedium: purpleOuterTextStyle,
  displaySmall: purpleOuterTextStyle,
  headlineLarge: purpleOuterTextStyle,
  headlineMedium: purpleOuterTextStyle,
  headlineSmall: purpleOuterTextStyle,
  titleLarge: purpleOuterTextStyle,
  titleMedium: purpleOuterTextStyle,
  titleSmall: purpleOuterTextStyle,
  bodyLarge: purpleOuterTextStyle,
  bodyMedium: purpleOuterTextStyle,
  bodySmall: purpleOuterTextStyle,
  labelLarge: purpleOuterTextStyle,
  labelMedium: purpleOuterTextStyle,
  labelSmall: purpleOuterTextStyle,
);

const whiteOuterTextTheme = TextTheme(
  displayLarge: whiteOuterTextStyle,
  displayMedium: whiteOuterTextStyle,
  displaySmall: whiteOuterTextStyle,
  headlineLarge: whiteOuterTextStyle,
  headlineMedium: whiteOuterTextStyle,
  headlineSmall: whiteOuterTextStyle,
  titleLarge: whiteOuterTextStyle,
  titleMedium: whiteOuterTextStyle,
  titleSmall: whiteOuterTextStyle,
  bodyLarge: whiteOuterTextStyle,
  bodyMedium: whiteOuterTextStyle,
  bodySmall: whiteOuterTextStyle,
  labelLarge: whiteOuterTextStyle,
  labelMedium: whiteOuterTextStyle,
  labelSmall: whiteOuterTextStyle,
);

const blackOuterTextTheme = TextTheme(
  displayLarge: blackOuterTextStyle,
  displayMedium: blackOuterTextStyle,
  displaySmall: blackOuterTextStyle,
  headlineLarge: blackOuterTextStyle,
  headlineMedium: blackOuterTextStyle,
  headlineSmall: blackOuterTextStyle,
  titleLarge: blackOuterTextStyle,
  titleMedium: blackOuterTextStyle,
  titleSmall: blackOuterTextStyle,
  bodyLarge: blackOuterTextStyle,
  bodyMedium: blackOuterTextStyle,
  bodySmall: blackOuterTextStyle,
  labelLarge: blackOuterTextStyle,
  labelMedium: blackOuterTextStyle,
  labelSmall: blackOuterTextStyle,
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
  cardTheme: const CardTheme(
    color: primaryColor,
  ),
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll<Color>(primaryColor),
    ),
  ),
  textTheme: purpleOuterTextTheme,
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
      foregroundColor: MaterialStatePropertyAll(white),
      backgroundColor: MaterialStatePropertyAll(primaryColor),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: primaryColor,
    contentTextStyle: TextStyle(color: white),
  ),
  useMaterial3: true,
);

const appBarElevatedButtonStyle = ButtonStyle(
  foregroundColor: MaterialStatePropertyAll(primaryColor),
  backgroundColor: MaterialStatePropertyAll(white),
);

const appBarIconButtonStyle = ButtonStyle(
  foregroundColor: MaterialStatePropertyAll(white),
  backgroundColor: MaterialStatePropertyAll(primaryColor),
);

ThemeData whiteOnPurpleTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: white,
    onPrimary: primaryColor,
    background: primaryColor,
    onBackground: white,
    surface: white,
    onSurface: primaryColor,
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    backgroundColor: primaryColor,
    collapsedBackgroundColor: primaryColor,
    iconColor: white,
    collapsedIconColor: white,
    textColor: white,
    collapsedTextColor: white,
    childrenPadding: EdgeInsetsDirectional.only(start: 20),
  ),
  cardTheme: const CardTheme(
    color: primaryColor,
  ),
  textTheme: whiteOuterTextTheme,
  dataTableTheme: const DataTableThemeData(
    dataTextStyle: TextStyle(
      color: white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: white),
    hintStyle: TextStyle(color: white.withOpacity(0.75)),
    iconColor: white,
    prefixIconColor: white,
    suffixIconColor: white,
    focusColor: secondaryColor,
    hoverColor: white,
    outlineBorder: BorderSide(color: white.withOpacity(0.75)),
    errorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: white),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: white.withOpacity(0.75)),
    ),
    border: const OutlineInputBorder(borderSide: BorderSide(color: white)),
  ),
  elevatedButtonTheme: const ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStatePropertyAll<Color>(primaryColor),
    ),
  ),
);

Color answerColor(int index) {
  return themeColors[index % themeColors.length];
}
