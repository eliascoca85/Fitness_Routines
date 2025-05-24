import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NutritionView extends StatefulWidget {
  const NutritionView({Key? key}) : super(key: key);

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      }); // Obtenemos la información del usuario desde SharedPreferences
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
      if (userData == null || userData!['id'] == null) return;

      final userId = userData!['id'];
      final serverUrl =
          'http://192.168.133.242:3000'; // IP del servidor actualizada      print('Realizando solicitud a: $serverUrl/api/alergias');
      final response = await http.get(
        Uri.parse('$serverUrl/api/alergias'),
        headers: {'Content-Type': 'application/json'},
      );
      print(
          'Respuesta alergias - Código: ${response.statusCode}, Cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> allAllergies = jsonDecode(response.body);

        // Simulamos obtener las alergias del usuario desde usuario_alergia
        // En el futuro deberías implementar un endpoint específico para esto
        final mockUserAllergyIds = await _fetchUserAllergyIds(userId);

        setState(() {
          userAllergies = allAllergies
              .where((allergy) => mockUserAllergyIds.contains(allergy['id']))
              .map<Map<String, dynamic>>((item) => {
                    'id': item['id'],
                    'nombre': item['nombre'],
                    'descripcion': item['descripcion'] ?? '',
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error al obtener alergias: $e');
    }
  }

  Future<List<int>> _fetchUserAllergyIds(int userId) async {
    // En una implementación real, esto debería hacer una consulta a la tabla usuario_alergia
    // Por ahora, usamos datos de prueba basados en la base de datos proporcionada

    // Datos de prueba basados en la base de datos
    Map<int, List<int>> userAllergiesMap = {
      5: [2], // usuario 5 -> alergia 2 (Gluten)
      6: [
        3,
        2,
        5
      ], // usuario 6 -> alergias 3, 2, 5 (Frutos secos, Gluten, Huevo)
      7: [1, 2], // usuario 7 -> alergias 1, 2 (Lactosa, Gluten)
      8: [1], // usuario 8 -> alergia 1 (Lactosa)
      11: [1, 2], // usuario 11 -> alergias 1, 2 (Lactosa, Gluten)
    };

    return userAllergiesMap[userId] ?? [];
  }

  Future<void> _fetchUserConditions() async {
    try {
      if (userData == null || userData!['id'] == null) return;

      final userId = userData!['id'];
      final serverUrl =
          'http://192.168.133.242:3000'; // IP del servidor actualizada      print('Realizando solicitud a: $serverUrl/api/condiciones');
      final response = await http.get(
        Uri.parse('$serverUrl/api/condiciones'),
        headers: {'Content-Type': 'application/json'},
      );
      print(
          'Respuesta condiciones - Código: ${response.statusCode}, Cuerpo: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> allConditions = jsonDecode(response.body);

        // Simulamos obtener las condiciones del usuario desde usuario_condicion
        // En el futuro deberías implementar un endpoint específico para esto
        final mockUserConditionIds = await _fetchUserConditionIds(userId);

        setState(() {
          userConditions = allConditions
              .where(
                  (condition) => mockUserConditionIds.contains(condition['id']))
              .map<Map<String, dynamic>>((item) => {
                    'id': item['id'],
                    'nombre': item['nombre'],
                    'descripcion': item['descripcion'] ?? '',
                  })
              .toList();
        });
      }
    } catch (e) {
      print('Error al obtener condiciones médicas: $e');
    }
  }

  Future<List<int>> _fetchUserConditionIds(int userId) async {
    // En una implementación real, esto debería hacer una consulta a la tabla usuario_condicion
    // Por ahora, usamos datos de prueba basados en la base de datos proporcionada

    // Datos de prueba basados en la base de datos
    Map<int, List<int>> userConditionsMap = {
      6: [1], // usuario 6 -> condición 1 (Hipertensión)
      7: [3, 1], // usuario 7 -> condiciones 3, 1 (Asma, Hipertensión)
      8: [4, 2], // usuario 8 -> condiciones 4, 2 (Artritis, Diabetes)
      11: [1, 2], // usuario 11 -> condiciones 1, 2 (Hipertensión, Diabetes)
    };

    return userConditionsMap[userId] ?? [];
  }

  void _generateNutritionPlan() {
    try {
      if (userData == null) return;

      // Extrayendo información relevante del usuario
      final List<String> allergyNames =
          userAllergies.map((a) => a['nombre'].toString()).toList();
      final List<String> conditionNames =
          userConditions.map((c) => c['nombre'].toString()).toList();
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

      // Ajustamos plan según condiciones médicas
      String? specialRecommendation;
      if (conditionNames.contains('Diabetes')) {
        macros = macros?.map((k, v) => k == 'carbohidratos'
            ? MapEntry(k, v * 0.8)
            : // reducir carbos en 20%
            k == 'proteinas'
                ? MapEntry(k, v * 1.1)
                : // aumentar proteínas en 10%
                MapEntry(k, v));
        specialRecommendation =
            'Debido a tu diabetes, se ha reducido la cantidad de carbohidratos y aumentado ligeramente las proteínas. Prioriza carbohidratos complejos con bajo índice glucémico.';
      } else if (conditionNames.contains('Hipertensión')) {
        specialRecommendation =
            'Para tu hipertensión, se recomienda una dieta baja en sodio. Evita alimentos procesados, embutidos y exceso de sal en las comidas.';
      }

      // Creamos listados de alimentos recomendados y prohibidos
      List<String> prohibitedFoods = [];
      if (allergyNames.contains('Gluten')) {
        prohibitedFoods.addAll([
          'Pan tradicional',
          'Pasta regular',
          'Cerveza',
          'Galletas',
          'Pasteles',
          'Trigo',
          'Cebada',
          'Centeno'
        ]);
      }
      if (allergyNames.contains('Lactosa')) {
        prohibitedFoods.addAll([
          'Leche',
          'Queso',
          'Yogur',
          'Helado',
          'Mantequilla',
          'Nata',
          'Productos con lácteos'
        ]);
      }
      if (allergyNames.contains('Frutos secos')) {
        prohibitedFoods.addAll([
          'Nueces',
          'Almendras',
          'Cacahuetes',
          'Avellanas',
          'Pistachos',
          'Mantequillas de frutos secos'
        ]);
      }
      if (allergyNames.contains('Huevo')) {
        prohibitedFoods.addAll([
          'Huevos',
          'Mayonesa',
          'Merengue',
          'Algunos pasteles',
          'Algunos aderezos'
        ]);
      }
      if (allergyNames.contains('Mariscos')) {
        prohibitedFoods.addAll([
          'Camarones',
          'Langostas',
          'Cangrejo',
          'Almejas',
          'Ostras',
          'Mejillones'
        ]);
      }

      // Alimentos recomendados basados en el perfil
      List<String> recommendedFoods = [
        'Frutas frescas',
        'Vegetales',
        'Agua abundante'
      ];

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
      recommendedFoods.addAll(proteins);

      // Si tiene diabetes, añadimos recomendaciones específicas
      if (conditionNames.contains('Diabetes')) {
        recommendedFoods.addAll([
          'Vegetales de hoja verde',
          'Alimentos con bajo índice glucémico',
          'Cereales integrales'
        ]);
        prohibitedFoods.addAll([
          'Azúcar refinada',
          'Refrescos',
          'Jugo de frutas comercial',
          'Dulces',
          'Pasteles'
        ]);
      }

      // Si tiene hipertensión, añadimos recomendaciones específicas
      if (conditionNames.contains('Hipertensión')) {
        recommendedFoods.addAll([
          'Vegetales de hoja verde',
          'Bayas',
          'Plátanos',
          'Semillas de lino'
        ]);
        prohibitedFoods.addAll([
          'Sal de mesa',
          'Alimentos enlatados con sal',
          'Carnes procesadas',
          'Embutidos',
          'Snacks salados'
        ]);
      }

      // Si tiene artritis
      if (conditionNames.contains('Artritis')) {
        recommendedFoods.addAll([
          'Pescados grasos (omega-3)',
          'Aceite de oliva',
          'Frutas del bosque',
          'Jengibre'
        ]);
        prohibitedFoods.addAll(
            ['Alimentos fritos', 'Exceso de carnes rojas', 'Azúcar refinada']);
      }

      // Eliminamos duplicados
      recommendedFoods = recommendedFoods.toSet().toList();
      prohibitedFoods = prohibitedFoods.toSet().toList();

      // Generando un plan de comidas sencillo
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
      mealPlan['Almuerzo']!
          .add('Ensalada con proteína magra (pollo o pescado)');
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

      // Guardamos toda la información en el plan nutricional
      setState(() {
        nutritionPlan = {
          'calories': calories,
          'macros': macros,
          'recommendedFoods': recommendedFoods,
          'prohibitedFoods': prohibitedFoods,
          'mealPlan': mealPlan,
          'specialRecommendation': specialRecommendation,
        };
      });
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
            Text(
              'Alergias',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            userAllergies.isEmpty
                ? const Text('No se han registrado alergias')
                : Column(
                    children: userAllergies
                        .map((allergy) => ListTile(
                              leading: const Icon(Icons.warning,
                                  color: Colors.orange),
                              title: Text(allergy['nombre']),
                              dense: true,
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
            Text(
              'Condiciones Médicas',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.green[800]),
            ),
            const SizedBox(height: 10),
            userConditions.isEmpty
                ? const Text('No se han registrado condiciones médicas')
                : Column(
                    children: userConditions
                        .map((condition) => ListTile(
                              leading:
                                  const Icon(Icons.healing, color: Colors.blue),
                              title: Text(condition['nombre']),
                              dense: true,
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
                        Text(meal),
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
                Text(
                  'Alimentos Recomendados',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.green[800]),
                ),
                const SizedBox(height: 10),
                if (nutritionPlan['recommendedFoods'] != null) ...[
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
                Text(
                  'Alimentos a Evitar',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.red[800]),
                ),
                const SizedBox(height: 10),
                if (nutritionPlan['prohibitedFoods'] != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (nutritionPlan['prohibitedFoods'] as List<String>)
                        .map((food) => Chip(
                              backgroundColor: Colors.red[100],
                              avatar: const Icon(Icons.not_interested,
                                  color: Colors.red),
                              label: Text(food),
                            ))
                        .toList(),
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
