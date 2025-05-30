import 'package:flutter/material.dart';
import 'views/home_page.dart';

class App extends StatelessWidget {
  final Map<String, dynamic> userData;

  const App({Key? key, required this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomePage(userData: userData);
  }
}
