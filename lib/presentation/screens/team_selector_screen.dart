import 'package:flutter/material.dart';

class TeamSelectorScreen extends StatelessWidget {
  final String leftTeamName;
  final String rightTeamName;
  final List<String> leftNumbers;
  final List<String?> leftCategories;
  final List<String> rightNumbers;
  final List<String?> rightCategories;
  final List<bool> leftIsTitular;
  final List<bool> rightIsTitular;

  const TeamSelectorScreen({
    super.key,
    required this.leftTeamName,
    required this.rightTeamName,
    required this.leftNumbers,
    required this.leftCategories,
    required this.rightNumbers,
    required this.rightCategories,
    required this.leftIsTitular,
    required this.rightIsTitular,
  });

  @override
  Widget build(BuildContext context) {
    // Tamaño de la pantalla para cálculos responsivos.
    final size = MediaQuery.of(context).size;

    // Tamaño de fuente dinámico para el diálogo.
    final double dialogFontSize = size.width * 0.035;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            final bool? confirm = await showDialog<bool>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: Colors.grey[850],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    "Confirmar abandono",
                    style: TextStyle(
                        fontSize: dialogFontSize * 1.3,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  content: Text(
                    "¿Seguro que deseas abandonar? Se perderán los jugadores registrados.",
                    style: TextStyle(
                      fontSize: dialogFontSize,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  // Aquí alineamos los botones en columna (vertical).
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              fontSize: dialogFontSize * 1.3,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            "Aceptar",
                            style: TextStyle(
                              fontSize: dialogFontSize * 1.3,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
            if (confirm == true) {
              Navigator.pushNamed(context, '/');
            }
          },
        ),
        title: Text(
          'Selecciona un equipo',
          style: TextStyle(
            fontSize: size.width * 0.04, // Tamaño dinámico según el ancho.
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              // Row para alinear los botones horizontalmente.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Columna para el equipo izquierdo (local).
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "0 cambios en 0 ventanas",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.03,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/localTeamChanges',
                              arguments: {
                                'team': 'left',
                                'numbers': leftNumbers,
                                'categories': leftCategories,
                                'isTitular': leftIsTitular,
                              },
                            );
                          },
                          child: Text(
                            leftTeamName,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Columna para el equipo derecho (visita).
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "0 cambios en 0 ventanas",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.03,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/visitorTeamChanges',
                              arguments: {
                                'team': 'right',
                                'numbers': rightNumbers,
                                'categories': rightCategories,
                                'isTitular': rightIsTitular,
                              },
                            );
                          },
                          child: Text(
                            rightTeamName,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
