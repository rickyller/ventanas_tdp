import 'package:flutter/material.dart';
import 'package:ventanas_tdp/presentation/screens/initial_screen.dart';
import 'package:ventanas_tdp/presentation/screens/local_team_changes_screen.dart';
import 'package:ventanas_tdp/presentation/screens/team_selector_screen.dart';
import 'package:ventanas_tdp/presentation/screens/visitor_team_changes_screen.dart';
// Importa aquí las demás pantallas según necesites, por ejemplo:
// import 'package:ventanas_tdp/presentation/screens/changes_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Ruta inicial.
      case '/':
        return MaterialPageRoute(
          builder: (_) => const InitialScreen(
            teamLeftInitials: 'Local',
            teamRightInitials: 'Visitante',
          ),
        );
      // Ruta para la selección de equipos.
      case '/teamSelector':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TeamSelectorScreen(
            leftTeamName: args?['leftTeamName'] ?? 'Local',
            rightTeamName: args?['rightTeamName'] ?? 'Visitante',
            leftNumbers: args != null && args['leftNumbers'] != null
                ? List<String>.from(args['leftNumbers'])
                : <String>[],
            leftCategories: args != null && args['leftCategories'] != null
                ? List<String?>.from(args['leftCategories'])
                : <String?>[],
            rightNumbers: args != null && args['rightNumbers'] != null
                ? List<String>.from(args['rightNumbers'])
                : <String>[],
            rightCategories: args != null && args['rightCategories'] != null
                ? List<String?>.from(args['rightCategories'])
                : <String?>[],
            leftIsTitular: args != null && args['leftIsTitular'] != null
                ? List<bool>.from(args['leftIsTitular'])
                : <bool>[],
            rightIsTitular: args != null && args['rightIsTitular'] != null
                ? List<bool>.from(args['rightIsTitular'])
                : <bool>[],
          ),
        );

      // Ruta para los cambios de equipo derecho o cambios generales.
      case '/changes':
        // Aquí podrías definir la pantalla a la que navegas para los cambios (por ejemplo, ChangesScreen).
        // final args = settings.arguments as Map<String, dynamic>?;
        // return MaterialPageRoute(builder: (_) => ChangesScreen(...));
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Pantalla de cambios',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        );
      // Ruta para los cambios del equipo local.
// Ruta para los cambios del equipo local.
      case '/localTeamChanges':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LocalTeamChangesScreen(),
        );

// Ruta para los cambios del equipo visitante.
      case '/visitorTeamChanges':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const VisitorTeamChangesScreen(),
        );

      // Si no se encuentra la ruta, se muestra un error.
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'No se encontró la ruta: ${settings.name}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        );
    }
  }
}
