import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/nutrition_service.dart';

class NutritionView extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const NutritionView({super.key, this.userData});

  @override
  State<NutritionView> createState() => _NutritionViewState();
}

class _NutritionViewState extends State<NutritionView> {
  bool isLoading = true;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> userAllergies = [];
  List<Map<String, dynamic>> userConditions = [];
  Map<String, dynamic> nutritionPlan = {};
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    // Si recibimos userData en el constructor, usamos esos datos
    if (widget.userData != null) {
      userData = widget.userData;
      _fetchUserData();
    } else {
      _loadUserData();
    }
  }

  Future<void> _fetchUserData() async {
    setState(() {
      isLoading = true; // Inicia la carga
    });

    await _fetchUserAllergies();
    await _fetchUserConditions();
    _generateNutritionPlan();

    setState(() {
      isLoading = false; // Finaliza la carga
    });
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Obtenemos la información del usuario desde SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson != null) {
        print('Datos del usuario obtenidos: $userJson');
        setState(() {
          userData = jsonDecode(userJson);
          print('ID del usuario: ${userData!['id']}');
        });

        // Obtenemos las alergias y condiciones del usuario
        await _fetchUserAllergies();
        await _fetchUserConditions();

        // Generamos el plan nutricional basado en el perfil del usuario
        _generateNutritionPlan();
      } else {
        setState(() {
          errorMessage =
              'No se encontró información del usuario. Por favor inicie sesión nuevamente.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error al cargar información: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserAllergies() async {
    try {
      if (userData == null || userData!['id'] == null) {
        print('Error: No hay ID de usuario disponible para obtener alergias');
        return;
      }

      final userId = userData!['id'];
      print('Obteniendo alergias para el usuario ID: $userId');

      final allergies = await NutritionService.getUserAllergies(userId);

      if (mounted) {
        setState(() {
          userAllergies = allergies.map((allergy) {
            return {
              'nombre': allergy['nombre']?.toString() ?? 'Desconocido',
              'descripcion': allergy['descripcion']?.toString() ?? '',
            };
          }).toList();
        });
      }

      print('Alergias obtenidas: ${userAllergies.length}');
      print('Detalle de alergias: $userAllergies');
    } catch (e) {
      print('Error al obtener alergias: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error al obtener alergias: $e';
        });
      }
    }
  }

  Future<void> _fetchUserConditions() async {
    try {
      if (userData == null || userData!['id'] == null) {
        print(
            'Error: No hay ID de usuario disponible para obtener condiciones médicas');
        return;
      }

      final userId = userData!['id'];
      print('Obteniendo condiciones médicas para el usuario ID: $userId');

      final conditions = await NutritionService.getUserConditions(userId);

      if (mounted) {
        setState(() {
          userConditions = conditions.map((condition) {
            return {
              'nombre': condition['nombre']?.toString() ?? 'Desconocido',
              'descripcion': condition['descripcion']?.toString() ?? '',
            };
          }).toList();
        });
      }

      print('Condiciones médicas obtenidas: ${userConditions.length}');
      print('Detalle de condiciones: $userConditions');
    } catch (e) {
      print('Error al obtener condiciones médicas: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Error al obtener condiciones médicas: $e';
        });
      }
    }
  }

  void _generateNutritionPlan() {
    try {
      if (userData == null) return;

      print(
          'Generando plan nutricional para el usuario: ${userData!['nombre']}');
      print(
          'Alergias: ${userAllergies.length}, Condiciones: ${userConditions.length}');

      // Convertimos las listas a un formato manejable, evitando errores si están vacías
      List<String> allergyNames = [];
      if (userAllergies.isNotEmpty) {
        allergyNames = userAllergies
            .where((a) => a['nombre'] != null)
            .map((a) => a['nombre'].toString())
            .toList();
      }

      List<String> conditionNames = [];
      if (userConditions.isNotEmpty) {
        conditionNames = userConditions
            .where((c) => c['nombre'] != null)
            .map((c) => c['nombre'].toString())
            .toList();
      }

      print('Alergias del usuario: $allergyNames');
      print('Condiciones médicas del usuario: $conditionNames');

      final String? gender = userData!['sexo'];
      final double? weight = userData!['peso'] != null
          ? double.tryParse(userData!['peso'].toString())
          : null;
      final double? height = userData!['altura'] != null
          ? double.tryParse(userData!['altura'].toString())
          : null;
      final int? age = userData!['edad'] != null
          ? int.tryParse(userData!['edad'].toString())
          : null;

      // Calculando calorías diarias recomendadas (fórmula Harris-Benedict)
      double? calories;
      if (weight != null && height != null && age != null && gender != null) {
        if (gender == 'Masculino') {
          calories = (10 * weight) + (6.25 * height) - (5 * age) + 5;
        } else if (gender == 'Femenino') {
          calories = (10 * weight) + (6.25 * height) - (5 * age) - 161;
        }
      }

      // Calculando distribución macronutrientes
      Map<String, double>? macros;
      if (calories != null) {
        // Distribuimos macros: 50% carbos, 30% proteínas, 20% grasas como base
        macros = {
          'carbohidratos':
              (calories * 0.5) / 4, // 4 calorías por gramo de carbohidratos
          'proteinas':
              (calories * 0.3) / 4, // 4 calorías por gramo de proteínas
          'grasas': (calories * 0.2) / 9, // 9 calorías por gramo de grasas
        };
      }

      // Creamos listados de alimentos recomendados y prohibidos
      List<String> prohibitedFoods = [];
      List<String> recommendedFoods = [
        'Frutas frescas',
        'Vegetales',
        'Agua abundante'
      ];
      String? specialRecommendation;
      List<String> recommendations = [];

      // ===== MANEJO DE ALERGIAS =====
      // Mapa de todas las posibles alergias y sus alimentos a evitar
      Map<String, List<String>> allergiesMap = {
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
          'Empanizados'
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

      // Agregar alimentos prohibidos basados en las alergias del usuario
      for (String allergyName in allergyNames) {
        if (allergiesMap.containsKey(allergyName)) {
          prohibitedFoods.addAll(allergiesMap[allergyName]!);
        }
      }

      // ===== MANEJO DE CONDICIONES MÉDICAS =====
      // Mapa de condiciones médicas y sus recomendaciones
      Map<String, Map<String, dynamic>> conditionsMap = {
        'Diabetes': {
          'macroAdjustments': {
            'carbohidratos': 0.8, // reducir carbos en 20%
            'proteinas': 1.1, // aumentar proteínas en 10%
            'grasas': 0.9, // reducir grasas en 10%
          },
          'recommendation':
              'Debido a tu diabetes, se ha reducido la cantidad de carbohidratos y aumentado ligeramente las proteínas. Prioriza carbohidratos complejos con bajo índice glucémico.',
          'prohibitedFoods': [
            'Azúcar refinada',
            'Refrescos azucarados',
            'Jugo de frutas comercial',
            'Dulces',
            'Pasteles',
            'Pan blanco',
            'Arroz blanco',
            'Miel',
            'Jarabe de maíz',
            'Cereales azucarados'
          ]
        },
        'Hipertensión': {
          'macroAdjustments': {
            'grasas': 0.9, // reducir grasas en 10%
          },
          'recommendation':
              'Para tu hipertensión, se recomienda una dieta baja en sodio. Evita alimentos procesados, embutidos y exceso de sal en las comidas.',
          'prohibitedFoods': [
            'Sal de mesa',
            'Alimentos enlatados con sal',
            'Carnes procesadas',
            'Embutidos',
            'Snacks salados',
            'Quesos muy salados',
            'Comida rápida',
            'Sopas instantáneas',
            'Salsas comerciales',
            'Encurtidos'
          ]
        },
        'Artritis': {
          'macroAdjustments': {},
          'recommendation':
              'Para tu artritis, se recomienda una dieta antiinflamatoria rica en ácidos grasos omega-3 y antioxidantes.',
          'prohibitedFoods': [
            'Alimentos fritos',
            'Exceso de carnes rojas',
            'Azúcar refinada',
            'Alcohol',
            'Comida procesada',
            'Harinas refinadas',
            'Alimentos con glutamato monosódico'
          ]
        },
        'Asma': {
          'macroAdjustments': {},
          'recommendation':
              'Para tu asma, es recomendable mantener un peso saludable y evitar alimentos que puedan desencadenar inflamación.',
          'prohibitedFoods': [
            'Conservantes sulfitos',
            'Colorantes artificiales',
            'Vino tinto',
            'Cerveza',
            'Mariscos',
            'Alimentos procesados'
          ]
        }
      };

      // Aplicar ajustes basados en las condiciones médicas del usuario
      for (String conditionName in conditionNames) {
        if (conditionsMap.containsKey(conditionName)) {
          // Ajustar macronutrientes si es necesario
          if (macros != null &&
              conditionsMap[conditionName]?['macroAdjustments'] != null) {
            final adjustmentsMap =
                conditionsMap[conditionName]!['macroAdjustments'];

            // Convertir explícitamente a Map<String, double>
            Map<String, double> adjustments = {};
            if (adjustmentsMap is Map) {
              adjustmentsMap.forEach((key, value) {
                if (key is String && value is num) {
                  adjustments[key] = value.toDouble();
                }
              });
            }

            // Aplicar los ajustes
            Map<String, double> newMacros = {};
            macros.forEach((k, v) {
              if (adjustments.containsKey(k)) {
                newMacros[k] = v * adjustments[k]!;
              } else {
                newMacros[k] = v;
              }
            });
            macros = newMacros;
          }

          // Agregar recomendaciones
          if (conditionsMap[conditionName]?['recommendation'] != null) {
            recommendations
                .add(conditionsMap[conditionName]!['recommendation'] as String);
          } // Agregar alimentos prohibidos
          if (conditionsMap[conditionName]?['prohibitedFoods'] != null) {
            final prohibitedList =
                conditionsMap[conditionName]!['prohibitedFoods'];
            if (prohibitedList is List) {
              List<String> foodsToAvoid = [];
              for (var food in prohibitedList) {
                if (food is String) {
                  foodsToAvoid.add(food);
                }
              }
              prohibitedFoods.addAll(foodsToAvoid);
            }
          }
        }
      }

      // Combinar todas las recomendaciones en una sola
      if (recommendations.isNotEmpty) {
        specialRecommendation = recommendations.join('\n\n');
      }

      // ===== ALIMENTOS RECOMENDADOS SEGÚN PERFIL =====

      // Agregar alimentos recomendados según alergias
      if (!allergyNames.contains('Gluten')) {
        recommendedFoods
            .addAll(['Granos integrales', 'Avena', 'Quinoa', 'Arroz integral']);
      } else {
        recommendedFoods.addAll(
            ['Arroz', 'Quinoa', 'Pasta sin gluten', 'Pan sin gluten', 'Maíz']);
      }

      if (!allergyNames.contains('Lactosa')) {
        recommendedFoods.addAll(
            ['Yogur bajo en grasa', 'Queso bajo en grasa', 'Leche descremada']);
      } else {
        recommendedFoods.addAll([
          'Leche de almendras',
          'Leche de coco',
          'Leche de arroz',
          'Yogur de coco'
        ]);
      }

      if (!allergyNames.contains('Frutos secos')) {
        recommendedFoods.addAll(['Nueces', 'Almendras', 'Semillas']);
      }

      // Proteínas recomendadas
      List<String> proteins = ['Pechuga de pollo', 'Pescado', 'Legumbres'];
      if (!allergyNames.contains('Huevo')) {
        proteins.add('Huevos');
      }
      if (!allergyNames.contains('Pescado')) {
        proteins.add('Salmón');
        proteins.add('Atún');
      }
      recommendedFoods.addAll(proteins);

      // Agregar alimentos recomendados según condiciones médicas
      if (conditionNames.contains('Diabetes')) {
        recommendedFoods.addAll([
          'Vegetales de hoja verde',
          'Alimentos con bajo índice glucémico',
          'Cereales integrales',
          'Canela (ayuda a regular el azúcar)',
          'Pescados ricos en omega-3'
        ]);
      }

      if (conditionNames.contains('Hipertensión')) {
        recommendedFoods.addAll([
          'Vegetales de hoja verde',
          'Bayas',
          'Plátanos',
          'Semillas de lino',
          'Nueces',
          'Legumbres',
          'Aguacate',
          'Yogur sin grasa',
          'Chocolate negro (70% o más)'
        ]);
      }

      if (conditionNames.contains('Artritis')) {
        recommendedFoods.addAll([
          'Pescados grasos (omega-3)',
          'Aceite de oliva',
          'Frutas del bosque',
          'Jengibre',
          'Cúrcuma',
          'Té verde',
          'Nueces',
          'Espinacas',
          'Brócoli'
        ]);
      }

      if (conditionNames.contains('Asma')) {
        recommendedFoods.addAll([
          'Alimentos ricos en vitamina D',
          'Frutas cítricas',
          'Alimentos ricos en magnesio',
          'Té verde',
          'Jengibre',
          'Cúrcuma',
          'Ajos'
        ]);
      }

      // Eliminamos duplicados
      recommendedFoods = recommendedFoods.toSet().toList();
      prohibitedFoods = prohibitedFoods.toSet().toList();

      // ===== GENERACIÓN DEL PLAN DE COMIDAS =====
      Map<String, List<String>> mealPlan = {
        'Desayuno': [],
        'Almuerzo': [],
        'Cena': [],
        'Snacks': [],
      };

      // Agregamos opciones de desayuno adaptadas a las restricciones
      if (!allergyNames.contains('Gluten') &&
          !allergyNames.contains('Lactosa')) {
        mealPlan['Desayuno']!.add('Avena con leche y fruta fresca');
      } else if (!allergyNames.contains('Gluten') &&
          allergyNames.contains('Lactosa')) {
        mealPlan['Desayuno']!.add('Avena con leche vegetal y fruta fresca');
      } else if (allergyNames.contains('Gluten') &&
          !allergyNames.contains('Lactosa')) {
        mealPlan['Desayuno']!.add('Cereal sin gluten con leche y fruta');
      } else {
        mealPlan['Desayuno']!
            .add('Cereal sin gluten con leche vegetal y fruta');
      }

      if (!allergyNames.contains('Huevo')) {
        mealPlan['Desayuno']!.add('Tortilla de vegetales');
      }

      mealPlan['Desayuno']!.add('Batido de frutas con proteína');

      // Opciones de almuerzo
      if (!allergyNames.contains('Pescado') &&
          !allergyNames.contains('Mariscos')) {
        mealPlan['Almuerzo']!
            .add('Ensalada con proteína magra (pollo o pescado)');
      } else {
        mealPlan['Almuerzo']!.add('Ensalada con proteína magra (pollo o tofu)');
      }

      if (!allergyNames.contains('Gluten')) {
        mealPlan['Almuerzo']!.add('Sándwich integral con proteína y vegetales');
      } else {
        mealPlan['Almuerzo']!.add('Wrap sin gluten con proteína y vegetales');
      }

      // Opciones de cena
      mealPlan['Cena']!
          .add('Proteína magra con vegetales y carbohidrato complejo');
      mealPlan['Cena']!.add('Salteado de vegetales con tofu y arroz integral');

      // Snacks saludables
      mealPlan['Snacks']!.add('Fruta fresca');
      if (!allergyNames.contains('Frutos secos')) {
        mealPlan['Snacks']!.add('Puñado de frutos secos');
      }
      if (!allergyNames.contains('Lactosa')) {
        mealPlan['Snacks']!.add('Yogur natural');
      }

      // Si tiene hipertensión, agregamos snacks específicos
      if (conditionNames.contains('Hipertensión')) {
        mealPlan['Snacks']!.add('Apio o zanahoria con hummus sin sal');
        mealPlan['Snacks']!.add('Plátano (rico en potasio)');
      } // ===== GUARDAMOS EL PLAN FINAL =====
      // Crear una copia explícita de Map<String, dynamic> para evitar problemas de tipo
      Map<String, dynamic> planNutricional = {};

      // Agregar valores con conversiones explícitas
      if (calories != null) {
        planNutricional['calories'] = calories;
      }

      if (macros != null) {
        // Convertir el mapa de macros a un nuevo mapa con tipos explícitos
        Map<String, double> macrosMap = {};
        macros.forEach((key, value) {
          macrosMap[key] = value;
        });
        planNutricional['macros'] = macrosMap;
      }

      // Agregar las listas de alimentos
      planNutricional['recommendedFoods'] = List<String>.from(recommendedFoods);
      planNutricional['prohibitedFoods'] = List<String>.from(prohibitedFoods);

      // Convertir el plan de comidas
      Map<String, List<String>> mealPlanMap = {};
      mealPlan.forEach((key, value) {
        mealPlanMap[key] = List<String>.from(value);
      });
      planNutricional['mealPlan'] = mealPlanMap;

      // Agregar recomendación especial si existe
      if (specialRecommendation != null) {
        planNutricional['specialRecommendation'] = specialRecommendation;
      }

      setState(() {
        nutritionPlan = planNutricional;
      });

      print('Plan nutricional generado correctamente');
    } catch (e) {
      print('Error al generar plan nutricional: $e');
      setState(() {
        errorMessage = 'Error al generar plan nutricional: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Nutricional'),
        backgroundColor: Colors.green,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        "Error en la carga de datos",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadUserData,
                        icon: Icon(Icons.refresh),
                        label: Text("Reintentar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildNutritionPlanView(),
    );
  }

  Widget _buildNutritionPlanView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfoSection(),
          const Divider(height: 30),
          _buildAllergiesSection(),
          const Divider(height: 30),
          _buildConditionsSection(),
          const Divider(height: 30),
          _buildNutritionPlanSection(),
          const SizedBox(height: 20),
          _buildMealPlanSection(),
          const SizedBox(height: 20),
          _buildRecommendationsSection(),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información del Usuario',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            _buildUserInfoRow('Nombre', userData?['nombre'] ?? 'No disponible'),
            _buildUserInfoRow(
                'Edad', '${userData?['edad'] ?? 'No disponible'} años'),
            _buildUserInfoRow('Sexo', userData?['sexo'] ?? 'No disponible'),
            _buildUserInfoRow(
                'Altura', '${userData?['altura'] ?? 'No disponible'} cm'),
            _buildUserInfoRow(
                'Peso', '${userData?['peso'] ?? 'No disponible'} kg'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.orange[800]),
                SizedBox(width: 8),
                Text(
                  'Alergias',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.orange[800]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            userAllergies.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        const Text('No se han registrado alergias'),
                      ],
                    ),
                  )
                : Column(
                    children: userAllergies
                        .map((allergy) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning,
                                      color: Colors.orange),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          allergy['nombre'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                          ),
                                        ),
                                        if (allergy['descripcion'] != null &&
                                            allergy['descripcion']
                                                .toString()
                                                .isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              allergy['descripcion'].toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionsSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite_border, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Condiciones Médicas',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.blue[800]),
                ),
              ],
            ),
            const SizedBox(height: 10),
            userConditions.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        const Text('No se han registrado condiciones médicas'),
                      ],
                    ),
                  )
                : Column(
                    children: userConditions
                        .map((condition) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.healing, color: Colors.blue),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          condition['nombre'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                        if (condition['descripcion'] != null &&
                                            condition['descripcion']
                                                .toString()
                                                .isNotEmpty)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              condition['descripcion']
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionPlanSection() {
    return Card(
      elevation: 4,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu Plan Nutricional Personalizado',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.green[800]),
            ),
            const SizedBox(height: 16),

            // Calorías diarias
            if (nutritionPlan['calories'] != null) ...[
              Text(
                'Necesidades Calóricas Diarias:',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${nutritionPlan['calories'].toStringAsFixed(0)} kcal',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.green[700]),
              ),
              const SizedBox(height: 10),
            ],

            // Macronutrientes
            if (nutritionPlan['macros'] != null) ...[
              Text(
                'Macronutrientes Diarios Recomendados:',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              _buildMacroRow('Carbohidratos',
                  nutritionPlan['macros']['carbohidratos'], Colors.amber),
              _buildMacroRow('Proteínas', nutritionPlan['macros']['proteinas'],
                  Colors.red[300]!),
              _buildMacroRow('Grasas', nutritionPlan['macros']['grasas'],
                  Colors.blue[300]!),
              const SizedBox(height: 16),
            ],

            // Recomendación especial
            if (nutritionPlan['specialRecommendation'] != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        nutritionPlan['specialRecommendation'],
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Text('${value.toStringAsFixed(1)} g'),
        ],
      ),
    );
  }

  Widget _buildMealPlanSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plan de Comidas Sugerido',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.green[800]),
            ),
            const SizedBox(height: 16),
            if (nutritionPlan['mealPlan'] != null) ...[
              for (var mealType in [
                'Desayuno',
                'Almuerzo',
                'Cena',
                'Snacks'
              ]) ...[
                Text(
                  mealType,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                ),
                const SizedBox(height: 5),
                for (var meal in nutritionPlan['mealPlan'][mealType] ?? [])
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 4.0),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record,
                            size: 8, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(child: Text(meal)),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Alimentos recomendados
        Card(
          elevation: 4,
          color: Colors.green[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[800]),
                    SizedBox(width: 8),
                    Text(
                      'Alimentos Recomendados',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.green[800]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (nutritionPlan['recommendedFoods'] != null) ...[
                  const Text(
                    'Basado en tu perfil y necesidades:',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (nutritionPlan['recommendedFoods'] as List<String>)
                            .map((food) => Chip(
                                  backgroundColor: Colors.green[100],
                                  avatar: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  label: Text(food),
                                ))
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Alimentos prohibidos
        Card(
          elevation: 4,
          color: Colors.red[50],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.block, color: Colors.red[800]),
                    SizedBox(width: 8),
                    Text(
                      'Alimentos a Evitar',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: Colors.red[800]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (nutritionPlan['prohibitedFoods'] != null) ...[
                  if ((nutritionPlan['prohibitedFoods'] as List<String>)
                      .isEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          const Text(
                              'No hay alimentos que debas evitar específicamente'),
                        ],
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Basado en tus alergias y condiciones médicas:',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              (nutritionPlan['prohibitedFoods'] as List<String>)
                                  .map((food) => Chip(
                                        backgroundColor: Colors.red[100],
                                        avatar: const Icon(Icons.not_interested,
                                            color: Colors.red),
                                        label: Text(food),
                                      ))
                                  .toList(),
                        ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
