import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'styles/index.dart';
import 'config_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController sexoController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();

  // Estados
  String message = '';
  String serverIP = '192.168.100.87';
  bool isLoading = false;

  // Listas para alergias y condiciones
  List<Map<String, dynamic>> alergias = [];
  List<Map<String, dynamic>> condicionesSalud = [];

  // Seleccionadas
  List<int> alergiasSeleccionadas = [];
  List<int> condicionesSeleccionadas = [];

  @override
  void initState() {
    super.initState();
    _loadServerIP();
    _cargarAlergias();
    _cargarCondiciones();
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
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:3000';
    } else {
      return 'http://localhost:3000';
    }
  }

  // Cargar alergias desde la API
  Future<void> _cargarAlergias() async {
    try {
      final url = '${getServerUrl()}/api/alergias';
      print('Obteniendo alergias desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Respuesta alergias - Código: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Alergias cargadas: ${data.length}');
        setState(() {
          alergias = data.cast<Map<String, dynamic>>();
        });
      } else {
        print('Error al cargar alergias: ${response.statusCode}');
        print('Cuerpo: ${response.body}');
      }
    } catch (e) {
      print('Error al cargar alergias: $e');
    }
  }

  // Cargar condiciones desde la API
  Future<void> _cargarCondiciones() async {
    try {
      final url = '${getServerUrl()}/api/condiciones';
      print('Obteniendo condiciones desde: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Respuesta condiciones - Código: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Condiciones cargadas: ${data.length}');
        setState(() {
          condicionesSalud = data.cast<Map<String, dynamic>>();
        });
      } else {
        print('Error al cargar condiciones: ${response.statusCode}');
        print('Cuerpo: ${response.body}');
      }
    } catch (e) {
      print('Error al cargar condiciones: $e');
    }
  }

  // Registrar usuario
  Future<void> registrarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
      message = 'Registrando usuario...';
    });

    try {
      final url = '${getServerUrl()}/api/users/register';
      print('Enviando solicitud a: $url');

      // Convertir altura y peso a números
      final double altura = double.tryParse(alturaController.text) ?? 0.0;
      final double peso = double.tryParse(pesoController.text) ?? 0.0;
      final int edad = int.tryParse(edadController.text) ?? 0;

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nameController.text,
          'email': emailController.text,
          'contraseña': passwordController.text,
          'sexo': sexoController.text,
          'edad': edad,
          'altura': altura,
          'peso': peso,
          'alergias': alergiasSeleccionadas,
          'condiciones': condicionesSeleccionadas,
        }),
      );

      print('Respuesta recibida: ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        setState(() {
          message = '¡Registro exitoso! Ya puedes iniciar sesión.';
          isLoading = false;
        });

        // Limpiar el formulario
        nameController.clear();
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        sexoController.clear();
        edadController.clear();
        alturaController.clear();
        pesoController.clear();

        // Mostrar diálogo de éxito
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Registro Exitoso'),
              content: Text(
                  'Tu cuenta ha sido creada correctamente. Ahora puedes iniciar sesión.'),
              actions: [
                TextButton(
                  child: Text('Iniciar Sesión'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pop(); // Volver a la pantalla de login
                  },
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          message =
              'Error en el registro: ${data['message'] ?? 'Error desconocido'}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error de conexión: $e';
        isLoading = false;
      });
      print('Error en el registro: $e');
    }
  }

  // Mostrar diálogo para seleccionar alergias
  Future<void> _mostrarDialogoAlergias() async {
    if (alergias.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudieron cargar las alergias')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Crear copia local para manipular
        List<int> seleccionTemp = [...alergiasSeleccionadas];

        return AlertDialog(
          title: Text('Selecciona tus alergias'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return ListView.builder(
                itemCount: alergias.length,
                itemBuilder: (context, index) {
                  final alergia = alergias[index];
                  final bool isSelected = seleccionTemp.contains(alergia['id']);

                  return CheckboxListTile(
                    title: Text(alergia['nombre'] ?? 'Alergia sin nombre'),
                    subtitle: Text(alergia['descripcion'] ?? ''),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          seleccionTemp.add(alergia['id']);
                        } else {
                          seleccionTemp.remove(alergia['id']);
                        }
                      });
                    },
                  );
                },
              );
            }),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                // Actualizar la lista principal
                setState(() {
                  alergiasSeleccionadas = seleccionTemp;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Mostrar diálogo para seleccionar condiciones de salud
  Future<void> _mostrarDialogoCondiciones() async {
    if (condicionesSalud.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No se pudieron cargar las condiciones de salud')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Crear copia local para manipular
        List<int> seleccionTemp = [...condicionesSeleccionadas];

        return AlertDialog(
          title: Text('Selecciona tus condiciones de salud'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return ListView.builder(
                itemCount: condicionesSalud.length,
                itemBuilder: (context, index) {
                  final condicion = condicionesSalud[index];
                  final bool isSelected =
                      seleccionTemp.contains(condicion['id']);

                  return CheckboxListTile(
                    title: Text(condicion['nombre'] ?? 'Condición sin nombre'),
                    subtitle: Text(condicion['descripcion'] ?? ''),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          seleccionTemp.add(condicion['id']);
                        } else {
                          seleccionTemp.remove(condicion['id']);
                        }
                      });
                    },
                  );
                },
              );
            }),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                // Actualizar la lista principal
                setState(() {
                  condicionesSeleccionadas = seleccionTemp;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Usuario'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.fitness_center,
                size: AppStyles.iconSize,
                color: Colors.blue,
              ),
              SizedBox(height: AppStyles.mediumPadding),
              Text(
                'Crea tu cuenta',
                textAlign: TextAlign.center,
                style: AppStyles.titleStyle,
              ),
              SizedBox(height: AppStyles.smallPadding),
              Text(
                'Completa el formulario para comenzar tu camino hacia un estilo de vida saludable',
                textAlign: TextAlign.center,
                style: AppStyles.subtitleStyle,
              ),
              SizedBox(height: AppStyles.largePadding),

              // Campos de texto para el registro
              TextFormField(
                controller: nameController,
                decoration: AppStyles.getInputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icons.person,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppStyles.defaultPadding),

              TextFormField(
                controller: emailController,
                decoration: AppStyles.getInputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icons.email,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor ingresa un email válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppStyles.defaultPadding),

              TextFormField(
                controller: passwordController,
                decoration: AppStyles.getInputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icons.lock,
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una contraseña';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppStyles.defaultPadding),

              TextFormField(
                controller: confirmPasswordController,
                decoration: AppStyles.getInputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: Icons.lock_outline,
                ),
                obscureText: true,
                validator: (value) {
                  if (value != passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppStyles.defaultPadding),

              // Datos adicionales
              Text(
                'Información Personal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: AppStyles.smallPadding),

              // Sexo (dropdown)
              DropdownButtonFormField<String>(
                decoration: AppStyles.getInputDecoration(
                  labelText: 'Sexo',
                  prefixIcon: Icons.person_outline,
                ),
                items: <String>['Masculino', 'Femenino', 'Otro']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    sexoController.text = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor selecciona tu sexo';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppStyles.defaultPadding),

              // Edad
              TextFormField(
                controller: edadController,
                decoration: AppStyles.getInputDecoration(
                  labelText: 'Edad',
                  prefixIcon: Icons.calendar_today,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu edad';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppStyles.defaultPadding),

              // Altura y peso
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: alturaController,
                      decoration: AppStyles.getInputDecoration(
                        labelText: 'Altura (cm)',
                        prefixIcon: Icons.height,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu altura';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppStyles.defaultPadding),
                  Expanded(
                    child: TextFormField(
                      controller: pesoController,
                      decoration: AppStyles.getInputDecoration(
                        labelText: 'Peso (kg)',
                        prefixIcon: Icons.monitor_weight,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingresa tu peso';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppStyles.mediumPadding),

              // Botones para alergias y condiciones
              Text(
                'Información Médica',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: AppStyles.smallPadding),

              // Alergias
              OutlinedButton.icon(
                icon: Icon(Icons.warning_amber_rounded),
                label: Text(
                    'Seleccionar Alergias (${alergiasSeleccionadas.length})'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _mostrarDialogoAlergias,
              ),
              SizedBox(height: AppStyles.defaultPadding),

              // Condiciones de salud
              OutlinedButton.icon(
                icon: Icon(Icons.medical_services),
                label: Text(
                    'Seleccionar Condiciones de Salud (${condicionesSeleccionadas.length})'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: _mostrarDialogoCondiciones,
              ),
              SizedBox(height: AppStyles.largePadding),

              // Botón de registro
              ElevatedButton(
                onPressed: isLoading ? null : registrarUsuario,
                style: AppStyles.primaryButtonStyle,
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'REGISTRARME',
                        style: AppStyles.buttonTextStyle,
                      ),
              ),
              SizedBox(height: AppStyles.defaultPadding),

              // Mensaje de estado
              if (message.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(AppStyles.smallPadding),
                  decoration: AppStyles.getMessageBoxDecoration(
                      message.contains('Error')),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppStyles.getMessageTextStyle(
                        message.contains('Error')),
                  ),
                ),

              SizedBox(height: AppStyles.defaultPadding),

              // Opción para volver al login
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('¿Ya tienes una cuenta? Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
