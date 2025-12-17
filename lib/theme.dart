import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TailOColors {
  static const coral = Color(0xFFEE6C4D);

  // Backgrounds
  static const darkBg = Color(0xFF151515); // Your Dark BG
  static const lightBg = Color(0xFFFBEFE6); // Your Light BG

  // Cards
  static const darkCard = Color(0xFF1C1C1E);
  static const lightCard = Colors.white; // Clean white cards on cream bg

  // Text
  static const darkText = Color(0xFFFBEFE6); // Your Off-white Text
  static const lightText = Color(0xFF151515); // Your Dark Text

  // Icons / Secondary
  static const muted = Color(0xFF7D7D81);
}

class TailOTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: TailOColors.darkBg,
    cardColor: TailOColors.darkCard,
    primaryColor: TailOColors.coral,
    dividerColor: Colors.white.withValues(alpha: 0.08), // For borders
    fontFamily: GoogleFonts.notoSans().fontFamily,
    // Define Text Theme to default to your color
    textTheme: GoogleFonts.notoSansTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: TailOColors.darkText,
      displayColor: TailOColors.darkText,
    ),
    iconTheme: const IconThemeData(color: TailOColors.muted),
  );

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: TailOColors.lightBg,
    cardColor: TailOColors.lightCard,
    primaryColor: TailOColors.coral,
    dividerColor: Colors.black.withValues(alpha: 0.08), // For borders
    fontFamily: GoogleFonts.notoSans().fontFamily,
    // Define Text Theme to default to your color
    textTheme: GoogleFonts.notoSansTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: TailOColors.lightText,
      displayColor: TailOColors.lightText,
    ),
    iconTheme: const IconThemeData(color: TailOColors.muted),
  );
}
