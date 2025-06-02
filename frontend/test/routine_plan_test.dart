import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/routine_logic.dart';

void main() {
  group('Routine Plan Generation', () {
    test('Rutina general sin condiciones', () {
      final userData = {
        'nombre': 'Juan',
        'edad': 30,
        'peso': 70,
        'sexo': 'Masculino',
      };
      final userConditions = <Map<String, dynamic>>[];

      final routine = generateRoutine(
        userData: userData,
        userConditions: userConditions,
      );

      expect(routine['nombre'], contains('General'));
      expect(routine['ejercicios'], isA<List>());
      expect(routine['duracionTotal'], greaterThan(0));
    });

    test('Rutina para usuario con Diabetes', () {
      final userData = {
        'nombre': 'Ana',
        'edad': 40,
        'peso': 65,
        'sexo': 'Femenino',
      };
      final userConditions = [
        {'nombre': 'Diabetes', 'descripcion': 'Diabetes tipo 2'}
      ];

      final routine = generateRoutine(
        userData: userData,
        userConditions: userConditions,
      );

      expect(routine['nombre'], contains('Diabetes'));
      expect(routine['ejercicios'], contains('Caminata'));
    });

    test('Rutina evita saltos si hay problema de espalda', () {
      final userData = {
        'nombre': 'Pedro',
        'edad': 50,
        'peso': 80,
        'sexo': 'Masculino',
      };
      final userConditions = [
        {'nombre': 'Lesión de espalda', 'descripcion': 'Dolor lumbar crónico'}
      ];

      final routine = generateRoutine(
        userData: userData,
        userConditions: userConditions,
      );

      expect(routine['nombre'], contains('Espalda'));
      expect(routine['ejercicios'], isNot(contains('Saltos de tijera')));
      expect(routine['ejercicios'], isNot(contains('Burpees')));
      expect(routine['intensidad'], equals('Baja'));
    });

    test('Rutina evita saltos si hay problema de rodilla', () {
      final userData = {
        'nombre': 'Lucía',
        'edad': 35,
        'peso': 68,
        'sexo': 'Femenino',
      };
      final userConditions = [
        {'nombre': 'Problemas de rodilla', 'descripcion': 'Dolor de rodilla'}
      ];

      final routine = generateRoutine(
        userData: userData,
        userConditions: userConditions,
      );

      expect(routine['nombre'], contains('Rodilla'));
      expect(routine['ejercicios'], isNot(contains('Saltos de tijera')));
      expect(routine['ejercicios'], isNot(contains('Burpees')));
      expect(routine['intensidad'], equals('Baja'));
    });

    test('Rutina incluye saltos si no hay restricciones', () {
      final userData = {
        'nombre': 'Carlos',
        'edad': 28,
        'peso': 75,
        'sexo': 'Masculino',
      };
      final userConditions = <Map<String, dynamic>>[];

      final routine = generateRoutine(
        userData: userData,
        userConditions: userConditions,
      );

      expect(routine['ejercicios'], contains('Saltos de tijera'));
      expect(routine['ejercicios'], contains('Burpees'));
      expect(routine['intensidad'], equals('Moderada'));
    });
  });
}
