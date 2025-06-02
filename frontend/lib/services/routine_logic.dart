Map<String, dynamic> generateRoutine({
  required Map<String, dynamic> userData,
  required List<Map<String, dynamic>> userConditions,
}) {
  // Ejercicios base
  final ejerciciosBajosImpacto = [
    'Caminata',
    'Yoga',
    'Natación',
    'Bicicleta estática',
    'Estiramientos',
    'Fortalecimiento de core'
  ];
  final ejerciciosConSaltos = [
    'Saltos de tijera',
    'Burpees',
    'Jump squats',
    'Cuerda'
  ];

  // Detectar condiciones restrictivas
  final tieneProblemasEspalda = userConditions
      .any((c) => c['nombre'].toString().toLowerCase().contains('espalda'));
  final tieneProblemasRodilla = userConditions
      .any((c) => c['nombre'].toString().toLowerCase().contains('rodilla'));
  final tieneDiabetes = userConditions
      .any((c) => c['nombre'].toString().toLowerCase().contains('diabetes'));

  List<String> ejercicios = List.from(ejerciciosBajosImpacto);

  if (!tieneProblemasEspalda && !tieneProblemasRodilla) {
    ejercicios.addAll(ejerciciosConSaltos);
  }

  String nombre = "Rutina General";
  if (tieneProblemasEspalda) {
    nombre = "Rutina Adaptada (Espalda)";
  } else if (tieneProblemasRodilla) {
    nombre = "Rutina Adaptada (Rodilla)";
  } else if (tieneDiabetes) {
    nombre = "Rutina para Diabetes";
  }

  return {
    'nombre': nombre,
    'ejercicios': ejercicios,
    'duracionTotal': ejercicios.length * 5, // 5 min por ejercicio
    'intensidad':
        (tieneProblemasEspalda || tieneProblemasRodilla) ? 'Baja' : 'Moderada'
  };
}
