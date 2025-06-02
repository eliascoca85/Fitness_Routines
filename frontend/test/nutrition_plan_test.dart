// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:frontend/services/nutrition_logic.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  group('Nutrition Plan Generation', () {
    test('Plan básico sin alergias ni condiciones', () {
      final userData = {
        'nombre': 'Juan',
        'sexo': 'Masculino',
        'peso': 70,
        'altura': 175,
        'edad': 30,
      };
      final userAllergies = <Map<String, dynamic>>[];
      final userConditions = <Map<String, dynamic>>[];

      final plan = generateNutritionPlan(
        userData: userData,
        userAllergies: userAllergies,
        userConditions: userConditions,
      );

      expect(plan['calories'], isNonZero);
      expect(plan['macros'], isA<Map<String, double>>());
      expect(plan['mealPlan'], isA<Map<String, List<String>>>());
    });

    test('Plan con alergia a Gluten', () {
      final userData = {
        'nombre': 'Ana',
        'sexo': 'Femenino',
        'peso': 60,
        'altura': 165,
        'edad': 28,
      };
      final userAllergies = [
        {'nombre': 'Gluten', 'descripcion': 'Alergia al gluten'}
      ];
      final userConditions = <Map<String, dynamic>>[];

      final plan = generateNutritionPlan(
        userData: userData,
        userAllergies: userAllergies,
        userConditions: userConditions,
      );

      expect(plan['calories'], greaterThan(0));
      expect(plan['prohibitedFoods'], contains('Pan blanco'));
    });

    test('Plan con condición Diabetes', () {
      final userData = {
        'nombre': 'Carlos',
        'sexo': 'Masculino',
        'peso': 80,
        'altura': 180,
        'edad': 40,
      };
      final userAllergies = <Map<String, dynamic>>[];
      final userConditions = [
        {'nombre': 'Diabetes', 'descripcion': 'Diabetes tipo 2'}
      ];

      final plan = generateNutritionPlan(
        userData: userData,
        userAllergies: userAllergies,
        userConditions: userConditions,
      );

      expect(plan['macros'], isA<Map<String, double>>());
      expect(plan['specialRecommendation'], contains('diabetes'));
    });
  });
}
