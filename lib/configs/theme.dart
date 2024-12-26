import 'package:flutter/material.dart';

// Definição das cores para o tema claro e escuro
class AppColors {
  // Tema Claro
  static const Color primaryLight = Color(0xFF009EEB); // Azul vivo
  static const Color secondaryLight = Color(0xFF53D3F3); // Azul claro brilhante
  static const Color backgroundLight = Color(0xFFF9F9F9); // Cinza muito claro 
  static const Color backgroundFormLight = Color(0xFFe9e9e9); // Cinza menos claro 
  static const Color textLight = Color(0xFF333333); // Cinza escuro
  static const Color textSecondaryLight = Color(0xFF666666); // Cinza médio
  static const Color errorLight = Color(0xFFD9534F); // Vermelho moderado
  static const Color successLight = Color(0xFF5CB85C); // Verde suave

  // Tema Escuro
  static const Color primaryDark = Color(0xFF007ACC); // Azul vívido
  static const Color secondaryDark =  Color(0xFF6FC3DF); // Azul claro suave
  static const Color backgroundDark = Color(0xFF121212); // Preto suave
  static const Color backgroundFormDark = Color(0xFF222222); // Preto suave
  static const Color textDark = Color(0xFFDADADA); // Cinza claro
  static const Color textSecondaryDark = Color(0xFFB3B3B3); // Cinza médio
  static const Color errorDark = Color(0xFFFF6B6B); // Vermelho vibrante
  static const Color successDark = Color(0xFF64E084); // Verde claro
}

// Tema Claro
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primaryLight,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: AppBarTheme(
    color: AppColors.primaryLight,
    titleTextStyle: TextStyle(
        color: AppColors.textLight, fontSize: 20, fontWeight: FontWeight.bold),
    iconTheme: IconThemeData(color: AppColors.textLight),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.textLight, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primaryLight,
    textTheme: ButtonTextTheme.primary,
  ),
  cardColor: AppColors.backgroundFormLight
);

// Tema Escuro
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primaryDark,
  scaffoldBackgroundColor: AppColors.backgroundDark,
  appBarTheme: AppBarTheme(
    color: AppColors.primaryDark,
    titleTextStyle: TextStyle(
        color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold),
    iconTheme: IconThemeData(color: AppColors.textDark),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: AppColors.textDark, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: AppColors.primaryDark,
    textTheme: ButtonTextTheme.primary,
  ),
  cardColor: AppColors.backgroundFormDark
);

// Função para alternar temas
ThemeData getTheme(Brightness brightness) {
  return brightness == Brightness.light ? lightTheme : darkTheme;
}
