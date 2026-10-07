import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens taken from the Figma file.
class AppColors {
  static const cream = Color(0xFFFEF2DE);
  static const teal = Color(0xFF1A9EB7);
  static const orange = Color(0xFFFF8600);
  static const amber = Color(0xFFFFA800);
  static const ink = Color(0xFF171614);
  static const grey = Color(0xFF9B9B9B);
  static const fieldBorder = Color(0xFFFDE2BA);
  static const fieldFill = Color(0xFFFFEFD6);
  static const card = Color(0xFFFFF7EA);
}

class AppText {
  static TextStyle poppins(double size,
          {FontWeight weight = FontWeight.w400,
          Color color = AppColors.ink,
          double? height,
          double? letterSpacing}) =>
      GoogleFonts.poppins(
          fontSize: size.sp,
          fontWeight: weight,
          color: color,
          height: height,
          letterSpacing: letterSpacing);

  static TextStyle dmSans(double size,
          {FontWeight weight = FontWeight.w700, Color color = AppColors.ink}) =>
      GoogleFonts.dmSans(fontSize: size.sp, fontWeight: weight, color: color);
}

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.teal, primary: AppColors.teal),
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cream,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
        ),
      );
}

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message,
          style: AppText.poppins(12, color: Colors.white, weight: FontWeight.w500)),
      backgroundColor: error ? const Color(0xFFC62828) : AppColors.teal,
    ));
}
