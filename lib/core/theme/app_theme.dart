import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue, // Main theme color from PRD (implicitly)
      // Define other properties based on Betwizz branding (if available)
      // For example:
      // primaryColor: const Color(0xFFXYZXYZ), // Specific brand color
      // accentColor: const Color(0xFFABCABC), // Specific accent color (use colorScheme.secondary in newer Flutter)
      // scaffoldBackgroundColor: Colors.grey[50],
      fontFamily: 'Roboto', // Example font, PRD doesn't specify one

      appBarTheme: const AppBarTheme(
        elevation: 1,
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        // systemOverlayStyle: SystemUiOverlayStyle.dark, // For status bar icons
      ),

      buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        // buttonColor: Colors.blue, // Default is primarySwatch
        // textTheme: ButtonTextTheme.primary,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          // backgroundColor: Colors.blue, // Primary color
          // foregroundColor: Colors.white, // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(color: Colors.blue.shade700),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
      ),

      // As per PRD 6.1, for ZAR formatting, FontFeature.tabularFigures is important.
      // This can be applied globally or specifically where currency is displayed.
      // Applying globally might affect other text, so use with caution or make it specific.
      // textTheme: Typography.material2018().black.copyWith(
      //   bodyText1: Typography.material2018().black.bodyText1?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
      //   bodyText2: Typography.material2018().black.bodyText2?.copyWith(fontFeatures: [const FontFeature.tabularFigures()]),
      //   // Apply to other text styles as needed, or use the FormattingUtils.getCurrencyTextStyle
      // ),

      // For color scheme
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        // secondary: const Color(0xFFABCABC), // Accent color
        // brightness: Brightness.light,
      ).copyWith(secondary: Colors.amber), // Example secondary color

      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  // static ThemeData get darkTheme {
  //   // Define a dark theme if needed
  //   return ThemeData(
  //     brightness: Brightness.dark,
  //     primarySwatch: Colors.blueGrey,
  //     // ... other dark theme properties
  //   );
  // }
}
