import 'package:flutter/material.dart';

/// Clase que contiene todos los estilos de la aplicación
class AppStyles {
  // Tema general de la aplicación
  static ThemeData get appTheme => ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
      );

  // Estilos para la pantalla de login
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  );

  static TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.grey[600],
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
  );

  static const double defaultPadding = 16.0;
  static const double largePadding = 40.0;
  static const double mediumPadding = 24.0;
  static const double smallPadding = 10.0;
  static const double iconSize = 100.0;

  // Estilos para los campos de texto
  static const InputDecoration textFieldDecoration = InputDecoration(
    border: OutlineInputBorder(),
  );

  static InputDecoration getInputDecoration({
    required String labelText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(),
      prefixIcon: Icon(prefixIcon),
    );
  }

  // Estilos para botones
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
  );

  // Estilos para el contenedor de mensajes
  static BoxDecoration getMessageBoxDecoration(bool isError) {
    return BoxDecoration(
      color: isError ? Colors.red[100] : Colors.green[100],
      borderRadius: BorderRadius.circular(8),
    );
  }

  static TextStyle getMessageTextStyle(bool isError) {
    return TextStyle(
      color: isError ? Colors.red[900] : Colors.green[900],
    );
  }
}
