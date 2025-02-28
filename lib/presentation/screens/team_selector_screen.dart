import 'package:flutter/material.dart';
import 'package:ventanas_tdp/presentation/widgets/basic_confirmation_dialog.dart';

class TeamSelectorScreen extends StatefulWidget {
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
  State<TeamSelectorScreen> createState() => _TeamSelectorScreenState();
}

class _TeamSelectorScreenState extends State<TeamSelectorScreen> {
  late List<String> _leftNumbers;
  late List<String?> _leftCategories;
  late List<bool> _leftIsTitular;

  late List<String> _rightNumbers;
  late List<String?> _rightCategories;
  late List<bool> _rightIsTitular;

  // Contadores para cambios y ventanas de cada equipo.
  int leftChangeCount = 0;
  int leftWindowCount = 0;
  int rightChangeCount = 0;
  int rightWindowCount = 0;

  // Listas para almacenar los detalles de las sustituciones agrupados por ventana.
  List<List<String>> leftSubstitutionDetails = [];
  List<List<String>> rightSubstitutionDetails = [];

  @override
  void initState() {
    super.initState();
    // Copiamos los valores iniciales a variables internas del estado.
    _leftNumbers = List.from(widget.leftNumbers);
    _leftCategories = List.from(widget.leftCategories);
    _leftIsTitular = List.from(widget.leftIsTitular);

    _rightNumbers = List.from(widget.rightNumbers);
    _rightCategories = List.from(widget.rightCategories);
    _rightIsTitular = List.from(widget.rightIsTitular);
  }

  void _showSubstitutionDialog(String teamName, List<List<String>> changes) {
    final Size screenSize = MediaQuery.of(context).size;
    final double substitutionFontSize = screenSize.width * 0.040;

    Widget titleWidget;
    if (changes.isEmpty) {
      // Si no hay cambios, mostramos un mensaje en el área del título.
      titleWidget = Container(
        height: screenSize.height * 0.360,
        alignment: Alignment.center,
        child: Text(
          "No se han realizado sustituciones",
          style: TextStyle(
            color: Colors.white,
            fontSize: substitutionFontSize + 6,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      // Calcula el ancho efectivo del diálogo (usando dialogWidthFactor = 0.7)
      final double effectiveDialogWidth = screenSize.width * 0.7;
      // Define el espacio (gap) entre columnas.
      final double gap = 12.0;
      // Calcula el ancho de cada columna: restamos el espacio entre columnas y dividimos entre 3,
      // y luego restamos 0.5 para evitar overflow.
      final double columnWidth = ((effectiveDialogWidth - (2 * gap)) / 3) - 0.5;

      // Agrupa las ventanas en tres listas (para cada columna).
      List<List<List<String>>> columnsData = [[], [], []];
      for (int i = 0; i < changes.length; i++) {
        columnsData[i % 3].add(changes[i]);
      }

      Widget substitutionContent = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.4,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primera columna.
              Container(
                width: columnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columnsData[0].asMap().entries.map((entry) {
                    int localIndex = entry.key;
                    int originalIndex = 0 + localIndex * 3;
                    List<String> windowChanges = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ventana ${originalIndex + 1}:",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: substitutionFontSize + 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            windowChanges.join(", "),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: substitutionFontSize,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: gap),
              // Segunda columna.
              Container(
                width: columnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columnsData[1].asMap().entries.map((entry) {
                    int localIndex = entry.key;
                    int originalIndex = 1 + localIndex * 3;
                    List<String> windowChanges = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ventana ${originalIndex + 1}:",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: substitutionFontSize + 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            windowChanges.join(", "),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: substitutionFontSize,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: gap),
              // Tercera columna.
              Container(
                width: columnWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: columnsData[2].asMap().entries.map((entry) {
                    int localIndex = entry.key;
                    int originalIndex = 2 + localIndex * 3;
                    List<String> windowChanges = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Ventana ${originalIndex + 1}:",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: substitutionFontSize + 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            windowChanges.join(", "),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: substitutionFontSize,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );

      // Fija la altura del área de sustituciones para que no se expanda.
      titleWidget = Container(
        height: screenSize.height * 0.360,
        child: substitutionContent,
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return BasicConfirmationDialog(
          title: titleWidget,
          confirmText: "",
          cancelText: "",
          onConfirm: () => Navigator.pop(context),
          onCancel: () => Navigator.pop(context),
          backgroundColor: Colors.grey[850]!,
          confirmButtonColor: const Color.fromARGB(255, 18, 108, 210),
          cancelButtonColor:
              Colors.transparent, // Para no mostrar botón de cancelar
          confirmIcon: const Icon(Icons.check, color: Colors.white),
          cancelIcon: null,
          buttonSpacing: 10.0,
          buttonSize: 28,
          dialogHeightFactor: 0.55,
          dialogWidthFactor: 0.7,
          content: null,
        );
      },
    );
  }

  /// Abre la pantalla de cambios para el equipo local.
  Future<void> _openLocalTeamChanges() async {
    if (leftWindowCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "No quedan ventanas para ${widget.leftTeamName}.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 80, 80),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }
    final result = await Navigator.pushNamed(
      context,
      '/localTeamChanges',
      arguments: {
        'teamName': widget.leftTeamName,
        'numbers': _leftNumbers,
        'categories': _leftCategories,
        'isTitular': _leftIsTitular,
      },
    );
    if (result is Map) {
      // Se espera que la pantalla de cambios retorne un Map con la llave 'substitutionChanges',
      // que es una lista de cadenas con los cambios realizados en esa ventana.
      final List<String>? windowChanges =
          result['substitutionChanges'] as List<String>?;
      if (windowChanges != null && windowChanges.isNotEmpty) {
        setState(() {
          leftWindowCount++;
          leftChangeCount += windowChanges.length;
          // Agregamos los cambios como un grupo (ventana).
          leftSubstitutionDetails.add(windowChanges);
          // Actualizamos las listas del equipo (en caso de que se hayan modificado).
          _leftNumbers = result['numbers'] as List<String>;
          _leftCategories = result['categories'] as List<String?>;
          _leftIsTitular = result['isTitular'] as List<bool>;
        });
      }
    }
  }

  /// Abre la pantalla de cambios para el equipo visitante.
  Future<void> _openVisitorTeamChanges() async {
    if (rightWindowCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "No quedan ventanas para ${widget.rightTeamName}.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 80, 80),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      );
      return;
    }
    final result = await Navigator.pushNamed(
      context,
      '/visitorTeamChanges',
      arguments: {
        'teamName': widget.rightTeamName,
        'numbers': _rightNumbers,
        'categories': _rightCategories,
        'isTitular': _rightIsTitular,
      },
    );
    if (result is Map) {
      final List<String>? windowChanges =
          result['substitutionChanges'] as List<String>?;
      if (windowChanges != null && windowChanges.isNotEmpty) {
        setState(() {
          rightWindowCount++;
          rightChangeCount += windowChanges.length;
          rightSubstitutionDetails.add(windowChanges);
          _rightNumbers = result['numbers'] as List<String>;
          _rightCategories = result['categories'] as List<String?>;
          _rightIsTitular = result['isTitular'] as List<bool>;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(36),
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
                            title: Center(child: Text("Confirmar abandono")),
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
                            buttonSpacing: 10.0,
                            buttonSize: 40,
                            dialogHeightFactor: 0.5,
                            dialogWidthFactor: 0.7,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Columna para el equipo izquierdo (local)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$leftChangeCount cambios \n $leftWindowCount ventanas",
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
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
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
                          onPressed: _openLocalTeamChanges,
                          child: Text(
                            widget.leftTeamName,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _showSubstitutionDialog(
                                widget.leftTeamName, leftSubstitutionDetails);
                          },
                          child: const Text("Historial"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Columna para el equipo derecho (visita)
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$rightChangeCount cambios \n $rightWindowCount ventanas",
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
                            foregroundColor: Colors.white,
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
                          onPressed: _openVisitorTeamChanges,
                          child: Text(
                            widget.rightTeamName,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: size.height * 0.02,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _showSubstitutionDialog(
                                widget.rightTeamName, rightSubstitutionDetails);
                          },
                          child: const Text("Historial"),
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
