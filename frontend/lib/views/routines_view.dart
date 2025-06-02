import 'package:flutter/material.dart';
import '../services/routine_service.dart';
import '../styles/index.dart';

// Constants for styling
const double cardRadius = 12.0;
const Color primaryColor = Colors.blue;
const Color accentColor = Colors.blue;
const Color accentColorLight = Colors.lightBlue;

class RoutinesView extends StatefulWidget {
  final Map<String, dynamic> userData;

  const RoutinesView({super.key, required this.userData});

  @override
  _RoutinesViewState createState() => _RoutinesViewState();
}

class _RoutinesViewState extends State<RoutinesView> {
  bool isLoading = true;
  List<Map<String, dynamic>> userRoutines = [];
  Map<String, dynamic> generatedRoutine = {};
  bool showGeneratedRoutine = false;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  // Cargar rutinas del usuario
  Future<void> _loadRoutines() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = widget.userData['id'];
      final routines = await RoutineService.getUserRoutines(userId);

      setState(() {
        userRoutines = routines;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar rutinas: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Generar rutina personalizada
  Future<void> _generateRoutine() async {
    setState(() {
      isGenerating = true;
      showGeneratedRoutine = false;
    });

    try {
      final userId = widget.userData['id'];
      final routine = await RoutineService.generateRoutine(userId);

      setState(() {
        generatedRoutine = routine;
        showGeneratedRoutine = true;
        isGenerating = false;
      });

      // Recargar las rutinas después de generar una nueva
      _loadRoutines();
    } catch (e) {
      print('Error al generar rutina: $e');
      setState(() {
        isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rutinas'),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoutines,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(AppStyles.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Botón para generar rutina
                      ElevatedButton.icon(
                        onPressed: isGenerating ? null : _generateRoutine,
                        icon: const Icon(Icons.fitness_center),
                        label: Text(isGenerating
                            ? 'Generando rutina...'
                            : 'Generar Rutina Personalizada'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: EdgeInsets.all(AppStyles.mediumPadding),
                        ),
                      ),
                      SizedBox(height: AppStyles.mediumPadding),

                      // Rutina generada (si existe)
                      if (showGeneratedRoutine && generatedRoutine.isNotEmpty)
                        _buildGeneratedRoutineCard(),

                      SizedBox(height: AppStyles.mediumPadding),

                      // Título de rutinas guardadas
                      Text(
                        'Mis Rutinas Guardadas',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppStyles.smallPadding),

                      // Lista de rutinas
                      userRoutines.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No tienes rutinas guardadas.\nGenera una rutina personalizada.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: userRoutines.length,
                              itemBuilder: (context, index) {
                                final routine = userRoutines[index];
                                return _buildRoutineCard(routine);
                              },
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Widget para mostrar la rutina generada
  Widget _buildGeneratedRoutineCard() {
    return Container(
      margin: EdgeInsets.only(bottom: AppStyles.mediumPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentColor, accentColorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(AppStyles.mediumPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Rutina Personalizada Para Ti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  generatedRoutine['nombre'] ?? 'Rutina Personalizada',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppStyles.smallPadding),
                Text(
                  generatedRoutine['descripcion'] ?? '',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          if (generatedRoutine.containsKey('ejercicios') &&
              generatedRoutine['ejercicios'] != null)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(cardRadius),
                  bottomRight: Radius.circular(cardRadius),
                ),
              ),
              padding: EdgeInsets.all(AppStyles.mediumPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ejercicios recomendados:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...(generatedRoutine['ejercicios'] as List).map((ejercicio) {
                    return _buildExerciseItem(ejercicio);
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Widget para mostrar un elemento de ejercicio
  Widget _buildExerciseItem(Map<String, dynamic> ejercicio) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppStyles.smallPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fitness_center, color: accentColor, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ejercicio['nombre'] ?? '',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(ejercicio['descripcion'] ?? ''),
                Text(
                  'Duración: ${ejercicio['duracion'] ?? ''} | Intensidad: ${ejercicio['intensidad'] ?? ''}',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar una tarjeta de rutina
  Widget _buildRoutineCard(Map<String, dynamic> routine) {
    return Card(
      margin: EdgeInsets.only(bottom: AppStyles.smallPadding),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: () {
          // Acción al presionar la tarjeta (podría mostrar detalles)
        },
        child: Padding(
          padding: EdgeInsets.all(AppStyles.mediumPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fitness_center,
                    color: accentColor,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      routine['nombre'] ?? 'Sin nombre',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                routine['descripcion'] ?? 'Sin descripción',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Creada: ${_formatDate(routine['fecha_creacion'])}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Formatear fecha
  String _formatDate(String? dateString) {
    if (dateString == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}
