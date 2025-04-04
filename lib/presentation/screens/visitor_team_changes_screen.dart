import 'package:flutter/material.dart';
import 'package:ventanas_tdp/presentation/widgets/substitute_selection_dialog.dart';
import 'package:ventanas_tdp/presentation/widgets/basic_confirmation_dialog.dart';

/// Clase para almacenar la información de una sustitución,
/// de modo que podamos revertirla.
class SubstitutionAction {
  final int titularIndex;
  final Map<String, dynamic> oldTitular; // el que salió
  final Map<String, dynamic> newTitular; // el que entró

  SubstitutionAction({
    required this.titularIndex,
    required this.oldTitular,
    required this.newTitular,
  });
}

class VisitorTeamChangesScreen extends StatefulWidget {
  const VisitorTeamChangesScreen({Key? key}) : super(key: key);

  @override
  _VisitorTeamChangesScreenState createState() =>
      _VisitorTeamChangesScreenState();
}

class _VisitorTeamChangesScreenState extends State<VisitorTeamChangesScreen> {
  late List<Map<String, dynamic>> titulares;
  late List<Map<String, dynamic>> suplentes;
  List<String> substitutionChanges = [];

  /// Pila de acciones para poder deshacer la última sustitución.
  final List<SubstitutionAction> _substitutionStack = [];

  bool _isInitialized = false;
  late List<Map<String, dynamic>> _originalTitulares;
  late List<Map<String, dynamic>> _originalSuplentes;

  // Antes estaba "String teamName = 'Visita';"
  // Ahora usamos la variable rightTeamName en su lugar.
  late String rightTeamName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        debugPrint('Argumentos recibidos (Visita): $args');
        // Ajusta esta línea si en tu TeamSelectorScreen pasas la key con otro nombre
        // Por ejemplo: {'teamName': widget.rightTeamName} o {'rightTeamName': widget.rightTeamName}
        if (args.containsKey('teamName')) {
          rightTeamName = args['teamName'] as String;
        } else {
          // Si no trae el argumento, un valor por defecto
          rightTeamName = 'Sin nombre';
        }
      } else {
        // Si no llegan argumentos
        rightTeamName = 'Sin nombre';
      }

      final numbers = List<String>.from(args?['numbers'] ?? []);
      final categories = List<String?>.from(args?['categories'] ?? []);
      final isTitularList = (args?['isTitular'] != null &&
              (args?['isTitular'] as List).isNotEmpty)
          ? List<bool>.from(args?['isTitular'])
          : List<bool>.filled(numbers.length, true);

      titulares = [];
      suplentes = [];
      for (int i = 0; i < numbers.length; i++) {
        final jugador = {
          'number': numbers[i],
          'category': categories.length > i ? categories[i] : null,
        };
        if (i < isTitularList.length && isTitularList[i]) {
          titulares.add(jugador);
        } else {
          suplentes.add(jugador);
        }
      }
      _originalTitulares = List<Map<String, dynamic>>.from(titulares);
      _originalSuplentes = List<Map<String, dynamic>>.from(suplentes);

      _isInitialized = true;
    }
  }

  Color getCircleColor(String? category) {
    if (category == null) return Colors.grey;
    if (category == "men") return const Color.fromARGB(255, 180, 163, 7);
    if (category == "Med") return Colors.blue;
    if (category == "May") return Colors.red;
    return Colors.grey;
  }

  /// Deshace la última sustitución (si existe).
  void _undoLastSubstitution() {
    if (_substitutionStack.isNotEmpty) {
      final lastAction = _substitutionStack.removeLast();
      final revertIndex = lastAction.titularIndex;
      titulares[revertIndex] = lastAction.oldTitular;
      suplentes.add(lastAction.newTitular);
      if (substitutionChanges.isNotEmpty) {
        substitutionChanges.removeLast();
      }
      setState(() {});
    }
  }

  /// Diálogo de error responsivo
  void _showValidationError(String message) {
    final Size screenSize = MediaQuery.of(context).size;
    final double dialogWidth = screenSize.width * 0.8;
    final double dialogHeight = screenSize.height * 0.5;

    showDialog<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: AlertDialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenSize.width * 0.08),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: dialogWidth,
                  maxHeight: dialogHeight,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Regla incumplida",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenSize.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: screenSize.width * 0.04,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    Align(
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: dialogWidth * 0.4,
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blueAccent,
                            textStyle: TextStyle(
                              fontSize: screenSize.width * 0.055,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: const Text("Aceptar"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Valida la regla: al menos 1 men y sum(men, Med) >= 3
  bool _validarTitulares() {
    final int countMen = titulares.where((t) {
      final cat = t['category']?.toString().trim().toLowerCase();
      return cat == 'men';
    }).length;

    final int countMed = titulares.where((t) {
      final cat = t['category']?.toString().trim().toLowerCase();
      return cat == 'med';
    }).length;

    debugPrint("Validación titulares VISITA => men=$countMen, med=$countMed");

    // 1) al menos 1 men
    if (countMen < 1) {
      _showValidationError(
        "Debe haber al menos un jugador Menor (men) en los titulares.",
      );
      return false;
    }
    // 2) men + med >= 3
    final int totalMenYMed = countMen + countMed;
    if (totalMenYMed < 3) {
      _showValidationError(
        "Actualmente tienes men=$countMen, med=$countMed (suma=$totalMenYMed).",
      );
      return false;
    }
    return true;
  }

  /// Muestra el diálogo de confirmación usando BasicConfirmationDialog.
  Future<bool?> _showConfirmDialog({
    required BuildContext context,
    required double dialogFontSize,
    required String title,
    required bool showSubstitutions,
  }) {
    final watchSize = MediaQuery.of(context).size;
    final double iconSize = watchSize.width * 0.09;
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Obtenemos el tamaño de la pantalla para hacerlo responsivo dentro del diálogo.
        final Size watchSize = MediaQuery.of(dialogContext).size;

        // Definimos un tamaño base para íconos u otros elementos si lo deseas.
        final double iconSize = watchSize.width * 0.08; // Ajusta a tu gusto

        return StatefulBuilder(
          builder: (BuildContext context,
              void Function(void Function()) setDialogState) {
            // Calcular el título dinámicamente, según el estado actual de substitutionChanges.
            final String titleText = showSubstitutions
              ? (substitutionChanges.isNotEmpty
                ? substitutionChanges.join("\n")
                : "No se han realizado sustituciones")
              : title;

            return BasicConfirmationDialog(
              // Ajustamos el título con la fuente que quieras
              title: Text(
                titleText,
                style: TextStyle(
                  fontSize: watchSize.width * 0.06, // Escala de fuente
                  color: Colors.white,
                ),
              ),
              confirmText: "",
              cancelText: "",
              onConfirm: () => Navigator.pop(dialogContext, true),
              onCancel: () => Navigator.pop(dialogContext, false),
              backgroundColor: Colors.grey[850]!,
              confirmButtonColor: const Color.fromARGB(255, 18, 108, 210),
              cancelButtonColor: const Color.fromARGB(255, 242, 20, 20),
              // Iconos ajustados con MediaQuery
              confirmIcon:
                  Icon(Icons.check, color: Colors.white, size: iconSize),
              cancelIcon:
                  Icon(Icons.close, color: Colors.white, size: iconSize),
              // Ícono intermedio para "undo"
              middleIcon: Icon(Icons.undo, color: Colors.white, size: iconSize),
              onMiddlePressed: () {
                _undoLastSubstitution();
                // Al actualizar la lista y llamar a setDialogState, se recalculará titleText.
                setDialogState(() {});
              },
              // Sin contenido adicional
              content: const SizedBox.shrink(),
              // Botones con tamaño responsivo
              buttonSize: watchSize.width * 0.17,
              buttonSpacing: watchSize.width * 0.03,
              // Ocupa todo el ancho (puedes bajarlo a 0.9 o 0.8 si prefieres margen)
              dialogWidthFactor: 1,
              // Controla la altura mínima del diálogo
              dialogMinHeight: watchSize.height * 0.45,
            );
          },
        );
      },
    );
  }

  /// Tap en un jugador titular para hacer el cambio, usando SubstituteSelectionDialog.
  void _onTitularTap(int titularIndex) {
    if (suplentes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'No hay suplentes',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SubstituteSelectionDialog(
        availableNumbers:
            suplentes.map((jugador) => jugador['number'] as String).toList(),
        availableCategories:
            suplentes.map((jugador) => jugador['category'] as String?).toList(),
        onConfirm: (selectedIndices) {
          if (selectedIndices.isNotEmpty) {
            final int selectedIndex = selectedIndices.first;
            setState(() {
              final substitute = suplentes[selectedIndex];
              final leaving = titulares[titularIndex];

              _substitutionStack.add(
                SubstitutionAction(
                  titularIndex: titularIndex,
                  oldTitular: leaving,
                  newTitular: substitute,
                ),
              );

              titulares[titularIndex] = substitute;
              suplentes.removeAt(selectedIndex);

              substitutionChanges.add(
                "Entra ${substitute['number']}, Sale ${leaving['number']}",
              );
            });
          }
        },
      ),
    );
  }

  /// Construye la “tarjeta” del jugador (similar a LocalTeamChangesScreen).
  Widget buildPlayerTile(
    Map<String, dynamic> jugador, {
    required bool esTitular,
    required VoidCallback? onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final double cardHeight = size.height * 0.25;
    final double avatarRadius = cardHeight * 0.3;
    final double titleFontSize = cardHeight * 0.25;
    final double subtitleFontSize = cardHeight * 0.20;
    final double horizontalPadding = cardHeight * 0.2;
    final double topPadding = cardHeight * 0.05;
    final double bottomPadding = cardHeight * 0.1;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: cardHeight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding,
              right: horizontalPadding,
              top: topPadding,
              bottom: bottomPadding,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: getCircleColor(jugador['category']),
                  child: Text(
                    jugador['number'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: cardHeight * 0.2,
                    ),
                  ),
                ),
                SizedBox(width: horizontalPadding * 0.5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jugador ${jugador['number']}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: titleFontSize,
                        ),
                      ),
                      SizedBox(height: cardHeight * 0.02),
                      Text(
                        jugador['category'] ?? 'S/C',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: subtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la pantalla con la misma estructura que el LocalTeamChangesScreen.
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double dialogFontSize = size.shortestSide * 0.040;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
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
                      // Igual que en Local: si no hubo cambios, sale; si hubo, confirma.
                      if (substitutionChanges.isEmpty) {
                        final updatedNumbers = [
                          for (var t in _originalTitulares)
                            t['number'] as String,
                          for (var s in _originalSuplentes)
                            s['number'] as String,
                        ];
                        final updatedCategories = [
                          for (var t in _originalTitulares)
                            t['category'] as String?,
                          for (var s in _originalSuplentes)
                            s['category'] as String?,
                        ];
                        final updatedIsTitular = [
                          for (var _ in _originalTitulares) true,
                          for (var _ in _originalSuplentes) false,
                        ];
                        final returnData = {
                          'numbers': updatedNumbers,
                          'categories': updatedCategories,
                          'isTitular': updatedIsTitular,
                          'substitutionChanges': <String>[],
                        };
                        Navigator.pop(context, returnData);
                      } else {
                        final bool? confirm = await _showConfirmDialog(
                          context: context,
                          dialogFontSize: dialogFontSize,
                          title: "Se descartarán los cambios realizados.",
                          showSubstitutions: false,
                        );
                        if (confirm == true) {
                          final updatedNumbers = [
                            for (var t in _originalTitulares)
                              t['number'] as String,
                            for (var s in _originalSuplentes)
                              s['number'] as String,
                          ];
                          final updatedCategories = [
                            for (var t in _originalTitulares)
                              t['category'] as String?,
                            for (var s in _originalSuplentes)
                              s['category'] as String?,
                          ];
                          final updatedIsTitular = [
                            for (var _ in _originalTitulares) true,
                            for (var _ in _originalSuplentes) false,
                          ];
                          final returnData = {
                            'numbers': updatedNumbers,
                            'categories': updatedCategories,
                            'isTitular': updatedIsTitular,
                            'substitutionChanges': <String>[],
                          };
                          Navigator.pop(context, returnData);
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  // Aquí mostramos el nombre del equipo visitante (rightTeamName).
                  Text(
                    rightTeamName,
                    style: TextStyle(
                      fontSize: size.shortestSide * 0.07,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Botón de confirmar.
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      final bool? confirm = await _showConfirmDialog(
                        context: context,
                        dialogFontSize: dialogFontSize,
                        title: "",
                        showSubstitutions: true,
                      );
                      if (confirm == true) {
                        // Validación de titulares
                        if (!_validarTitulares()) {
                          // Si falla la validación, no cierra la pantalla
                          return;
                        }
                        final updatedNumbers = [
                          for (var t in titulares) t['number'] as String,
                          for (var s in suplentes) s['number'] as String,
                        ];
                        final updatedCategories = [
                          for (var t in titulares) t['category'] as String?,
                          for (var s in suplentes) s['category'] as String?,
                        ];
                        final updatedIsTitular = [
                          for (var _ in titulares) true,
                          for (var _ in suplentes) false,
                        ];
                        final returnData = {
                          'numbers': updatedNumbers,
                          'categories': updatedCategories,
                          'isTitular': updatedIsTitular,
                          'substitutionChanges': substitutionChanges,
                        };
                        Navigator.pop(context, returnData);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            "Titulares",
            style: TextStyle(
              color: Colors.white,
              fontSize: size.shortestSide * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...titulares.asMap().entries.map((entry) {
            int index = entry.key;
            final jugador = entry.value;
            return buildPlayerTile(
              jugador,
              esTitular: true,
              onTap: () => _onTitularTap(index),
            );
          }),
          const SizedBox(height: 16),
          if (suplentes.isNotEmpty) ...[
            Text(
              "Suplentes",
              style: TextStyle(
                color: Colors.white,
                fontSize: size.shortestSide * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...suplentes.map(
              (jugador) => buildPlayerTile(
                jugador,
                esTitular: false,
                onTap: null,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
