import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform, HttpException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async' show TimeoutException;
import 'package:shared_preferences/shared_preferences.dart';
import 'config_page.dart';
import 'styles/index.dart';
import 'register_page.dart';
import 'views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        setState(() {
          _userData = jsonDecode(userDataString);
        });
      }
    } catch (e) {
      print('Error al verificar sesión: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Routines',
      theme: AppStyles.appTheme,
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _userData != null
              ? HomePage(userData: _userData!)
              : LoginPage(),
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
  String serverIP = '192.168.100.87'; // Valor predeterminado

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
        serverIP = prefs.getString('server_ip') ?? '192.168.100.87';
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
      // En dispositivos Android físicos, usa la IP del PC desde la configuración
      // Si estás en un emulador Android, cambia automáticamente a 10.0.2.2
      bool isEmulator = false;
      try {
        // Esta comparación puede ayudar a detectar un emulador
        isEmulator = Platform.environment.containsKey('ANDROID_EMULATOR') ||
            Platform.operatingSystemVersion.toLowerCase().contains('emulator');
      } catch (e) {
        print('Error detectando emulador: $e');
      }

      return isEmulator
          ? 'http://10.0.2.2:3000' // URL para emulador Android
          : 'http://$serverIP:3000'; // URL para dispositivo físico (tu PC)
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
        ); // Navegar a la pantalla de inicio pasando los datos del usuario
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userData: data['user']),
          ),
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
      setState(() {
        message = 'Error de conexión: $e';
      });
      print('Error en el login: $e');
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
        padding: EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppStyles.largePadding),
            const Icon(
              Icons.fitness_center,
              size: AppStyles.iconSize,
              color: Colors.blue,
            ),
            const SizedBox(height: AppStyles.mediumPadding),
            const Text(
              'Fitness Routines',
              textAlign: TextAlign.center,
              style: AppStyles.titleStyle,
            ),
            const SizedBox(height: AppStyles.smallPadding),
            Text(
              'Tu app de entrenamiento personalizado',
              textAlign: TextAlign.center,
              style: AppStyles.subtitleStyle,
            ),
            const SizedBox(height: AppStyles.largePadding),
            TextField(
              controller: emailController,
              decoration: AppStyles.getInputDecoration(
                labelText: 'Email',
                prefixIcon: Icons.email,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: AppStyles.defaultPadding),
            TextField(
              controller: passwordController,
              decoration: AppStyles.getInputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icons.lock,
              ),
              obscureText: true,
            ),
            const SizedBox(height: AppStyles.mediumPadding),
            ElevatedButton(
              onPressed: login,
              style: AppStyles.primaryButtonStyle,
              child: const Text(
                'INICIAR SESIÓN',
                style: AppStyles.buttonTextStyle,
              ),
            ),
            const SizedBox(height: AppStyles.smallPadding),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: const Text(
                '¿No tienes cuenta? Regístrate aquí',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: AppStyles.defaultPadding),
            message.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(AppStyles.smallPadding),
                    decoration: AppStyles.getMessageBoxDecoration(
                        message.contains('Error') || message.contains('falló')),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: AppStyles.getMessageTextStyle(
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
