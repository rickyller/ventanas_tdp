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

  // Listas para almacenar los detalles de las sustituciones agrupadas por ventana.
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
    // Ajusta la fuente del texto dentro de las columnas
    final double substitutionFontSize = screenSize.width * 0.03;
    // Ajusta el alto máximo del contenido
    final double dialogMaxHeight = screenSize.height * 0.36;

    Widget titleWidget;
    if (changes.isEmpty) {
      // Si no hay cambios, mensaje en el área del título
      titleWidget = Container(
        height: dialogMaxHeight,
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
      // Diálogo estilo scroll en columnas
      final double effectiveDialogWidth = screenSize.width * 0.7;
      // Espacio entre columnas
      final double gap = screenSize.width * 0.03;
      // Calcula el ancho de cada columna (dividido en 3)
      final double columnWidth = ((effectiveDialogWidth - (2 * gap)) / 3) - 0.5;

      // Agrupamos las ventanas en 3 columnas
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
              for (int col = 0; col < 3; col++) ...[
                if (col > 0) SizedBox(width: gap),
                Container(
                  width: columnWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: columnsData[col].asMap().entries.map((entry) {
                      int localIndex = entry.key;
                      int originalIndex = col + localIndex * 3;
                      List<String> windowChanges = entry.value;
                      return _buildChangesColumn(
                        windowIndex: originalIndex,
                        windowChanges: windowChanges,
                        fontSize: substitutionFontSize,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

      titleWidget = Container(
        height: dialogMaxHeight,
        child: substitutionContent,
      );
    }

    // Ajustamos el tamaño de los botones del diálogo (check) con MediaQuery
    final double dialogButtonSize = screenSize.width * 0.15;
    final double spacingBetweenButtons = screenSize.width * 0.02;

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
          // Ajusta el espacio entre botones e íconos
          buttonSpacing: spacingBetweenButtons,
          // Ajusta el tamaño de los botones de confirmación/cancelación
          buttonSize: dialogButtonSize,
          dialogHeightFactor: 0.55,
          dialogWidthFactor: 0.7,
          content: null,
        );
      },
    );
  }

  /// Widget helper para armar la columna de cambios en el diálogo
  Widget _buildChangesColumn({
    required int windowIndex,
    required List<String> windowChanges,
    required double fontSize,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ventana ${windowIndex + 1}:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize + 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            windowChanges.join(", "),
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLocalTeamChanges() async {
    if (leftWindowCount >= 3) {
      _showNoWindowsSnackBar(widget.leftTeamName);
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
      final List<String>? windowChanges =
          result['substitutionChanges'] as List<String>?;
      if (windowChanges != null && windowChanges.isNotEmpty) {
        setState(() {
          leftWindowCount++;
          leftChangeCount += windowChanges.length;
          leftSubstitutionDetails.add(windowChanges);
          _leftNumbers = result['numbers'] as List<String>;
          _leftCategories = result['categories'] as List<String?>;
          _leftIsTitular = result['isTitular'] as List<bool>;
        });
      }
    }
  }

  Future<void> _openVisitorTeamChanges() async {
    if (rightWindowCount >= 3) {
      _showNoWindowsSnackBar(widget.rightTeamName);
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

  /// Muestra un snackBar cuando se han agotado las ventanas de un equipo
  void _showNoWindowsSnackBar(String teamName) {
    final size = MediaQuery.of(context).size;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            "No quedan ventanas para $teamName.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: size.width * 0.04,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 80, 80),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.03),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.015,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las dimensiones de la pantalla
    final Size screenSize = MediaQuery.of(context).size;

    // Ajustes de tamaños relativos
    final double titleFontSize = screenSize.width * 0.055;
    final double leftRightPadding = 24.0; // Mantenemos el 24.0 que tú usabas
    final double buttonVerticalPadding = screenSize.height * 0.03;
    final double buttonSmallVerticalPadding = screenSize.height * 0.02;
    final double buttonFontSize = screenSize.width * 0.045;
    final double smallButtonFontSize = screenSize.width * 0.03;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(36), // Mantiene tu altura original
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
                            final double confirmDialogFontSize =
                              screenSize.width * 0.06;
                            return BasicConfirmationDialog(
                            title: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              Text(
                                "Confirmar abandono",
                                style: TextStyle(
                                fontSize: confirmDialogFontSize,
                                color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 20), // Añade más espacio
                              ],
                            ),
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
              padding: EdgeInsets.symmetric(horizontal: leftRightPadding),
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
                            fontSize: titleFontSize,
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
                              vertical: buttonVerticalPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: buttonFontSize,
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
                              vertical: buttonSmallVerticalPadding,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: smallButtonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _showSubstitutionDialog(
                              widget.leftTeamName,
                              leftSubstitutionDetails,
                            );
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
                            fontSize: titleFontSize,
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
                              vertical: buttonVerticalPadding,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: buttonFontSize,
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
                              vertical: buttonSmallVerticalPadding,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: TextStyle(
                              fontSize: smallButtonFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _showSubstitutionDialog(
                              widget.rightTeamName,
                              rightSubstitutionDetails,
                            );
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
