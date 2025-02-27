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
  // ignore: library_private_types_in_public_api
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

  // Contador para debug: si se presiona dos veces se omiten las validaciones.
  int _debugCheckCount = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Se envuelve el contenido en un Stack para posicionar el botón central.
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
                      // Encabezado: nombre de equipo
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0, bottom: 10.0),
                        child: Center(
                          child: editingLeft
                              ? SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: leftTeamController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      fontSize: 14,
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
                                          vertical: 4.0, horizontal: 4.0),
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
                                    style: const TextStyle(
                                      fontSize: 14,
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
                          itemCount: leftNumbers.length + 1,
                          itemBuilder: (context, index) {
                            if (index < leftNumbers.length) {
                              Widget circle = Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
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
                                    radius: 15,
                                    child: Text(
                                      leftNumbers[index],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              // Si es el primer jugador suplente (índice 11) mostramos la nomenclatura "supl:"
                              if (leftNumbers.length > 11 && index == 11) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "supl:",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    circle,
                                  ],
                                );
                              }
                              return circle;
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon:
                                      const Icon(Icons.add, color: Colors.blue),
                                  onPressed: () {
                                    setState(() {
                                      leftNumbers
                                          .add('${leftNumbers.length + 1}');
                                      leftCategories.add(null);
                                      // Los jugadores agregados más allá del once inicial son suplentes
                                      leftIsTitular.add(false);
                                    });
                                    // Desplazar la lista para mostrar el botón "+"
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      leftScrollController.animateTo(
                                        leftScrollController
                                            .position.maxScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    });
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
                // Pequeña nomenclatura en el centro (si la necesitas)
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text("May",
                          style: TextStyle(color: Colors.red, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("Med",
                          style: TextStyle(color: Colors.blue, fontSize: 12)),
                      SizedBox(height: 4),
                      Text("men",
                          style: TextStyle(color: Colors.yellow, fontSize: 12)),
                    ],
                  ),
                ),
                // Columna derecha (Equipo visitante)
                Expanded(
                  child: Column(
                    children: [
                      // Encabezado: nombre de equipo
                      Padding(
                        padding: const EdgeInsets.only(top: 35.0, bottom: 10.0),
                        child: Center(
                          child: editingRight
                              ? SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: rightTeamController,
                                    autofocus: true,
                                    style: const TextStyle(
                                      fontSize: 14,
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
                                          vertical: 4.0, horizontal: 4.0),
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
                                    style: const TextStyle(
                                      fontSize: 14,
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
                          itemCount: rightNumbers.length + 1,
                          itemBuilder: (context, index) {
                            if (index < rightNumbers.length) {
                              Widget circle = Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: InkWell(
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
                                    radius: 15,
                                    child: Text(
                                      rightNumbers[index],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              if (rightNumbers.length > 11 && index == 11) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      "supl:",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    circle,
                                  ],
                                );
                              }
                              return circle;
                            } else {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon:
                                      const Icon(Icons.add, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      rightNumbers
                                          .add('${rightNumbers.length + 1}');
                                      rightCategories.add(null);
                                      // Los jugadores agregados más allá del once inicial son suplentes
                                      rightIsTitular.add(false);
                                    });
                                    // Desplazar la lista para mostrar el botón "+"
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      rightScrollController.animateTo(
                                        rightScrollController
                                            .position.maxScrollExtent,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    });
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
            // Botón central con una palomita (check) en el centro de la vista.
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 40, // Ajusta el tamaño según lo necesites
                height: 40,
                child: FloatingActionButton(
                  backgroundColor: Colors.green,
                  onPressed: () {
                    // Incrementa el contador para debug.
                    _debugCheckCount++;
                    // Si se presiona 2 o más veces, omite las validaciones.
                    if (_debugCheckCount >= 2) {
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
                      return;
                    }

                    // Validación para el equipo izquierdo
                    List<String> leftErrors = [];
                    if (leftNumbers.toSet().length != leftNumbers.length) {
                      leftErrors.add(
                          "No se pueden repetir números en el equipo $leftTeamName.");
                    }
                    int leftMedCount = 0;
                    int leftMenCount = 0;
                    for (int i = 0; i < leftNumbers.length; i++) {
                      if (leftIsTitular[i]) {
                        if (leftCategories[i] == "Med" ||
                            leftCategories[i] == "men") {
                          leftMedCount++;
                        }
                        if (leftCategories[i] == "men") {
                          leftMenCount++;
                        }
                      }
                    }
                    bool leftValid = (leftMedCount >= 2 && leftMenCount >= 1) ||
                        (leftMenCount >= 3);
                    if (!leftValid) {
                      leftErrors.add(
                          "El equipo $leftTeamName debe tener al menos 2 medianos (o 3 menores) y 1 menor entre los titulares.");
                    }

                    // Validación para el equipo derecho
                    List<String> rightErrors = [];
                    if (rightNumbers.toSet().length != rightNumbers.length) {
                      rightErrors.add(
                          "No se pueden repetir números en el equipo $rightTeamName.");
                    }
                    int rightMedCount = 0;
                    int rightMenCount = 0;
                    for (int i = 0; i < rightNumbers.length; i++) {
                      if (rightIsTitular[i]) {
                        if (rightCategories[i] == "Med" ||
                            rightCategories[i] == "men") {
                          rightMedCount++;
                        }
                        if (rightCategories[i] == "men") {
                          rightMenCount++;
                        }
                      }
                    }
                    bool rightValid =
                        (rightMedCount >= 2 && rightMenCount >= 1) ||
                            (rightMenCount >= 3);
                    if (!rightValid) {
                      rightErrors.add(
                          "El equipo $rightTeamName debe tener al menos 2 medianos (o 3 menores) y 1 menor entre los titulares.");
                    }

                    // Si hay errores, se muestran en un AlertDialog.
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
                      showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                        backgroundColor: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: const Center(
                          child: Text(
                          "Verifica los equipos",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          ),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            // Errores específicos detectados.
                            Text(
                            errorMessage,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.right,
                            ),
                          ],
                          ),
                        ),
                        actions: [
                          Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                            "Aceptar",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                            ),
                          ),
                          ),
                        ],
                        );
                      },
                      );
                      return;
                    }

                    // Si las validaciones se cumplen, se procede a la siguiente pantalla.
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
                  child: const Icon(Icons.check, color: Colors.white, size: 20),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
