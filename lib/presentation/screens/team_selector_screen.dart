import 'package:flutter/material.dart';
import 'package:ventanas_tdp/presentation/widgets/basic_confirmation_dialog.dart';

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
    Key? key,
    required this.leftTeamName,
    required this.rightTeamName,
    required this.leftNumbers,
    required this.leftCategories,
    required this.rightNumbers,
    required this.rightCategories,
    required this.leftIsTitular,
    required this.rightIsTitular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Tamaño de la pantalla para cálculos responsivos.
    final size = MediaQuery.of(context).size;
    // Tamaño de fuente para el diálogo.

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // Altura estándar
        child: Container(
          color: Colors.grey[900],
          child: SafeArea(
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () async {
                      final bool? confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return BasicConfirmationDialog(
                            title: "Confirmar abandono",
                            confirmText: "",
                            cancelText: "",
                            onConfirm: () => Navigator.pop(context, true),
                            onCancel: () => Navigator.pop(context, false),
                            backgroundColor: Colors.grey[850]!,
                            confirmButtonColor:
                                const Color.fromARGB(255, 18, 108, 210),
                            cancelButtonColor:
                                const Color.fromARGB(255, 242, 20, 20),
                            confirmIcon:
                                const Icon(Icons.check, color: Colors.white),
                            cancelIcon:
                                const Icon(Icons.close, color: Colors.white),
                            buttonSpacing: 4.0,
                          );
                        },
                      );
                      if (confirm == true) {
                        Navigator.pushNamed(context, '/');
                      }
                    },
                  ),
                  const SizedBox(width: 4),

                ],
              ),
            ),
          ),
        ),
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
                            fontSize: size.width * 0.055,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        // Botón para el equipo izquierdo (local)
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
                                'teamName': leftTeamName,
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
                            fontSize: size.width * 0.055,
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
