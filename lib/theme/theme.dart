import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// App Theme
ThemeData appTheme(BuildContext context) {
  return ThemeData(
    backgroundColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(
        color: AppColors.blackLv2,
      ),
    ),
    textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Montserrat',
          bodyColor: AppColors.blackLv2,
          displayColor: AppColors.blackLv2,
        ),
    primaryColor: AppColors.mainDark,
    primarySwatch: AppColors.mainDark,
  );
}

class AppColors {
  // This class is not meant to be instatiated or extended; this constructor
  // prevents instantiation and extension.
  // ignore: unused_element
  AppColors._();

  // App Material Color
  static const MaterialColor mainDark = MaterialColor(
    0xFF525455,
    <int, Color>{
      50: Color(0xFF525455),
      100: Color(0xFF252a2e),
      200: Color(0xFF1F2325),
      300: Color(0xFF1D2022),
      400: Color(0xFF1C1E20),
      500: Color(0xFF191B1C),
      600: Color(0xFF161818),
      700: Color(0xFF131515),
      800: Color(0xFF111212),
      900: Color(0xFF0B0C0C),
    },
  );

  // App Color
  static const Color blackLv1 = Color(0xFF252a2e);
  static const Color blackLv2 = Color(0xFF303439);
  static const Color blackLv3 = Color(0xFF585e63);
  static const Color blackLv4 = Color(0xFFa5a6a8);
  static const Color blackLv5 = Color(0xFFC8C8C8);

  static const Color whiteLv1 = Color(0xFFFFFFFF);
  static const Color whiteLv2 = Color(0xFFF8F8F8);
  static const Color whiteLv3 = Color(0xFFF0F0F0);

  static const Color brownLv1 = Color(0xFF552E18);
  static const Color brownLv2 = Color(0xFF66402B);
  static const Color brownLv3 = Color(0xFF8D5F46);
  static const Color brownLv4 = Color(0xFFF5E8B4);

  static const Color yellowLv1 = Color(0xFFfec432);
  static const Color yellowLv3 = Color(0xFFFFCF56);
  static const Color yellowLv4 = Color(0xFFFFF291);
  static const Color yellowLv5 = Color(0xFFFBF3CD);
  static const Color yellowLv6 = Color(0xFFFFFAE5);

  static const Color amberLv1 = Color(0xFFD09606);

  static const Color orangeLv1 = Color(0xFFAF4C00);
  static const Color orangeLv2 = Color(0xFFD06E06);
  static const Color orangeLv3 = Color(0xFFFF9531);
  static const Color orangeLv4 = Color(0xFFFFCF91);
  static const Color orangeLv5 = Color(0xFFFBE7CD);

  static const Color redLv1 = Color(0xFFfd4a45);
  static const Color redLv2 = Color(0xFFDF0D0D);
  static const Color redLv3 = Color(0xFFFF6947);
  static const Color redLv4 = Color(0xFFFFAFA6);

  static const Color greenLv1 = Color(0xFF00640C);
  static const Color greenLv2 = Color(0xFF02AE16);
  static const Color greenLv3 = Color(0xFF47E827);
  static const Color greenLv4 = Color(0xFFB9FF91);

  static const Color blueLv1 = Color(0xFF005B97);
  static const Color blueLv2 = Color(0xFF067FD0);
  static const Color blueLv3 = Color(0xFF31C8FF);
  static const Color blueLv4 = Color(0xFFA8F2FF);

  static const Color darkBlueLv1 = Color(0xFF091E35);
  static const Color darkBlueLv2 = Color(0xFF082444);
  static const Color darkBlueLv3 = Color(0xFF00316E);
  static const Color darkBlueLv4 = Color(0xFF001C57);
  static const Color darkBlueLv5 = Color(0xFF001540);
}
