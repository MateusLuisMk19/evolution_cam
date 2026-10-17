import 'package:flutter/material.dart';

class AppController extends ChangeNotifier {
  static AppController instance = AppController();

  /// Começa com o modo do sistema; o utilizador pode alternar no menu.
  bool isDarkTheme =
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;

  void changeTheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }
}
