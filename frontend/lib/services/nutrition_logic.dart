
Map<String, dynamic> generateNutritionPlan({
  required Map<String, dynamic> userData,
  required List<Map<String, dynamic>> userAllergies,
  required List<Map<String, dynamic>> userConditions,
}) {
  // Extraer nombres de alergias y condiciones con tipo seguro
  final List<String> allergyNames = userAllergies
      .where((a) => a['nombre'] != null)
      .map((a) => a['nombre'].toString())
      .toList();

  final List<String> conditionNames = userConditions
      .where((c) => c['nombre'] != null)
      .map((c) => c['nombre'].toString())
      .toList();

  // Inicializar macros con valores por defecto
  Map<String, double> macros = {
    'carbohidratos': 0.0,
    'proteinas': 0.0,
    'grasas': 0.0
  };

  // Calcular calorías base considerando alergias
  final String? gender = userData['sexo'];
  final weight = double.tryParse(userData['peso']?.toString() ?? '0');
  final height = double.tryParse(userData['altura']?.toString() ?? '0');
  final age = int.tryParse(userData['edad']?.toString() ?? '0');

  double calories = 0.0;
  if (weight != null && height != null && age != null && gender != null) {
    calories = gender == 'Masculino'
        ? (10 * weight) + (6.25 * height) - (5 * age) + 5
        : (10 * weight) + (6.25 * height) - (5 * age) - 161;
    // Ajustar calorías si hay alergias alimentarias importantes
    if (allergyNames.contains('Gluten') || allergyNames.contains('Lactosa')) {
      calories *= 1.1; // Aumentar 10% para compensar restricciones
    }
  }

  // Calcular macros base
  macros['carbohidratos'] = (calories * 0.5) / 4;
  macros['proteinas'] = (calories * 0.3) / 4;
  macros['grasas'] = (calories * 0.2) / 9;

  // Inicializar listas
  final List<String> prohibitedFoods = [];
  final List<String> recommendedFoods = [];
  final List<String> recommendations = [];

  // Mapa de condiciones médicas y sus recomendaciones
  final Map<String, Map<String, dynamic>> conditionsMap = {
    'Diabetes': {
      'macroAdjustments': <String, double>{
        'carbohidratos': 0.8,
        'proteinas': 1.1,
        'grasas': 0.9
      },
      'recommendation': 'Se han ajustado los macronutrientes para tu diabetes.',
      'prohibitedFoods': <String>[
        'Azúcar refinada',
        'Refrescos azucarados',
        'Dulces',
        'Pan blanco',
        'Arroz blanco',
        'Pasta refinada'
      ]
    },
    'Hipertensión': {
      'macroAdjustments': <String, double>{
        'grasas': 0.8,
        'carbohidratos': 1.0,
        'proteinas': 1.0
      },
      'recommendation':
          'Se ha reducido el contenido de grasas por tu hipertensión.',
      'prohibitedFoods': <String>[
        'Sal en exceso',
        'Embutidos',
        'Alimentos procesados',
        'Conservas con alto contenido de sodio'
      ]
    },
    'Artritis': {
      'macroAdjustments': <String, double>{
        'grasas': 0.9,
        'carbohidratos': 1.0,
        'proteinas': 1.1
      },
      'recommendation':
          'Se han ajustado los macronutrientes para reducir la inflamación.',
      'prohibitedFoods': <String>[
        'Carnes rojas en exceso',
        'Alimentos procesados',
        'Bebidas azucaradas'
      ]
    }
  };

  // Mapa de todas las posibles alergias y sus alimentos a evitar
  final Map<String, List<String>> allergiesMap = {
    'Gluten': [
      'Pan tradicional',
      'Pasta regular',
      'Cerveza',
      'Galletas',
      'Pasteles',
      'Trigo',
      'Cebada',
      'Centeno',
      'Salsas espesas',
      'Cereales de desayuno',
      'Empanizados',
      'Pan blanco'
    ],
    'Lactosa': [
      'Leche',
      'Queso',
      'Yogur',
      'Helado',
      'Mantequilla',
      'Nata',
      'Productos con lácteos',
      'Algunos chocolates',
      'Salsas cremosas',
      'Algunos panes'
    ],
    'Frutos secos': [
      'Nueces',
      'Almendras',
      'Cacahuetes',
      'Avellanas',
      'Pistachos',
      'Mantequillas de frutos secos',
      'Pasteles con frutos secos',
      'Algunos cereales',
      'Algunos chocolates',
      'Algunos postres'
    ],
    'Huevo': [
      'Huevos',
      'Mayonesa',
      'Merengue',
      'Algunos pasteles',
      'Algunos aderezos',
      'Pan brioche',
      'Algunos fideos',
      'Algunos rebozados',
      'Soufflés',
      'Flanes'
    ],
    'Mariscos': [
      'Camarones',
      'Langostas',
      'Cangrejo',
      'Almejas',
      'Ostras',
      'Mejillones',
      'Paella',
      'Sopas de mariscos',
      'Salsas de pescado',
      'Surimi'
    ],
    'Pescado': [
      'Todo tipo de pescado',
      'Salsas de pescado',
      'Caldos de pescado',
      'Sushi',
      'Aceite de pescado',
      'Suplementos omega-3'
    ],
    'Soya': [
      'Tofu',
      'Salsa de soya',
      'Leche de soya',
      'Tempeh',
      'Miso',
      'Edamame',
      'Proteína vegetal texturizada'
    ]
  };

  // Procesar condiciones médicas
  for (String conditionName in conditionNames) {
    final condition = conditionsMap[conditionName];
    if (condition != null) {
      // Aplicar ajustes de macros
      final adjustments = condition['macroAdjustments'] != null
          ? (condition['macroAdjustments'] is Map<String, num>
              ? Map<String, num>.from(condition['macroAdjustments'])
              : Map<String, num>.from((condition['macroAdjustments'] as Map)
                  .map((k, v) => MapEntry(k.toString(),
                      v is num ? v : double.tryParse(v.toString()) ?? 0.0))))
          : null;
      if (adjustments != null) {
        adjustments.forEach((key, value) {
          if (macros.containsKey(key)) {
            macros[key] = macros[key]! * value.toDouble();
          }
        });
      }
      // Agregar recomendaciones y alimentos prohibidos
      if (condition['recommendation'] is String) {
        recommendations.add(condition['recommendation'] as String);
      }
      if (condition['prohibitedFoods'] is List) {
        prohibitedFoods
            .addAll((condition['prohibitedFoods'] as List).whereType<String>());
      }
    }
  }

  // Agregar alimentos prohibidos basados en las alergias del usuario
  for (String allergyName in allergyNames) {
    if (allergiesMap.containsKey(allergyName)) {
      prohibitedFoods.addAll(allergiesMap[allergyName]!);
    }
  }

  // Generar plan de comidas
  final Map<String, List<String>> mealPlan = {
    'Desayuno': [],
    'Almuerzo': [],
    'Cena': [],
    'Snacks': [],
  };

  // Añadir comidas básicas
  mealPlan['Desayuno']!.addAll(
      ['Fruta fresca de temporada', 'Proteína magra', 'Cereales integrales']);

  mealPlan['Almuerzo']!.addAll(
      ['Ensalada variada', 'Proteína magra', 'Carbohidratos complejos']);

  mealPlan['Cena']!.addAll(
      ['Vegetales al vapor', 'Proteína magra', 'Carbohidratos moderados']);

  mealPlan['Snacks']!.addAll([
    'Frutas frescas',
    'Frutos secos (si no hay alergia)',
    'Yogur natural (si no hay intolerancia)'
  ]);

  // Generar plan final con tipos seguros
  final Map<String, dynamic> generatedPlan = {
    'calories': calories,
    'macros': Map<String, double>.from(macros),
    'recommendedFoods': List<String>.from(recommendedFoods),
    'prohibitedFoods': List<String>.from(prohibitedFoods.toSet()),
    'mealPlan': mealPlan.map((k, v) => MapEntry(k, List<String>.from(v))),
    'specialRecommendation': recommendations.join('\n\n'),
  };

  return generatedPlan;
}
