import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'styles/index.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final TextEditingController ipController = TextEditingController();
  String message = '';

  @override
  void initState() {
    super.initState();
    _loadServerIP();
  }

  // Cargar la IP guardada (si existe)
  Future<void> _loadServerIP() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('server_ip') ?? '192.168.19.134';
    setState(() {
      ipController.text = ip;
    });
  }

  // Guardar la IP
  Future<void> _saveServerIP() async {
    if (ipController.text.isEmpty) {
      setState(() {
        message = 'Por favor ingresa una dirección IP válida';
      });
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_ip', ipController.text.trim());
      setState(() {
        message = 'Configuración guardada correctamente';
      });
    } catch (e) {
      setState(() {
        message = 'Error al guardar la configuración: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración del Servidor')),
      body: Padding(
        padding: EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: ipController,
              decoration: AppStyles.getInputDecoration(
                labelText: 'Dirección IP del Servidor',
                prefixIcon: Icons.computer,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: AppStyles.mediumPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ipController.text = '192.168.19.134';
                    });
                  },
                  style: ConfigStyles.presetButtonStyle,
                  child: const Text('WiFi 1'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ipController.text = '192.168.100.186';
                    });
                  },
                  style: ConfigStyles.presetButtonStyle,
                  child: const Text('WiFi 2'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ipController.text = '192.168.56.1';
                    });
                  },
                  style: ConfigStyles.presetButtonStyle,
                  child: const Text('Ethernet'),
                ),
              ],
            ),
            SizedBox(height: AppStyles.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ipController.text = '10.0.2.2';
                    });
                  },
                  style: ConfigStyles.presetButtonStyle,
                  child: const Text('Emulador'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      ipController.text = 'localhost';
                    });
                  },
                  style: ConfigStyles.presetButtonStyle,
                  child: const Text('USB'),
                ),
              ],
            ),
            SizedBox(height: AppStyles.defaultPadding),
            ElevatedButton(
              onPressed: _saveServerIP,
              style: AppStyles.primaryButtonStyle,
              child: const Text('Guardar Configuración'),
            ),
            SizedBox(height: AppStyles.defaultPadding),
            if (message.isNotEmpty)
              Container(
                padding: EdgeInsets.all(AppStyles.smallPadding),
                decoration: AppStyles.getMessageBoxDecoration(
                    message.contains('Error')),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style:
                      AppStyles.getMessageTextStyle(message.contains('Error')),
                ),
              ),
            SizedBox(height: AppStyles.largePadding),
            Container(
              padding: ConfigStyles.infoPadding,
              decoration: ConfigStyles.infoContainerDecoration,
              child: Text(
                'Nota: La dirección IP del servidor puede cambiar según la red.\n\n'
                'Tus IPs actuales (según ipconfig) son:\n'
                '• WiFi 1: 192.168.19.134\n'
                '• WiFi 2: 192.168.100.186\n'
                '• Ethernet: 192.168.56.1\n\n'
                'Para conexión USB (opción recomendada):\n'
                '1. Activa la depuración USB en tu dispositivo\n'
                '2. Conecta tu dispositivo al PC con un cable USB\n'
                '3. Ejecuta en una terminal: adb reverse tcp:3000 tcp:3000\n'
                '4. Selecciona la opción "USB" y guarda la configuración\n'
                '5. Asegúrate que el servidor esté ejecutándose en tu PC\n\n'
                'Para emulador, usa la opción "Emulador" (10.0.2.2)',
                style: ConfigStyles.helpTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
