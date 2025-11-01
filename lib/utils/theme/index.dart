import 'package:emc_mob/utils/constants/colors.dart';
import 'package:emc_mob/utils/theme/text_theme.dart';

import 'package:flutter/material.dart';

class EAppTheme {
  /// To keep the class constructor private
  EAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Lexend',
    brightness: Brightness.light,
    primaryColor: EColors.primary,
    scaffoldBackgroundColor: EColors.secondary,
    textTheme: ETextTheme.lightTextTheme,
  );
}
