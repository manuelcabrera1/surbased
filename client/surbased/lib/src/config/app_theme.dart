import 'package:flutter/material.dart';

class AppTheme {
  // Definición de colores base
  static const Color primaryBlue =
      Color(0xFF073763); // Azul oscuro para elementos principales
  static const Color secondaryBlue =
      Color(0xFF1976D2); // Azul medio para elementos secundarios
  static const Color accentBlue = Color(0xFF2196F3); // Azul claro para acentos
  static const Color lightBlue =
      Color(0xFFBBDEFB); // Azul muy claro para fondos suaves
  static const Color darkText =
      Color(0xFF0C343D); // Azul muy oscuro para textos importantes
  static const Color pureWhite = Color(0xFFFFFFFF); // Blanco puro
  static const Color offWhite = Color(0xFFF5F5F5); // Blanco hueso para fondos
  static const Color greyText =
      Color(0xFF757575); // Gris para textos secundarios
  static const Color blackText =
      Color(0xFF000000); // Negro para textos principales

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: primaryBlue,
        onPrimary: pureWhite,
        primaryContainer: lightBlue,
        onPrimaryContainer: primaryBlue,
        secondary: secondaryBlue,
        onSecondary: pureWhite,
        secondaryContainer: lightBlue.withOpacity(0.5),
        onSecondaryContainer: secondaryBlue,
        tertiary: blackText.withOpacity(0.9),
        onTertiary: pureWhite,
        tertiaryContainer: lightBlue.withOpacity(0.3),
        onTertiaryContainer: accentBlue,
        error: Colors.red,
        onError: pureWhite,
        errorContainer: Colors.red.withOpacity(0.6),
        onErrorContainer: Colors.red,
        surface: pureWhite,
        onSurface: darkText,
        onSurfaceVariant: greyText,
        outline: primaryBlue.withOpacity(0.2),
        shadow: Colors.black.withOpacity(0.1),
      ),

      scaffoldBackgroundColor: offWhite,

      tabBarTheme: TabBarTheme(
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: pureWhite,
        unselectedLabelColor: pureWhite.withOpacity(0.7),
        indicatorColor: pureWhite,
      ),
      // Estilo de las Cards
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: primaryBlue.withOpacity(0.05),
            width: 1,
          ),
        ),
        color: secondaryBlue.withOpacity(0.2),
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
      ),

      // Configuración de AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: pureWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: pureWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: pureWhite,
        ),
      ),

      // Barra de navegación
      navigationBarTheme: const NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: pureWhite),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: pureWhite),
        ),
        backgroundColor: primaryBlue,
      ),

      // Botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: pureWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 48), // Botones anchos
          // Estilos para estado deshabilitado usando nuestra paleta
          disabledBackgroundColor: lightBlue.withOpacity(0.5),
          disabledForegroundColor: greyText,
        ),
      ),

      // Campos de texto
      inputDecorationTheme: InputDecorationTheme(
        suffixStyle: const TextStyle(color: darkText),
        filled: true,
        fillColor: pureWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(
          fontSize: 16,
          color: greyText,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryBlue,
          fontSize: 16,
        ),
      ),

      // Íconos
      iconTheme: const IconThemeData(
        color: primaryBlue,
        size: 24,
      ),

      // Textos
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: blackText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: blackText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: blackText,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: pureWhite,
        ),
      ),

      // Links
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    // Colores específicos para el tema oscuro
    const Color darkBackground = Color(0xFF121212);
    const Color darkSurface = Color(0xFF1E1E1E);
    const Color darkCardColor = Color(0xFF2C2C2C);
    const Color darkPrimaryBlue =
        Color(0xFF2196F3); // Azul más brillante para el tema oscuro
    const Color darkSecondaryBlue = Color(0xFF64B5F6);
    const Color darkAccentBlue = Color(0xFF90CAF9);
    const Color darkText = Color(0xFFE0E0E0);
    const Color darkGreyText = Color(0xFFAAAAAA);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimaryBlue,
        onPrimary: pureWhite,
        primaryContainer: darkPrimaryBlue.withOpacity(0.2),
        onPrimaryContainer: darkPrimaryBlue,
        secondary: darkSecondaryBlue,
        onSecondary: pureWhite,
        secondaryContainer: darkSecondaryBlue.withOpacity(0.2),
        onSecondaryContainer: darkSecondaryBlue,
        tertiary: darkAccentBlue,
        onTertiary: darkBackground,
        tertiaryContainer: darkAccentBlue.withOpacity(0.2),
        onTertiaryContainer: darkAccentBlue,
        error: Colors.red[700]!,
        onError: pureWhite,
        errorContainer: Colors.red[900]!,
        onErrorContainer: pureWhite,
        surface: darkSurface,
        onSurface: darkText,
        onSurfaceVariant: darkGreyText,
        outline: darkGreyText.withOpacity(0.5),
        shadow: Colors.black,
      ),

      scaffoldBackgroundColor: darkBackground,

      // Estilo de las Cards para tema oscuro
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: darkPrimaryBlue.withOpacity(0.1),
            width: 1,
          ),
        ),
        color: darkCardColor,
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
      ),

      // Configuración de AppBar para tema oscuro
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: darkText,
        ),
      ),

      // Barra de navegación para tema oscuro
      navigationBarTheme: const NavigationBarThemeData(
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: darkText),
        ),
        iconTheme: WidgetStatePropertyAll(
          IconThemeData(color: darkText),
        ),
        backgroundColor: darkSurface,
      ),

      // Botones elevados para tema oscuro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryBlue,
          foregroundColor: pureWhite,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 48),
          disabledBackgroundColor: darkPrimaryBlue.withOpacity(0.3),
          disabledForegroundColor: darkGreyText,
        ),
      ),

      // Campos de texto para tema oscuro
      inputDecorationTheme: InputDecorationTheme(
        suffixStyle: const TextStyle(color: darkText),
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPrimaryBlue),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkPrimaryBlue.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPrimaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[700]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red[700]!, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(
          fontSize: 16,
          color: darkGreyText,
        ),
        floatingLabelStyle: const TextStyle(
          color: darkPrimaryBlue,
          fontSize: 16,
        ),
      ),

      // Íconos para tema oscuro
      iconTheme: const IconThemeData(
        color: darkPrimaryBlue,
        size: 24,
      ),

      // Textos para tema oscuro
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: darkText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: darkGreyText,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: pureWhite,
        ),
      ),

      // Links para tema oscuro
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimaryBlue,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
