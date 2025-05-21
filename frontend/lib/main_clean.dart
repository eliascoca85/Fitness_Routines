import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform, HttpException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async' show TimeoutException;
import 'package:shared_preferences/shared_preferences.dart';
import 'config_page.dart';
import 'styles/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Routines',
      theme: AppStyles.appTheme,
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String message = '';
  String serverIP =
      '192.168.19.134'; // Valor predeterminado para WiFi principal

  @override
  void initState() {
    super.initState();
    _loadServerIP();
  }

  // Cargar la IP guardada desde SharedPreferences
  Future<void> _loadServerIP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        serverIP = prefs.getString('server_ip') ?? '192.168.19.134';
      });
      print('IP del servidor cargada: $serverIP');
    } catch (e) {
      print('Error al cargar la IP del servidor: $e');
    }
  }

  String getServerUrl() {
    if (kIsWeb) {
      // En modo web, usamos window.location.hostname para usar el mismo origen
      // Esto ayuda a evitar problemas de CORS
      try {
        // Intentamos usar la API de window.location para obtener el host actual
        String currentHost = Uri.base.host; // Obtiene el hostname actual en web
        return 'http://$currentHost:3000';
      } catch (e) {
        print('Error obteniendo hostname: $e');
        // Si falla, usamos localhost como respaldo
        return 'http://localhost:3000';
      }
    } else if (Platform.isAndroid) {
      // En dispositivos Android, hay varias opciones de conexión:
      // 1. Emulador: 10.0.2.2
      // 2. USB con reenvío: localhost
      // 3. WiFi: IP de tu PC

      // Para conexión USB con depuración, puedes usar 10.0.2.2 (emulador) o localhost (USB con adb reverse)
      if (serverIP == '10.0.2.2') {
        return 'http://10.0.2.2:3000'; // URL para emulador Android
      } else if (serverIP == 'localhost' || serverIP == '127.0.0.1') {
        return 'http://localhost:3000'; // Para conexión USB con adb reverse
      } else {
        return 'http://$serverIP:3000'; // URL para tu PC en la red WiFi
      }
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // En aplicaciones de escritorio usa localhost
      return 'http://localhost:3000';
    } else {
      // Para otras plataformas (iOS, etc.)
      return 'http://localhost:3000';
    }
  }

  Future<void> login() async {
    try {
      final url = '${getServerUrl()}/login';
      setState(() {
        message = 'Conectando a $url...';
      });
      print('Intentando conectar a: $url');

      final response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': emailController.text,
          'contraseña': passwordController.text,
        }),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException(
              'La conexión tardó demasiado. Verifica que el servidor esté activo.');
        },
      );

      print('Respuesta recibida. Código: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');

      if (response.statusCode != 200) {
        throw HttpException('Error HTTP: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['success']) {
        // Guardar datos del usuario para sesión persistente
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data['user']));

        setState(() {
          message = 'Bienvenido, ${data['user']['nombre']}';
        });

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inicio de sesión exitoso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Aquí mostraríamos una pantalla de "Login exitoso"
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Exitoso'),
              content: Text(
                  'Has iniciado sesión como ${data['user']['nombre']}. En próximas versiones, aquí se mostrará la pantalla principal de la app.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          message = 'Login fallido: ${data['message']}';
        });

        // Mostrar mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${data['message']}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      String errorMsg = 'Error de conexión';
      if (e is TimeoutException) {
        errorMsg =
            'La conexión tardó demasiado. Verifica que el servidor esté activo en $serverIP';
      } else if (e is HttpException) {
        errorMsg = 'Error HTTP: $e';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMsg =
            'Conexión rechazada al servidor en $serverIP:3000. Verifica:\n\n'
            '1. Que el servidor esté ejecutándose (node index.js)\n'
            '2. Que la IP sea correcta (IP actual: $serverIP)\n'
            '3. Si usas WiFi, que tu PC y el teléfono estén en la misma red\n'
            '4. Si usas USB, ejecuta: adb reverse tcp:3000 tcp:3000\n\n'
            'Usa el botón de configuración para cambiar la IP';
      }

      setState(() {
        message = 'Error de conexión: $errorMsg';
      });
      print('Error en el login: $e');

      // Mostrar mensaje de error más detallado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Configurar',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigPage()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ConfigPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(LoginStyles.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: LoginStyles.largePadding),
            Icon(
              Icons.fitness_center,
              size: LoginStyles.iconSize,
              color: LoginStyles.primaryColor,
            ),
            SizedBox(height: LoginStyles.mediumPadding),
            Text(
              'Fitness Routines',
              textAlign: TextAlign.center,
              style: LoginStyles.titleStyle,
            ),
            SizedBox(height: LoginStyles.smallPadding),
            Text(
              'Tu app de entrenamiento personalizado',
              textAlign: TextAlign.center,
              style: LoginStyles.subtitleStyle,
            ),
            SizedBox(height: LoginStyles.largePadding),
            TextField(
              controller: emailController,
              decoration: LoginStyles.getInputDecoration(
                labelText: 'Email',
                prefixIcon: Icons.email,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: LoginStyles.defaultPadding),
            TextField(
              controller: passwordController,
              decoration: LoginStyles.getInputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icons.lock,
              ),
              obscureText: true,
            ),
            SizedBox(height: LoginStyles.mediumPadding),
            ElevatedButton(
              onPressed: login,
              style: LoginStyles.primaryButtonStyle,
              child: Text(
                'INICIAR SESIÓN',
                style: LoginStyles.buttonTextStyle,
              ),
            ),
            SizedBox(height: LoginStyles.defaultPadding),
            message.isNotEmpty
                ? Container(
                    padding: EdgeInsets.all(LoginStyles.smallPadding),
                    decoration: LoginStyles.getMessageBoxDecoration(
                        message.contains('Error') || message.contains('falló')),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: LoginStyles.getMessageTextStyle(
                          message.contains('Error') ||
                              message.contains('falló')),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
