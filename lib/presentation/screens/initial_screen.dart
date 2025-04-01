import 'package:flutter/material.dart';
import 'package:ventanas_tdp/presentation/screens/team_selector_screen.dart';
import '../widgets/number_input_dialog.dart';

class InitialScreen extends StatefulWidget {
  final String teamLeftInitials;
  final String teamRightInitials;

  const InitialScreen({
    super.key,
    required this.teamLeftInitials,
    required this.teamRightInitials,
  });

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  late List<String> leftNumbers;
  late List<String> rightNumbers;
  late List<String?> leftCategories;
  late List<String?> rightCategories;
  // Variable para identificar si el jugador es titular (true) o suplente (false)
  late List<bool> leftIsTitular;
  late List<bool> rightIsTitular;

  late String leftTeamName;
  late String rightTeamName;

  late TextEditingController leftTeamController;
  late TextEditingController rightTeamController;

  bool editingLeft = false;
  bool editingRight = false;

  // Controladores para el scroll en cada lista
  final ScrollController leftScrollController = ScrollController();
  final ScrollController rightScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    leftTeamName = widget.teamLeftInitials;
    rightTeamName = widget.teamRightInitials;
    leftTeamController = TextEditingController(text: leftTeamName);
    rightTeamController = TextEditingController(text: rightTeamName);

    // Se inicializan 11 jugadores titulares en cada equipo.
    leftNumbers = List.generate(11, (index) => '${index + 1}');
    rightNumbers = List.generate(11, (index) => '${index + 1}');
    leftCategories = List.filled(11, null, growable: true);
    rightCategories = List.filled(11, null, growable: true);
    leftIsTitular = List.filled(11, true, growable: true);
    rightIsTitular = List.filled(11, true, growable: true);
  }

  @override
  void dispose() {
    leftTeamController.dispose();
    rightTeamController.dispose();
    leftScrollController.dispose();
    rightScrollController.dispose();
    super.dispose();
  }

  Color getCircleColor(String? category) {
    if (category == null) return Colors.grey;
    if (category == "men") return const Color.fromARGB(255, 180, 163, 7);
    if (category == "Med") return Colors.blue;
    if (category == "May") return Colors.red;
    return Colors.grey;
  }

  void _showNumberInputDialog(
    BuildContext context,
    int index,
    String currentNumber, {
    required bool isLeft,
  }) {
    showDialog(
      context: context,
      builder: (context) => NumberInputDialog(
        defaultNumber: currentNumber, // Se pasa el número de la bolita
        onAccept: (result) {
          setState(() {
            if (isLeft) {
              leftNumbers[index] = result.number;
              leftCategories[index] = result.category;
            } else {
              rightNumbers[index] = result.number;
              rightCategories[index] = result.category;
            }
          });
          Navigator.of(context).pop();
        },
        onCancel: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Función para mostrar un diálogo de error con estilo personalizado
  void _showErrorDialog(String title, String message, double baseFontSize) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 34, 33, 33),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: baseFontSize + 4,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              fontSize: baseFontSize + 2,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Aceptar",
                style: TextStyle(fontSize: baseFontSize + 2),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ajusta estos valores para que los círculos se vean de forma adecuada
    final circleRadius = screenWidth * 0.07;
    final circleTextFontSize = screenWidth * 0.05;
    final headerFontSize = screenWidth * 0.045;
    final paddingTop = screenHeight * 0.15;
    final teamNameBoxWidth = screenWidth * 0.25;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna izquierda (Equipo local)
                Expanded(
                  child: Column(
                    children: [
                      // Encabezado de equipo
                      Padding(
                        padding: EdgeInsets.only(
                          top: paddingTop,
                          bottom: screenHeight * 0.015,
                        ),
                        child: Center(
                          child: editingLeft
                              ? SizedBox(
                                  width: teamNameBoxWidth,
                                  child: TextField(
                                    controller: leftTeamController,
                                    autofocus: true,
                                    style: TextStyle(
                                      fontSize: headerFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        leftTeamName = value;
                                        editingLeft = false;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 4.0,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      editingLeft = true;
                                    });
                                  },
                                  child: Text(
                                    leftTeamName,
                                    style: TextStyle(
                                      fontSize: headerFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Lista de bolitas (equipo local)
                      Expanded(
                        child: ListView.builder(
                          controller: leftScrollController,
                          padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                          itemCount: leftNumbers.length + 1,
                          itemBuilder: (context, index) {
                            if (index < leftNumbers.length) {
                              Widget circle = InkWell(
                                onTap: () {
                                  _showNumberInputDialog(
                                    context,
                                    index,
                                    leftNumbers[index],
                                    isLeft: true,
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor:
                                      getCircleColor(leftCategories[index]),
                                  radius: circleRadius,
                                  child: Text(
                                    leftNumbers[index],
                                    style: TextStyle(
                                      fontSize: circleTextFontSize,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );

                              // Si es el primer suplente (índice 11), mostramos "supl:"
                              if (leftNumbers.length > 11 && index == 11) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "supl:",
                                      style: TextStyle(
                                        fontSize: circleTextFontSize * 0.8,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    circle,
                                  ],
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: circle,
                              );
                            } else {
                              // Botón para agregar jugadores
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                    size: circleTextFontSize * 1.5,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      leftNumbers.add(
                                        '${leftNumbers.length + 1}',
                                      );
                                      leftCategories.add(null);
                                      leftIsTitular.add(false);
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                      (_) {
                                        leftScrollController.animateTo(
                                          leftScrollController
                                              .position.maxScrollExtent,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Texto central (categorías)
                Container(
                  width: screenWidth * 0.1,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "May",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: headerFontSize,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "Med",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: headerFontSize,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.005),
                      Text(
                        "men",
                        style: TextStyle(
                          color: Colors.yellow,
                          fontSize: headerFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                // Columna derecha (Equipo visitante)
                Expanded(
                  child: Column(
                    children: [
                      // Encabezado de equipo
                      Padding(
                        padding: EdgeInsets.only(
                          top: paddingTop,
                          bottom: screenHeight * 0.015,
                        ),
                        child: Center(
                          child: editingRight
                              ? SizedBox(
                                  width: teamNameBoxWidth,
                                  child: TextField(
                                    controller: rightTeamController,
                                    autofocus: true,
                                    style: TextStyle(
                                      fontSize: headerFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    onSubmitted: (value) {
                                      setState(() {
                                        rightTeamName = value;
                                        editingRight = false;
                                      });
                                    },
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 4.0,
                                        horizontal: 4.0,
                                      ),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      editingRight = true;
                                    });
                                  },
                                  child: Text(
                                    rightTeamName,
                                    style: TextStyle(
                                      fontSize: headerFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Lista de bolitas (equipo visitante)
                      Expanded(
                        child: ListView.builder(
                          controller: rightScrollController,
                          padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                          itemCount: rightNumbers.length + 1,
                          itemBuilder: (context, index) {
                            if (index < rightNumbers.length) {
                              Widget circle = InkWell(
                                onTap: () {
                                  _showNumberInputDialog(
                                    context,
                                    index,
                                    rightNumbers[index],
                                    isLeft: false,
                                  );
                                },
                                child: CircleAvatar(
                                  backgroundColor:
                                      getCircleColor(rightCategories[index]),
                                  radius: circleRadius,
                                  child: Text(
                                    rightNumbers[index],
                                    style: TextStyle(
                                      fontSize: circleTextFontSize,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );

                              if (rightNumbers.length > 11 && index == 11) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "supl:",
                                      style: TextStyle(
                                        fontSize: circleTextFontSize * 0.8,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    circle,
                                  ],
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: circle,
                              );
                            } else {
                              // Botón para agregar jugadores
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.red,
                                    size: circleTextFontSize * 1.5,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      rightNumbers.add(
                                        '${rightNumbers.length + 1}',
                                      );
                                      rightCategories.add(null);
                                      rightIsTitular.add(false);
                                    });
                                    WidgetsBinding.instance
                                        .addPostFrameCallback(
                                      (_) {
                                        rightScrollController.animateTo(
                                          rightScrollController
                                              .position.maxScrollExtent,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Botón central (check)
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: screenWidth * 0.15,
                height: screenWidth * 0.15,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    // Validación 1: que cada equipo tenga al menos 11 jugadores.
                    if (leftNumbers.length < 11 || rightNumbers.length < 11) {
                      _showErrorDialog(
                        "Error de validación",
                        "Ambos equipos deben tener al menos 11 jugadores.",
                        headerFontSize,
                      );
                      return;
                    }

                    // Validaciones adicionales para equipo izquierdo
                    List<String> leftErrors = [];

                    if (leftNumbers.toSet().length != leftNumbers.length) {
                      leftErrors.add("No se pueden repetir números en el equipo $leftTeamName.");
                    }

                    int leftMedCount = 0;
                    int leftMenCount = 0;
                    for (int i = 0; i < leftNumbers.length; i++) {
                      if (leftIsTitular[i]) {
                        if (leftCategories[i] == "Med") {
                          leftMedCount++;
                        } else if (leftCategories[i] == "men") {
                          leftMenCount++;
                        }
                      }
                    }

                    bool leftValid = ((leftMedCount >= 2 && leftMenCount >= 1) ||
                        (leftMenCount >= 2 && leftMedCount >= 1) ||
                        (leftMenCount >= 3));
                    if (!leftValid) {
                      leftErrors.add(
                        "El equipo $leftTeamName debe tener:\n"
                        "- 2 medianos y 1 menor, o\n"
                        "- 2 menores y 1 mediano, o\n"
                        "- 3 menores (entre los titulares)."
                      );
                    }

                    // Validaciones adicionales para equipo derecho
                    List<String> rightErrors = [];
                    if (rightNumbers.toSet().length != rightNumbers.length) {
                      rightErrors.add("No se pueden repetir números en el equipo $rightTeamName.");
                    }
                    int rightMedCount = 0;
                    int rightMenCount = 0;
                    for (int i = 0; i < rightNumbers.length; i++) {
                      if (rightIsTitular[i]) {
                        if (rightCategories[i] == "Med") {
                          rightMedCount++;
                        } else if (rightCategories[i] == "men") {
                          rightMenCount++;
                        }
                      }
                    }

                    bool rightValid = ((rightMedCount >= 2 && rightMenCount >= 1) ||
                        (rightMenCount >= 2 && rightMedCount >= 1) ||
                        (rightMenCount >= 3));
                    if (!rightValid) {
                      rightErrors.add(
                        "El equipo $rightTeamName debe tener:\n"
                        "- 2 medianos y 1 menor, o\n"
                        "- 2 menores y 1 mediano, o\n"
                        "- 3 menores (entre los titulares)."
                      );
                    }

                    if (leftErrors.isNotEmpty || rightErrors.isNotEmpty) {
                      String errorMessage = "";
                      if (leftErrors.isNotEmpty) {
                        errorMessage += leftErrors.join("\n");
                      }
                      if (rightErrors.isNotEmpty) {
                        if (errorMessage.isNotEmpty) {
                          errorMessage += "\n";
                        }
                        errorMessage += rightErrors.join("\n");
                      }
                      _showErrorDialog("Error de validación", errorMessage, headerFontSize);
                      return;
                    }

                    // Si no hay errores, pasa a la siguiente pantalla
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TeamSelectorScreen(
                          leftTeamName: leftTeamName,
                          rightTeamName: rightTeamName,
                          leftNumbers: leftNumbers,
                          leftCategories: leftCategories,
                          rightNumbers: rightNumbers,
                          rightCategories: rightCategories,
                          leftIsTitular: leftIsTitular,
                          rightIsTitular: rightIsTitular,
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: headerFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
