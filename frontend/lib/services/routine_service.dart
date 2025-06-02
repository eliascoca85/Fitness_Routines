import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class RoutineService {
  // Obtener URL del servidor
  static Future<String> getServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String serverIP = prefs.getString('server_ip') ?? '192.168.100.87';

      if (kIsWeb) {
        try {
          String currentHost = Uri.base.host;
          return 'http://$currentHost:3000';
        } catch (e) {
          print('Error obteniendo hostname: $e');
          return 'http://localhost:3000';
        }
      } else if (Platform.isAndroid) {
        if (serverIP == '10.0.2.2') {
          return 'http://10.0.2.2:3000'; // URL para emulador Android
        } else if (serverIP == 'localhost' || serverIP == '127.0.0.1') {
          return 'http://localhost:3000'; // Para conexión USB con adb reverse
        } else {
          return 'http://$serverIP:3000'; // URL para tu PC en la red WiFi
        }
      } else {
        return 'http://localhost:3000';
      }
    } catch (e) {
      print('Error obteniendo URL del servidor: $e');
      return 'http://localhost:3000';
    }
  }

  // Obtener todas las rutinas de un usuario
  static Future<List<Map<String, dynamic>>> getUserRoutines(int userId) async {
    try {
      final url = '${await getServerUrl()}/api/routines/user/$userId';
      print('Obteniendo rutinas desde: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return List<Map<String, dynamic>>.from(data['routines']);
        } else {
          print('Error en respuesta: ${data['message']}');
          return [];
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error obteniendo rutinas: $e');
      return [];
    }
  }

  // Generar una rutina personalizada para un usuario
  static Future<Map<String, dynamic>> generateRoutine(int userId) async {
    try {
      final url = '${await getServerUrl()}/api/routines/generate/$userId';
      print('Generando rutina en: $url');

      final response = await http.post(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['routine'];
        } else {
          print('Error en respuesta: ${data['message']}');
          return {};
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error generando rutina: $e');
      return {};
    }
  }

  // Obtener detalles de una rutina específica
  static Future<Map<String, dynamic>> getRoutineDetail(int routineId) async {
    try {
      final url = '${await getServerUrl()}/api/routines/$routineId';
      print('Obteniendo detalle de rutina desde: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['routine'];
        } else {
          print('Error en respuesta: ${data['message']}');
          return {};
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error obteniendo detalle de rutina: $e');
      return {};
    }
  }
}
