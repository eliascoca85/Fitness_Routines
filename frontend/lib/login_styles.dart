import 'package:flutter/material.dart';

/// Estilos específicos para la página de login
class LoginStyles {
  // Constantes de espaciado
  static const double largePadding = 40.0;
  static const double mediumPadding = 24.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 10.0;

  // Tamaños
  static const double iconSize = 100.0;

  // Colores
  static const Color primaryColor = Colors.blue;
  static final Color subtitleColor = Colors.grey[600]!;

  // TextStyles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static final TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: subtitleColor,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
  );

  // InputDecoration
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

  // ButtonStyle
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
  );

  // Estilos para mensajes
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
