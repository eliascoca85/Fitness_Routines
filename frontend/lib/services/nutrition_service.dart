import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class NutritionService {
  // Obtener URL del servidor
  static Future<String> getServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String serverIP = prefs.getString('server_ip') ?? '192.168.100.87';

      if (kIsWeb) {
        return 'http://${Uri.base.host}:3000';
      } else if (Platform.isAndroid) {
        return 'http://$serverIP:3000';
      } else {
        return 'http://localhost:3000';
      }
    } catch (e) {
      print('Error obteniendo URL del servidor: $e');
      return 'http://localhost:3000';
    }
  }

  // Obtener alergias del usuario
  static Future<List<dynamic>> getUserAllergies(dynamic userId) async {
    final baseUrl = await getServerUrl();
    final response =
        await http.get(Uri.parse('$baseUrl/api/nutrition/alergias/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['allergies'] ??
          []; // Si no hay alergias, devolver lista vacía
    } else {
      throw Exception('Error al obtener alergias');
    }
  }

  // Obtener condiciones médicas del usuario
  static Future<List<dynamic>> getUserConditions(dynamic userId) async {
    final baseUrl = await getServerUrl();
    final response =
        await http.get(Uri.parse('$baseUrl/api/nutrition/condiciones/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['conditions'] ??
          []; // Si no hay condiciones, devolver lista vacía
    } else {
      throw Exception('Error al obtener condiciones médicas');
    }
  }

  // Actualizar alergias del usuario
  static Future<bool> updateUserAllergies(
      dynamic userId, List<Map<String, dynamic>> alergias) async {
    try {
      final baseUrl = await getServerUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/api/nutrition/alergias/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json
            .encode({'alergias': alergias.map((a) => a['id'] ?? a).toList()}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error en updateUserAllergies: $e');
      return false;
    }
  }

  // Actualizar condiciones médicas del usuario
  static Future<bool> updateUserConditions(
      dynamic userId, List<Map<String, dynamic>> condiciones) async {
    try {
      final baseUrl = await getServerUrl();
      final response = await http.put(
        Uri.parse('$baseUrl/api/nutrition/condiciones/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'condiciones': condiciones}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error en updateUserConditions: $e');
      return false;
    }
  }
}
