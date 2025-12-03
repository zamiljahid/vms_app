import 'package:visitor_management/constants/color_code.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData greenTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorCode.greenDarkBackground,
    secondaryHeaderColor: ColorCode.greenLightHighlight,
    primaryColorDark: ColorCode.greenDarkBackground,
    primaryColorLight: ColorCode.white,
    primaryColor: ColorCode.greenPrimaryAccent,
    fontFamily: 'neosansstd_regular',
    colorScheme: ColorScheme.light(
      primary: ColorCode.greenPrimaryAccent,
      secondary: ColorCode.greenCardColor,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      iconColor: ColorCode.greenPrimaryAccent,
      labelStyle: TextStyle(
        color: ColorCode.primaryText,
        fontSize: 15,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorCode.greenPrimaryAccent,
        textStyle: const TextStyle(
          color: ColorCode.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorCode.greenCardColor,
      iconTheme: const IconThemeData(
        color: ColorCode.white,
      ),
    ),
  );

  static ThemeData amberTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorCode.amberDarkBackground,
    secondaryHeaderColor: ColorCode.amberLightHighlight,
    primaryColorDark: ColorCode.amberCardColor,
    primaryColorLight: ColorCode.amberPrimaryAccent,
    primaryColor: ColorCode.amberPrimaryAccent,
    fontFamily: 'neosansstd_regular',
    colorScheme: ColorScheme.light(
      primary: ColorCode.amberPrimaryAccent,
      secondary: ColorCode.amberCardColor,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      iconColor: ColorCode.amberPrimaryAccent,
      labelStyle: TextStyle(
        color: ColorCode.primaryText,
        fontSize: 15,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorCode.amberPrimaryAccent,
        textStyle: const TextStyle(
          color: ColorCode.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorCode.amberCardColor,
      iconTheme: const IconThemeData(
        color: ColorCode.white,
      ),
    ),
  );

  static ThemeData blueTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorCode.blueDarkBackground,
    secondaryHeaderColor: ColorCode.blueLightHighlight,
    primaryColorDark: ColorCode.blueCardColor,
    primaryColorLight: ColorCode.bluePrimaryAccent,
    primaryColor: ColorCode.bluePrimaryAccent,
    fontFamily: 'neosansstd_regular',
    colorScheme: ColorScheme.light(
      primary: ColorCode.bluePrimaryAccent,
      secondary: ColorCode.blueCardColor,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      iconColor: ColorCode.bluePrimaryAccent,
      labelStyle: TextStyle(
        color: ColorCode.primaryText,
        fontSize: 15,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorCode.bluePrimaryAccent,
        textStyle: const TextStyle(
          color: ColorCode.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorCode.blueCardColor,
      iconTheme: const IconThemeData(
        color: ColorCode.white,
      ),
    ),
  );

  static ThemeData redTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorCode.redDarkBackground,
    secondaryHeaderColor: ColorCode.redLightHighlight,
    primaryColorDark: ColorCode.redCardColor,
    primaryColorLight: ColorCode.white,
    primaryColor: ColorCode.redPrimaryAccent,
    fontFamily: 'neosansstd_regular',
    colorScheme: ColorScheme.light(
      primary: ColorCode.redPrimaryAccent,
      secondary: ColorCode.redCardColor,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      iconColor: ColorCode.redPrimaryAccent,
      labelStyle: TextStyle(
        color: ColorCode.primaryText,
        fontSize: 15,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorCode.redPrimaryAccent,
        textStyle: const TextStyle(
          color: ColorCode.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorCode.redCardColor,
      iconTheme: const IconThemeData(
        color: ColorCode.white,
      ),
    ),
  );

  static ThemeData purpleTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorCode.purpleDarkBackground,
    secondaryHeaderColor: ColorCode.purpleLightHighlight,
    primaryColorDark: ColorCode.purpleCardColor,
    primaryColorLight: ColorCode.purplePrimaryAccent,
    primaryColor: ColorCode.purplePrimaryAccent,
    fontFamily: 'neosansstd_regular',
    colorScheme: ColorScheme.light(
      primary: ColorCode.purplePrimaryAccent,
      secondary: ColorCode.purpleCardColor,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      iconColor: ColorCode.purplePrimaryAccent,
      labelStyle: TextStyle(
        color: ColorCode.primaryText,
        fontSize: 15,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorCode.purplePrimaryAccent,
        textStyle: const TextStyle(
          color: ColorCode.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorCode.purpleCardColor,
      iconTheme: const IconThemeData(
        color: ColorCode.white,
      ),
    ),
  );

  static ThemeData orangeTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorCode.orangeDarkBackground,
    secondaryHeaderColor: ColorCode.orangeLightHighlight,
    primaryColorDark: ColorCode.orangeCardColor,
    primaryColorLight: ColorCode.orangePrimaryAccent,
    primaryColor: ColorCode.orangePrimaryAccent,
    fontFamily: 'neosansstd_regular',
    colorScheme: ColorScheme.light(
      primary: ColorCode.orangePrimaryAccent,
      secondary: ColorCode.orangeCardColor,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      iconColor: ColorCode.orangePrimaryAccent,
      labelStyle: TextStyle(
        color: ColorCode.primaryText,
        fontSize: 15,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorCode.orangePrimaryAccent,
        textStyle: const TextStyle(
          color: ColorCode.white,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorCode.orangeCardColor,
      iconTheme: const IconThemeData(
        color: ColorCode.white,
      ),
    ),
  );
}
