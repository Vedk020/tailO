import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart'; // Import your colors

class TailOTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TailOColors.darkBg,
    cardColor: TailOColors.darkCard,
    primaryColor: TailOColors.primary,
    dividerColor: TailOColors.borderDark,

    // Modern Google Font
    fontFamily: GoogleFonts.notoSans().fontFamily,

    // Text Theme
    textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: TailOColors.darkText,
      displayColor: TailOColors.darkText,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: TailOColors.muted),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: TailOColors.darkBg,
      elevation: 0,
      iconTheme: IconThemeData(color: TailOColors.darkText),
    ),
  );

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: TailOColors.lightBg,
    cardColor: TailOColors.lightCard,
    primaryColor: TailOColors.primary,
    dividerColor: TailOColors.borderLight,

    fontFamily: GoogleFonts.notoSans().fontFamily,

    textTheme: GoogleFonts.notoSansTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: TailOColors.lightText,
      displayColor: TailOColors.lightText,
    ),

    iconTheme: const IconThemeData(color: TailOColors.muted),

    appBarTheme: const AppBarTheme(
      backgroundColor: TailOColors.lightBg,
      elevation: 0,
      iconTheme: IconThemeData(color: TailOColors.lightText),
    ),
  );
}
