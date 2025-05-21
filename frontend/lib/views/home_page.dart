import 'package:flutter/material.dart';
import 'package:frontend/views/header.dart';
import 'package:frontend/views/footer.dart';
import 'package:frontend/views/routine_view.dart';
import 'package:frontend/views/profile_view.dart';
import 'package:frontend/views/nutrition_view.dart' as nutrition_view;
import 'package:frontend/views/progress_view.dart' as progress_view;

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomePage({Key? key, required this.userData}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _buildHomeTab(),
      _buildRoutinesTab(),
      _buildNutritionTab(),
      _buildProgressTab(),
      _buildProfileTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildHomeTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.home, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            '¡Bienvenido, ${widget.userData['nombre']}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Aquí encontrarás un resumen de tu progreso y actividades recientes',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          _buildSummaryCard(
            title: 'Rutina Recomendada',
            icon: Icons.recommend,
            content: 'Entrenamiento de fuerza - 45 minutos',
            color: Colors.orange[300]!,
          ),
          const SizedBox(height: 15),
          _buildSummaryCard(
            title: 'Calorías Hoy',
            icon: Icons.local_fire_department,
            content: '1,850 / 2,200 kcal',
            color: Colors.green[300]!,
          ),
          const SizedBox(height: 15),
          _buildSummaryCard(
            title: 'Próximo Objetivo',
            icon: Icons.emoji_events,
            content: 'Completar 5 entrenamientos esta semana',
            color: Colors.purple[300]!,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  content,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesTab() {
    return RoutineView(userData: widget.userData);
  }

  Widget _buildNutritionTab() {
    return nutrition_view.NutritionView(userData: widget.userData);
  }

  Widget _buildProgressTab() {
    return progress_view.ProgressView(userData: widget.userData);
  }

  Widget _buildProfileTab() {
    return ProfileView(userData: widget.userData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: _getTitle(),
        actions: _getActions(),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: AppFooter(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  String _getTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Mis Rutinas';
      case 2:
        return 'Nutrición';
      case 3:
        return 'Mi Progreso';
      case 4:
        return 'Perfil';
      default:
        return 'Fitness App';
    }
  }

  List<Widget>? _getActions() {
    switch (_selectedIndex) {
      case 1: // Rutinas
        return [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Acción para agregar nueva rutina
            },
          ),
        ];
      case 2: // Nutrición
        return [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              // Mostrar calendario de alimentación
            },
          ),
        ];
      default:
        return null;
    }
  }
}
