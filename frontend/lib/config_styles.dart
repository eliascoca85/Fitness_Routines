import 'package:flutter/material.dart';

/// Estilos específicos para la página de configuración
class ConfigStyles {
  // Estilos para los botones de presets de IP
  static final ButtonStyle presetButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[200],
    foregroundColor: Colors.black,
  );

  // Estilo para el texto de ayuda
  static final TextStyle helpTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.grey[700],
  );

  // Decoración para el contenedor de información
  static BoxDecoration infoContainerDecoration = BoxDecoration(
    color: Colors.blue[50],
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.blue[200]!),
  );

  // Padding para el contenedor de información
  static const EdgeInsets infoPadding = EdgeInsets.all(12.0);
}
