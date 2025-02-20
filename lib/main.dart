import 'package:flutter/material.dart';
import 'app_routes.dart';

void main() {
  runApp(const MyWearApp());
}

class MyWearApp extends StatelessWidget {
  const MyWearApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Árbitro',
      theme: ThemeData.dark(),
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
